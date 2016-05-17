#!/bin/bash
set -e
set -o pipefail

GW="$1" 
PORT="$2"
ROUTE="$3"

cat <<EOF > /etc/danted.conf
logoutput: syslog

# the interface name can be used instead of the address.
internal: 0.0.0.0 port = $PORT

external: $GW

# methods for socks-rules.
method: username none

#user.privileged: proxy
user.notprivileged: nobody

client pass {
  from: 0.0.0.0/0 port 1-65535 to: 0.0.0.0/0
  log: connect disconnect
}

pass {
  from: 0.0.0.0/0 to: $ROUTE
  protocol: tcp udp
}

block {
	from: 0.0.0.0/0 to: 0.0.0.0/0
	log: connect error
}
EOF

danted -D