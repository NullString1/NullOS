{ pkgs, config, vars, ... }:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ ];
    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
      "fs.suid_dumpable" = 0;
      "fs.protected_fifos" = 2;
      "fs.protected_regular" = 2;
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.perf_event_paranoid" = 3;
      "net.ipv4.ip_forward" = vars.enableIPForwarding;
      "net.ipv6.conf.all.forwarding" = vars.enableIPForwarding;
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "kernel.unprivileged_userns_clone" = 1;
    };
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 3;
    plymouth.enable = false;
  };
}
