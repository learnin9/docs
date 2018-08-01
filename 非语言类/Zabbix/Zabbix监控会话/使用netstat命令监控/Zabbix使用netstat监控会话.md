# Zabbix使用netstat监控会话

* [原文链接](https://www.cnblogs.com/cloudos/p/8308946.html)

> TCP的连接状态对于我们web服务器来说是至关重要的，尤其是并发量ESTAB；或者是syn_recv值，假如这个值比较大的话我们可以认为是不是受到了攻击，或是是time_wait值比较高的话，我们要考虑看我们内核是否需要调优，太高的time_wait值的话会占用太多端口，要是端口少的话后果不堪设想

## TCP状态介绍

### man netstat查看TCP的各种状态信息描述：
 * `LISTEN`  侦听来自远方TCP端口的连接请求；
 * `SYN-SENT`  在发送连接请求后等待匹配的连接请求；
 * `SYN-RECEIVED`  在收到和发送一个连接请求后等待对连接请求的确认；
 * `ESTABLISHED`   代表一个打开的连接，数据可以传送给用户；  
 * `FIN-WAIT-1`   等待远程TCP的连接中断请求，或先前的连接中断请求的确认；
 * `FIN-WAIT-2`   从远程TCP等待连接中断请求；
 * `CLOSE-WAIT`   等待从本地用户发来的连接中断请求；
 * `CLOSING`    等待远程TCP对连接中断的确认；
 * `LAST-ACK`   等待原来发向远程TCP的连接中断请求的确认；
 * `TIME-WAIT`   等待足够的时间以确保远程TCP接收到连接中断请求的确认；
 * `CLOSED`       没有任何连接状态；

### 监控原理

```
root@Node1 ~]# /bin/netstat -an|awk '/^tcp/{++S[$NF]}END{for(a in S) print a,S[a]}'  //通过netstat获取相关值
LISTEN 10
ESTABLISHED 1
TIME_WAIT 178
```

## 监控脚本编写

* 编写脚本，放于 `/etc/zabbix/zabbix_agentd.d/`目录下

```
[root@Node1 zabbix_agentd.d]# cat tcp_status.sh
#!/bin/bash
#This script is used to get tcp and udp connetion status
#tcp status
metric=$1
tmp_file=/tmp/tcp_status.txt
/bin/netstat -an|awk '/^tcp/{++S[$NF]}END{for(a in S) print a,S[a]}' > $tmp_file
case $metric in
   closed)
          output=$(awk '/CLOSED/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   listen)
          output=$(awk '/LISTEN/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   synrecv)
          output=$(awk '/SYN_RECV/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   synsent)
          output=$(awk '/SYN_SENT/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   established)
          output=$(awk '/ESTABLISHED/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   timewait)
          output=$(awk '/TIME_WAIT/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   closing)
          output=$(awk '/CLOSING/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   closewait)
          output=$(awk '/CLOSE_WAIT/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   lastack)
          output=$(awk '/LAST_ACK/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
         ;;
   finwait1)
          output=$(awk '/FIN_WAIT1/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
         ;;
   finwait2)
          output=$(awk '/FIN_WAIT2/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
         ;;
         *)
          echo -e "\e[033mUsage: sh  $0 [closed|closing|closewait|synrecv|synsent|finwait1|finwait2|listen|established|lastack|timewait]\e[0m"
esac
```


* 赋予脚本执行权限

```
[root@Node1 ~]# chmod a+x /etc/zabbix/zabbix_agentd.d/tcp_status.sh   //赋予执行权限
[root@Node1 ~]# ll /etc/zabbix/zabbix_agentd.d/tcp_status.sh
-rwxr-xr-x 1 root root 2502 Jan 18 09:48 /etc/zabbix/zabbix_agentd.d/tcp_status.sh
[root@Node1 ~]#
```


* 添加zabbix配置文件，放于 /etc/zabbix/zabbix_agentd.d/目录下（agent的配置文件 /etc/zabbix/zabbix_agentd.conf 中定义了其他key的包含目录）创建配置文件tcp_status.conf


```
[root@Node1 ~]# cat /etc/zabbix/zabbix_agentd.d/tcp_status.conf
UserParameter=tcp.status[*],/etc/zabbix/zabbix_agentd.d/tcp_status.sh "$1"   //脚本路径
```

* 确保配置Agent配置文件开启自定义参数`UnsafeUserParameters=1`

```
[root@Node1 ~]# grep -n "^[a-Z]" /etc/zabbix/zabbix_agentd.conf
13:PidFile=/var/run/zabbix/zabbix_agentd.pid
32:LogFile=/var/log/zabbix/zabbix_agentd.log
43:LogFileSize=0
57:DebugLevel=3
97:Server=172.17.21.208
138:ServerActive=172.17.21.208
149:Hostname=Node1.contoso.com
267:Include=/etc/zabbix/zabbix_agentd.d/*.conf    
286:UnsafeUserParameters=1                //1代表允许，0代表关闭
```


* 重启zabbix-agent服务

```
[root@Node1 ~]# systemctl restart zabbix-agent.service
```


**备注** ：因为脚本是把tcp的一些信息存放在/tmp/下，为了zabbix可以读取到我们设置zabbix可以读的权限，确保属主与属组都为zabbix即可

```
[root@Node1 ~]# chown zabbix.zabbix /tmp/tcp_status.txt   //改变属主与属主
[root@Node1 ~]# ll /tmp/tcp_status.txt
-rw-rw-r-- 1 zabbix zabbix 38 Jan 18 11:32 /tmp/tcp_status.txt
```


* 在zabbix servere服务器上测试,是否能正常获取数据

```
[root@Node3 ~]# zabbix_get -s 172.17.21.206 -p 10050 -k "tcp.status[listen]"
[root@Node3 ~]# zabbix_get -s 172.17.21.206 -p 10050 -k "tcp.status[timewait]"
[root@Node3 ~]# zabbix_get -s 172.17.21.206 -p 10050 -k "tcp.status[established]"
[root@Node3 ~]#
```


**后记**：发现通过netstat监控服务器的tcp等连接数效率比较低，netstat统计占用大量cpu带来服务器额外的压力，通过ss命令会更加合适，详情请看：[这篇文章]()
