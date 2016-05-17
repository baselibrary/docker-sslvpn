#!/bin/bash

#enable job control in script
set -e
set -o pipefail

#####   variables  ##### 
: ${SSH_PORT:=20022}
: ${SSH_CERT:=}
: ${SSH_PASS:=}
: ${VPN_TYPE:=}
: ${VPN_USER:=}
: ${VPN_PASS:=}
: ${VPN_ROUTE:=}
: ${AUTH_SEED:=}
: ${SOCK_PORT:=10080}

#run sslvpn in background
if [[ $# -lt 1 ]] || [[ "$1" == "-"* ]]; then
	## check the required parameters
	if [ -z "$VPN_TYPE" -o -z "$VPN_USER" ]; then
		echo >&2 'Error: vpn type and user option is not specified'
		exit 1
	fi

	## setting the ssh
	if [ "$AUTHORIZED_KEYS" -o "$SSH_PASS" ]; then
		if [ "$AUTHORIZED_KEYS" ]; then
    	/usr/bin/ansible local -o -c local -m authorized_key  -a "user=root key='${AUTHORIZED_KEYS}'"
  	fi
  	if [ "$SSH_PASS" ]; then
    	echo "root:$SSH_PASS" | chpasswd
  	fi
  	if [ "$SSH_PORT" ]; then
    	sed -i "s/Port.*/Port $SSH_PORT/g" /etc/ssh/sshd_config
  	fi
  	service ssh restart
	fi

	## setting the totp seed
  if [ "$AUTH_SEED" ]; then
    /usr/bin/ansible local -o -c local -m shell  -a "echo $AUTH_SEED > ~/.ga && chmod 0400 ~/.ga"
  fi

  ##### run scripts  #####
  echo "========================================================================"
  echo "startup: run expect                                                     "
  echo "========================================================================"
  if [ -f "/opt/sslvpn/$VPN_TYPE.exp" ]; then
  	while sleep 1; do
    	exec expect /opt/sslvpn/$VPN_TYPE.exp "$@"
  	done
  else 
  	echo "Unsupported vpn type"
  fi
else
  exec "$@"
fi
