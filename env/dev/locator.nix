{
  applications.locator = {
    # All resources will be deployed into this namespace.
    namespace = "demo";

    # Automatically generate a namespace resource for the
    # above set namespace
    createNamespace = false;

    resources =
      let
        labels = {
          "app.kubernetes.io/name" = "locator";
        };
      in
      {
        # Define a deployment for running an locator server
        deployments.locator.spec = {
          selector.matchLabels = labels;
          template = {
            metadata.labels = labels;
            spec = {
              nodeSelector."kubernetes.io/arch" = "amd64";
              securityContext.fsGroup = 1000;
              containers.locator = {
                image = "ghcr.io/fkouhai/rss_locator-x86_64-linux:1.0.1";
                imagePullPolicy = "IfNotPresent";
                livenessProbe = {
                  httpGet = {
                    path = "/health";
                    port = 3000;
                  };
                  initialDelaySeconds = 3;
                  periodSeconds = 5;
                };
                readinessProbe = {
                  httpGet = {
                    path = "/health";
                    port = 3000;
                  };
                  initialDelaySeconds = 3;
                  periodSeconds = 10;
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
        services.locator.spec = {
          selector = labels;
          ports.http.port = 3000;
        };
      };
  };
}
