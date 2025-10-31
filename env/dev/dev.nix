{
  nixidy.target.repository = "https://github.com/FKouhai/rss-demo-infra.git";
  nixidy.target.branch = "main";
  nixidy.target.rootPath = "./manifests/dev";
  nixidy.defaults.syncPolicy = {
    autoSync = {
      enable = true;
      selfHeal = true;
      prune = true;
    };
  };
}
