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
                image = "ghcr.io/fkouhai/rss-notify-x86_64-linux:0.0.4";
                imagePullPolicy = "IfNotPresent";
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
