#!/bin/bash

#enable job control in script
set -e
set -o pipefail

#####   variables  ##### 
: ${SSH_PASS:=}
: ${VPN_TYPE:=}
: ${VPN_USER:=}
: ${VPN_PASS:=}
: ${TOTP_SEED:=}

#run sslvpn in background
if [[ $# -lt 1 ]] || [[ "$1" == "-"* ]]; then
	## check the required parameters
	if [ -z "$VPN_TYPE" -z "$VPN_USER" ]; then
		echo >&2 'Error: vpn type and user option is not specified'
		exit 1
	fi

	## setting the ssh
	if [ "$AUTHORIZED_KEYS" -a "$SSH_PASS" ]; then
		if [ "$AUTHORIZED_KEYS" ]; then
    	/usr/bin/ansible local -o -c local -m authorized_key  -a "user=root key='${AUTHORIZED_KEYS}'"
  	fi
  	if [ "$SSH_PASS" ]; then
    	echo "root:$SSH_PASS" | chpasswd
  	fi
  	service ssh restart
	fi

	## setting the totp seed
  if [ "$TOTP_SEED" ]; then
    /usr/bin/ansible local -o -c local -m shell  -a "echo $TOTP_SEED > ~/.ga && chmod 0400 ~/.ga"
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
