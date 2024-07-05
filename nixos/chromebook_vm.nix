# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./chromebook_vm-hardware-configuration.nix
    ];

  environment.systemPackages = with pkgs; [
    #jetbrains.goland
  ];
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "chromebook_vm"; # Define your hostname.
  services.xserver.xkb.layout = "us";
  services.openssh.enable = true;

  system.stateVersion = "24.05"; # Did you read the comment?

}

