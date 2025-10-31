{
  applications.poller = {
    # All resources will be deployed into this namespace.
    namespace = "demo";

    # Automatically generate a namespace resource for the
    # above set namespace
    createNamespace = true;

    resources =
      let
        labels = {
          "app.kubernetes.io/name" = "poller";
        };
      in
      {
        # Define a deployment for running an poller server
        deployments.poller.spec = {
          selector.matchLabels = labels;
          template = {
            metadata.labels = labels;
            spec = {
              securityContext.fsGroup = 1000;
              containers.poller = {
                image = "ghcr.io/fkouhai/rss_poller-x86_64-linux:0.1.7";
                imagePullPolicy = "IfNotPresent";
                env = [
                  {
                    name = "NOTIFICATION_SENDER";
                    value = "http://notify.demo.svc.cluster.local:3000/push";
                  }
                  {
                    name = "OTEL_EP";
                    value = "signoz-otel-collector.signoz.svc.cluster.local:4317";
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
