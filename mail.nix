{ config, pkgs, ... }:

{ 

  programs.msmtp.enable = true;
  programs.msmtp.setSendmail = true;
  programs.msmtp.defaults = {
    aliases = "/etc/aliases";
    port = 587;
    tls = true;
  };
  programs.msmtp.accounts.default = {
    auth = true;
    host = "MAILSERVER";
    password = "PASS";
    user = "MAIL";
    domain = "MAILDOMAIN";
    from = "MAILFROM";
  };

  services.zfs.zed.enableMail = true;
  nixpkgs.config.packageOverrides = pkgs: {
    zfsStable = pkgs.zfsStable.override { enableMail = true; };
  };
  services.zfs.zed.settings = {
    ZED_DEBUG_LOG = "/tmp/zed.debug.log";

    ZED_EMAIL_ADDR = [ "MAIL" ];
    ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
    ZED_EMAIL_OPTS = "@ADDRESS@";

    ZED_NOTIFY_INTERVAL_SECS = 3600;
    ZED_NOTIFY_VERBOSE = true;

    ZED_USE_ENCLOSURE_LEDS = true;
    ZED_SCRUB_AFTER_RESILVER = true;
  };

  # SMARTMON
  services.smartd.enable = true;
  services.smartd.notifications.mail.enable = true;
  services.smartd.notifications.mail.recipient = "MAIL";
  services.smartd.notifications.mail.sender = "MAIL";
  services.smartd.notifications.mail.mailer = "/run/wrappers/bin/sendmail";

}
