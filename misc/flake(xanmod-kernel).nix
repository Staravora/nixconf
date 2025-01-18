{
  description = "My first flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    
  in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;
        modules = [ 
          ({ pkgs, ... }: {
            nixpkgs.config = {
              allowUnfree = true;
            };

            # Switch to xanmod kernel
            boot.kernelPackages = pkgs.linuxPackages_xanmod;

            # Performance tweaks
            boot.kernelParams = [ 
              "preempt=full"
              "mitigations=off"
            ];

            # CPU frequency scaling
            powerManagement = {
              enable = true;
              cpuFreqGovernor = "performance";
            };
          })
          ./configuration.nix 
        ];
      };
    };
    homeConfigurations = {
      staravora = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [ ./home.nix ];
      };
    };
  };
}
