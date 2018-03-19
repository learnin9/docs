服务端：
```
driftfile /var/lib/ntp/drift
restrict default nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict ::1
restrict 172.19.103.0 mask 255.255.255.0 nomodify notrap
server ntp.cloud.top iburst
restrict ntp.cloud.top nomodify notrap noquery
server 127.127.1.0
fudge 127.127.1.0 stratum 10
includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys
disable monitor
```

客户端：
```
driftfile /var/lib/ntp/drift
restrict default nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict ::1
server ntp.cloud.top
restrict ntp.cloud.top nomodify notrap noquery
includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys
disable monitor

```


CentOS6下的NTP服务通用配置
```
driftfile /var/lib/ntp/drift
restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery

restrict 127.0.0.1
restrict -6 ::1

# 允许内网其他机器同步时间
restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap

server 210.72.145.44 perfer 
server 202.112.10.36             # 1.cn.pool.ntp.org
server 59.124.196.83             # 0.asia.pool.ntp.org

# 允许上层时间服务器主动修改本机时间
restrict 210.72.145.44 nomodify notrap noquery
restrict 202.112.10.36 nomodify notrap noquery
restrict 59.124.196.83 nomodify notrap noquery

# Undisciplined Local Clock. This is a fake driver intended for backup
# and when no outside source of synchronized time is available. 
# 外部时间服务器不可用时，以本地时间作为时间服务
server  127.127.1.0     # local clock
fudge   127.127.1.0 stratum 10
includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys
```