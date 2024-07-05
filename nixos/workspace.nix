{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ./workspace-hardware-configuration.nix
  ];

  services.tailscale.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.xserver = {
    enable = true;
    xkb = {
      options = "ctrl:swapcaps";
    };
  };

  networking = {
    #networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    nameservers = ["1.1.1.1" "8.8.8.8"];
    hostName = "workspace";
    wireless = {
      enable = true;  # Enables wireless support via wpa_supplicant.
      userControlled.enable = true;
      environmentFile = config.age.secrets.wifi.path;
      networks = {
        "@WIFI_SSID@" = {
          auth = ''
            psk="@WIFI_PSK@"
          '';
        };
      };
    };
  };
}
