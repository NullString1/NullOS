{ ... }:
{
  home.activation.removeKdeglobals = ''
    rm -f $HOME/.config/kdeglobals
  '';
}
