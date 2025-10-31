{
  applications.notify = {
    # All resources will be deployed into this namespace.
    namespace = "demo";

    # Automatically generate a namespace resource for the
    # above set namespace
    createNamespace = true;

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
              securityContext.fsGroup = 1000;
              containers.notify = {
                image = "ghcr.io/fkouhai/rss_notify-x86_64-linux:0.1.7";
                imagePullPolicy = "IfNotPresent";
                env = [
                  {
                    name = "OTEL_EP";
                    value = "signoz-otel-collector.signoz.cluster.local:4317";
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
