#!/bin/bash

#enable job control in script
set -e
set -o pipefail

#####   variables  #####  
: ${SSLVPN_HOST:=58.56.174.4}
: ${SSLVPN_PORT:=10443}
: ${SSLVPN_USER:=01389079}
: ${SSLVPN_PASS:=WGD123456h}

#run CouchDB in background
if [ "$1" = 'expect' ]; then
  ##### run scripts  #####
  echo "========================================================================"
  echo "startup: run expect                                                     "
  echo "========================================================================"
  while sleep 1; do
    exec "$@" /opt/forticlient-sslvpn/config/fortisslvpn.exp
  done
else
  exec "$@"
fi
