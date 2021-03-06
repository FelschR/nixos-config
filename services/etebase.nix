{ config, pkgs, ... }:

let etebaseHost = "etebase.felschr.com";
in {
  services.etebase-server.enable = true;
  services.etebase-server.openFirewall = true;
  services.etebase-server.settings = {
    global = { secret_file = "/etc/nixos/secrets/etebase-server"; };
    allowed_hosts = { allowed_host1 = etebaseHost; };
  };

  services.nginx = {
    virtualHosts."${etebaseHost}" = {
      enableACME = true;
      forceSSL = true;
      locations."/".proxyPass = "http://localhost:8001";
    };
  };
}
