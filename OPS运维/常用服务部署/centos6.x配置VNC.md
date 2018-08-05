1.安装软件包

```auto
# yum install tigervnc-server -y
```
更改配置文件

```auto
vim /etc/sysconfig/vncservers
```
添加一下内容

```auto
VNCSERVERS=“2:root 3:admin 4:support”
VNCSERVERARGS[2]="-geometry 1440x900"
VNCSERVERARGS[3]="-geometry 1440x900"
VNCSERVERARGS[4]="-geometry 1440x900"
```
 
其他设置

```auto
vncpasswd  设置vnc用户root的密码
server vncserver reload  重启服务
```