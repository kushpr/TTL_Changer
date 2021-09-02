#!/system/bin/sh
MODDIR=${0%/*}

set_ttl_65(){	
  echo 65 > /proc/sys/net/ipv4/ip_default_ttl
}

filter_interface(){	
  table="$1"
  int="$2"
  iptables -t filter -D OUTPUT -o "$int" -j $table
  iptables -t filter -D FORWARD -o "$int" -j $table
 	iptables -t filter -I OUTPUT -o "$int" -j $table
  iptables -t filter -I FORWARD -o "$int" -j $table
}

filter_ttl_65(){
  table="$1"
  if `grep -q ttl /proc/net/ip_tables_matches` ; then
    iptables -t filter -F $table
    iptables -t filter -N $table
    iptables -t filter -A $table -m ttl --ttl-lt 63 -j REJECT
    iptables -t filter -A $table -m ttl --ttl-eq 63 -j RETURN
    iptables -t filter -A $table -j CONNMARK --set-mark 64

    filter_interface $table 'dummy0' 
    filter_interface $table 'rmnet0'
    filter_interface $table 'rmnet1'
    filter_interface $table 'swlan0'
    filter_interface $table 'wlan0'
    filter_interface $table 'eth0'
    filter_interface $table 'lo'
    filter_interface $table 'tun0'
    
    ip rule add fwmark 64 table 164
    ip route add default dev lo table 164
    ip route flush cache
  fi
}

settings put global tether_dun_required 0

echo 65 > /proc/sys/net/ipv6/conf/all/hop_limit

if [ -x "$(command -v iptables)" ];then
  if `grep -q TTL /proc/net/ip_tables_targets` ; then
    iptables -t mangle -A POSTROUTING -j TTL --ttl-set 65
  else	
    set_ttl_65		filter_ttl_64 sort_out_interface	
  fi
else
  set_ttl_65
fi
