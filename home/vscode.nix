{ pkgs, lib, ... }:
let
  defaultSettings = {
    "git.enableSmartCommit" = true;
    "git.confirmSync" = false;
    "editor.formatOnSave" = true;
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
    "workbench.colorTheme" = "Dark+";
    "notebook.markup.fontSize" = 14;
    "git.openRepositoryInParentFolders" = "always";
    "nix.serverSettings" = {
      "nixd" = {
        "formatting" = {
          "command" = [ "${pkgs.nixfmt}/bin/nixfmt" ];
        };
      };
    };
  };
in
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
          christian-kohler.path-intellisense
        ];
        userSettings = lib.mkForce { };
      };
    };
  };

  home.activation.mergeVsCodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    targetDir="$HOME/.config/Code/User"
    targetFile="$targetDir/settings.json"
    mkdir -p "$targetDir"

    # Remove Nix store symlink if present so we can write a physical file
    if [ -L "$targetFile" ]; then
      rm -f "$targetFile"
    fi

    defaults=${lib.escapeShellArg (builtins.toJSON defaultSettings)}

    if [ -f "$targetFile" ] && [ -s "$targetFile" ]; then
      # Merge Nix defaults with user settings, giving priority to user settings
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' <(echo "$defaults") "$targetFile" > "$targetFile.tmp"
      mv "$targetFile.tmp" "$targetFile"
    else
      echo "$defaults" | ${pkgs.jq}/bin/jq '.' > "$targetFile"
    fi

    chmod 644 "$targetFile"
  '';
}
