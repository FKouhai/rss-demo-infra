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
                image = "ghcr.io/fkouhai/rss_frontend-x86_64-linux:0.1.1";
                imagePullPolicy = "IfNotPresent";
                env = [
                  {
                    name = "POLLER_ENDPOINT";
                    value = "http://poller.demo.svc.cluster.local:3000/rss";
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
              host = "frontend.143.47.60.246.nip.io";
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
