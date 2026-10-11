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
  home.packages = with pkgs; [
    nixd
    nixfmt
  ];

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
    if [ "$(uname)" = "Darwin" ]; then
      targetDir="$HOME/Library/Application Support/Code/User"
    else
      targetDir="$HOME/.config/Code/User"
    fi
    targetFile="$targetDir/settings.json"

    $DRY_RUN_CMD mkdir -p "$targetDir"

    if [ -L "$targetFile" ]; then
      $DRY_RUN_CMD rm -f "$targetFile"
    fi

    defaults=${lib.escapeShellArg (builtins.toJSON defaultSettings)}

    if [ -f "$targetFile" ] && [ -s "$targetFile" ]; then
      tmpFile=$(mktemp "$targetDir/settings.XXXXXX.tmp")

      # Merge chain:
      # 1. Start with Nix defaults (.[0])
      # 2. Layer User changes on top (.[1])
      # 3. Force-layer any value from Nix defaults matching "/nix/store" (.[2])
      if ${pkgs.jq}/bin/jq -s '
        (.[0] | with_entries(select(.value | tostring | test("^/nix/store")))) as $nixPaths |
        (.[0] * .[1]) * $nixPaths
      ' <(echo "$defaults") "$targetFile" > "$tmpFile" 2>/dev/null; then
        $DRY_RUN_CMD mv "$tmpFile" "$targetFile"
      else
        echo "Warning: Could not parse $targetFile as valid JSON. Retaining existing file." >&2
        rm -f "$tmpFile"
      fi
    else
      echo "$defaults" | ${pkgs.jq}/bin/jq '.' > "$targetFile"
    fi

    $DRY_RUN_CMD chmod 644 "$targetFile"
  '';
}
