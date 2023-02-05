{ config, pkgs, ... }:

{ 
  # SAMBA
  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  services.samba = {
    enable = true;
    securityType = "user";
    
    openFirewall = true;
    # You will still need to set up the user accounts to begin with:
    # $ sudo smbpasswd -a yourusername

    # This adds to the [global] section:
    extraConfig = ''
      browseable = yes
      workgroup = k1024
      server string = nixos
      netbios name = nixos
      security = user 
      hosts allow = 192.168.178.0/16 127.0.0.1 localhost
      hosts deny = 0.0.0.0/0
      guest account = nobody
      map to guest = bad user
      server role = standalone
      logging = systemd
      follow symlinks = yes
      load printers = no
      printing = bsd
      printcap name = /dev/null
      disable spoolss = yes
      strict locking = no
      aio read size = 0
      aio write size = 0
      vfs objects = catia streams_xattr
      mangled names = no
      catia:mappings = 0x22:0xa8,0x2a:0xa4,0x2f:0xf8,0x3a:0xf7,0x3c:0xab,0x3e:0xbb,0x3f:0xbf,0x5c:0xff,0x7c:0xa6

      # Security
      client ipc max protocol = SMB3
      client ipc min protocol = SMB2_10
      client max protocol = SMB3
      client min protocol = SMB2_10
      server max protocol = SMB3
      server min protocol = SMB2_10      

      create mask = 666
      force create mode = 666
      security mask = 666
      force security mode = 666

      directory mask = 2777
      force directory mode = 2777
      directory security mask = 2777
      force directory security mode = 2777
    '';

    shares = {
      public = {
        path = "/srv/public";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "write list" = "flower";
      };
      flower = {
        path = "/srv/private/flower";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "flower";
      };
      aileen = {
        path = "/srv/private/aileen";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "aileen";
      };

    };
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
        </service-group>
      '';
    };
  };
}
