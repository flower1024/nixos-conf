{ config, pkgs, ... }:

{ 
  systemd.services.duckdns = {
    startAt = "*:0/5";
    path = with pkgs; [ curl utillinux ];
    description = "duckdns domain update";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    script = ''
DOMAINS=Domain List
TOKEN=Doken

IP4=$(curl "http://fritz.box:49000/igdupnp/control/WANIPConn1" -H "Content-Type: text/xml; charset="utf-8"" -H "SoapAction:urn:schemas-upnp-org:service:WANIPConnection:1#GetExternalIPAddress" -d "<?xml version='1.0' encoding='utf-8'?> <s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'> <s:Body> <u:GetExternalIPAddress xmlns:u='urn:schemas-upnp-org:service:WANIPConnection:1' /> </s:Body> </s:Envelope>" -s | grep -Eo '\<[[:digit:]]{1,3}(\.[[:digit:]]{1,3}){3}\>')
IP6=$(curl "http://fritz.box:49000/igdupnp/control/WANIPConn1" -H "Content-Type: text/xml; charset="utf-8"" -H "SoapAction:urn:schemas-upnp-org:service:WANIPConnection:1#X_AVM_DE_GetExternalIPv6Address" -d "<?xml version='1.0' encoding='utf-8'?> <s:Envelope s:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/' xmlns:s='http://schemas.xmlsoap.org/soap/envelope/'> <s:Body> <u:GetExternalIPAddress xmlns:u='urn:schemas-upnp-org:service:WANIPConnection:1' /> </s:Body> </s:Envelope>" -s | grep  -Eo '<NewExternalIPv6Address>.*</NewExternalIPv6Address>' | cut -c 25- | rev | cut -c 26- | rev)

URL=

if [ "$IP6" = "" ]
then
    URL="https://www.duckdns.org/update?domains=$DOMAINS&token=$TOKEN&ip=$IP4"
else
    URL="https://www.duckdns.org/update?domains=$DOMAINS&token=$TOKEN&ip=$IP4&ipv6=$IP6"
fi

echo -n "Connecting: $URL "
curl $URL > /dev/null 2>&1 \
    && echo OK \
    || echo FAILED
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };    
}
