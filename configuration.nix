# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  system.stateVersion = "22.05";
  
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./network-configuration.nix
      ./zfs-configuration.nix
    ];

  # Bootloader Config
  boot.loader.systemd-boot.enable = true;

  # Copy configuration on switch
  system.copySystemConfiguration = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hhartmann = {
     isNormalUser = true;
     extraGroups = [ "wheel" "docker" "qemu-libvirtd" "libvirtd" ]; # wheel = ‘sudo’
     packages = with pkgs; [ ];
     openssh.authorizedKeys.keyFiles = [ /etc/nixos/ssh/authorized_keys ];
  };

  # Passwordless sudo
  security.sudo.wheelNeedsPassword = false;
  
  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
     zsh
     emacs
     curl
     wget
     tmux
     git
     git-lfs
     zsh
     ripgrep
     docker-compose
     bridge-utils
     gnumake
     htop
     vagrant
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.zsh.enable = true;
  services.openssh.enable = true;
  networking.firewall.enable = false;
  virtualisation.docker.enable = true;

  # https://discourse.nixos.org/t/set-up-vagrant-with-libvirt-qemu-kvm-on-nixos/14653
  virtualisation.libvirtd.enable = true;
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

}
