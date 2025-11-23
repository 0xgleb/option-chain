{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";

    git-hooks.url = "github:cachix/git-hooks.nix";
    git-hooks.inputs.nixpkgs.follows = "nixpkgs";

    devenv.url = "github:cachix/devenv/v1.7";
    devenv.inputs = {
      nixpkgs.follows = "nixpkgs";
      git-hooks.follows = "git-hooks";
    };

    foundry.url = "github:shazow/foundry.nix/stable";
  };

  outputs =
    { nixpkgs, flake-utils, devenv, git-hooks, foundry, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ foundry.overlay ];
        };

        env = { };
        src = ./.;
        hooks = {
          nil.enable = true;
          nixfmt-classic.enable = true;
          deadnix.enable = true;
          statix.enable = true;
          denofmt.enable = true;
          shellcheck.enable = true;
        };

      in {
        devShells = {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [{
              # https://devenv.sh/reference/options/
              packages = with pkgs; [ ];

              languages = {
                nix.enable = true;
                solidity.enable = true;
                solidity.foundry.enable = true;
              };

              inherit env;
              git-hooks = { inherit hooks; };
              difftastic.enable = true;
              cachix.enable = true;

              # Disable process-compose as we don't need it
              process.managers.process-compose.enable = false;
            }];
          };
        };

        packages = { };

        checks.git-hooks = git-hooks.lib.${system}.run { inherit hooks src; };
      });

  nixConfig = {
    extra-substituters = "https://devenv.cachix.org";
    extra-trusted-public-keys =
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    allow-unfree = true;
  };
}
