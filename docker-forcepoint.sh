#!/bin/bash

/etc/init.d/dbus start &
chown 104:105 /run/systemd/resolve &
/usr/lib/systemd/systemd-resolved &

/etc/init.d/ssh start &

forcepoint-client ${VPN_IPADDR} --certaccept --resolver /usr/bin/systemd-resolve --verbose --daemonize --user ${VPN_USERNAME} --password ${VPN_PASSWORD}${VPN_OTP}

# openssl s_client -showcerts -connect ipa-ca.idm.cmcc.scc:443 </dev/null 2>/dev/null|openssl x509 -outform PEM >/usr/local/share/ca-certificates/cmcc.crt
# update-ca-certificates

export KRB5CCNAME=FILE:/tmp/krb5cc_`id -u`
kinit -n
kinit -T FILE:/tmp/krb5cc_`id -u` ${VPN_USERNAME}

# ip addr

docker-ubuntu-x_startup.sh apulse /usr/local/bin/firefox/firefox --no-remote -P default "${@}" &

bash
