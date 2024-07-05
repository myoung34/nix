{ config, lib, pkgs, inputs, ... }:
{
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  environment.systemPackages = with pkgs; [ 
    lightdm-gtk-greeter
    wl-clipboard
    htop
    keybase-gui
  ];

  services.displayManager.defaultSession = "none+i3";

  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
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
