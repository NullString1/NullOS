{
  pkgs,
  lib,
  config,
  vars,
  ...
}:
let
  genCertsScript = pkgs.writeShellScript "wayvnc-gen-certs" ''
    export CONFIG_DIR="$XDG_CONFIG_HOME/wayvnc"
    mkdir -p "$CONFIG_DIR"
    cd "$CONFIG_DIR"

    if [ ! -f rsa_key.pem ]; then
      echo "Generating wayvnc RSA private key..."
      ${pkgs.openssl}/bin/openssl genrsa -traditional -out rsa_key.pem 2048
      chmod 600 rsa_key.pem
    fi

    if [ ! -f tls_key.pem ] || [ ! -f tls_cert.pem ]; then
      echo "Generating wayvnc TLS certificate and private key..."
      ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:2048 \
        -keyout tls_key.pem -out tls_cert.pem \
        -days 3650 -nodes -subj "/CN=${vars.hostname}" \
        -addext "subjectAltName = DNS:localhost,DNS:${vars.hostname},IP:127.0.0.1"
      chmod 600 tls_key.pem tls_cert.pem
    fi
  '';
in
{
  services.wayvnc = {
    enable = true;
    autoStart = true;
    settings = {
      address = "0.0.0.0";
      port = 5900;
      enable_auth = true;
      enable_pam = true;
      rsa_private_key_file = "${config.xdg.configHome}/wayvnc/rsa_key.pem";
      private_key_file = "${config.xdg.configHome}/wayvnc/tls_key.pem";
      certificate_file = "${config.xdg.configHome}/wayvnc/tls_cert.pem";
    };
  };
  systemd.user.services.wayvnc = {
    Service = {
      Restart = "always";
      ExecStart = lib.mkForce "${pkgs.wayvnc}/bin/wayvnc -r -g";
      ExecStartPre = genCertsScript;
    };
  };
}
