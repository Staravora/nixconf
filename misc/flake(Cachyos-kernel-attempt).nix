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
    
    cachyosOverlay = final: prev: {
      linux_cachyos = prev.callPackage
        ({ stdenv, buildLinux, ... }: 
        
        buildLinux rec {
          version = "6.7-cachyos1";
          modDirVersion = "6.7";
          
          src = builtins.fetchGit {
            url = "https://github.com/CachyOS/linux-cachyos.git";
            ref = "6.7";  # Branch name
            rev = "f2de7fe64a97b57f57fe3fecfdd655c9bb488bdc";  # Full commit hash
          };
          
          structuredExtraConfig = with lib.kernel; {
            BORE_SCHEDULER = lib.mkForce yes;
            CACULE_SCHED = lib.mkForce yes;
            
            # Preempt settings
            PREEMPT = lib.mkForce yes;
            PREEMPT_BUILD = lib.mkForce yes;
            PREEMPT_DYNAMIC = lib.mkForce no;
            
            # Other performance options
            HZ_1000 = lib.mkForce yes;
            HZ = lib.mkForce (freeform "1000");
          };

          allowImportFromDerivation = true;
          ignoreConfigErrors = true;
        }) {};
      
      linuxPackages_cachyos = final.linuxPackagesFor final.linux_cachyos;
    };

  in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;
        modules = [ 
          ({ pkgs, ... }: {
            nixpkgs = {
              overlays = [ cachyosOverlay ];
              config = {
                allowUnfree = true;
                allowBroken = true;
              };
            };
            boot.kernelParams = [ "preempt=full" ];
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
