**主机分配**

* 192.168.214.143
* 192.168.214.152
* 192.168.214.153

**各节点时间同步**

```
[root@Ansible ~]# ansible zk -m shell -a 'ntp.tuna.tsinghua.edu.cn'
```

**关闭selinux**

```
[root@Ansible ~]# ansible zk -m shell -a "sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config"
[root@Ansible ~]# ansible zk -m shell -a "setenforce 0"
```

**关闭防火墙**

```
[root@Ansible ~]# ansible zk -m shell -a "systemctl disable firewalld"
[root@Ansible ~]# ansible zk -m shell -a "systemctl stop firewalld"
```

### 安装JDK

**各节点下载jdk安装包**

ansible 下载还不太会用，先手动下载吧，每个节点跑一次吧，后续更新怎么解决更好。
```
[root@192 ~]# curl -L "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.rpm" -H "Cookie: oraclelicense=accept-securebackup-cookie"  -H "Connection: keep-alive" -O' 
```

**进行安装**

```
[root@Ansible ~]# ansible zk -m shell -a "yum -y install jdk-8u181-linux-x64.rpm"
```

**测试java**

```
[root@Ansible ~]# ansible zk -m shell -a 'java -version'
```

### 安装zookeeper

* 各节点下载安装包

```
ansible zk -m shell -a 'mkdir -p /app/soft/'
ansible zk -m shell -a "wget -P /app/soft/ https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.13/zookeeper-3.4.13.tar.gz"
```

* 解压并修改目录名称

```
ansible zk -m shell -a 'tar zxvf zookeeper-3.4.12.tar.gz -C /app/soft'
[root@Ansible ~]# ansible zk -m shell -a 'mv /app/soft/zookeeper-3.4.12 /app/soft/zookeeper'
```

* 创建zoo.cfg配置文件

```
[root@Ansible ~]# ansible zk -m shell -a 'cp /app/soft/zookeeper/conf/zoo_sample.cfg /app/soft/zookeeper/conf/zoo.cfg'
```

将zookeeper配置文件复制一份到ansible进行修改配置内容如下：

```
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/opt/zookeeper/datadir      #各节点创建相应目录,可根据实际情况变更目录
dataLogDir=/opt/zookeeper/logdir    #各节点创建相应目录,可根据实际情况变更目录
clientPort=2181
server.1 192.168.214.143:2888:3888  #各节点配置相同
server.2 192.168.214.152:2889:3889
server.3 192.168.214.153:2890:3890
```

* 复制配置文件到各节点

```
[root@Ansible ~]# ansible zk -m copy -a 'src=/home/zoo.cfg dest=/app/soft/zookeeper/conf/'
```

* 创建各节点数据存放目录

```
[root@Ansible ~]# ansible zk -m shell -a 'mkdir -pv /opt/zookeeper/{datadir,logdir}'
```

* 给个节点添加节点ID

```
[root@zookeeper1 ~]# echo 1 >  /opt/zookeeper/datadir/myid
[root@zookeeper2 ~]# echo 2 >  /opt/zookeeper/datadir/myid
[root@zookeeper3 ~]# echo 3 >  /opt/zookeeper/datadir/myid
```

* 检车节点

```
[root@Ansible ~]# ansible zk -m shell -a "cat /opt/zookeeper/datadir/myid"
192.168.214.152 | SUCCESS | rc=0 >>
2

192.168.214.153 | SUCCESS | rc=0 >>
3

192.168.214.143 | SUCCESS | rc=0 >>
1
```


* 启动集群

```
[root@Ansible ~]# ansible zk -m shell -a "/app/soft/zookeeper/bin/zkServer.sh start"

[root@Ansible ~]# ansible zk -m shell -a "/app/soft/zookeeper/bin/zkServer.sh status"
192.168.214.143 | SUCCESS | rc=0 >>
Mode: followerZooKeeper JMX enabled by default
Using config: /app/soft/zookeeper/bin/../conf/zoo.cfg

192.168.214.152 | SUCCESS | rc=0 >>
Mode: followerZooKeeper JMX enabled by default
Using config: /app/soft/zookeeper/bin/../conf/zoo.cfg

192.168.214.153 | SUCCESS | rc=0 >>
Mode: leaderZooKeeper JMX enabled by default
Using config: /app/soft/zookeeper/bin/../conf/zoo.cfg
#第一行Mode后面就是节点的角色
```


### 测试同步

* 在leader节点创建一个数据节点test2，到follower节点查看

```
[zk: localhost:2181(CONNECTED) 1] create /test2 'test2 node'
Created /test2

#follower节点查看

[zk: localhost:2181(CONNECTED) 5] get /test2
test2 node
cZxid = 0x100000004
ctime = Sun Sep 02 14:38:22 CST 2018
mZxid = 0x100000004
mtime = Sun Sep 02 14:38:22 CST 2018
pZxid = 0x100000004
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 10
numChildren = 0
```


* 测试故障leader转移

```
[root@Ansible ~]# ansible zk -m shell -a "/data/zookeeper/bin/zkServer.sh status"
192.168.214.152 | SUCCESS | rc=0 >>
Mode: followerZooKeeper JMX enabled by default
Using config: /data/zookeeper/bin/../conf/zoo.cfg

192.168.214.153 | SUCCESS | rc=0 >>
Mode: leaderZooKeeper JMX enabled by default
Using config: /data/zookeeper/bin/../conf/zoo.cfg

192.168.214.143 | FAILED | rc=1 >>
Error contacting service. It is probably not running.ZooKeeper JMX enabled by default
Using config: /data/zookeeper/bin/../conf/zoo.cfgnon-zero return code
```

可以看到原来的leader节点挂了以后另一153节点获得leader身份

