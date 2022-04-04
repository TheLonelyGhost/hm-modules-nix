# Home Manager Modules

A Nix Flake that contains composable modules (and default args) for highly opinionated workstation setup. This is intended for my personal use only, but exists so other git repos in `~/.config/nixpkgs` can reference and include it.

## Usage

Ensure setup is complete, [per the manual](https://nix-community.github.io/home-manager/index.html#ch-nix-flakes), to make `home-manager` work with [Nix Flakes](https://nixos.wiki/wiki/Flakes).

Put contents that look something like this in a file called `~/.config/nixpkgs/flake.nix`, creating parent directories as necessary:

```nix
{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "flake:nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

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
        # This is where all the configuration for all platforms, consistently, happens
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
        # Everything in this section should be replaced with your own settings, following similar
        # structure. Placeholders have been inserted to show what should be present and you should
        # replace it with your own system information.

        # Any number of these that you want, following `username@hostname` pattern for the key
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

When that is put in place, run the following command:

```console
$ cd ~/.config/nixpkgs
$ nix flake build '.#homeConfigurations."'"$(whoami)@$(hostname)"'".activationPackage'
$ ./result/bin/activate && rm ./result
```

Any subsequent commands can run `home-manager switch` instead.
