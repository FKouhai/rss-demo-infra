{
  applications.frontend = {
    # All resources will be deployed into this namespace.
    namespace = "demo";

    # Automatically generate a namespace resource for the
    # above set namespace
    createNamespace = true;

    resources =
      let
        labels = {
          "app.kubernetes.io/name" = "frontend";
        };
      in
      {
        # Define a deployment for running an frontend server
        deployments.frontend.spec = {
          selector.matchLabels = labels;
          template = {
            metadata.labels = labels;
            spec = {
              securityContext.fsGroup = 1000;
              containers.frontend = {
                image = "ghcr.io/fkouhai/rss_frontend-x86_64-linux:0.5.0";
                imagePullPolicy = "IfNotPresent";
                livenessProbe = {
                  httpGet = {
                    path = "/api/healthz";
                    port = 4321;
                  };
                  initialDelaySeconds = 5;
                  periodSeconds = 10;
                };
                readinessProbe = {
                  httpGet = {
                    path = "/api/healthz";
                    port = 4321;
                  };
                  initialDelaySeconds = 5;
                  periodSeconds = 10;
                };
                env = [
                  {
                    name = "LOCATOR_URL";
                    value = "http://locator.demo.svc.cluster.local:3000";
                  }
                ];
              };
            };
          };
        };
        services.frontend.spec = {
          selector = labels;
          ports.http.port = 4321;
        };
        ingresses.frontend.spec = {
          rules = [
            {
              host = "rss.universe.home";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "frontend";
                    port.number = 4321;
                  };
                }
              ];
            }
          ];
        };
      };
  };
}
