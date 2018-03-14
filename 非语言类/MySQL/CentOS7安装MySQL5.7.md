安装环境：CentOS7 64位 MINI版，安装MySQL5.7
1. 配置YUM源,在MySQL官网中下载YUM源rpm安装包：http://dev.mysql.com/downloads/repo/yum/ 

* 下载mysql源安装包

```
wget http://dev.mysql.com/get/mysql57-community-release-el7-8.noarch.rpm
```

* 安装mysql源

```
yum install mysql57-community-release-el7-8.noarch.rpm
```

* 检查mysql源是否安装成功

```
yum repolist enabled | grep "mysql.*-community.*"
```

 
可以修改vim /etc/yum.repos.d/mysql-community.repo源，改变默认安装的mysql版本。比如要安装5.6版本，将5.7源的enabled=1改成enabled=0。然后再将5.6源的enabled=0改成enabled=1即可。改完之后的效果如下所示： 
这里写图片描述



2. 安装MySQL


```
yum install mysql-community-server
```


3. 启动MySQL服务

```
systemctl start mysqld
```

4. 查看MySQL的启动状态

```angular2html
systemctl status mysqld

●mysqld.service-MySQLServer
Loaded:loaded(/usr/lib/systemd/system/mysqld.service;disabled;vendorpreset:disabled)
Active:active(running)since五2016-06-2404:37:37CST;35minago
MainPID:2888(mysqld)
CGroup:/system.slice/mysqld.service
└─2888/usr/sbin/mysqld--daemonize--pid-file=/var/run/mysqld/mysqld.pid
6月2404:37:36localhost.localdomainsystemd[1]:StartingMySQLServer...
6月2404:37:37localhost.localdomainsystemd[1]:StartedMySQLServer.
```

4、开机启动

```
systemctl enable mysqld
systemctl daemon-reload
```

5. 修改root本地登录密码,mysql安装完成之后，在/var/log/mysqld.log文件中给root生成了一个默认密码。通过执行`grep'temporarypassword'/var/log/mysqld.log`找到root默认密码，然后登录mysql进行修改：




* 修改密码

```
shell>mysql -u root -p
mysql> ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass4!';
```

* 在/etc/my.cnf文件添加validate_password_policy配置，指定密码策略

选择0（LOW），1（MEDIUM），2（STRONG）其中一种，选择2需要提供密码字典文件

`validate_password_policy=0`

如果不需要密码策略，添加my.cnf文件中添加如下配置禁用即可：
`validate_password=off`
重新启动mysql服务使配置生效：


6. 添加远程登录用户

默认只允许root帐户在本地登录，如果要在其它机器上连接mysql，必须修改root允许远程连接，或者添加一个允许远程连接的帐户，为了安全起见，我添加一个新的帐户：

```
mysql>GRANT ALL PRIVILEGES ON *.* TO 'yangxin'@'%' IDENTIFIED BY 'Yangxin0917!' WITH GRANT OPTION;
```

7. 配置默认编码为utf8

* 修改/etc/my.cnf配置文件，在[mysqld]下添加编码配置，如下所示：
```
[mysqld]
character_set_server=utf8
init_connect='SETNAMESutf8'
```

> 默认配置文件路径： 
* 配置文件：/etc/my.cnf 
* 日志文件：/var/log//var/log/mysqld.log 
* 服务启动脚本：/usr/lib/systemd/system/mysqld.service 
* socket文件：/var/run/mysqld/mysqld.pid