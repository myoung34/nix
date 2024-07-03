{ config, lib, pkgs, inputs, ... }:
{
  imports = [
    ./workspace-hardware-configuration.nix
  ];


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

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };


  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.displayManager.defaultSession = "none+i3";
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      options = "ctrl:swapcaps";
    };
    desktopManager = {
      xterm.enable = false;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
        git
        go
        llvm_12 # following for trying libbpfgo
        gnumake
        clang
        libbpf
        libelf
      ];
    };
  };
}
