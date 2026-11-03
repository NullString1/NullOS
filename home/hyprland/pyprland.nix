{
  pkgs,
  vars,
  config,
  ...
}:
let
  warp-show = pkgs.writeShellScript "warp-show" ''
    PID=$(pidof -s warp-taskbar)
    if [ -z "$PID" ]; then
      echo "Error: warp-taskbar not running"
      exit 1
    fi

    # Send the D-Bus signal
    gdbus call --session \
      --dest "org.kde.StatusNotifierItem-$PID-1" \
      --object-path /MenuBar \
      --method com.canonical.dbusmenu.EventGroup \
      "[ (1, 'clicked', <int32 0>, @u 0) ]"

    for i in {1..50}; do
      if hyprctl clients -j | grep "Cloudflare Zero Trust" > /dev/null; then
          exit 0
      fi
      sleep 0.1
    done

    echo "Timed out waiting for window"
    exit 1
  '';
in
{
  home.packages = with pkgs; [
    pyprland
    glib
  ];

  systemd.user.services.pyprland = {
    Unit = {
      Description = "Pyprland daemon";
      PartOf = [ "hyprland-session.target" ];
      After = [ "hyprland-session.target" ];
    };
    Service = {
      ExecStartPre = "${pkgs.writeShellScript "pypr-cleanup" ''
        rm -f ''${XDG_RUNTIME_DIR:-/run/user/1000}/hypr/*/.pyprland.sock
      ''}";
      ExecStart = "${pkgs.libcap}/bin/capsh --caps= -- -c '${pkgs.pyprland}/bin/pypr'";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install = {
      WantedBy = [ "hyprland-session.target" ];
    };
  };

  home.file.".config/pypr/config.toml".text = ''
    [pyprland]
    plugins = [
      "scratchpads",
      "external:tscratch"
    ]

    [scratchpads.vpn]
    animation = "fromTop"
    class = "Cloudflare Zero Trust"
    match_by = "class"
    process_tracking = false
    close_on_hide = true
    lazy = true
    command = "${warp-show}"

    [tscratch.dev]
    width = "95%"
    height = "90%"
    top = "6%"
    gap = 14
    orientation = "horizontal"
    layout = "columns"
    restore_focus = true
    presets = [
      [0.8, 0.2],
      [0.5, 0.5],
      [0.2, 0.8]
    ]

    [tscratch.dev.windows.term]
    command = "ghostty --class=scratchpad.ghostty"
    class = "scratchpad.ghostty"
    ratio = 0.8
    min_width = "350px"
    max_width = "1650px"
    min_height = "500px"
    max_height = "950px"
    animation = "fromTop"

    [tscratch.dev.windows.gemini]
    command = "${vars.browser.meta.mainProgram} --profile-directory=Default --app=https://gemini.google.com/app"
    initialClass = "brave-gemini.google.com__app-Default"
    ratio = 0.2
    min_width = "340px"
    max_width = "1650px"
    min_height = "600px"
    max_height = "950px"
    animation = "fromRight"
    solo_position = "right"
    solo_width = "420px"
  '';
}
