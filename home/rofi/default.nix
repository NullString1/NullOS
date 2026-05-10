{ config, ... }:
{
  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "drun,filebrowser,run";
      show-icons = true;
      icon-theme = "Papirus";
      font = "JetBrainsMono Nerd Font Mono 12";
      drun-display-format = "{icon} {name}";
      display-drun = " Apps";
      display-run = " Run";
      display-filebrowser = " File";
    };
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
      # Catppuccin Mocha colors
      base00 = "1e1e2e";  # background
      base01 = "181825";  # darker
      base05 = "cdd6f4";  # text
      base08 = "f38ba8";  # red (selected)
      base0B = "a6e3a1";  # green (active)
      base0D = "89b4fa";  # blue
      base0E = "cba6f7";  # mauve (urgent)
      base09 = "fab387";  # peach
    in
    {
      "*" = {
        bg = mkLiteral "#${base00}ee";
        bg-alt = mkLiteral "#${base01}ee";
        foreground = mkLiteral "#${base05}";
        selected = mkLiteral "#${base0D}";
        active = mkLiteral "#${base0B}";
        text-selected = mkLiteral "#${base00}";
        text-color = mkLiteral "#${base05}";
        border-color = mkLiteral "#${base0D}";
        urgent = mkLiteral "#${base0E}";
      };
      "window" = {
        transparency = "real";
        width = mkLiteral "800px";
        location = mkLiteral "center";
        anchor = mkLiteral "center";
        border-radius = mkLiteral "15px";
        background-color = mkLiteral "@bg";
      };
      "mainbox" = {
        spacing = mkLiteral "10px";
        orientation = mkLiteral "vertical";
        children = map mkLiteral [ "inputbar" "listview" "message" ];
        background-color = mkLiteral "transparent";
      };
      "inputbar" = {
        spacing = mkLiteral "10px";
        padding = mkLiteral "12px";
        border-radius = mkLiteral "10px";
        background-color = mkLiteral "@bg-alt";
        children = map mkLiteral [ "textbox-prompt-colon" "entry" ];
      };
      "textbox-prompt-colon" = {
        expand = false;
        str = "  ";
        background-color = mkLiteral "inherit";
      };
      "entry" = {
        background-color = mkLiteral "inherit";
        placeholder = "Search apps...";
      };
      "listview" = {
        columns = 1;
        lines = 8;
        cycle = true;
        scrollbar = false;
        spacing = mkLiteral "5px";
        background-color = mkLiteral "transparent";
      };
      "element" = {
        spacing = mkLiteral "10px";
        padding = mkLiteral "10px";
        border-radius = mkLiteral "8px";
        background-color = mkLiteral "transparent";
      };
      "element normal.normal" = {
        background-color = mkLiteral "inherit";
      };
      "element selected.normal" = {
        background-color = mkLiteral "@selected";
      };
      "element-icon" = {
        size = mkLiteral "32px";
      };
      "element-text" = {
        vertical-align = mkLiteral "0.5";
      };
    };
  };
}