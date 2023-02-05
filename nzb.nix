{ config, pkgs, ... }:

{ 
  systemd.services.tor-socat-nzb = {
    path = with pkgs; [ socat ];
    description = "tor socat wrapper for nzb";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    script = ''
socat TCP4-LISTEN:10000,reuseaddr,fork,keepalive,bind=127.0.0.1 SOCKS4A:127.0.0.1:ONION.onion:80,socksport=9050
    '';
  };

  services.tor.enable = true;
  services.tor.openFirewall = true;
  services.tor.client.enable = true;

  services.sabnzbd.enable = true;
  services.sabnzbd.group = "data";
  services.sabnzbd.user = "flower";
  systemd.services.sabnzbd.preStart = "chown flower:data -R /var/lib/sabnzbd";
  systemd.services.sabnzbd.serviceConfig.PermissionsStartOnly = "true";

  system.activationScripts.sabnzbd = ''
    chown flower:data -R /var/lib/sabnzbd
  '';

  system.activationScripts.tor = ''
    ${pkgs.systemd}/bin/systemctl restart tor
  '';
}
