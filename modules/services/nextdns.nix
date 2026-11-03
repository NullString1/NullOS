{
  config,
  vars,
  ...
}:
let
  deviceName = vars.nextdnsDeviceName or vars.hostname;
in
{
  sops.templates."nextdns.conf" = {
    path = "/etc/systemd/resolved.conf.d/nextdns.conf";
    mode = "0444";
    content = ''
      [Resolve]
      DNS=
      DNS=45.90.28.0#${deviceName}-${config.sops.placeholder.nextdnsProfileId}.dns.nextdns.io 2a07:a8c0::#${deviceName}-${config.sops.placeholder.nextdnsProfileId}.dns.nextdns.io 45.90.30.0#${deviceName}-${config.sops.placeholder.nextdnsProfileId}.dns.nextdns.io 2a07:a8c1::#${deviceName}-${config.sops.placeholder.nextdnsProfileId}.dns.nextdns.io
      FallbackDNS=
      FallbackDNS=45.90.28.0#${deviceName}-${config.sops.placeholder.nextdnsProfileId}.dns.nextdns.io 2a07:a8c0::#${deviceName}-${config.sops.placeholder.nextdnsProfileId}.dns.nextdns.io 45.90.30.0#${deviceName}-${config.sops.placeholder.nextdnsProfileId}.dns.nextdns.io 2a07:a8c1::#${deviceName}-${config.sops.placeholder.nextdnsProfileId}.dns.nextdns.io
      Domains=~.
      DNSOverTLS=${vars.nextdnsOverTLS}
      DNSSEC=yes
    '';
    restartUnits = [ "systemd-resolved.service" ];
  };

  networking = {
    networkmanager.dns = "systemd-resolved";
  };

  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        MulticastDNS = true;
      };
    };
  };
}
