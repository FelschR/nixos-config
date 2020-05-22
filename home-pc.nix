{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    <home-manager/nixos>
    ./hardware/base.nix
    ./hardware/gpu-nvidia.nix
    ./hardware/ledger.nix
    ./system
    ./desktop
    # ./plex.nix
  ];

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "p7zip-16.02" # currently used by lutris
  ];

  networking.hostName = "felix-nixos";

  hardware.enableAllFirmware = true;
  hardware.cpu.amd.updateMicrocode = true;
  services.fwupd.enable = true;

  programs.adb.enable = true;

  programs.zsh.enable = true;

  users.users.felschr = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.felschr = import ./home/felschr.nix;
  };

  # only change this when specified in release notes
  system.stateVersion = "19.09";

  system.autoUpgrade.enable = true;
}
