## CentOS 7 硬盘扩容

> 集群的存储节点硬盘空间不多了，添加一块新的200硬盘上去

1. 查看新添加的硬盘情况

```
fdisk -l  
```

2. 将新添加的硬盘加入到物理卷
```
pvcreate  /dev/sdb 
```

3. 查看物理卷情况  
     
```
vgdisplay
```
  
  
4. 将新的sdb添加到centos卷组下
  
```             
vgextend centos /dev/sdb  
``` 

5. 将全部空间划分给centos卷组  
``` 
lvextend -l +100%FREE /dev/centos/root
```
6. 使用 xfs_growfs 命令在线调整xfs格式文件系统大小

```
xfs_growfs /dev/centos/root
```

**CentOS6**:

```
resize2fs -p /dev/VolGroup/lv_root
```

7. 查看centos的大小是否已经扩容

```
df -hl                         
```


其它情况:
--------

> 遇到了特殊的场景，新增的两块硬盘需要单独挂个目录出来，继续写文档

1. 创建物理卷

```
pvcreate /dev/sdb /dev/sdc
```

2. 把两块硬盘设备加入到data卷组中，然后查看卷组的状态。

```
vgcreate data /dev/sdb /dev/sdc
vgdisplay
```

3. 先创建一个100G大小的吧，再往上加全部空间

```
lvcreate -n vo -L 100G  data
lvextend -l +100%FREE /dev/data/vo 
```
4. 格式化准备用

```
mkfs.xfs /dev/data/vo
如果遇到特殊情况直接执行 mkfs.xfs /dev/data/vo
```

5. 重新分配空间

```
xfs_growfs /dev/data/vo
```

6. 挂载使用

```
mount /dev/data/vo /data
```

7. 修改配置文件，配置自动挂载

```
echo "/dev/data/vo  /data xfs  defaults    0 0" >> /etc/fstab
```