{
  description = "ArgoCD config for rss-demo";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixidy.url = "github:arnarg/nixidy";

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nixidy,
    }:
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        # This declares the available nixidy envs.
        nixidyEnvs = nixidy.lib.mkEnvs {
          inherit pkgs;

          envs = {
            dev.modules = [
              ./env/dev/dev.nix
              ./env/dev/poller.nix
              ./env/dev/frontend.nix
              ./env/dev/notify.nix
            ];
          };
        };

        packages.nixidy = nixidy.packages.${system}.default;

        # Run `nix develop` to enter.
        devShells.default = pkgs.mkShell {
          buildInputs = [ nixidy.packages.${system}.default ];
        };
      }
    ));
}
