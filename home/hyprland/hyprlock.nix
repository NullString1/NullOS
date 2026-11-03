{ username, ... }:
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
      };
      background = [
        {
          path = "/home/${username}/Pictures/Wallpapers/screen.jpg";
          blur_passes = 3;
          blur_size = 8;
        }
      ];
      image = [
        {
          path = "/home/${username}/.config/face.jpg";
          size = 150;
          border_size = 4;
          border_color = "rgb(0C96F9)";
          rounding = -1; # Negative means circle
          position = "0, 200";
          halign = "center";
          valign = "center";
        }
      ];
      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(CFE6F4)";
          inner_color = "rgb(657DC2)";
          outer_color = "rgb(0D0E15)";
          outline_thickness = 5;
          placeholder_text = "Password...";
          shadow_passes = 2;
        }
      ];
      label = [
        {
          monitor = "";
          text = "$TIME";
          text_align = "center";
          font_size = 48;
          color = "rgb(CFE6F4)";
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = ''cmd[update:60000] date +"%A, %d %B %Y"'';
          text_align = "center";
          font_size = 18;
          color = "rgb(657DC2)";
          position = "0, 30";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
