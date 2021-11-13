#!/system/bin/sh
sleep 15

set_ttl_65()
{
  echo 65 > /proc/sys/net/ipv4/ip_default_ttl
  echo 65 > /proc/sys/net/ipv6/conf/all/hop_limit
  echo 1 > /proc/sys/net/ipv4/ip_forward
  echo 1 > /proc/sys/net/ipv4/conf/all/forwarding
  echo 1 > /proc/sys/net/ipv4/ip_dynaddr
  echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
}
mark_traffic_ttl()
{  
for i in $(ifconfig -a | sed 's/[ \t].*//;/^$/d'); do (iptables -t mangle -A PREROUTING -i $i -j TTL --ttl-set 65); done
}
settings put global tether_dun_required 0
    
settings put system tether_entitlement_check_state 0

if [ -x "$(command -v iptables)" ]
then
	if [ $(grep -q TTL /proc/net/ip_tables_targets) ]
	then
		for i in $(ifconfig -a | sed 's/[ \t].*//;/^$/d'); do (iptables -t mangle -A POSTROUTING -i $i -j TTL --ttl-set 65); done
	else
	set_ttl_65
	mark_traffic_ttl
	fi
else
	set_ttl_65
fi
