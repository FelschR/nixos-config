{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.home-manager = {
    url = "github:nix-community/home-manager/master";
  };

  inputs.nur.url = "github:nix-community/NUR/master";

  outputs = { self, nixpkgs, home-manager, nur }: let
    systemModule = { hostName, hardwareConfig, config }: ({ pkgs, ... }: {
      networking.hostName = hostName;

      # Let 'nixos-version --json' know about the Git revision
      # of this flake.
      system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;

      nix.registry.nixpkgs.flake = nixpkgs;

      nixpkgs.overlays = [
        nur.overlay
      ];

      imports = [
        hardwareConfig
        home-manager.nixosModules.home-manager
        config
      ];
    });
  in {

    nixosConfigurations.felix-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          nixpkgs.nixosModules.notDetected
          (systemModule {
            hostName = "felix-nixos";
            hardwareConfig = ./hardware/felix-nixos.nix;
            config = ./home-pc.nix;
          })
        ];
    };

    nixosConfigurations.pilot1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules =
        [
          nixpkgs.nixosModules.notDetected
          (systemModule {
            hostName = "pilot1";
            hardwareConfig = ./hardware-configuration.nix; # TODO
            config = ./work-pc.nix;
          })
        ];
    };

    homeManagerModules.git = import ./home/modules/git.nix;

  };
}