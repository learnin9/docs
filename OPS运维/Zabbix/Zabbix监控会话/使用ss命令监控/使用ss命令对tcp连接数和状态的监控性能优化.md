# 使用ss命令对tcp连接数和状态的监控性能优化

> 之前对tcp的监控采用netstat命令，发现在服务器繁忙的时候效果不理想，这个命令占用大量的cpu有时候高达90%以上，可能会导致业务的不稳定，所以改用ss命令对脚本进行优化

* 对tcp连接数和状态的监控意义主要有以下几点：
 * 可以观察服务器的压力分布(连接数大于5W的时候可能系统会有一定的压力，可以考虑加服务器)
 * 如果服务器的连接数突然变得极小(比如100以下)，可能是业务系统故障导致在线用户被踢出

## 脚本编写

* 在需要被监控的zabbix-agent端添加脚本编写
* 创建文件夹

```
mkdir -p /usr/local/zabbix-agent/scripts/
mkdir -p /etc/zabbix/zabbix_agentd.d/
vim /usr/local/zabbix-agent/scripts/tcp_status_ss.sh
```

脚本内容：
```
#!/bin/bash
#scripts for tcp status
function SYNRECV {
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'SYN-RECV' | awk '{print $2}'
}
function ESTAB {
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'ESTAB' | awk '{print $2}'
}
function FINWAIT1 {
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'FIN-WAIT-1' | awk '{print $2}'
}
function FINWAIT2 {
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'FIN-WAIT-2' | awk '{print $2}'
}
function TIMEWAIT {
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'TIME-WAIT' | awk '{print $2}'
}
function LASTACK {
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'LAST-ACK' | awk '{print $2}'
}
function LISTEN {
/usr/sbin/ss -ant | awk '{++s[$1]} END {for(k in s) print k,s[k]}' | grep 'LISTEN' | awk '{print $2}'
}
$1
```


或者:

```
function SYNRECV {
/usr/sbin/ss -s | grep 'synrecv' | awk '{print $2}'
}
function ESTAB {
/usr/sbin/ss -s | grep 'estab' | awk '{print $2}'
}
function FINWAIT1 {
/usr/sbin/ss -o |  grep 'FIN-WAIT-1'|wc -l
}
function FINWAIT2 {
/usr/sbin/ss -ant| grep 'FIN-WAIT-2' | wc -l
}
function TIMEWAIT {
/usr/sbin/ss -ant | grep 'TIME-WAIT' | wc -l
}
function LASTACK {
/usr/sbin/ss -ant | grep 'LAST-ACK' | wc -l
}
function LISTEN {
/usr/sbin/ss -ant | grep 'LISTEN' | wc -l
}
$1
```

* 赋予脚本执行权限

```
chmod +x /usr/local/zabbix-agent/scripts/tcp_status_ss.sh
```

## 服务端配置

* 填写key值：当然大家在加入key值之后最好再服务器上面去执行看有没有返回值：
* 编辑配置文件，定义监控项：

```
vim /etc/zabbix/zabbix_agentd.d/tcp_status_ss.conf
```

写入以下内容：

```
#monitor tcp
UserParameter=tcp[*],/usr/local/zabbix-agent/scripts/tcp_status_ss.sh $1
```

* 重启agent

```
service zabbix-agent restart
```

* zabbix-server服务端测试

```
zabbix_get -s 192.168.3.18 -p 10050 -k "tcp[LISTEN]"
zabbix_get -s 192.168.3.18 -p 20050 -k "tcp[LISTEN]"
22
```

## zabbix web端配置：

* 登录Zabbix的web界面，一次选择 `Configuration` > `Templates`,在主界面的右上角有个 `Import` 按钮，用来导入模板
