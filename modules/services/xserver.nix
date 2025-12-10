{ vars, ... }:
{
  services.xserver = {
    enable = false;
    xkb = {
      layout = vars.keyboardLayout;
      variant = "";
    };
  };
}
