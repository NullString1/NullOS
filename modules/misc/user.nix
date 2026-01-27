{
  pkgs,
  inputs,
  vars,
  ...
}:
let
  username = vars.username;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs username vars; };
    users.${username} = {
      imports = [ ../../home ];
      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "26.05";
      };
    };
  };
  users.mutableUsers = true;
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
  nix.settings.allowed-users = [ "${username}" ];
}
