{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    #nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # You can access packages and modules from different nixpkgs revs
    # at the same time. Here's an working example:
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    agenix.url = "github:ryantm/agenix";

    browser-previews = { 
      url = github:nix-community/browser-previews; 
      inputs.nixpkgs.follows = "nixpkgs"; 
    };
  };

  outputs = {
    self,
    nixpkgs,
    agenix,
    browser-previews,
    nixos-wsl,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      "aarch64-linux"
      "i686-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules/nixos;

    # Available through 'nixos-rebuild --flake .#workspace'
    nixosConfigurations = {
      desktop-wsl = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          agenix.nixosModules.default
          nixos-wsl.nixosModules.default
          {
            environment.systemPackages = [ 
              agenix.packages.x86_64-linux.default 
            ];
            system.stateVersion = "24.05";
            wsl.enable = true;
            age.secrets = {
            };
            age.identityPaths = [ "/home/myoung/.ssh/github" ];
          }
          ./nixos/desktop-wsl.nix
          ./nixos/configuration.nix
        ];
      };
      workspace = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        modules = [
          ./nixos/configuration.nix
          ./nixos/workspace.nix
          agenix.nixosModules.default
          {
            environment.systemPackages = [ 
              agenix.packages.x86_64-linux.default 
              nixpkgs.legacyPackages.x86_64-linux.lightdm-gtk-greeter
              nixpkgs.legacyPackages.x86_64-linux.wl-clipboard
              nixpkgs.legacyPackages.x86_64-linux.htop
              nixpkgs.legacyPackages.x86_64-linux.keybase-gui
              inputs.browser-previews.packages.x86_64-linux.google-chrome
            ];
            age.secrets = {
              wifi = {
                file = ./secrets/workspace_wifi.age;
              };
            };
            age.identityPaths = [ "/etc/ssh/ssh_host_rsa_key" ];
          }
        ];
      };
    };
  };
}