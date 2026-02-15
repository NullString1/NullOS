{ pkgs, ... }:
{
  home.packages = with pkgs; [ nixd ];

  nixpkgs.config.allowUnfree = true;

  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        extensions = with pkgs.vscode-extensions; [
          #jeff-hykin.better-nix-syntax
          ms-vscode.cpptools-extension-pack
          mads-hartmann.bash-ide-vscode
          vadimcn.vscode-lldb
          github.copilot-chat
          ms-python.black-formatter
          rust-lang.rust-analyzer
          mkhl.direnv
          jnoortheen.nix-ide
          bradlc.vscode-tailwindcss
          tamasfe.even-better-toml
          github.vscode-github-actions
          ms-vscode.hexeditor
          ms-toolsai.jupyter
          ms-python.python
          rust-lang.rust-analyzer
          svelte.svelte-vscode
          mechatroner.rainbow-csv
          dbaeumer.vscode-eslint
        ];
      };
    };
  };
}
