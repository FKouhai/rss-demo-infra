{
  applications.notify = {
    # All resources will be deployed into this namespace.
    namespace = "demo";

    # Automatically generate a namespace resource for the
    # above set namespace
    createNamespace = false;

    resources =
      let
        labels = {
          "app.kubernetes.io/name" = "notify";
        };
      in
      {
        # Define a deployment for running an notify server
        deployments.notify.spec = {
          selector.matchLabels = labels;
          template = {
            metadata.labels = labels;
            spec = {
              nodeSelector."kubernetes.io/arch" = "amd64";
              securityContext.fsGroup = 1000;
              containers.notify = {
                image = "ghcr.io/fkouhai/rss_notify-x86_64-linux:1.0.1";
                imagePullPolicy = "IfNotPresent";
                livenessProbe = {
                  httpGet = {
                    path = "/healthz";
                    port = 3000;
                  };
                  initialDelaySeconds = 3;
                  periodSeconds = 5;
                };
                readinessProbe = {
                  httpGet = {
                    path = "/ready";
                    port = 3000;
                  };
                  initialDelaySeconds = 5;
                  periodSeconds = 10;
                };
                env = [
                  {
                    name = "OTEL_EP";
                    value = "signoz-otel-collector.signoz.svc.cluster.local:4317";
                  }
                  {
                    name = "LOCATOR_URL";
                    value = "http://locator.demo.svc.cluster.local:3000";
                  }
                  {
                    name = "SERVICE_FQDN";
                    value = "notify.demo.svc.cluster.local:3000";
                  }
                ];
              };
            };
          };
        };
        services.notify.spec = {
          selector = labels;
          ports.http.port = 3000;
        };
      };
  };
}
