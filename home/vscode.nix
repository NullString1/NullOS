{ pkgs, ... }:
{
  home.packages = with pkgs; [ nixd ];

  nixpkgs.config.allowUnfree = true;

  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        extensions = with pkgs.vscode-extensions; [
          bbenoist.nix
          jeff-hykin.better-nix-syntax
          ms-vscode.cpptools-extension-pack
          mads-hartmann.bash-ide-vscode
          tamasfe.even-better-toml
          vadimcn.vscode-lldb
          github.copilot-chat
          github.copilot
          ms-python.black-formatter
          rust-lang.rust-analyzer
        ];
      };
    };
  };
}
