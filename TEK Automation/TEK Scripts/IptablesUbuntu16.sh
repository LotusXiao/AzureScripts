#!/bin/bash
#Script to persist IPtables rules for Ubuntu 16.04 LTS

sudo /sbin/iptables -A INPUT -p tcp --dport 80 -j DROP
sudo /sbin/iptables -I INPUT 1 -p tcp -s 10.0.1.4 --dport 80 -j ACCEPT
sudo /sbin/iptables-save > /etc/iptables.rules

echo '#!/bin/sh' > /etc/network/if-pre-up.d/iptablesload
echo 'iptables-restore < /etc/iptables.rules' >> /etc/network/if-pre-up.d/iptablesload
echo 'exit 0' >> /etc/network/if-pre-up.d/iptablesload
chmod +x /etc/network/if-pre-up.d/iptablesload
