{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [ nixd ];

  nixpkgs.config.allowUnfree = true;

  programs.vscode = {
    enable = true;
    profiles = {
      default = {
        extensions = with pkgs.vscode-extensions; [
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
          svelte.svelte-vscode
          mechatroner.rainbow-csv
          dbaeumer.vscode-eslint
        ];
        userSettings = {
          "git.enableSmartCommit" = true;
          "git.confirmSync" = false;
          "editor.formatOnSave" = true;
          "git.enableCommitSigning" = true;
          "explorer.confirmDelete" = false;
          "editor.fontFamily" = "JetBrainsMono Nerd Font Mono";
          "editor.fontSize" = 14;
          "editor.fontLigatures" = true;
          "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font Mono";
          "diffEditor.renderSideBySide" = true;
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
          "svelte.enable-ts-plugin" = true;
          "git.blame.editorDecoration.enabled" = true;
          "diffEditor.ignoreTrimWhitespace" = false;
          "workbench.colorTheme" = lib.mkForce "Dark+";
          "notebook.markup.fontSize" = 14;
        };
      };
    };
  };
}