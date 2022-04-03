{ pkgs, isWSL, windowsUsername, workstation-deps, ... }:
# vim: ts=2 sts=2 sw=2 et

{
  home.packages = [
    workstation-deps.keepassxc-get
  ] ++ (pkgs.lib.optional (!isWSL) [
    pkgs.keepassxc
  ]);
  home.file.".zsh/config/keepassxc-relay.zsh".text = pkgs.lib.optionalString isWSL ''
  eval "$(${workstation-deps.wsl-keepassxc-relay}/bin/keepassxc-relay '${windowsUsername}')"
  '';

}
