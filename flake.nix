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
      overlays = [
        (final: prev: {
          stable = import nixpkgs-stable {
            system = prev.system;
            config.allowUnfree = true;
          };
        })
      ];
      vars = import ./variables.nix { inherit nixpkgs; };
      inherit (vars) system username;
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.${system}.nixfmt-tree;
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          overlays = overlays;
          config = {
            allowUnfree = true;
          };
        };
        extraSpecialArgs = {
          inherit vars;
          inherit inputs;
          username = vars.username;
        };
        modules = [
          inputs.stylix.homeModules.stylix
          ./home/default.nix
          {
            home = {
              username = "${username}";
              homeDirectory = "/home/${username}";
              stateVersion = "26.05";
            };
          }
        ];
      };
      nixosConfigurations = {
        nslapt = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit vars;
            inherit inputs;
            inherit home-manager;
            fusion360 = fusion360.packages.${system}.default;
          };
          pkgs = import nixpkgs {
            inherit system;
            overlays = overlays;
            config = {
              allowUnfree = true;
              android_sdk.accept_license = true;
            };
          };
          modules = [
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = {
                inherit vars;
                inherit inputs;
                fusion360 = fusion360.packages.${system}.default;
                username = vars.username;
              };
              home-manager.users.${username} = {
                imports = [
                  inputs.stylix.homeModules.stylix
                  ./home/default.nix
                ];
                home = {
                  username = "${username}";
                  homeDirectory = "/home/${username}";
                  stateVersion = "26.05";
                };
              };
            }
            {
              users.mutableUsers = true;
              users.users.${username} = {
                isNormalUser = true;
                description = "${vars.gitUsername}";
                extraGroups = [
                  "kvm"
                  "adbusers"
                  "docker"
                  "libvirtd"
                  "lp"
                  "networkmanager"
                  "scanner"
                  "wheel"
                  "dialout"
                  "audio"
                ];
                shell = nixpkgs.legacyPackages.${system}.zsh;
                ignoreShellProgramCheck = true;
              };
              nix.settings.allowed-users = [ "${username}" ];
            }
            ./modules/misc
            ./modules/services
            ./modules/software
            ./modules/system
            ./modules/system/hardware_nslapt.nix

            # Specialisations for different configurations
            {
              specialisation = {
                # Power-efficient mode with NVIDIA disabled
                power-efficient = {
                  inheritParentConfig = true;
                  configuration = {
                    # Override NVIDIA configuration
                    services.xserver.videoDrivers = nixpkgs.lib.mkForce [ "modesetting" ];
                    hardware.nvidia.prime.offload.enable = nixpkgs.lib.mkForce false;
                    hardware.nvidia.powerManagement.enable = nixpkgs.lib.mkForce false;

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

                    # Additional power saving
                    powerManagement.cpuFreqGovernor = nixpkgs.lib.mkForce "powersave";
                  };
                };
              };
            }
          ];
        };
        nspc = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit vars;
            inherit inputs;
            inherit home-manager;
            fusion360 = fusion360.packages.${system}.default;
          };
          pkgs = import nixpkgs {
            inherit system;
            overlays = overlays;
            config = {
              allowUnfree = true;
              android_sdk.accept_license = true;
            };
          };
          modules = [
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = {
                inherit vars;
                inherit inputs;
                fusion360 = fusion360.packages.${system}.default;
                username = vars.username;
              };
              home-manager.users.${username} = {
                imports = [
                  inputs.stylix.homeModules.stylix
                  ./home/default.nix
                ];
                home = {
                  username = "${username}";
                  homeDirectory = "/home/${username}";
                  stateVersion = "25.05";
                };
              };
            }
            {
              users.mutableUsers = true;
              users.users.${username} = {
                isNormalUser = true;
                description = "${vars.gitUsername}";
                extraGroups = [
                  "kvm"
                  "adbusers"
                  "docker"
                  "libvirtd"
                  "lp"
                  "networkmanager"
                  "scanner"
                  "wheel"
                  "dialout"
                  "audio"
                ];
                shell = nixpkgs.legacyPackages.${system}.zsh;
                ignoreShellProgramCheck = true;
              };
              nix.settings.allowed-users = [ "${username}" ];
            }
            ./modules/misc
            ./modules/services
            ./modules/software
            ./modules/system
            ./modules/system/hardware_nspc.nix
          ];
        };
      };
      inherit vars;
    };
}
