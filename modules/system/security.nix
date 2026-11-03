{
  vars,
  pkgs,
  lib,
  ...
}:
{
  security = {
    sudo.wheelNeedsPassword = vars.requirePasswordForSudo;
    rtkit.enable = vars.enableAudio;
    allowUserNamespaces = true;
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if ( subject.isInGroup("users") && (
           action.id == "org.freedesktop.login1.reboot" ||
           action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
           action.id == "org.freedesktop.login1.power-off" ||
           action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
           action.id.indexOf("org.freedesktop.udisks2.") === 0
          ))
          { return polkit.Result.YES; }
        })
      '';
    };
    pam.services.swaylock = {
      text = "auth include login ";
    };
    pam.services.hyprlock = { };
    # wrappers = lib.mkIf vars.isHyprland {
    #   Hyprland.source = lib.mkForce "${pkgs.hyprland}/bin/.Hyprland-wrapped";
    # };
  };
}
