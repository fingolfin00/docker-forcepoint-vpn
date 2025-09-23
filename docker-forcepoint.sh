#!/bin/bash

/etc/init.d/dbus start &
chown 104:105 /run/systemd/resolve &
/usr/lib/systemd/systemd-resolved &

/etc/init.d/ssh start &

forcepoint-client ${VPN_IPADDR} --certaccept --resolver /usr/bin/systemd-resolve --verbose --daemonize --user ${VPN_USERNAME} --password ${VPN_PASSWORD}${VPN_OTP}

# ip addr

docker-ubuntu-x_startup.sh apulse /usr/local/bin/firefox/firefox --no-remote -P default "${@}" &

bash
