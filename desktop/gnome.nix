{ config, pkgs, ... }:

with pkgs;
let
  gnome-shell-extension-pop-shell = stdenv.mkDerivation rec {
    pname = "gnome-shell-extension-pop-shell";
    version = "2020-03-13";

    src = fetchFromGitHub {
      owner = "pop-os";
      repo = "shell";
      rev = "ad4f28cbf185b35d8cb3e8710dabee80737156ce";
      sha256 = "0a312ilbip6gd4ppff8kjr77ilcbwn3wksf2x8ppj0nhfmrich6n";
    };

    nativeBuildInputs = [ glib ];
    buildInputs = [ nodePackages.typescript ];

    # the gschema doesn't seem to be installed properly (see dconf)
    makeFlags = [ "INSTALLBASE=$(out)/share/gnome-shell/extensions" ];
  };
in
{
  environment.systemPackages = with pkgs; [
    gnome3.dconf-editor
    gnome3.gnome-tweaks
    gnome3.gnome-shell-extensions # required for user-theme
    gnomeExtensions.dash-to-panel
    gnomeExtensions.appindicator
    gnome-shell-extension-pop-shell
  ];

  # Enable Gnome 3
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;
  services.xserver.desktopManager.gnome3.enable = true;
  environment.gnome3.excludePackages = with pkgs; [
    gnome3.geary
    gnome3.gnome-weather
    gnome3.gnome-calendar
    gnome3.gnome-maps
    gnome3.gnome-contacts
    gnome3.gnome-software
    gnome3.gnome-packagekit
    gnome3.epiphany
  ];
} 