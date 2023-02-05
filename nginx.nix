{ config, pkgs, ... }:

{ 
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "MAIL";
  services.nginx = {
    enable = true;
    group = "data";
    recommendedOptimisation = true;
    additionalModules = [ pkgs.nginxModules.subsFilter ];
    commonHttpConfig = ''

      proxy_redirect off;
      proxy_buffering off;
      aio threads;
      directio 16M;
      output_buffers 2 1M;

      sendfile_max_chunk 512k;

    '';

    upstreams.nzb.servers = { "127.0.0.1:10000" = { }; };
    upstreams.sab.servers = { "127.0.0.1:8082" = { }; };
    upstreams.emby.servers = { "127.0.0.1:8096" = { }; };

    virtualHosts = {

      "DOMAIN.duckdns.org" = {
        forceSSL = true;
        enableACME = true;
        basicAuth = {
          flower = "PASS";
        };
        extraConfig = ''
          proxy_redirect          http://ONIONURL/ /;
          proxy_set_header        Host            $host;
          proxy_set_header        X-Real-IP       $remote_addr;
          proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
          client_max_body_size    10m;
          client_body_buffer_size 128k;
          proxy_connect_timeout   90;
          proxy_send_timeout      90;
          proxy_read_timeout      90;
          proxy_buffers           32 4k;
        '';
        locations."/" = {
          proxyPass = "http://nzb";
        };
      };

      "DOMAIN.duckdns.org" = {
        forceSSL = true;
        enableACME = true;
        basicAuth = {
          flower = "PASS";
        };
        extraConfig = ''
          proxy_redirect          http://localhost:8082/ /;
          proxy_set_header        Host            $host;
          proxy_set_header        X-Real-IP       $remote_addr;
          proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
          client_max_body_size    10m;
          client_body_buffer_size 128k;
          proxy_connect_timeout   90;
          proxy_send_timeout      90;
          proxy_read_timeout      90;
          proxy_buffers           32 4k;
        '';
        locations."/" = {
          proxyPass = "http://sab";
        };
      };
      "DOMAIN.duckdns.org" = {
        forceSSL = true;
        enableACME = true;
        basicAuth = {
          flower = "PASS";
          aileen = "PASS";
        };
        extraConfig = ''
          proxy_redirect          http://localhost:8096/ /;
          proxy_set_header        Host            $host;
          proxy_set_header        X-Real-IP       $remote_addr;
          proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
          client_max_body_size    10m;
          client_body_buffer_size 128k;
          proxy_connect_timeout   90;
          proxy_send_timeout      90;
          proxy_read_timeout      90;
          proxy_buffers           32 4k;
        '';
        locations."/" = {
          proxyPass = "http://emby";
        };
      };
    };
  };
}
