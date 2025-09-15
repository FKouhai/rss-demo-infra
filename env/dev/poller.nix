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
                image = "ghcr.io/fkouhai/rss_poller-x86_64-linux:0.0.4";
                imagePullPolicy = "IfNotPresent";
                env = [
                  {
                    name = "NOTIFICATION_ENDPOINT";
                    value = "rss-notify.demo.cluster.svc.local:3000";
                  }
                  {
                    name = "OTEL_EP";
                    value = "";
                  }
                  {
                    name = "NOTIFICATION_SENDER";
                    value = "https://discord.com/api/webhooks/1400936674522828892/rEYQaa9DRY9pKse9YPT4XjWQmDOd6gARpp6OdYU27icRoucGCkGs3zhdlxhNuOucSiSZ";
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
      };
  };
}
