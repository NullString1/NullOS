{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.dbgate ];
}
