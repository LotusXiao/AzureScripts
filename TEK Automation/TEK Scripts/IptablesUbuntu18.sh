#!/bin/bash
#Script to persist IPtables rules for Ubuntu 18.04 LTS

# Set IPtables rules
sudo /sbin/iptables -A INPUT -p tcp --dport 80 -j DROP
sudo /sbin/iptables -I INPUT 1 -p tcp -s 10.0.1.4 --dport 80 -j ACCEPT
sudo /sbin/iptables-save > /etc/iptables.rules

# Persist IPtables rules for execution after reboot
echo 'sudo /sbin/iptables -A INPUT -p tcp --dport 80 -j DROP' > /etc/network/iptables
echo 'sudo /sbin/iptables -I INPUT 1 -p tcp -s 10.0.1.4 --dport 80 -j ACCEPT' >> /etc/network/iptables
echo 'sudo /sbin/iptables-save > /etc/iptables.rules' >> /etc/network/iptables

# Create service to apply rules on reboot
echo '[Unit]' > /etc/systemd/system/iptables-rules.service
echo 'Description = Persist IP tables rules after reboot' >> /etc/systemd/system/iptables-rules.service
echo '[Service]' >> /etc/systemd/system/iptables-rules.service
echo 'Type=oneshot' >> /etc/systemd/system/iptables-rules.service
echo 'ExecStart=/etc/network/iptables' >> /etc/systemd/system/iptables-rules.service
echo '[Install]' >> /etc/systemd/system/iptables-rules.service
echo 'WantedBy=network-pre.target' >> /etc/systemd/system/iptables-rules.service

# Enable created service
sudo systemctl enable iptables-rules.service
