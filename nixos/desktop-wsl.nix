{ config, lib, nixpkgs, pkgs, inputs, ... }:
{
  imports = [
    ./desktop-wsl-hardware-configuration.nix
  ];

  wsl = {
    enable = true;
    #wslConf.automount.root = "/mnt";
    #wslConf.interop.appendWindowsPath = false;
    #wslConf.network.generateHosts = false;
    defaultUser = "myoung";
    #startMenuLaunchers = true;
    wslConf.boot.systemd = true;
    wslConf.network.hostname = "desktop-wsl";

    # Enable integration with Docker Desktop (needs to be installed)
    docker-desktop.enable = false;

    extraBin = with pkgs; [
      # Binaries for Docker Desktop wsl-distro-proxy
      { src = "${coreutils}/bin/mkdir"; }
      { src = "${coreutils}/bin/cat"; }
      { src = "${coreutils}/bin/whoami"; }
      { src = "${coreutils}/bin/ls"; }
      { src = "${busybox}/bin/addgroup"; }
      { src = "${su}/bin/groupadd"; }
      { src = "${su}/bin/usermod"; }
    ];
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  ## patch the script 
  systemd.services.docker-desktop-proxy.script = lib.mkForce ''${config.wsl.wslConf.automount.root}/wsl/docker-desktop/docker-desktop-user-distro proxy --docker-desktop-root ${config.wsl.wslConf.automount.root}/wsl/docker-desktop "C:\Program Files\Docker\Docker\resources"'';

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  system.stateVersion = "24.05";
}
