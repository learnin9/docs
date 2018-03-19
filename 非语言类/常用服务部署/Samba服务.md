### Samba


**服务简介**

目前samba服务器虽然还会是有很多诟病，但是很多情况下还是哟必要使用这个服务的，很多公司内部都是需要使用文件共享来做文件分享与传输，使用第三方服务还存在是否需要付费。

#### Samba部署

还是用centos6吧，毕竟已经用习惯了，但是这项服务其实在centos7下没有什么区别的
``` auto
yum install samba -y
chkconfig smb on && service smb start
```
#### Samba服务自定义
这里其实最简单的还是自己添加一个共享吧
```auto
[smb]
         comment = smb           #定义连接名称
         path = /var/ftp         #定义共享的目录，这里我是为了和FTP服务整合到一起，所以自己使用了这个目录
         browseable = no         #smb连接的时候是否会自动显示连接名称，稍微安全隐私一点吧
         create mask = 0755      #自定义创建文件的权限
         directory mask = 0755   #自定义创建目录的权限
         write list = admin      #定义admin用户拥有写的权限
         read list = admin       #定义admin用户拥有读的权限
         guest ok = no           #关闭匿名访问
```
> 上面的文件其实自定义是完全可以的，我们可以针对不同的部门添加不同的权限以及访问目录
