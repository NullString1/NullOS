let
  pc = import ./pc.nix;
in
pc
// {
  laptopPowerManagement = true;
  nextdnsOverTLS = "opportunistic";
}
