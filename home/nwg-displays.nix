{ pkgs, ... }:
{
  home.packages = [
    (pkgs.nwg-displays.overrideAttrs (old: {
      version = "0.4.3";
      src = pkgs.fetchFromGitHub {
        owner = "nwg-piotr";
        repo = "nwg-displays";
        rev = "v0.4.3";
        sha256 = "sha256-f7x6PTsND0eprhqvIdkZdHujcCbkJnqoXIKeE0O/YPE=";
      };
    }))
  ];
}
