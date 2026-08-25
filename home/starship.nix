{ lib, ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$nix_shell"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_state"
        "$git_status"
        "\n"
        "$character"
      ];
      directory = {
        style = "blue";
        read_only = " 󰌾";
      };

      character = {
        success_symbol = "[❯](blue)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](cyan)";
      };

      nix_shell = {
        format = "[$symbol]($style) ";
        symbol = " ";
        style = "";
      };

      git_branch = {
        symbol = " ";
        style = "blue";
      };

      git_status = {
        format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218)($ahead_behind$stashed)]($style)";
        style = "cyan";
        conflicted = "";
        renamed = "";
        deleted = "";
        staged = "≡";
      };

      git_state = {
        format = "([$state( $progress_current/$progress_total)]($style)) ";
        style = "bright-black";
      };

      buf = {
        symbol = " ";
      };
      c = {
        symbol = " ";
      };
      docker_context = {
        symbol = " ";
      };
      fossil_branch = {
        symbol = " ";
      };
      golang = {
        symbol = " ";
      };
      hg_branch = {
        symbol = " ";
      };
      hostname = {
        ssh_symbol = " ";
      };
      lua = {
        symbol = " ";
      };
      memory_usage = {
        symbol = "󰍛 ";
      };
      meson = {
        symbol = "󰔷 ";
      };
      nim = {
        symbol = "󰆥 ";
      };
      nodejs = {
        symbol = " ";
      };
      ocaml = {
        symbol = " ";
      };
      package = {
        symbol = "󰏗 ";
      };
      python = {
        symbol = " ";
      };
      rust = {
        symbol = " ";
      };
      swift = {
        symbol = " ";
      };
      zig = {
        symbol = " ";
      };
    };
  };
}
