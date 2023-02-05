{ config, pkgs, ... }:

 
  let
    mkTwitchRecorder = twitch: {
      path = with pkgs; [ streamlink ];
      description = "record twitch stream ${twitch}";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        User = "flower";
        Group = "data";
      };
      script = ''
while true; do
    streamlink -l warning --twitch-disable-hosting --twitch-disable-ads --twitch-disable-reruns twitch.tv/${twitch} best -o "/srv/public/media/Twitch/$(date "+%Y")-$(date "+%m")-$(date "+%d") $(date "+%H"):$(date "+%M")-${twitch}.ts" > /dev/null 2>&1 || echo > /dev/null
    sleep 15
done
      '';
    };
  in
  {
    systemd.services.twitch-linustech = mkTwitchRecorder "linustech";
    systemd.services.twitch-gronkh = mkTwitchRecorder "gronkh";
  }

