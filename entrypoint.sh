#!/bin/bash
/etc/init.d/ssh restart

curl -o /opt/crx_url_list.txt https://pac-proxy.herokuapp.com/

echo 'acl crx_url url_regex -i "/opt/crx_url_list.txt"
acl localnet src 10.0.0.0/8 # RFC1918 possible internal network
acl localnet src 172.16.0.0/12  # RFC1918 possible internal network
acl localnet src 192.168.0.0/16 # RFC1918 possible internal network
acl localnet src fc00::/7       # RFC 4193 local private network range
acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines
acl SSL_ports port 443
acl Safe_ports port 80      # http
acl Safe_ports port 443     # https
acl Safe_ports port 1025-65535  # unregistered ports
acl CONNECT method CONNECT
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access deny manager
http_access deny to_localhost
http_access allow crx_url
http_access deny all
http_port 8888
cache_dir ufs /var/spool/squid 2048 16 256
coredump_dir /var/spool/squid
refresh_pattern .       0   20% 4320
via off
request_header_access X-Sogou-Auth deny all
request_header_access X-Sogou-Timestamp deny all
request_header_access X-Sogou-Tag deny all
request_header_access Server deny all
request_header_access WWW-Authenticate deny all
request_header_access All allow all
httpd_suppress_version_string on
visible_hostname localhost
forwarded_for transparent' > /etc/squid3/squid.conf

service squid3 start

/usr/bin/python /ssr/shadowsocks/server.py -s 0.0.0.0 -p 6080 -k china -m aes-256-cfb -O auth_sha1_v4 -o http_simple
