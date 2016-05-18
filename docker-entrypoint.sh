#!/bin/bash

#enable job control in script
set -e
set -o pipefail

#####   variables  #####
VPN_TYPE=${VPN_TYPE:=openvpn}
VPN_USER=${VPN_USER:=}
VPN_PASS=${VPN_PASS:=}
VPN_SEED=${VPN_SEED:=}
VPN_ROUTE=${VPN_ROUTE:=}
SSH_PORT=${SSH_PORT:=20022}
SSH_PASS=${SSH_PASS:=}
SOCK_USER=${SOCK_USER:=sock}
SOCK_PASS=${SOCK_PASS:=sock}
SOCK_PORT=${SOCK_PORT:=10080}



#run sslvpn in background
if [[ $# -lt 1 ]] || [[ "$1" == "-"* ]]; then
  ## check the required parameters
  if [ -z "$VPN_TYPE" -o -z "$VPN_HOST" -o -z "$VPN_PORT" -o -z "$VPN_USER" ]; then
    echo >&2 'Error: vpn option is not specified'
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
  fi

  ## setting the totp seed
  if [ "$VPN_SEED" ]; then
    /usr/bin/ansible local -o -c local -m shell  -a "echo $VPN_SEED > ~/.ga && chmod 0400 ~/.ga"
  fi

  ##### run scripts  #####
  echo "========================================================================"
  echo "startup: run expect                                                     "
  echo "========================================================================"
  confd -onetime -backend=env -confdir=/opt/sslvpn/conf -config-file=/opt/sslvpn/conf/conf.d/$VPN_TYPE.toml

  exec supervisord -c /opt/sslvpn/conf/supervisord.conf
else
  exec "$@"
fi
