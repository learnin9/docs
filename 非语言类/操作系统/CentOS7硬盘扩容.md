#### 集群的存储节点硬盘空间不多了，添加一块新的200硬盘上去

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

7. 查看centos的大小是否已经扩容

```
df -hl                         
```