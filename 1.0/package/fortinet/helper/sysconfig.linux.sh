#! /bin/bash

export PATH=/sbin:/usr/sbin:/bin:/usr/bin
export LANGUAGE=en_US.utf8

base=`dirname "$0"`
echo "begin sysconfig linux" >> "$base/forticlientsslvpn.log"

echo -n "Generating pppd.resolv.conf..." >> "$base/forticlientsslvpn.log"

ifup=0
while [ "$ifup" == "0" ]; do
	sleep 1
	logstat=`awk '
	/^Connect:/	{
		dns1 = "";
		dns2 = "";
		up = 0;
		}
	/^local/	{
		up = 1;
		}
	/^primary/	{
		dns1 = $4;
		}
	/^secondary/	{
		dns2 = $4;
		}
	END		{
		print dns1 ":" dns2 ":" up
	}' "$base/pppd.log"`

	dns1=`echo $logstat|awk -F : ' {print $1 }'`
	dns2=`echo $logstat|awk -F : ' {print $2 }'`
	ifup=`echo $logstat|awk -F : ' {print $3 }'`
done

if [ "x$dns1" != "x" ]; then
	echo "nameserver	$dns1" > "$base/pppd.resolv.conf"
fi

if [ "x$dns1" == "x$dns2" ]; then
	dns2=""
fi

if [ "x$dns2" != "x" ]; then
	echo "nameserver	$dns2" >> "$base/pppd.resolv.conf"
fi

echo "Done" >> "$base/forticlientsslvpn.log"

if [ -f "$base/pppd.resolv.conf" ]; then
	cat "$base/pppd.resolv.conf" >> "$base/forticlientsslvpn.log"
	cat "$base/pppd.resolv.conf" "$base/resolv.conf.backup" > /etc/resolv.conf
	rm -f "$base/pppd.resolv.conf"
fi

source "$base/forticlientsslvpn.backup.tmp"
rm -f "$base/forticlientsslvpn.backup.tmp"

echo "server route $svrt" >> "$base/forticlientsslvpn.log"
ifn=`route -n|grep "^1.1.1.1"|awk '{print $8}'`
echo "interface $ifn" >> "$base/forticlientsslvpn.log"

addr=`ip addr show $ifn | grep "inet" | tr '/' ' ' | awk '{ print $2 }'`
echo "address $addr" >> "$base/forticlientsslvpn.log"

echo "delete route 1.1.1.1" >> "$base/forticlientsslvpn.log"
route -n del 1.1.1.1 >> "$base/forticlientsslvpn.log"

rm -f "$base/forticlientsslvpn.cleanup.tmp"
touch "$base/forticlientsslvpn.cleanup.tmp"
chown root "$base/forticlientsslvpn.cleanup.tmp"
chgrp root "$base/forticlientsslvpn.cleanup.tmp"
chmod a-w "$base/forticlientsslvpn.cleanup.tmp"
if [ $1 == 1.1.1.1 ]; then
	if [ "$specialgw" != "" ]; then
		echo "Add the route for 1.1.1.1($specialgw)" >> "$base/forticlientsslvpn.log"
		route -n add 1.1.1.1 gw $specialgw >> "$base/forticlientsslvpn.log"
		if [ $specialhasrd == 0 ]; then
			echo "route -n del 1.1.1.1" >> "$base/forticlientsslvpn.cleanup.tmp"
		fi
	fi
else
	if [ $svrhasrd == 1 ]; then
		echo "route to $1 already OK" >> "$base/forticlientsslvpn.log"
	else if [ "$svrgw" != "" ]; then
		echo "Add route for $1($svrgw)" >> "$base/forticlientsslvpn.log"
		route -n add $1 gw $svrgw >> "$base/forticlientsslvpn.log"
		echo "route -n del $1" >> "$base/forticlientsslvpn.cleanup.tmp"
		fi
	fi
fi

if [ "$2" == "0" ]; then
	echo "router $addr server route $svrt" >> "$base/forticlientsslvpn.log"
	echo "route -n add default gw $addr" >> "$base/forticlientsslvpn.log"
	route -n add default gw $addr >> "$base/forticlientsslvpn.log"
	
	#the following code is used to handle exclusive routing
	#when exclusive routing is enabled.
	if [ "$3" = "1" ]; then
		
		#get the interface through which to gateway
		outinf=`ip route get $svrgw | awk -F " dev " '{ print $2 }' | awk '{ print $1}'`
		
		routes=`route -n | tr "\n" ";"`

		declare -i n1=0
		OIFS=$IFS
		IFS=';'
		for x in $routes
		do
			if [ $n1 -gt 1 ]; then
				arrRoutes[$n1]=$x
			fi
			n1=n1+1
		done
		IFS=$OIFS

		declare -i n2=0
		for i in "${arrRoutes[@]}"; do
			n2=0
			for x in $i
			do
				cols[$n2]=$x
				n2=n2+1
			done
			if [ ${cols[0]} != "0.0.0.0" ] && [ ${cols[0]} != "$1" ] ; then
				echo "route -n add -net ${cols[0]} netmask ${cols[2]} dev ppp0" >> "$base/forticlientsslvpn.log"
				route -n add -net ${cols[0]} netmask ${cols[2]} dev ppp0
				route -n del -net ${cols[0]} netmask ${cols[2]} dev ${cols[7]}
				let metric=${cols[4]}
				route -n add -net ${cols[0]} netmask ${cols[2]} metric $((metric+10)) dev ${cols[7]} 
				echo "route -n del -net ${cols[0]} netmask ${cols[2]} dev ${cols[7]}" >> "$base/forticlientsslvpn.cleanup.tmp"
				echo "route -n add -net ${cols[0]} netmask ${cols[2]} metric $((metric)) dev ${cols[7]}" >> "$base/forticlientsslvpn.cleanup.tmp"
			fi
		done
	
		#have to add a route to server's gateway, without it tunnel can run for some seconds
		#then server becomes unreachable.
		if [ "$svrgw" != "" ]; then
			route -n add -host $svrgw  dev $outinf
			echo "route -n del $svrgw" >> "$base/forticlientsslvpn.cleanup.tmp"
		fi
	fi
fi

tuns=`echo $2|sed s/,/\ /g`
if [ "$2" != "0" ]; then
	for tun in $tuns;
	do
		tund=`echo $tun|awk -F / ' {print $1}'`
		tunm=`echo $tun|awk -F / ' {print $2}'`
		if [ $tund != "0.0.0.0" ]; then
			echo "route -n add -net $tund netmask $tunm gw $addr" >> "$base/forticlientsslvpn.log"
			route -n add -net $tund netmask $tunm gw $addr >>"$base/forticlientsslvpn.log" 2>&1
		fi
	done
fi
