{ config, pkgs, ... }:

{
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
  virtualisation.libvirtd.enable = true;

  environment.systemPackages = with pkgs; [ virt-manager ];
}
