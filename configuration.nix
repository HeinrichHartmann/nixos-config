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
     extraGroups = [ "wheel" "docker" ]; # whell = ‘sudo’ 
     packages = with pkgs; [ ];
     openssh.authorizedKeys.keyFiles = [ /etc/nixos/ssh/authorized_keys ];
  };

  # Passwordless sudo
  security.sudo.wheelNeedsPassword = false;
  

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
     emacs
     curl
     wget
     tmux
     git
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh.enable = true;
  networking.firewall.enable = false;

  virtualisation.docker.enable = true;


  services.dhcpd4 = {
    enable = true;
    interfaces = [ "eno1" ];
    extraConfig = ''
      option domain-name-servers 1.1.1.1;
      option subnet-mask 255.255.255.0;

      subnet 192.168.2.0 netmask 255.255.255.0 {
        option routers 192.168.2.12;
        interface eno1;
        range 192.168.2.150 192.168.2.254;
      }
    '';
  };


}

