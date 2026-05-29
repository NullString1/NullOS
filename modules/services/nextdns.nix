{
  config,
  ...
}:
{
  sops.templates."dnscrypt-proxy.toml" = {
    content = ''
      ipv6_servers = true
      server_names = [ "${config.sops.placeholder.nextdnsServerName}" ]
      require_dnssec = true
      bootstrap_resolvers = ['1.1.1.1:53', '1.0.0.1:53']
      [static]
        [static."${config.sops.placeholder.nextdnsServerName}"]
          stamp = '${config.sops.placeholder.nextdnsStamp}'
    '';
    mode = "0444";
  };
  services.dnscrypt-proxy = {
    enable = true;
    configFile = config.sops.templates."dnscrypt-proxy.toml".path;
  };
  networking = {
    networkmanager.dns = "systemd-resolved";
  };
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNS = [
          "127.0.0.1"
          "::1"
        ];
        Domains = "~.";
        FallbackDns = [
          "127.0.0.1"
          "::1"
        ];
      };
    };
  };
}
