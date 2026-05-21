{ config, lib, ... }:
{
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      ipv6_servers = true;
      server_names = [ (lib.readFile config.sops.secrets.nextdnsServerName.path) ];
      require_dnssec = true;
      static = {
        "${lib.readFile config.sops.secrets.nextdnsServerName.path}" = {
          stamp = lib.trim (lib.readFile config.sops.secrets.nextdnsStamp.path);
        };
      };
    };
  };
  networking = {
    nameservers = [
      "127.0.0.1"
      "::1"
    ];
    networkmanager.dns = "none";
    dhcpcd.extraConfig = "nohook resolv.conf";
  };
  services.resolved.enable = lib.mkForce false;
}
