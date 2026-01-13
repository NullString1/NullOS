{ pkgs, ... }:
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

  home.file.".config/hypr/pyprland.toml".text = ''
    [pyprland]
    plugins = [
      "scratchpads",
    ]

    [scratchpads.term]
    animation = "fromTop"
    command = "ghostty"
    class = "com.mitchellh.ghostty"
    size = "70% 70%"
    max_size = "1920px 100%"

    [scratchpads.vpn]
    animation = "fromTop"
    class = "Cloudflare Zero Trust"
    match_by="class"
    process_tracking=false
    command = "${warp-show}"
  '';

}
