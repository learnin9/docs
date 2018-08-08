# KVM虚拟机的磁盘与网卡热插拔添加卸载

## kvm磁盘热插拔扩展

* 使用到的指令集：
 * `virsh attach-disk`：添加磁盘
 * `virsh detach-disk`：删除磁盘
 * `virsh domblklist vm`： 查看vm虚拟机磁盘列表

## 挂载raw格式的磁盘

示例，将vm3虚拟机添加一块新磁盘

添加一块1G的磁盘文件

```
[root@KVM ~]# qemu-img create -f raw /kvm/vm3/vdc.raw 1G
Formatting '/kvm/vm3/vdc.raw', fmt=raw size=1073741824
```

将空盘添加到虚拟机vm3

```
[root@KVM ~]# virsh attach-disk vm3 /kvm/vm3/vdc.raw vdc --cache none
Disk attached successfully
```

连接到vm3格式化磁盘

```
[root@KVM ~]# virsh console vm3
Connected to domain vm3
Escape character is ^]
#回车
localhost login: root
Password:
Last login: Sat Jul 28 12:41:23 on ttyS0

#fdisk查看磁盘内容

Disk /dev/vdc: 1073 MB, 1073741824 bytes, 2097152 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

格式化并挂载

```
[root@localhost ~]# mkfs -t ext4 /dev/vdc

#挂载
[root@localhost ~]# mount /dev/vdc /mnt/
[ 1507.485894] EXT4-fs (vdc): mounted filesystem with ordered data mode. Opts: (null)
[root@localhost ~]# df -h
Filesystem               Size  Used Avail Use% Mounted on
/dev/mapper/centos-root  8.0G  960M  7.1G  12% /
devtmpfs                 1.1G     0  1.1G   0% /dev
tmpfs                    1.2G     0  1.2G   0% /dev/shm
tmpfs                    1.2G  8.4M  1.1G   1% /run
tmpfs                    1.2G     0  1.2G   0% /sys/fs/cgroup
/dev/vda1               1014M  142M  873M  14% /boot
tmpfs                    129M     0  129M   0% /run/user/0
/dev/vdc                 976M  2.6M  907M   1% /mnt   #挂载成功

#测试写入文件
[root@localhost ~]# dd if=/dev/zero of=/mnt/bigfile bs=1M count=100
100+0 records in
100+0 records out
104857600 bytes (105 MB) copied, 0.90489 s, 116 MB/s
[root@localhost ~]# du -sh /mnt/
101M    /mnt/
```

查看vm3的磁盘列表

```
[root@KVM ~]# virsh domblklist vm3
Target     Source
------------------------------------------------
vda        /kvm/vm3/vm3.qcow2
vdb        /kvm/vm3/vdb.raw
vdc        /kvm/vm3/vdc.raw
```


## 拔掉磁盘

**注意：使用virsh指令删除磁盘会直接强制将虚拟机中磁盘删除，如果磁盘已经挂载使用，要停止该磁盘的写操作，否则会造成数据丢失，拔掉的磁盘存储在kvm宿主机的vm实例的镜像目录中，需要使用可以再挂载使用**

删除磁盘

```
[root@KVM ~]# virsh detach-disk vm3 vdb
Disk detached successfully


[root@KVM ~]# virsh detach-disk vm3 vdc
Disk detached successfully

[root@KVM ~]# virsh domblklist vm3
Target     Source
------------------------------------------------
vda        /kvm/vm3/vm3.qcow2
hda        -
```

当继续讲vdc磁盘插入后，在虚拟机中会自动识别其名称，如果之前没有插入vdb，及时执行插入指令命名为vdc也没有用，虚拟机系统会自动命名为 /dev/vdb, 由此可间虚拟机命令是按字母顺序来的


## 挂载qcow2格式磁盘

创建img镜像

qcow2格式的磁盘可以动态增加，**创建的镜像类型后缀可以是qcow2，或者可以是img ;** 在创建qcow2格式镜像文件时可以指定格式，可以使用如下指令查看使用方式:

```
[root@KVM ~]# qemu-img create -f qcow2 /kvm/vm3/vdc.img -o ?
Supported options:
size             Virtual disk size  #指定镜像大小加 -o 选项
compat           Compatibility level (0.10 or 1.1)
backing_file     File name of a base image
backing_fmt      Image format of the base image
encryption       Encrypt the image
cluster_size     qcow2 cluster size
preallocation    Preallocation mode (allowed values: off, metadata, falloc, full)
#preallocation 指定磁盘划分方式，metadata：只写入磁盘元数据到磁盘，空间动态增长；full全量划分，空间全部占用
lazy_refcounts   Postpone refcount updates
```

创建vdc.img磁盘镜像

```
[root@KVM ~]# qemu-img create -f qcow2 -o size=1G,preallocation=metadata /kvm/vm4/vdc.img
```

查看磁盘信息

```
[root@KVM ~]# qemu-img info /kvm/vm4/vdc.img
image: /kvm/vm4/vdc.img
file format: qcow2
virtual size: 1.0G (1073741824 bytes)
disk size: 332K
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: false
```

添加插入磁盘vdf.img

```
[root@KVM ~]# virsh attach-disk vm4 /kvm/vm4/vdc.img vdc
Disk attached successfully
```

console连接到vm4虚拟机，格式化挂载磁盘

```
#磁盘信息
Disk /dev/vdb: 1074 MB, 1074135040 bytes, 2097920 sectors  #变成了vdb
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
#格式化
[root@localhost ~]# mkfs -t ext4 /dev/vdb
#挂载
[root@localhost ~]# mount /dev/vdb  /opt/
复制一个大文件查看磁盘占用
[root@localhost opt]# dd if=/dev/zero of=/opt/bigfile bs=1M count=300
#查看KVM宿主机中vm3的镜像文件大小
[root@KVM vm4]# du -sh vdc.img
349M    vdc.img
```



### qcow2镜像文件

删除上面所有的镜像，重新创建一个后缀为qcow2的镜像文件
```
[root@KVM ~]# qemu-img create -f qcow2 -o size=1G,preallocation=metadata /kvm/vm4/vdb.qcow2
```

查看文件类型

```
[root@KVM ~]# qemu-img info /kvm/vm4/vdb.qcow2
image: /kvm/vm4/vdb.qcow2
file format: qcow2
virtual size: 1.0G (1073741824 bytes)
disk size: 332K
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: false

#添加插入磁盘
[root@KVM ~]# virsh attach-disk vm4 /kvm/vm4/vdb.qcow2 vdb
Disk attached successfully

# 连接到vm4 格式化挂载
[root@localhost ~]# mkfs -t ext4 /dev/vdb
[root@localhost ~]# mount /dev/vdb  /mnt/
[root@localhost mnt]# dd if=/dev/zero of=/mnt/bigfile bs=1M count=232

#查看磁盘镜像文件
[root@KVM vm4]# du -sh vdb.qcow2
281M    vdb.qcow2
```

## KVM网卡热插拔

网卡的热插拔添加方式与磁盘的方式差不多，指令也差不多

* virsh attach-interface ： 添加一块网卡
* virsh detach-interface：删除一块网卡，指定MAC
* virsh domiflist ：查看虚拟机网卡列表

添加一个网卡到物理桥br0上

```
[root@KVM ~]# virsh attach-interface vm4 bridge br0
Interface attached successfully

[root@localhost opt]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:9b:4a:12 brd ff:ff:ff:ff:ff:ff
    inet 192.168.214.160/24 brd 192.168.214.255 scope global dynamic eth0
       valid_lft 1055sec preferred_lft 1055sec
    inet6 fe80::e210:b7c:a67b:5f0/64 scope link
       valid_lft forever preferred_lft forever
    inet6 fe80::8df2:2e2f:c5dd:912/64 scope link tentative dadfailed
       valid_lft forever preferred_lft forever
3: ens10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:25:ad:60 brd ff:ff:ff:ff:ff:ff
    inet 192.168.214.164/24 brd 192.168.214.255 scope global dynamic ens10
       valid_lft 1758sec preferred_lft 1758sec
    inet6 fe80::19f7:b5b1:90fd:4664/64 scope link
       valid_lft forever preferred_lft forever
```
ens10是新加的网卡

撤销网卡，撤销网卡前先关闭网卡

```
[root@localhost ~]# ip link set dev ens10 down
```

**注意：撤销某一块网卡要指定该网卡的MAC，要不会撤销该网卡所在网桥上所有的网卡**

```
[root@KVM ~]# virsh detach-interface vm4 bridge --mac 52:54:00:25:ad:60
Interface detached successfully
```

查看虚拟机网卡列表

```
[root@KVM ~]# virsh domiflist vm4
Interface  Type       Source     Model       MAC
-------------------------------------------------------
vnet1      bridge     br0        virtio      52:54:00:9b:4a:12
```
