# KVM虚拟化主机安装

---

* 最小化安装CentOS6.X或者CentOS7.X，RHEL6.X以上系列建议建议选择安装最小虚拟化主机
* 如果要安装桌面可以先选择最小化虚拟主机，再选择Gnome桌面包

**安装过程**

* 检查CPU是否支持虚拟技术

```auto
# cat /proc/cpuinfo | egrep 'vmx|svm'
```

* 安装kvm相关

```auto
# yum -y groupinstall "Virtualization" "Virtualization Client" "Virtualization Platform" "Virtualization Tools"
```

* 安装网桥工具

```auto
# yum install bridge-utils -y
# ifconfig virbr0
确认有以下内容输出
virbr0    Link encap:Ethernet  HWaddr 52:54:00:A0:83:9A  
         inet addr:192.168.122.1  Bcast:192.168.122.255  Mask:255.255.255.0
         UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
         RX packets:0 errors:0 dropped:0 overruns:0 frame:0
         TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
         collisions:0 txqueuelen:0
         RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
```

* 配置桥接网络

```auto
# mkdir -p /backup    //创建备份目录
# cd /etc/sysconfig/network-scripts
# cp -r ifcfg-eth0 /backup/     //对默认的配置文件进行备份
# vim /etc/sysconfig/network-scripts/ifcfg-eth0
修改为以下格式内容
...
DEVICE=eth0
TYPE=Ethernet
ONBOOT=yes
NM_CONTROLLED=no
BRIDGE=br0
...

# vim /etc/sysconfig/network-scripts/ifcfg-br0     //添加桥接网络配置文件
...
DEVICE=br0
TYPE=Bridge
ONBOOT=yes
NM_CONTROLLED=no
BOOTPROTO=Static     //如果想使用DHCP方式，把这里换成dhcp，下面的都删掉就行了
IPADDR=192.168.1.80
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=114.114.114.114
...
```

执行sysctl -p，检查下面三项内容是否都为0

```auto
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
```

* 重新启动网络`service network restart`，检查Bridge是否设置成功

```auto
br0       Link encap:Ethernet  HWaddr 00:0C:29:69:07:FE  
         inet addr:192.168.1.80  Bcast:192.168.1.255  Mask:255.255.255.0
         inet6 addr: fe80::20c:29ff:fe69:7fe/64 Scope:Link
         UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
         RX packets:788 errors:0 dropped:0 overruns:0 frame:0
         TX packets:369 errors:0 dropped:0 overruns:0 carrier:0
         collisions:0 txqueuelen:0
         RX bytes:78433 (76.5 KiB)  TX bytes:58258 (56.8 KiB)
eth0      Link encap:Ethernet  HWaddr 00:0C:29:69:07:FE  
         inet6 addr: fe80::20c:29ff:fe69:7fe/64 Scope:Link
         UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
         RX packets:37360 errors:0 dropped:0 overruns:0 frame:0
         TX packets:8899 errors:0 dropped:0 overruns:0 carrier:0
         collisions:0 txqueuelen:1000
         RX bytes:38608283 (36.8 MiB)  TX bytes:796592 (777.9 KiB)
```

#### 安装虚拟机

* 创建镜像存放目录

```auto
# mkdir -p /opt/kvmimg
# mkdir -p /iso
# chmod 777 /iso
```

* 虚拟机安装命令

Linux:

```auto
# virt-install --name www --boot menu=on --ram 2048 --vcpus=2 --os-variant=rhel6 --accelerate --cdrom=/iso/CentOS-6.4-x86_64-bin-DVD1.iso --disk path=/opt/kvmimg/vm01.img,size=5,bus=virtio --bridge=br0,model=virtio --autostart --vnc --vncport=5900 --vnclisten=0.0.0.0
```

Windows:

```auto
# virt-install --name windows-2008 --boot menu=on --ram 2048 --vcpus=2 --os-variant=win7 --accelerate --cdrom=/iso/cn_windows_server_2008_r2_standard_enterprise_datacenter_and_web_with_sp1_x64_dvd_617598.iso--disk path=/opt/kvmimg/2008server.img,size=50,bus=ide--bridge=br0,model=virtio --autostart --vnc --vncport=5900 --vnclisten=0.0.0.0
```

* 常用virsh命令

```auto
1）virsh list 列出当前虚拟机列表，不包括未启动的
2）virsh list --all 列出所有虚拟机，包括所有已经定义的虚拟机
3）virsh destroy vm-name 关闭虚拟机
4）virsh start vm-name 启动虚拟机
5）virsh edit vm-name 编辑虚拟机xml文件
6）virsh undefine vm-name 删除虚拟机
7）virsh shutdown vm-name 停止虚拟机
8）virsh reboot vm-name 重启虚拟机
9）virsh autostart vm-name 虚拟机随宿主机启动
```
