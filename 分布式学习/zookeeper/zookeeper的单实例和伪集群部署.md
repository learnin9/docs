## zookeeper的单实例和伪集群部署

### zookeeper工作方式

ZooKeeper 是一个开源的分布式协调服务，由雅虎创建，是 Google Chubby 的开源实现。 分布式应用程序可以基于 ZooKeeper 实现诸如数据发布/订阅、负载均衡、命名服务、分布式协 调/通知、集群管理、Master 选举、分布式锁和分布式队列 等功能。

在使用中，通常以集群的方式部署，Zookeeper节点部署越多，服务的可靠性越高，建议部署奇数个节点，因为zookeeper集群是以宕机个数过半才会让整个集群宕机的，集群节点数为奇数最佳。

zookeeper也可以以单实例或伪集群的方式运行，只不过这种方式不适用高并发的环境。下面记录一下部署zookeeper的过程，包括单实例和伪集群，分布式集群的部署。

### 安装JDK

zookeeper是由JAVA开发，运行需要有JAVA环境，安装前先安装JDK。

JDK下载：http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html

下载完成后直接yum安装即可

### 单机实例部署

* 下载

各版本可以在官方网站下载 : https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/

这里下载的版本是 3.4.12

* 解压至指定路径

```
[root@zookeeper ~]# tar zxf zookeeper-3.4.12.tar.gz  -C /data/
```

* 修改解压目录名称，做伪集群或分布式集群最好将目录标明白，容易看清

```
[root@zookeeper ~]# mv /data/zookeeper-3.4.12/ /data/zookeeper1
```

* 修改配置文件

```
[root@zookeeper ~]# cd /data/zookeeper1/conf/
[root@zookeeper conf]# mv zoo_sample.cfg zoo.cfg
```

* 单机实例部署配置如下

```
[root@zookeeper conf]# vim zoo.cfg 
tickTime=2000 #2000毫秒=2秒
initLimit=10
syncLimit=5
dataDir=/opt/zookeeper/datadir
dataLogDir=/opt/zookeeper/logdir
clientPort=2181
```

* 创建数据目录

```
[root@zookeeper conf]# mkdir -pv /opt/zookeeper/{datadir,logdata}
mkdir: 已创建目录 "/opt/zookeeper"
mkdir: 已创建目录 "/opt/zookeeper/datadir"
mkdir: 已创建目录 "/opt/zookeeper/logdata"
```

**配置参数说明**

* *ickTime这个时间是作为zookeeper服务器之间或客户端与服务器之间维持心跳的时间间隔,也就是说每个tickTime时间就会发送一个心跳。
initLimit ： 配置项是用来配置zookeeper接受客户端（这里所说的客户端不是用户连接zookeeper服务器的客户端,而是zookeeper服务器集群中连接到leader的follower 服务器）初始化连接时最长能忍受多少个心跳时间间隔数。当已经超过10个心跳的时间（也就是tickTime）长度后 zookeeper 服务器还没有收到客户端的返回信息,那么表明这个客户端连接失败。总的时间长度就是 10*2000=20秒。

* syncLimit ：配置项标识leader与follower之间发送消息,请求和应答时间长度,最长不能超过多少个tickTime的时间长度,总的时间长度就是5*2000=10秒。
  * dataDir ：是zookeeper保存数据的目录，默认情况下如果不定义dataLogDir，zookeeper将写数据的日志文件也保存在这个目录里，最好分开定义

* clientPort ： 客户端连接Zookeeper服务器的端口,Zookeeper会监听这个端口接受客户端的访问请求；
* server.n=ipA:B:C ：定义集群节点号，ip，监听端口，选举通信端口，n是一个数字,表示这个是第几号服务器,A是这个服务器的IP地址，B第一个端口用来集群成员的信息交换,表示这个服务器与集群中的leader服务器交换信息的端口，C是在leader挂掉时专门用来进行选举leader所用的端口。

* 启动zookeeper

```
[root@zookeeper ~]# /data/zookeeper1/bin/zkServer.sh start

ZooKeeper JMX enabled by default
Using config: /data/zookeeper1/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
```

* 查看状态

```
[root@zookeeper ~]# /data/zookeeper1/bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /data/zookeeper1/bin/../conf/zoo.cfg
Mode: standalone  #单机模式
```

* 查看端口 2181已经启动

###  zookeeper指令

zookeeper启动后，可以先连接测试是否正常

```
[root@zookeeper ~]# cd /data/zookeeper1/bin/
[root@zookeeper bin]# ./zkCli.sh -server 127.0.0.1

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
[zk: 127.0.0.1(CONNECTED) 0]   #登录成功
```
> zookeeper启动后会在当前用户的家目录生成状态日志zookeeper.out，平时服务状态出现问题可以从里面找到问题所在

连接上zk后，随意输入一个字符，通常是？号，会给出zookeeper的指令帮助

```
[zk: 127.0.0.1(CONNECTED) 0] ?
ZooKeeper -server host:port cmd args
    stat path [watch]
    set path data [version]
    ls path [watch]   #查看节点
    delquota [-n|-b] path
    ls2 path [watch]
    setAcl path acl
    setquota -n|-b val path
    history 
    redo cmdno
    printwatches on|off
    delete path [version]
    sync path
    listquota path
    rmr path
    get path [watch]
    create [-s] [-e] path data acl   #创建节点
    addauth scheme auth
    quit 
    getAcl path
    close 
    connect host:port  #连接指令
```

* 创建节点

```
[zk: 127.0.0.1(CONNECTED) 1] create /test "test"
Created /test
[zk: 127.0.0.1(CONNECTED) 2] ls /
[zookeeper, test]
```

* 获取节点内容

```
[zk: 127.0.0.1(CONNECTED) 3] get /test 
test
cZxid = 0x8  ：该节点是由哪个事务ID产生
ctime = Sat Sep 01 21:41:06 CST 2018
mZxid = 0x8  ：最近更新了该节点的事务ID
mtime = Sat Sep 01 21:41:06 CST 2018
pZxid = 0x8  ：该节点的子节点列表被修改的事务ID
cversion = 0 ：子节点版本号
dataVersion = 0 ： 数据版本号
aclVersion = 0 ： ACL版本号
ephemeralOwner = 0x0  
dataLength = 4  ： 数据长度
numChildren = 0  ： 子节点个数
```

> 乐观并发访问控制和悲观并发访问控制 —延伸

* 更新节点

```
[zk: 127.0.0.1(CONNECTED) 4] set /test "test path"
```

* 删除节点

```
[zk: 127.0.0.1(CONNECTED) 6] delete /test
[zk: 127.0.0.1(CONNECTED) 7] ls /test
Node does not exist: /test
#如果删除有子目录的节点，使用rmr指令
```

> 临时节点不能有子节点

### ookeeper四字命令

使用telnet可以连接zookeeper发送4个字符的命令。

```
[root@zookeeper bin]# telnet 127.0.0.1 2181
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
ruok  #探测是否存活
imokConnection closed by foreign host.
```


```
[root@zookeeper bin]# telnet 127.0.0.1 2181
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
stat            #查看zk版本信息
Zookeeper version: 3.4.12-e5259e437540f349646870ea94dc2658c4e44b3b, built on 03/27/2018 03:55 GMT
Clients:
 /127.0.0.1:52636[0](queued=0,recved=1,sent=0)

Latency min/avg/max: 0/2/308
Received: 248
Sent: 247
Connections: 1
Outstanding: 0
Zxid: 0xc
Mode: standalone
Node count: 5
Connection closed by foreign host.
```

```
[root@zookeeper bin]# telnet 127.0.0.1 2181
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
conf   #查看节点配置信息
clientPort=2181
dataDir=/opt/zookeeper/datadir/version-2
dataLogDir=/opt/zookeeper/logdir/version-2
tickTime=2000
maxClientCnxns=60
minSessionTimeout=4000
maxSessionTimeout=40000
serverId=0
Connection closed by foreign host.
```


### zookeeper伪集群部署

zookeeper伪集群是部署在一台服务器上，通过创建多个工作目录配置项等，实现多实例的运行

在上面的基础上，再添加两个实例

* 将原来/data/zookeeper1目录复制

```
[root@zookeeper ~]# cp -ar /data/zookeeper1/ /data/zookeeper2
[root@zookeeper ~]# cp -ar /data/zookeeper1/ /data/zookeeper3
[root@zookeeper ~]# ls /data/
zookeeper1  zookeeper2  zookeeper3
```

* 修改zookeeper1配置文件

```
[root@zookeeper ~]# vim  /data/zookeeper1/conf/zoo.cfg 

dataDir=/opt/zookeeper/datadir     #各伪节点目录不能相同
dataLogDir=/opt/zookeeper/logdir
clientPort=2181   #各伪节点端口不能相同

#下面的节点定义各伪节点要相同
server.1=192.168.214.171:2888:3888 
server.2=192.168.214.171:2889:3889
server.3=192.168.214.171:2890:3890
```

* 修改zookeeper2配置文件

```
[root@zookeeper ~]# vim  /data/zookeeper2/conf/zoo.cfg 

dataDir=/opt/zookeeper2/datadir
dataLogDir=/opt/zookeeper2/logdir
clientPort=2182
server.1=192.168.214.171:2888:3888
server.2=192.168.214.171:2889:3889
server.3=192.168.214.171:2890:3890
```

* 修改zookeeper3配置文件

```
dataDir=/opt/zookeeper3/datadir
dataLogDir=/opt/zookeeper3/logdir
clientPort=2183
server.1=192.168.214.171:2888:3888
server.2=192.168.214.171:2889:3889
server.3=192.168.214.171:2890:3890
```

* 创建数据存放目录

```
[root@zookeeper ~]# mkdir -pv /opt/zookeeper{2,3}/{datadir,logdir}
mkdir: 已创建目录 "/opt/zookeeper2"
mkdir: 已创建目录 "/opt/zookeeper2/datadir"
mkdir: 已创建目录 "/opt/zookeeper2/logdir"
mkdir: 已创建目录 "/opt/zookeeper3"
mkdir: 已创建目录 "/opt/zookeeper3/datadir"
mkdir: 已创建目录 "/opt/zookeeper3/logdir"
```

* 为每个节点设置节点ID号

```
[root@zookeeper ~]# echo 1 > /opt/zookeeper/datadir/myid
[root@zookeeper ~]# echo 2 > /opt/zookeeper2/datadir/myid
[root@zookeeper ~]# echo 3 > /opt/zookeeper3/datadir/myid

[root@zookeeper ~]# cat /opt/zookeeper/datadir/
myid       version-2/ 
[root@zookeeper ~]# cat /opt/zookeeper/datadir/myid 
1
[root@zookeeper ~]# cat /opt/zookeeper2/datadir/myid 
2
[root@zookeeper ~]# cat /opt/zookeeper3/datadir/myid 
3
```

* 启动集群

```
[root@zookeeper ~]# /data/zookeeper1/bin/zkServer.sh start
ZooKeeper JMX enabled by default
Using config: /data/zookeeper1/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED

[root@zookeeper ~]# /data/zookeeper2/bin/zkServer.sh start
ZooKeeper JMX enabled by default
Using config: /data/zookeeper2/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED

[root@zookeeper ~]# /data/zookeeper3/bin/zkServer.sh start
ZooKeeper JMX enabled by default
Using config: /data/zookeeper3/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
```

* 查看状态

```
[root@zookeeper ~]# /data/zookeeper1/bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /data/zookeeper1/bin/../conf/zoo.cfg
Mode: leader

[root@zookeeper ~]# /data/zookeeper2/bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /data/zookeeper2/bin/../conf/zoo.cfg
Mode: follower

[root@zookeeper ~]# /data/zookeeper3/bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /data/zookeeper3/bin/../conf/zoo.cfg
Mode: follower
```


* 测试master切换

关闭leader节点

```
[root@zookeeper ~]# /data/zookeeper1/bin/zkServer.sh stop
ZooKeeper JMX enabled by default
Using config: /data/zookeeper1/bin/../conf/zoo.cfg
Stopping zookeeper ... STOPPED

#zookeeper2节点立即变成了leader

[root@zookeeper ~]# /data/zookeeper2/bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /data/zookeeper2/bin/../conf/zoo.cfg
Mode: leader
```


* 再启动zookeeper1节点，会以follower角色工作

```
[root@zookeeper ~]# /data/zookeeper1/bin/zkServer.sh start
ZooKeeper JMX enabled by default
Using config: /data/zookeeper1/bin/../conf/zoo.cfg
Starting zookeeper ... STARTED
[root@zookeeper ~]# /data/zookeeper1/bin/zkServer.sh status
ZooKeeper JMX enabled by default
Using config: /data/zookeeper1/bin/../conf/zoo.cfg
Mode: follower
```

关于zookeeper的单机模式和伪集群就写到这，分布式集群部署[点击阅读](zookeeper分布式集群部署.md)