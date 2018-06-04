#### 适用于Zabbix-Agent


```
#bin/bash
#20170926
iptables -F
iptables -X

iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

iptables -A INPUT -s 192.168.4.0/24 -m multiport -p tcp --dport 22,80,443 -j ACCEPT
iptables -A INPUT -s 192.168.5.0/24 -m multiport -p tcp --dport 22,80,443 -j ACCEPT
iptables -A INPUT -p tcp --dport 10050 -j ACCEPT
iptables -A INPUT -p tcp --sport 10051 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -I INPUT -p udp --sport 123 -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -p all -j ACCEPT

iptables -A FORWARD -f -m limit --limit 100/s --limit-burst 100 -j ACCEPT
iptables -A FORWARD -p icmp -m limit --limit 1/s --limit-burst 10 -j ACCEPT
iptables -A FORWARD -m state --state INVALID -j DROP

iptables -A OUTPUT -p tcp --sport 31337 -j DROP
iptables -A OUTPUT -p tcp --dport 31337 -j DROP
iptables -A OUTPUT -p tcp --sport 31338 -j DROP
iptables -A OUTPUT -p tcp --dport 31338 -j DROP
iptables -A OUTPUT -p tcp --sport 31339 -j DROP
iptables -A OUTPUT -p tcp --dport 31339 -j DROP
iptables -A OUTPUT -p tcp --sport 31340 -j DROP
iptables -A OUTPUT -p tcp --dport 31340 -j DROP

service iptables save
service iptables restart
iptables -nv -L
```