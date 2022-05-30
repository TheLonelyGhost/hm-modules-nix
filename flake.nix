{
  description = "A home-manager flake with modules that can be called via `imports = []` in home-manager's config block";

  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "flake:nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;

    neovim-nix.url = "github:thelonelyghost/neovim-nix";
    workstation-deps-nix.url = "github:thelonelyghost/workstation-deps-nix";
    golang-webdev-nix.url = "github:thelonelyghost/golang-webdev-nix";

    zsh-plugin-syntax-highlight.url = "github:zdharma-continuum/fast-syntax-highlighting";
    zsh-plugin-syntax-highlight.flake = false;
  };

  outputs = { self, nixpkgs, home-manager, flake-compat, flake-utils, neovim-nix, workstation-deps-nix, golang-webdev-nix, zsh-plugin-syntax-highlight }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        neovim = neovim-nix.packages."${system}";
        workstation-deps = workstation-deps-nix.packages."${system}";
        golang-webdev = golang-webdev-nix.outputs.packages."${system}";
        inherit zsh-plugin-syntax-highlight;
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.bashInteractive
            pkgs.gnumake
          ];
        };
        packages = {
          extraSpecialArgs = import ./modules/baseExtraArgs.nix {
            inherit pkgs neovim workstation-deps golang-webdev zsh-plugin-syntax-highlight;
          };

          base-cli = import ./modules/base-cli.nix;
          direnv = import ./modules/direnv.nix;
          neovim = import ./modules/neovim.nix;
          git = import ./modules/git.nix;
          golang = import ./modules/golang.nix;
          gpg = import ./modules/gpg.nix;
          ripgrep = import ./modules/ripgrep.nix;
          ssh = import ./modules/ssh.nix;
          keepassxc = import ./modules/keepassxc.nix;
          starship = import ./modules/starship.nix;
          taskwarrior = import ./modules/taskwarrior.nix;
          tmux = import ./modules/tmux.nix;
          zsh = import ./modules/zsh.nix;
        };
      }
    );
}
