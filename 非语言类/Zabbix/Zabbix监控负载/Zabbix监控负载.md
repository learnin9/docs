# zabbix监控cpu的负载

> 安装完zabbix后，在Template OS Linux这个模板下面默认有监控cpu负载的触发器，但是这个默认的触发器是以cpu负载的个数为触发值的，由于agent客户机每台的cpu核数是不一样的，所以，以负载的个数为触发值不是很好，下面我设置的触发值是cpu负载占cpu核数的百分比

## agent端操作

* 创建一个脚本目录，所有的zabbix agent的脚本都放在这里，方便管理

```
mkdir -p /etc/zabbix/itemscripts         
cd /etc/zabbix/itemscripts
```

* 创建一个cpu负载的脚本


```
vi cpu_load.sh                           
```

脚本内容如下：

```
#!/bin/bash
TERM=linux
export TERM
cpucore=`cat /proc/cpuinfo | grep 'processor' |wc -l`
cpuload=`top -bn 1 | grep 'load average' | awk -F":" '{print $5}' | awk -F"," '{print $1*100}'`
cpuload_percent=$[${cpuload}/${cpucore}]
echo $cpuload_percent
```

**注意**：

* 在脚本中使用`top`时，一定要定义`TERM`环境变量
* 使用脚本在非交互式模式下调用`top -n 1`命令时，经常会出现: `top: failed tty get`错误，解决方法：加`-b`参数即可
* shell脚本里默认是不支持小数计算的
* `cpuload_percent`：这个值最终乘100了
* shell中的计算：`$[]` 如:`$[4/2]

## 修改记录1：

* 上面的那个脚本不是很好，使用下面的python脚本更好一些

```
#!/usr/bin/python
#encoding:utf-8
import commands
#统计cpu的使用率
oneloadcpu=commands.getoutput("uptime | sed 's/.*average://g' | awk -F',' '{print $1}'")
cpunumbers=commands.getoutput('cat /proc/cpuinfo  | grep processor |wc -l')
cpupercent=float(oneloadcpu)*100/float(cpunumbers)
print cpupercent
```

* 测试一下脚本的返回

```
[root@scj itemscripts]# top -n 1
top - 05:19:53 up 23:09,  3 users,  load average: 0.25, 0.06, 0.02
Tasks:  99 total,   1 running,  98 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.1%us,  0.1%sy,  0.0%ni, 98.9%id,  0.7%wa,  0.0%hi,  0.1%si,  0.0%st
Mem:    118012k total,   109260k used,     8752k free,    26820k buffers
Swap:  1048568k total,    55472k used,   993096k free,    11960k cached
注意：由top知：当前cpu核数为1，且当前的负载是0.25，所以cpu负载与cpu总核数的比例是25
[root@www run]./cpu_load.sh    (注意：当执行脚本时是有返回值的)
25
```

* 编写配置文件，定义监控项

```
vim /etc/zabbix/zabbix_agentd.d/userparameter_cpu.conf
UserParameter=cpu_load_percent,bash /etc/zabbix/itemscripts/cpu_load.sh
```


* 重启zabbix agent服务

```
service zabbix-agent restart
```


## server端

* 测试一下：

```
[root@scj ~]# zabbix_get -s 192.168.186.128 -k cpu_load_percent
25                                               （OK）
```

* 到web界面添加相应的监控项

**注意** ：正常情况下，cpu的负载值不会超过cpu的总核数,在设置触发值条件时，我们可以设置，持续1分钟内若cpu的负载与cpu总核数比例大于99，则触发报警

## 总结：

* 从上面的步骤来看，zabbix监控cpu的负载与cpu总核数比例的方法，不是很理想,若被监控的agent机，有上百台或上千台的话，这种方法就废了
* 不过：如果我们的线上配置了puppet或是saltstack的话，就非常方便了，我们只需要在master端进行相应的配置，然后把数据推送给agent端，搞定！！！！
