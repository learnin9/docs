#bin/bash
#20170926
iptables -F
iptables -X

#入链默认为DROP,出链为允许,转发默认禁止
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

#业务规则,允许34,35网段允许访问http,https,ssh服务
iptables -A INPUT -s 192.168.34.0/24 -m multiport -p tcp --dport 22,80,443 -j ACCEPT
iptables -A INPUT -s 192.168.35.0/24 -m multiport -p tcp --dport 22,80,443 -j ACCEPT

#数据备份FTP上传
iptables -A INPUT -s 172.19.2.253 -j ACCEPT

#允许MySQL主从复制
iptables -A INPUT -s 100.100.100.253 -p tcp --sport 3306 -j ACCEPT

#其它协议(DNS,SMTP,NTP,PING)
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A INPUT -p tcp --sport 25 -j ACCEPT
iptables -A INPUT -p udp --sport 123 -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
iptables -A INPUT -i lo -p all -j ACCEPT

iptables -A FORWARD -f -m limit --limit 100/s --limit-burst 100 -j ACCEPT
iptables -A FORWARD -p icmp -m limit --limit 1/s --limit-burst 10 -j ACCEPT
iptables -A FORWARD -m state --state INVALID -j DROP

service iptables save
service iptables restart
iptables -nv -L
