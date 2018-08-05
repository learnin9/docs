本篇内容使用自动的方式配置LVS规则
-----

* 脚本实现

> 下面的脚本内容是实现自动添加ipvsadm规则，VIP地址信息及后端RS服务自动添加ARP规则等，只要执行脚本就可以自动完成LVS的DR模式调度配置

* LVS Director server脚本

```
#!/bin/bash
#Author:gudaoyufu.com
#Date:2018-07-03
vip='192.168.214.140'
iface='lo:1'
#mask='255.255.255.255'
port='80'
rs1='192.168.214.143'
rs2='192.168.214.145'
scheduler='wrr'
type='-g'
rpm -q ipvsadm &> /dev/null || yum -y install ipvsadm &> /dev/null

case $1 in
start)
    ip addr add $vip dev $iface
    iptables -F

    ipvsadm -A -t ${vip}:${port} -s $scheduler
    ipvsadm -a -t ${vip}:${port} -r ${rs1} $type -w 1
    ipvsadm -a -t ${vip}:${port} -r ${rs2} $type -w 1
    echo "The LVS Director Server is Ready!"
    ;;
stop)
    ipvsadm -C
    ip addr del $vip dev $iface &> /dev/null
    echo "The LVS Director Server is Canceled!"
    ;;
*)
    echo "Usage: $(basename $0) start|stop"
    exit 1
    ;;
esac
```

* 后端RS服务配置脚本


```
#!/bin/bash
#Author:gudaoyufu.com
#Date:2017-07-03
vip=192.168.214.140
#mask='255.255.255.0'
dev='lo:1'
rpm -q httpd &> /dev/null || yum -y install httpd &>/dev/null
service httpd start &> /dev/null && echo "The httpd Server is Ready!"
echo "<h1>`hostname`</h1>" > /var/www/html/index.html

case $1 in
start)
    echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
    echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
    echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
    echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce
    ip addr add $vip dev $dev
    #route add -host $vip dev $dev
    echo "The RS Server is Ready!"
    ;;
stop)
    ip addr del $vip dev $dev
    echo 0 > /proc/sys/net/ipv4/conf/all/arp_ignore
    echo 0 > /proc/sys/net/ipv4/conf/lo/arp_ignore
    echo 0 > /proc/sys/net/ipv4/conf/all/arp_announce
    echo 0 > /proc/sys/net/ipv4/conf/lo/arp_announce
    echo "The RS Server is Canceled!"
    ;;
*)
    echo "Usage: $(basename $0) start|stop"
    exit 1
    ;;
esac
```


* 客户端访问测试

```
[root@client ~]# for i in {1..10}; do curl 192.168.214.140;done
<h1>www1</h1>
<h1>www2</h1>
<h1>www1</h1>
<h1>www2</h1>
<h1>www1</h1>
<h1>www2</h1>
<h1>www1</h1>
<h1>www2</h1>
<h1>www1</h1>
<h1>www2</h1>
```


* 修改权重测试

```
[root@LVS ~]# ipvsadm -e -t 192.168.214.140:80 -r 192.168.214.145 -g -w 3
```

* 查看规则

```
[root@LVS ~]# ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.214.140:80 wrr
  -> 192.168.214.143:80           Route   1      0          0         
  -> 192.168.214.145:80           Route   3      0          0    
```

* 再测试

```
[root@client ~]# for i in {1..10}; do curl 192.168.214.140;done
<h1>www1</h1>
<h1>www2</h1>
<h1>www1</h1>
<h1>www1</h1>
<h1>www1</h1>
<h1>www2</h1>
<h1>www1</h1>
<h1>www1</h1>
<h1>www1</h1>
<h1>www2</h1>
```

### 结合ldirectord添加sorry server

* 安装

```
[root@LVS ~]# yum install ldirectord-3.9.6-0rc1.1.1.x86_64.rpm  -y
```

* 复制配置文件

```
cp /usr/share/doc/ldirectord-3.9.6/ldirectord.cf /etc/ha.d/
```

* 配置自动管理规则

```
#Global Directives
checktimeout=3            #3秒无响应剔除故障主机
checkinterval=1             #每秒检查一次
fallback=127.0.0.1:80    #sorry server(lvs主机提供httpd)
autoreload=yes             #配置文件修改后自动加载生效，不用重启服务
logfile="/var/log/ldirectord.log"
quiescent=no               #主机故障后删除

#Sample for an http virtual service
virtual=192.168.214.140:80
        real=192.168.214.143:80 gate
        real=192.168.214.145:80 gate
        fallback=127.0.0.1:80 gate
        service=http
        scheduler=rr
        #persistent=600
        #netmask=255.255.255.255
        protocol=tcp
        checktype=negotiate        
        checkport=80
        request="index.html"         #检测后端主机的页面
        receive="www"                  #匹配检测页面中的关键字，检测到说明正常，检测不到就认为异常  
```

* 第一次配置完以后要启动ldirectord使用配置生效

```
systemctl start ldirectord 
```

* 测试

```
[root@client ~]# for i in {1..10}; do curl 192.168.214.140;done
<h1>www1</h1>
<h1>www2</h1>
<h1>www1</h1>
<h1>www2</h1>
<h1>www1</h1>
<h1>www2</h1>
<h1>www1</h1>
<h1>www2</h1>
<h1>www1</h1>
<h1>www2</h1>

```

* 关闭www1服务测试

```
[root@client ~]# for i in {1..10}; do curl 192.168.214.140;done
<h1>www2</h1>
<h1>www2</h1>
<h1>www2</h1>
<h1>www2</h1>
<h1>www2</h1>
<h1>www2</h1>
<h1>www2</h1>
<h1>www2</h1>
<h1>www2</h1>
<h1>www2</h1>
```

* 关闭www2测试，当后端服务全部被关闭的时候sorry server会自动上线，如下，此时访问的页面都是由sorry server提示

```
[root@LVS ~]# ipvsadm -Ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.214.140:80 rr
  -> 127.0.0.1:80                 Route   1      0          0 
```

* 再测试

```
[root@client ~]# for i in {1..10}; do curl 192.168.214.140;done
Sorry,server error
Sorry,server error
Sorry,server error
Sorry,server error
Sorry,server error
Sorry,server error
Sorry,server error
Sorry,server error
Sorry,server error
Sorry,server error
```
