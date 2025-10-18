{config, lib, ...}: let
  publicIP = "138.199.167.2";
  domain = lib.replaceStrings ["."] ["-"] publicIP;
  baseDomain = "${domain}.nip.io";

  grafanaDomain = "grafana.${baseDomain}";
  prometheusDomain = "prometheus.${baseDomain}";
in {
  # ACME configuration for Let's Encrypt
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@${baseDomain}"; # Change this to your email
  };

  # Nginx reverse proxy
  services.nginx = {
    enable = true;

    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts = {
      # Grafana with HTTPS
      "${grafanaDomain}" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
          proxyWebsockets = true;
        };
      };

      "${prometheusDomain}" = {
        forceSSL = true;
        enableACME = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.prometheus.port}";
        };
      };
    };
  };

  # Open HTTP and HTTPS ports
  networking.firewall.allowedTCPPorts = [
    80   # HTTP (needed for ACME challenge)
    443  # HTTPS
  ];
}
