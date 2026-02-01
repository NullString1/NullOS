{
  description = "NullOS";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix/master";
    nixvim = {
      url = "github:nix-community/nixvim/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fusion360 = {
      url = "github:nullstring1/fusion-360-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      fusion360,
      ...
    }@inputs:
    let
      vars = import ./variables.nix { inherit pkgs; };
      inherit (vars) system username;

      overlays = [
        (final: prev: {
          stable = import nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
          fusion360 = fusion360.packages.${system}.default;
        })
      ];

      pkgs = import nixpkgs {
        inherit system;
        inherit overlays;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
          cudaSupport = vars.useNvidia;
        };
      };

      homeManagerModules = [
        inputs.stylix.homeModules.stylix
        ./home/default.nix
        {
          nixpkgs.overlays = overlays;
          home = {
            inherit username;
            homeDirectory = "/home/${username}";
            stateVersion = "26.05";
          };
        }
      ];

      mkSystem =
        {
          hardware,
          hostname,
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit vars inputs home-manager;
          };
          modules = [
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = {
                inherit vars inputs;
                inherit (vars) username;
              };
              home-manager.users.${username} = {
                imports = homeManagerModules;
              };
            }
            {
              nixpkgs.pkgs = pkgs;
            }
            {
              users.users.${username} = {
                isNormalUser = true;
                description = "${vars.gitUsername}";
                extraGroups = [
                  "kvm"
                  "libvirtd"
                  "lp"
                  "networkmanager"
                  "scanner"
                  "wheel"
                  "dialout"
                  "audio"
                ]
                ++ (if vars.enableAndroid then [ "adbusers" ] else [ ])
                ++ (if vars.enableDocker then [ "docker" ] else [ ]);
                shell = pkgs.zsh;
                ignoreShellProgramCheck = true;
              };
              nix.settings.allowed-users = [ "@wheel" ]; # More secure
            }
            ./modules/misc
            ./modules/services
            ./modules/software
            ./modules/system
            hardware
          ]
          ++ extraModules;
        };

    in
    {
      formatter.x86_64-linux = pkgs.nixfmt;

      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit vars inputs;
          username = vars.username;
        };
        modules = homeManagerModules;
      };

      nixosConfigurations = {
        nslapt = mkSystem {
          hostname = "nslapt";
          hardware = ./modules/system/hardware_nslapt.nix;
          extraModules = [
            (
              { pkgs, ... }:
              {
                specialisation = {
                  # Power-efficient mode with NVIDIA disabled
                  power-efficient = {
                    inheritParentConfig = true;
                    configuration = {
                      # Override NVIDIA configuration
                      services.xserver.videoDrivers = pkgs.lib.mkForce [ "modesetting" ];
                      hardware.nvidia.prime.offload.enable = pkgs.lib.mkForce false;
                      hardware.nvidia.powerManagement.enable = pkgs.lib.mkForce false;

                      # Use integrated graphics only
                      boot.blacklistedKernelModules = [
                        "nouveau"
                        "nvidia"
                        "nvidia_drm"
                        "nvidia_uvm"
                        "nvidia_modeset"
                      ];

                      boot.kernelParams = [
                        "i915.enable_psr=1"
                        "i915.enable_fbc=1"
                      ];
                      powerManagement.cpuFreqGovernor = pkgs.lib.mkForce "powersave";
                    };
                  };
                };
              }
            )
          ];
        };

        nspc = mkSystem {
          hostname = "nspc";
          hardware = ./modules/system/hardware_nspc.nix;
        };

        nsminipc = mkSystem {
          hostname = "nsminipc";
          hardware = ./modules/system/hardware_nsminipc.nix;
        };
      };

      inherit vars;
    };
}
