#!/system/bin/sh
MODDIR=${0%/*}

 set_ttl_65()
{
  echo 65 > /proc/sys/net/ipv4/ip_default_ttl
  echo 65 > /proc/sys/net/ipv6/conf/all/hop_limit
  echo 65 > /proc/sys/net/ipv6/conf/ip6_vti0/hop_limit
  echo 1 > /proc/sys/net/ipv4/ip_forward 
}
mark_traffic_ttl()
{  
   iptables -t mangle -A PREROUTING -i v4-rmnet0 -j TTL --ttl-set 65
   iptables -t mangle -A PREROUTING -i rmnet0 -j TTL --ttl-set 65
   iptables -t mangle -A PREROUTING -i rmnet1 -j TTL --ttl-set 65
   iptables -t mangle -A PREROUTING -i ap0 -j TTL --ttl-set 65
   iptables -t mangle -A PREROUTING -i swlan0 -j TTL --ttl-set 65
   iptables -t mangle -A PREROUTING -i tun0 -j TTL --ttl-set 65
   iptables -t mangle -A PREROUTING -i ipv6_vti0 -j TTL --ttl-set 65
   iptables -t mangle -A PREROUTING -i rmnet_data0 -j TTL --ttl-set 65
   iptables -t mangle -A PREROUTING -i rmnet_data1 -j TTL --ttl-set 65
}
route_hotspottraffic_tovpn()
{
 iptables -t nat -I POSTROUTING 1 -o tun0 -j MASQUERADE
 iptables -I FORWARD 1 -i tun0 -o swlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 
 iptables -I FORWARD 1 -i swlan0 -o tun0 -j ACCEPT
}
settings put global tether_dun_required 0

if [ -x "$(command -v iptables)" ]
then
	if grep -q TTL /proc/net/ip_tables_targets
	then
		iptables -t mangle -A PREROUTING -i rmnet0 -j TTL --ttl-set 65
        iptables -t mangle -A PREROUTING -i rmnet1 -j TTL --ttl-set 65
        iptables -t mangle -A PREROUTING -i rmnet_data0 -j TTL --ttl-set 65
        iptables -t mangle -A PREROUTING -i swlan0 -j TTL --ttl-set 65
        iptables -t mangle -A PREROUTING -i tun0 -j TTL --ttl-set 65
	else
		set_ttl_65
		mark_traffic_ttl
        route_hotspottraffic_tovpn
	fi
else
	set_ttl_65
fi
