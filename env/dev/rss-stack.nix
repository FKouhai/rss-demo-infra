{ config, lib, ... }:
let
  # Single version pin: GHCR image tags AND the OCI chart release.
  # Bump on every promotion (matches the app repo release tag).
  version = config.demo.version;
  arch = "x86_64-linux";
  tagged = svc: {
    # Base GHCR repo (underscores); the chart appends archSuffix
    # ("-x86_64-linux") to match the published tags.
    repository = "${lib.replaceStrings [ "-" ] [ "_" ] svc}";
    tag = version;
  };
in
{
  applications.rss-stack = {
    # All resources will be deployed into this namespace.
    namespace = "demo";

    # Automatically generate a namespace resource for the
    # above set namespace
    createNamespace = true;

    helm.releases.rss-stack = {
      chart = lib.helm.downloadHelmChart {
        repo = "oci://ghcr.io/fkouhai/charts";
        chart = "rss-stack";
        version = version;
        # First eval with lib.fakeHash, then paste the real hash
        # from the error. Re-pin on every version bump.
        chartHash = "sha256-IHmJH3XEGXcJyK2o3dn7rQRll386wVz+X8yNqpNszak=";
      };

      values = {
        otel.endpoint = "otel-collector-opentelemetry-collector.monitoring.svc.cluster.local:4317";

        global = {
          nodeSelector."kubernetes.io/arch" = "amd64";
        };

        nats = {
          enabled = true;
          podAnnotations."backup.velero.io/backup-volumes" = "data";
        };

        secrets = {
          # ESO-managed Secret (openbao backend) with keys:
          #   webhook-url    -> DEFAULT_WEBHOOK_URL (poller fallback)
          #   gateway-secret -> CONFIG_GATEWAY_SECRET (config + frontend)
          webhookSecret = "rss-secrets";
          gatewaySecret = "rss-secrets";
        };

        ingress = {
          enabled = true;
          host = "rss.fkouhailabs.net";
          tls = {
            enabled = true;
            secretName = "rss-http-tls";
          };
          annotations."cert-manager.io/cluster-issuer" = "fkouhailabs";
        };

        services = {
          poller = (tagged "rss-poller") // {
          };
          outbox = (tagged "rss-outbox") // {
            db = {
              driver = "postgres";
              postgres.dsnSecret = "rss-outbox-db";
              sqlite.storage = "1Gi";
            };
            podAnnotations."backup.velero.io/backup-volumes" = "data";
          };
          notify = (tagged "rss-notify") // {
          };
          aggregator = (tagged "rss-aggregator") // {
            db = {
              driver = "postgres";
              postgres.dsnSecret = "rss-aggregator-db";
              sqlite.storage = "1Gi";
            };
            podAnnotations."backup.velero.io/backup-volumes" = "data";
          };
          config = (tagged "rss-config") // {
            db = {
              driver = "postgres";
              postgres.dsnSecret = "rss-config-db";
              sqlite.storage = "1Gi";
            };
            podAnnotations."backup.velero.io/backup-volumes" = "data";
            # Must match the IdP group; the frontend pre-checks it too.
            adminGroups = "admins";
          };
          frontend = (tagged "rss-frontend") // {
            # Must match config's adminGroups and the IdP group.
            adminGroups = "admins";            oidc = {
              issuer = "https://id.fkouhailabs.net";
              clientID = "d01f93ef-572c-4319-925a-e42561b457c5";
              clientSecret.secretName = "rss-oidc";
              sessionKey.secretName = "rss-oidc";
            };
          };
        };
      };
    };
  };
}
