{
  applications.poller = {
    # All resources will be deployed into this namespace.
    namespace = "demo";

    # Automatically generate a namespace resource for the
    # above set namespace
    createNamespace = false;

    resources =
      let
        labels = {
          "app.kubernetes.io/name" = "poller";
        };
      in
      {
        configMaps.poller-config.data."config.json" = builtins.toJSON {
          rss_feeds = [
            "https://feeds.arstechnica.com/arstechnica/index"
            "https://lobste.rs/t/devops.rss"
            "https://hnrss.org/newest?comments=250"
            "https://discordstatus.com/history.rss"
            "https://www.githubstatus.com/history.rss"
            "https://determinate.systems/rss.xml"
          ];
        };

        # Define a deployment for running an poller server
        deployments.poller.spec = {
          selector.matchLabels = labels;
          template = {
            metadata.labels = labels;
            spec = {
              nodeSelector."kubernetes.io/arch" = "amd64";
              securityContext.fsGroup = 1000;
              volumes = [
                {
                  name = "poller-config";
                  configMap.name = "poller-config";
                }
              ];
              containers.poller = {
                image = "ghcr.io/fkouhai/rss_poller-x86_64-linux:1.0.3";
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
                volumeMounts = [
                  {
                    name = "poller-config";
                    mountPath = "/etc/rss-poller";
                    readOnly = true;
                  }
                ];
                env = [
                  {
                    name = "OTEL_EP";
                    value = "otel-collector.monitoring.svc.cluster.local:4317";
                  }
                  {
                    name = "LOCATOR_URL";
                    value = "http://locator.demo.svc.cluster.local:3000";
                  }
                  {
                    name = "SERVICE_FQDN";
                    value = "poller.demo.svc.cluster.local:3000";
                  }
                  {
                    name = "NOTIFICATION_ENDPOINT";
                    value = "https://discord.com/api/webhooks/1433874286921253005/2g9_U5BsPm-YUB0fdx4vaqmhV_mz-VHwOYBabV5ZGjHXggwTC_4jbh1uuTdg7WHyxcXN";
                  }
                ];
              };
            };
          };
        };
        services.poller.spec = {
          selector = labels;
          ports.http.port = 3000;
        };
        ingresses.poller.spec = {
          rules = [
            {
              host = "poller.universe.home";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "poller";
                    port.number = 3000;
                  };
                }
              ];
            }
          ];
        };
      };
  };
}
