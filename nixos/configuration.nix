# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    #./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;

      trusted-users = [ "root" "@users" ];
    };

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  time.timeZone = "US/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  services.keybase.enable = true;
  services.kbfs.enable = true;
  services.pcscd.enable = true;
  services.openssh.enable = true; # even on WSL so that I can generate host keys

  users.defaultUserShell=pkgs.zsh;
  users.users.myoung = {
    shell = pkgs.zsh;
    isNormalUser = true;
    extraGroups = [ "docker" "users" "wheel" ];
    packages = with pkgs; [
      tldr
      chezmoi
      mise
    ];
  };

  security.sudo.extraRules= [
    {  users = [ "myoung" ];
      commands = [
         { command = "ALL" ;
           options= [ "NOPASSWD" ]; # "SETENV" # Adding the following could be a good idea
        }
      ];
    }
  ];


  programs = {
    tmux = {
      enable = false;
    };
    zsh = {
      enable = true;
      interactiveShellInit= ''
      ZSH_THEME="robbyrussell"

      plugins=(
        git
        tmux
      )

      if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        ZSH_TMUX_AUTOSTART=false
      else
        ZSH_TMUX_AUTOSTART=true
      fi
      '';
      ohMyZsh = {
        enable = true;
      };
    };
  };

  environment.systemPackages = [
    pkgs.vim
    pkgs.ripgrep
    pkgs.wget
    pkgs.docker
    pkgs.age-plugin-yubikey
    pkgs.gnupg
    pkgs.pinentry
    pkgs.pinentry-curses
    pkgs.git
    pkgs.tmux
    pkgs.tree
    pkgs.bind
    pkgs.zsh
    pkgs.screen
    pkgs.age
    pkgs.gnumake
    
    pkgs.python3
    pkgs.nodejs
    pkgs.unzip

    pkgs.neovim
    pkgs.gcc

    # For dev stuff
    pkgs.devenv
    pkgs.tenv

    pkgs.jq
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
    enableSSHSupport = true;
  };

  networking.firewall.enable = false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.05";
}
