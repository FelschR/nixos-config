{ config, pkgs, ... }:

with pkgs;

let
  mqttDomain = "mqtt.${config.networking.domain}";
  mqttWSPort = "9001";
in {
  # just installed for ConBee firmware updates
  environment.systemPackages = with pkgs; [ deconz ];

  services.nginx = {
    virtualHosts = {
      ${mqttDomain} = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${mqttWSPort}";
          proxyWebsockets = true;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.mosquitto.port ];

  services.mosquitto = {
    enable = true;
    host = "0.0.0.0";
    checkPasswords = true;
    extraConf = ''
      listener ${mqttWSPort}
      protocol websockets
    '';
    users = {
      "hass" = {
        acl = [
          "topic readwrite homeassistant/#"
          "topic readwrite tasmota/#"
          "topic readwrite owntracks/#"
        ];
        hashedPasswordFile = "/etc/nixos/secrets/mqtt/hass";
      };
      "tasmota" = {
        acl = [ "topic readwrite tasmota/#" "topic readwrite homeassistant/#" ];
        hashedPasswordFile = "/etc/nixos/secrets/mqtt/tasmota";
      };
      "owntracks" = {
        acl = [ "topic readwrite owntracks/#" ];
        hashedPasswordFile = "/etc/nixos/secrets/mqtt/owntracks";
      };
      "felix" = {
        acl = [ "topic read owntracks/#" "topic readwrite owntracks/felix/#" ];
        hashedPasswordFile = "/etc/nixos/secrets/mqtt/felix";
      };
      "birgit" = {
        acl = [ "topic read owntracks/#" "topic readwrite owntracks/birgit/#" ];
        hashedPasswordFile = "/etc/nixos/secrets/mqtt/birgit";
      };
    };
  };

  services.home-assistant = {
    enable = true;
    openFirewall = true;
    config = {
      homeassistant = {
        name = "Home";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        elevation = 0;
        unit_system = "metric";
        temperature_unit = "C";
        external_url = "https://home.felschr.com";
        internal_url = "http://192.168.1.234:8123";
      };
      default_config = { };
      config = { };
      "automation editor" = "!include automations.yaml";
      automation = { };
      frontend = { };
      mobile_app = { };
      discovery = { };
      zeroconf = { };
      ssdp = { };
      shopping_list = { };
      zha = {
        database_path = "/var/lib/hass/zigbee.db";
        zigpy_config = { ota = { ikea_provider = true; }; };
      };
      mqtt = {
        broker = "localhost";
        port = config.services.mosquitto.port;
        username = "hass";
        password = "!secret mqtt_password";
        discovery = true;
        discovery_prefix = "homeassistant";
      };
      owntracks = { mqtt_topic = "owntracks/#"; };
      netatmo = {
        client_id = "!secret netatmo_client_id";
        client_secret = "!secret netatmo_client_secret";
      };
      sensor = [{
        platform = "template";
        sensors = {
          energy_total_usage = {
            friendly_name = "Total Energy Usage";
            unit_of_measurement = "kWh";
            value_template = ''
              {{
                (states.sensor.outlet_computer_energy_total.state | float) +
                (states.sensor.outlet_tv_energy_total.state | float)
              }}
            '';
          };
        };
      }];
      utility_meter = {
        energy_total_usage_daily = {
          source = "sensor.energy_total_usage";
          cycle = "daily";
        };
        energy_total_usage_monthly = {
          source = "sensor.energy_total_usage";
          cycle = "monthly";
        };
        energy_total_usage_yearly = {
          source = "sensor.energy_total_usage";
          cycle = "yearly";
        };
      };
    };
    # configWritable = true; # doesn't work atm
  };
}
