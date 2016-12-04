#!/bin/sh

# clear iptables first
iptables --flush

# add china blacklist
# -------------------------------
if [ ! -f rc.firewall.china ]; then
	wget http://www.okean.com/antispam/iptables/rc.firewall.china
fi
sh rc.firewall.china
# -------------------------------
# configure natting 
public_int=$(ls -C /sys/class/net/ | awk '{ print $1}')
private_int=$(ls -C /sys/class/net/ | awk '{ print $2}')
iptables --table nat --flush
iptables --table nat --append POSTROUTING --out-interface $public_int -j MASQUERADE
iptables --append FORWARD --in-interface $private_int -j ACCEPT
