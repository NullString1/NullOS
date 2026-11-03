{
  description = "NullOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
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
      url = "github:hyprwm/Hyprland/v0.55.1";
    };
    dolphin-overlay = {
      url = "github:MattiDragon/dolphin-overlay/b9dabd238054ff973e45c05a72345c756e0f286e";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hypr-kdeconnect-fix = {
      url = "github:nullstring1/hypr-kdeconnect-fix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    opencode-v2-overlay = {
      url = "path:/mdata/NS/Projects/opencode2flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tscratch = {
      url = "path:/mdata/NS/Projects/tscratch";
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

          topLevelVarOverrides = removeAttrs machineConfig reservedMachineKeys;
          machineVarOverrides = lib.attrsets.recursiveUpdate topLevelVarOverrides (machineConfig.vars or { });

          mergedVars = lib.attrsets.recursiveUpdate knownVarDefaults machineVarOverrides;
          vars = mergedVars // {
            isHyprland = mergedVars.desktopEnvironment == "hyprland";
            isKDE = mergedVars.desktopEnvironment == "kde";
            isCage = mergedVars.desktopEnvironment == "cage";
            isHeadless = mergedVars.desktopEnvironment == null;
          };
        in
        {
          inherit vars;
          extraNixosConfig = machineConfig.extraNixosConfig or { };
        };

      lib = nixpkgs.lib;

      overlays = [
        (
          final: prev:
          let
            stable = import nixpkgs-stable {
              localSystem = final.stdenv.hostPlatform;
              config.allowUnfree = true;
            };
          in
          {
            stable = stable;
            fusion360 = fusion360.packages.${final.stdenv.hostPlatform.system}.default or null;
          }
        )
        (final: prev: {
          hyprland = inputs.hyprland.packages.${final.stdenv.hostPlatform.system}.hyprland or null;
          xdg-desktop-portal-hyprland =
            inputs.hyprland.packages.${final.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland or null;
        })
        (final: prev: {
          ananicy-rules-cachyos = prev.ananicy-rules-cachyos.overrideAttrs (oldAttrs: {
            version = "1.1.38";
            src = prev.fetchFromGitHub {
              owner = "CachyOS";
              repo = "ananicy-rules";
              rev = "1.1.38";
              hash = "sha256-g9Vitk0QHLSVNnOUzblVk8ot6YQ3twbv5nPa4njRZ8c=";
            };
          });
        })
        (final: prev: {
          pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
            (python-final: python-prev: {
              patool = python-prev.patool.overridePythonAttrs (oldAttrs: {
                doCheck = false;
              });
            })
          ];
        })
        inputs.dolphin-overlay.overlays.default
        inputs.opencode-v2-overlay.overlays.default
        inputs.tscratch.overlays.default
        # sops-nix still builds sops-install-secrets with buildGo125Module,
        # which nixpkgs removed (Go 1.25 EOL). Alias it to the current
        # default Go builder until upstream migrates.
        # TODO: drop once sops-nix moves off Go 1.25.
        (final: prev: {
          buildGo125Module = prev.buildGoModule;
        })
      ];

      pkgs = import nixpkgs {
        localSystem = system;
        inherit overlays;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };

      homeManagerModules = vars: [
        inputs.catppuccin.homeModules.catppuccin
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
        {
          hostname,
          chosenPkgs ? pkgs,
        }:
        let
          machine = loadMachineConfig hostname;
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = chosenPkgs;
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
          system ? "x86_64-linux",
          chosenPkgs ? (import nixpkgs {
            localSystem = system;
            inherit overlays;
            config = {
              allowUnfree = true;
              android_sdk.accept_license = true;
            };
          }),
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
            inputs.opencode-v2-overlay.nixosModules.default
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
              nixpkgs.pkgs = chosenPkgs;
            }
            {
              sops.defaultSopsFile = ./machines/${hostname}/secrets.yaml;
              sops.defaultSopsFormat = "yaml";
              sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
              sops.secrets = {
                githubToken = { };
              }
              // lib.optionalAttrs vars.enableNextDNS {
                nextdnsProfileId = { };
                nextdnsIpUpdateUrl = { };
              }
              // lib.optionalAttrs vars.enableResticBackup {
                resticRepository = {
                  owner = vars.username;
                  group = "users";
                };
              };
            }
            (
              { pkgs, ... }:
              {
                users.users.${username} = {
                  isNormalUser = true;
                  description = "${username}";
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
            )
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
          ++ extraModules
          ++ lib.optionals vars.enableKDEConnect [ inputs.hypr-kdeconnect-fix.nixosModules.default ];
        };

    in
    {
      formatter.x86_64-linux = pkgs.nixfmt-tree;

      devShells.x86_64-linux.default = pkgs.mkShell {
        name = "nullos-dev";
        packages = with pkgs; [
          nh
          sops
          age
          nixfmt-tree
          deadnix
          statix
          nil
        ];
        shellHook = ''
          fr() {
            local host="$(hostname)"
            local target="''${1:-$host}"
            if [[ "$target" == -* ]] || [ -z "$1" ]; then
              nh os switch --hostname "$host" "$@"
            elif [ "$target" = "$host" ]; then
              nh os switch --hostname "$host" "''${@:2}"
            else
              nh os switch --hostname "$target" --target-host "$target" "''${@:2}"
            fi
          }
          fu() {
            local host="$(hostname)"
            local target="''${1:-$host}"
            if [[ "$target" == -* ]] || [ -z "$1" ]; then
              nh os switch --hostname "$host" --update "$@"
            elif [ "$target" = "$host" ]; then
              nh os switch --hostname "$host" --update "''${@:2}"
            else
              nh os switch --hostname "$target" --target-host "$target" --update "''${@:2}"
            fi
          }
          export -f fr fu
          echo "🚀 Welcome to NullOS Development Shell"
          echo "Usage: fr [hostname] [args]  (e.g., fr, fr nsminipc, fr --dry)"
          echo "       fu [hostname] [args]  (e.g., fu, fu nslapt, fu --dry)"
        '';
      };

      packages.x86_64-linux = {
        nspc = self.nixosConfigurations.nspc.config.system.build.toplevel;
        nslapt = self.nixosConfigurations.nslapt.config.system.build.toplevel;
        nsminipc = self.nixosConfigurations.nsminipc.config.system.build.toplevel;
      };

      packages.aarch64-linux = {
        serv2 = self.nixosConfigurations.serv2.config.system.build.toplevel;
      };

      homeConfigurations = builtins.listToAttrs (
        map (hostname: {
          name = "${username}@${hostname}";
          value = mkHome {
            hostname = hostname;
            chosenPkgs = pkgs;
          };
        }) machineHostnames
      );

      nixosConfigurations = {
        serv2 = mkSystem {
          hostname = "serv2";
          system = "aarch64-linux";
          hardware = ./modules/system/hardware_serv2.nix;
        };

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
