{ config, pkgs, ... }:

{ 
  services.borgbackup.jobs.nixos = {
    paths = [ "/home" "/srv/private" "/srv/public" ];
    exclude = [ "/srv/public/media/nzb" "/srv/public/media/Twitch" ];
    encryption.mode = "none";
    repo = "ssh://root@meta/mnt/zbackup";
    compression = "zstd";
    startAt = "06:30";
    prune.keep = {
      within = "1d";
      daily = 7;
      weekly = 4;
      monthly = 1;
    };
    postHook = ''
      echo Subject: NixOS lokal Borg status > /tmp/borgmail
      borg info ssh://root@meta/mnt/zbackup >> /tmp/borgmail
      borg list ssh://root@meta/mnt/zbackup >> /tmp/borgmail
      cat /tmp/borgmail | ${pkgs.msmtp}/bin/msmtp MAIL
    '';
  };

  services.borgbackup.jobs.wirehole = {
    paths = [ "/srv/private/flower/k1024" "/srv/private/flower/Privat" "/srv/public/Bilder" "/srv/public/eBooks" ];
    encryption.mode = "repokey-blake2";
    encryption.passphrase = "PASS";
    repo = "ssh://root@HOST/srv/backup";
    compression = "zstd";
    startAt = "06:30";
    prune.keep = {
      within = "1d";
      daily = 7;
      weekly = 4;
      monthly = 1;
    };
    postHook = ''
      echo Subject: NixOS wirehole Borg status > /tmp/borgmail-wirehole
      borg info ssh://root@HOST/srv/backup >> /tmp/borgmail-wirehole
      borg list ssh://root@HOST/srv/backup >> /tmp/borgmail-wirehole
      cat /tmp/borgmail-wirehole | ${pkgs.msmtp}/bin/msmtp MAIL
    '';
  };

}
