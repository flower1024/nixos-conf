{ config, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.allowedBridges = [ "br0" ];

  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;
  virtualisation.docker.storageDriver = "zfs";
  virtualisation.docker.autoPrune.enable = true;
  virtualisation.oci-containers.backend = "docker";

  virtualisation.docker.daemon.settings = {
    storage-opts = [ "zfs.fsname=zroot/DOCKER" ];
  };

  virtualisation.oci-containers.containers.emby = {
    image = "emby/embyserver:latest";
    ports = ["8096:8096"];

    volumes = [
      "/srv/public:/data"
      "/srv/config/emby:/config"
    ];

    environment = {
      UID = "995";
      GID = "994";
    };

    extraOptions = [
      "--device" "/dev/dri:/dev/dri"
      "--network=host"
      "--runtime=nvidia"
    ];
  };

  systemd.services.docker-pullall = {
    startAt = "05:00";
    path = with pkgs; [ docker ];
    description = "pull docker containers";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    script = 
      ''
        systemctl stop docker-emby

        for image in $(docker images --format "{{.Repository}}"); do docker pull $image; done

        systemctl start docker-emby

        docker system prune -af
        docker image prune -af
      '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

}
