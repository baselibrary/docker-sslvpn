#! /bin/bash

export PATH=/sbin:/usr/sbin:/bin:/usr/bin

base=`dirname "$0"`
echo "begin cleanup linux..." >> "$base/forticlientsslvpn.log"
if [ -f "$base/resolv.conf.backup" ]; then
	echo "restore /etc/resolv.conf" >> "$base/forticlientsslvpn.log"
	mv -f "$base/resolv.conf.backup" /etc/resolv.conf
fi

echo "clean up route..." >> "$base/forticlientsslvpn.log"
if [ -f "$base/forticlientsslvpn.cleanup.tmp" ]; then
	source "$base/forticlientsslvpn.cleanup.tmp"
	rm -f "$base/forticlientsslvpn.cleanup.tmp"
fi

if [ -f "$base/pppd.log" ]; then
	echo "truncate pppd.log" >> "$base/forticlientsslvpn.log"
	tlog=`tail -n 300 "$base/pppd.log"`
	echo "$tlog" > "$base/pppd.log"
fi

if [ -f "$base/forticlientsslvpn.log" ]; then
	echo "truncate forticlientsslvpn.log" >> "$base/forticlientsslvpn.log"
	tlog=`tail -n 30000 "$base/forticlientsslvpn.log"`
	echo "$tlog" > "$base/forticlientsslvpn.log"
fi
