#!/system/bin/sh
MODDIR=${0%/*}

set_ttl_65()
{
  echo 65 > /proc/sys/net/ipv4/ip_default_ttl
  echo 65 > /proc/sys/net/ipv6/conf/all/hop_limit
  echo 1 > /proc/sys/net/ipv4/ip_forward
  echo 1 > /proc/sys/net/ipv4/conf/all/forwarding
  echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
  echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
}
mark_traffic_ttl()
{  
   iptables -t mangle -A PREROUTING -i p2p0 -j TTL --ttl-set 65
   
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
   iptables -A FORWARD -i swlan0 -o tun0 -j ACCEPT
   
   iptables -A FORWARD -i tun0 -o swlan0 -m state --state ESTABLISHED,RELATED \
            -j ACCEPT
   iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
}
settings put global tether_dun_required 0

if [ -x "$(command -v iptables)" ]
then
	if [ `grep -q TTL /proc/net/ip_tables_targets` ]
	then
         iptables -t mangle -A PREROUTING -i p2p0 -j TTL --ttl-set 65
         
         iptables -t mangle -A PREROUTING -i v4-rmnet0 -j TTL --ttl-set 65
         
         iptables -t mangle -A PREROUTING -i rmnet0 -j TTL --ttl-set 65
         
         iptables -t mangle -A PREROUTING -i rmnet1 -j TTL --ttl-set 65
         
         iptables -t mangle -A PREROUTING -i ap0 -j TTL --ttl-set 65
         
         iptables -t mangle -A PREROUTING -i swlan0 -j TTL --ttl-set 65
         
         iptables -t mangle -A PREROUTING -i tun0 -j TTL --ttl-set 65
         
         iptables -t mangle -A PREROUTING -i ipv6_vti0 -j TTL --ttl-set 65
         
         iptables -t mangle -A PREROUTING -i rmnet_data0 -j TTL --ttl-set 65
         
         iptables -t mangle -A PREROUTING -i rmnet_data1 -j TTL --ttl-set 65
	else
		set_ttl_65
		mark_traffic_ttl
        route_hotspottraffic_tovpn
	fi
else
	set_ttl_65
fi
