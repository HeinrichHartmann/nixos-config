{ config, pkgs, ... }:

let
  # https://github.com/TrilliumIT/docker-zfs-plugin
  docker-zfs-plugin = pkgs.buildGoModule rec {
    name = "docker-zfs-plugin";
    pname = "docker-zfs-plugin";
    vendorSha256 = "CWXX6VEh8k09OhBm6FYSvLA3qTReAao/22a9VW6NQdQ=";
    src = pkgs.fetchFromGitHub {
      owner = "TrilliumIT";
      repo = "docker-zfs-plugin";
      rev = "0fb28118b1860c0534419a580d1500cff1d3c015";
      sha256 = "W1m4cjmnu7zhA7AKTTrDQWUd4saQNQjEsuBUgBjyVYg=";
    };
  };
in
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
      # defaults to weekly scrubbing 2am Sundays
      enable = true; 
    };
    autoSnapshot = {
      # https://www.mankier.com/5/configuration.nix#Options-services.zfs.autoSnapshot.enable
      enable = true;
      flags = "-k -p --utc";
      frequent = 0; # Number of frequent (15-minute) auto-snapshots that you wish to keep.
      hourly = 0;   # Number of hourly snapshots to keep
      daily = 7;
      weekly = 4;
      monthly = 5 * 12;
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
  #
  # Docker ZFS Plugin
  #
  # https://github.com/TrilliumIT/docker-zfs-plugin
  #
  environment.systemPackages = [ docker-zfs-plugin ];
  
  # [Unit]
  # Description=zfs plugin
  # After=zfs-mount.service zfs-import-cache.service
  # Before=docker.service
  # Requires=zfs-mount.service zfs-import-cache.service
  #
  # #Recommended condition for each pool you intend to use
  # ConditionPathIsMountPoint=/var/lib/docker-volumes/zfs/tank
  #
  # [Service]
  # ExecStart=/usr/local/bin/docker-zfs-plugin --dataset-name tank/docker-volumes
  #
  # [Install]
  # WantedBy=docker.service
  {
    systemd.services.docker-zfs-plugin = {
      enable = true;
      description = "Add support for zfs-backed volumes";
      requires = ["zfs-mount.service" "zfs-import-cache.service"];
      after = ["zfs-mount.service" "zfs-import-cache.service"];
      before = [ "docker.service" ];
      
      unitConfig = {
         ConditionPathIsMountPoint = "/share/hhartmann/var/docker"
      Type = "simple";
      # ...
    };
    serviceConfig = {
      ExecStart = "${foo}/bin/foo";
      # ...
    };
    wantedBy = [ "multi-user.target" ];
    # ...
  };
}

}
