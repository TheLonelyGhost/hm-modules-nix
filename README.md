# Home Manager Modules

A Nix Flake that contains composable modules (and default args) for highly opinionated workstation setup. This is intended for my personal use only, but exists so other git repos in `~/.config/nixpkgs` can reference and include it.

## Usage

```nix
{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    hm-modules-nix.url = "github:thelonelyghost/hm-modules-nix";
    hm-modules-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, flake-compat, flake-utils, hm-modules-nix }:
    let
      stateVersion = "21.11";
      baseConfig = { pkgs, fullName, commitEmail, hostname, username, homeDirectory, windowsUsername ? "" }: let
        system = pkgs.system;
        hm-modules = hm-modules-nix.packages."${system}";
      in {
        configuration = { pkgs, homeDirectory, ... }: {
          programs.home-manager.enable = true;

          imports = [
            hm-modules.base-cli
            hm-modules.direnv
            hm-modules.git
            hm-modules.golang
            hm-modules.gpg
            hm-modules.keepassxc
            hm-modules.neovim
            hm-modules.ripgrep
            hm-modules.ssh
            hm-modules.starship
            hm-modules.tmux
            hm-modules.zsh
          ];
        };

        inherit pkgs;

        extraSpecialArgs = hm-modules.extraSpecialArgs {
          inherit system hostname username homeDirectory fullName commitEmail windowsUsername;
        };

        inherit stateVersion system username homeDirectory;
      };
    in
    {
      homeConfigurations = {
        "jdoe@localhost" = home-manager.lib.homeManagerConfiguration (
          let
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };

            fullName = "John Doe";
            commitEmail = "jdoe@example.com";

            system = "x86_64-linux";
            hostname = "localhost";
            username = "jdoe";
            homeDirectory = "/home/${username}";
          in
          baseConfig {
            inherit pkgs fullName commitEmail hostname username homeDirectory;
          }
        );

        "jdoe@home-base.local" = home-manager.lib.homeManagerConfiguration (
          let
            pkgs = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };

            fullName = "John Doe";
            commitEmail = "jdoe@example.com";

            system = "x86_64-linux";
            hostname = "home-base.local";
            username = "jdoe";
            homeDirectory = "/home/${username}";

            # is WSL:
            windowsUsername = "john";
          in
          baseConfig {
            inherit pkgs fullName commitEmail hostname username homeDirectory windowsUsername;
          }
        );
      };
    };
}
```
