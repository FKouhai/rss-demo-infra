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
              securityContext.fsGroup = 1000;
              containers.notify = {
                image = "ghcr.io/fkouhai/rss_notify-x86_64-linux:0.2.0";
                imagePullPolicy = "IfNotPresent";
                livenessProbe = {
                  httpGet = {
                    path = "/healthz";
                    port = 3000;
                  };
                  initialDelaySeconds = 3;
                  periodSeconds = 5;
                };
                env = [
                  {
                    name = "OTEL_EP";
                    value = "signoz-otel-collector.signoz.svc.cluster.local:4317";
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
