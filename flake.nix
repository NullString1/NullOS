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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dolphin-overlay = {
      url = "github:rumboon/dolphin-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      fusion360,
      sops-nix,
      self,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      username = "nullstring1";

      loadMachineConfig =
        hostname:
        let
          machineConfig = import ./machines/${hostname}/default.nix {
            inherit
              self
              pkgs
              lib
              inputs
              ;
          };
          baseConfig = import ./machines/profiles/base.nix { inherit pkgs; };
          profileConfig = import ./machines/profiles/${machineConfig.profile}.nix;
          baseVars = lib.attrsets.recursiveUpdate baseConfig profileConfig;
          machineOnlyVarDefaults = {
            hostname = "";
            stylixImage = self + /wallpapers/screen.jpg;
            waybarConfig = self + /home/waybar/default.nix;
            animationSet = self + /home/hyprland/animations-end4.nix;
            extraMonitorSettings = "";
            enableNvidiaOffload = false;
          };
          knownVarDefaults = lib.attrsets.recursiveUpdate baseVars machineOnlyVarDefaults;
          reservedMachineKeys = [
            "profile"
            "vars"
            "extraNixosConfig"
          ];
          legacyMachineVarOverrides = builtins.intersectAttrs knownVarDefaults machineConfig;
          machineVarOverrides = lib.attrsets.recursiveUpdate legacyMachineVarOverrides (
            machineConfig.vars or { }
          );
          vars = lib.attrsets.recursiveUpdate knownVarDefaults machineVarOverrides;
          inferredExtraNixosConfig = removeAttrs machineConfig (
            (builtins.attrNames legacyMachineVarOverrides) ++ reservedMachineKeys
          );
        in
        {
          inherit vars;
          extraNixosConfig = lib.attrsets.recursiveUpdate inferredExtraNixosConfig (
            machineConfig.extraNixosConfig or { }
          );
        };

      lib = nixpkgs.lib;

      overlays = [
        (
          final: prev:
          let
            stable = import nixpkgs-stable {
              inherit system;
              config.allowUnfree = true;
            };
          in
          {
            stable = stable;
            fusion360 = fusion360.packages.${system}.default;
            sunshine = stable.sunshine;
          }
        )
        (final: prev: {
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (python-final: python-prev: {
              picosvg = python-prev.picosvg.overridePythonAttrs (oldAttrs: {
                doCheck = false;
              });
            })
          ];
        })
        (final: prev: {
          hyprland = inputs.hyprland.packages.${system}.hyprland;
          xdg-desktop-portal-hyprland = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
        })
        inputs.dolphin-overlay.overlays.default
      ];

      pkgs = import nixpkgs {
        inherit system;
        inherit overlays;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };

      homeManagerModules = vars: [
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

      machineHostnames = [
        "nslapt"
        "nspc"
        "nsminipc"
      ];

      mkHome =
        hostname:
        let
          machine = loadMachineConfig hostname;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            vars = machine.vars;
            inherit inputs;
            username = username;
          };
          modules = homeManagerModules machine.vars;
        };

      mkSystem =
        {
          hostname,
          hardware,
          extraModules ? [ ],
        }:
        let
          machine = loadMachineConfig hostname;
          vars = machine.vars;
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit vars inputs home-manager;
          };
          modules = [
            inputs.home-manager.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            {
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = {
                inherit vars inputs;
                inherit (vars) username;
              };
              home-manager.users.${username} = {
                imports = homeManagerModules vars;
              };
            }
            {
              nixpkgs.pkgs = pkgs;
            }
            {
              sops.defaultSopsFile = ./machines/${hostname}/secrets.yaml;
              sops.defaultSopsFormat = "yaml";
              sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
              sops.secrets = {
                githubToken = { };
              }
              // lib.optionalAttrs vars.enableResticBackup {
                resticRepository = { };
              };
            }
            {
              users.users.${username} = {
                isNormalUser = true;
                description = "NullString1";
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
              nix.settings.allowed-users = [ "@wheel" ];
            }
            (
              { config, ... }:
              {
                nix.extraOptions = ''
                  !include ${config.sops.secrets.githubToken.path}
                '';
              }
            )
            ./modules/misc
            ./modules/services
            ./modules/software
            ./modules/system
            hardware
            machine.extraNixosConfig
          ]
          ++ extraModules;
        };

    in
    {
      formatter.x86_64-linux = pkgs.nixfmt;

      homeConfigurations = builtins.listToAttrs (
        map (hostname: {
          name = "${username}@${hostname}";
          value = mkHome hostname;
        }) machineHostnames
      );

      nixosConfigurations = {
        nslapt = mkSystem {
          hostname = "nslapt";
          hardware = ./modules/system/hardware_nslapt.nix;
          extraModules = [
            (
              { pkgs, ... }:
              {
                specialisation = {
                  power-efficient = {
                    inheritParentConfig = true;
                    configuration = {
                      services.xserver.videoDrivers = pkgs.lib.mkForce [ "modesetting" ];
                      hardware.nvidia.prime.offload.enable = pkgs.lib.mkForce false;
                      hardware.nvidia.powerManagement.enable = pkgs.lib.mkForce false;
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
    };
}
