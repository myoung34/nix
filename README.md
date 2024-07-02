## NixOS

My NixOS configuration(s)

Its dirty, but I'm learning.

### Notes

### WSL2

1: download the latest `nixos-wsl.tar.gz` from [here](https://github.com/nix-community/NixOS-WSL/releases)
2: import `wsl --import NixOS $env:USERPROFILE\NixOS\ .\nixos-wsl.tar.gz`
3: get in: `wsl -d NixOS`
4: Update everything to make a working `nixos-rebuild` starting place:
```
cat <<EOF | sudo tee /etc/nixos/configuration.nix
{ config, lib, pkgs, ... }:

{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
  ];

  wsl.enable = true;
  wsl.defaultUser = "myoung"; # Replace with your desired user
  wsl.wslConf.network.hostname = "desktop-wsl"; # Replace with your hostname
  environment.systemPackages = with pkgs; [
    vim # my basic editor
    git # needed for pulling the repo, etc
  ];
  system.stateVersion = "24.05";
}
EOF


sudo nix-channel --add  https://nixos.org/channels/nixos-24.05 nixos
sudo nix-channel --update
sudo nixos-rebuild boot
exit
```
5: Reboot and make sure youre the default user from wsl.defaultUser. Note: you may need to do this twice for whatever reason (but only this one time to set up for flakes)
```
wsl -t NixOS
wsl --shutdown NixOS
wsl -d NixOS
$ whoami; hostname # should return what you configured in `/etc/nixos/configuration.nix`
```
6: Clone this repo down and you're good to go!
```
cd ~
mkdir -p repos/github
git clone https://github.com/myoung34/nix
cd ~/repos/github/nix
sudo nixos-rebuild switch --flake .#desktop-wsl
chezmoi init https://github.com/myoung34/dotfiles
chezmoi apply
```
