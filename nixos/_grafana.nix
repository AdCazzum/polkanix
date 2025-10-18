{config, ...}: {
  # Prometheus - monitoring system and time series database
  services.prometheus = {
    enable = true;
    port = 9090;

    scrapeConfigs = [
      {
        job_name = "polkadot-validator";
        scrape_interval = "15s";
        static_configs = [{
          targets = ["localhost:${toString config.dotnix.polkadot-validator.prometheusPort}"];
        }];
      }
      {
        job_name = "prometheus";
        scrape_interval = "15s";
        static_configs = [{
          targets = ["localhost:9090"];
        }];
      }
    ];
  };

  # Grafana - visualization and analytics platform
  services.grafana = {
    enable = true;

    settings = {
      server = {
        http_addr = "127.0.0.1"; # Only listen on localhost, nginx will proxy
        http_port = 3000;
        domain = "grafana.138-199-167-2.nip.io";
        root_url = "https://grafana.138-199-167-2.nip.io";
        serve_from_sub_path = false;
        enforce_domain = false;
      };

      analytics = {
        reporting_enabled = false;
      };

      security = {
        admin_user = "admin";
        admin_password = "admin"; # Grafana will prompt you to change this on first login
      };
    };

    # Datasource configuration
    provision = {
      enable = true;

      datasources.settings.datasources = [{
        name = "Prometheus";
        type = "prometheus";
        access = "proxy";
        url = "http://localhost:${toString config.services.prometheus.port}";
        isDefault = true;
        jsonData = {
          timeInterval = "15s";
        };
      }];
    };
  };

  # Grafana and Prometheus are now only accessible via nginx reverse proxy
  # No direct firewall ports needed
}
