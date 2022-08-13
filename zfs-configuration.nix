{ config, pkgs, ... }:

{
  #
  # ZFS
  #
  # - https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html
  # - https://github.com/indocomsoft/dotfiles/blob/df0a4473f56fcca74f48f920fd2fe1bc8968dd34/nixos/configuration.nix#L66
  boot.supportedFilesystems = [ "zfs" ];
  boot.initrd.kernelModules = [ "zfs" ];
  boot.postBootCommands = ''
    # To debug check: journalctrl -b | grep stage-2-init
    echo Importing all zfs zpool pools
    ${pkgs.zfs}/bin/zpool import -a -N
    echo Mounting all zfs filesystems
    ${pkgs.zfs}/bin/zfs mount -a
  '';
  services.zfs= {
    autoScrub = {
      enable = true;
    };
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
      frequent = 0;
      hourly = 0;
      daily = 7;
      weekly = 4;
      monthly = 12;
    };
  };
  systemd.services.zfs-export-on-shutdown = {
    enable = true;
    description = "Export zfs pools on shutdown";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.zfs}/bin/zpool export -a";
    };
    wantedBy = [ "multi-user.target" ];
  };
}