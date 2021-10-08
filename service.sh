#!/system/bin/sh
MODDIR=${0%/*}

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
        iptables -t mangle -A PREROUTING -i ap0 -j TTL --ttl-set 65
  
        iptables -t mangle -A PREROUTING -i dummy0 -j TTL --ttl-set 65

        iptables -t mangle -A PREROUTING -i eth0 -j TTL --ttl-set 65

        iptables -t mangle -A PREROUTING -i lo -j TTL --ttl-set 65
  
        iptables -t mangle -A PREROUTING -i p2p0 -j TTL --ttl-set 65
  
        iptables -t mangle -A PREROUTING -i rmnet0 -j TTL --ttl-set 65
  
        iptables -t mangle -A PREROUTING -i rmnet1 -j TTL --ttl-set 65
   
        iptables -t mangle -A PREROUTING -i rmnet_data0 -j TTL --ttl-set 65
   
        iptables -t mangle -A PREROUTING -i rmnet_data1 -j TTL --ttl-set 65
  
        iptables -t mangle -A PREROUTING -i rmnet_data2 -j TTL --ttl-set 65
  
        iptables -t mangle -A PREROUTING -i rmnet_ipa0 -j TTL --ttl-set 65  
  
        iptables -t mangle -A PREROUTING -i rmnet_mhi0 -j TTL --ttl-set 65  
  
        iptables -t mangle -A PREROUTING -i rndis0 -j TTL --ttl-set 65
  
        iptables -t mangle -A PREROUTING -i swlan0 -j TTL --ttl-set 65
  
        iptables -t mangle -A PREROUTING -i tun0 -j TTL --ttl-set 65
  
        iptables -t mangle -A PREROUTING -i usb0 -j TTL --ttl-set 65


settings put global tether_dun_required 0

if [ -x "$(command -v iptables)" ]
then
	if [ `grep -q TTL /proc/net/ip_tables_targets` ]
	then
	    iptables -t mangle -A POSTROUTING -i ap0 -j TTL --ttl-set 65
	 
        iptables -t mangle -A POSTROUTING -i dummy0 -j TTL --ttl-set 65
  
        iptables -t mangle -A POSTROUTING -i eth0 -j TTL --ttl-set 65
  
        iptables -t mangle -A POSTROUTING -i lo -j TTL --ttl-set 65
  
        iptables -t mangle -A POSTROUTING -i p2p0 -j TTL --ttl-set 65
  
        iptables -t mangle -A POSTROUTING -i rmnet0 -j TTL --ttl-set 65
  
        iptables -t mangle -A POSTROUTING -i rmnet1 -j TTL --ttl-set 65  
  
        iptables -t mangle -A POSTROUTING -i rmnet_data0 -j TTL --ttl-set 65
  
        iptables -t mangle -A POSTROUTING -i rmnet_data1 -j TTL --ttl-set 65 
  
        iptables -t mangle -A POSTROUTING -i rmnet_data2 -j TTL --ttl-set 65
  
        iptables -t mangle -A POSTROUTING -i rmnet_ipa0 -j TTL --ttl-set 65      
  
        iptables -t mangle -A POSTROUTING -i rmnet_mhi0 -j TTL --ttl-set 65        
  
        iptables -t mangle -A POSTROUTING -i rndis0 -j TTL --ttl-set 65
  
        iptables -t mangle -A POSTROUTING -i swlan0 -j TTL --ttl-set 65
  
        iptables -t mangle -A POSTROUTING -i tun0 -j TTL --ttl-set 65  
  
        iptables -t mangle -A POSTROUTING -i usb0 -j TTL --ttl-set 65     
	else
		set_ttl_65
		mark_traffic_ttl
	fi
else
	set_ttl_65
fi
