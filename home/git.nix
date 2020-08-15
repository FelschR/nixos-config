{ config, pkgs, ... }:

let
in
{
  imports = [
    ./modules/git.nix
  ];

  programs.git.custom = {
    profiles = {
      private = {
        name       = "Felix Tenley";
        email      = "dev@felschr.com";
        signingKey = "6AB3 7A28 5420 9A41 82D9  0068 910A CB9F 6BD2 6F58";
        dirs       = [ "/etc/nixos/" ];
      };
      work = {
        name       = "Felix Schröter";
        email      = "fs@upsquared.com";
        signingKey = "F28B FB74 4421 7580 5A49  2930 BE85 F0D9 987F A014";
        dirs       = [ "~/dev/" ];
      };
    };
    defaultProfile = "private";
  };
}
