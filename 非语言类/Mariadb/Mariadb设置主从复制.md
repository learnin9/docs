# mariadb的主从同步和读写分离

>  数据库的优化设计对以后web项目能否承担高并发所带来的巨大负担是个非常好的解决方案。主从同步和读写分离就是个常用的方法，主数据库用来写入数据，从数据库用来查询，分担了主数据库的一大部分工作，这样做的好处是当主服务器崩了之后，还是在从服务器上获取到数据，起到的备份的作用。接下来说说如何实现数据库的主从同步和读写分离看个人情况，可有三四台主机都没问题。本人现在是用2台服务器，实现2台服务器数据库的主从同步。我把阿里云主机的数据库作为主数据库，腾讯云主机的数据库作为从数据库，两台主机的系统都是centos7，mariadb的版本为5.5.52


## 配置主数据库：

* 用vim打开`my.cnf`：

添加如下配置:
```
server-id=1   #主数据库的id  
log-bin=master-bin   #日志路径，作用是从数据库是根据这个日志来复制主数据库的数据的      
```
* 登录mariadb，授权远程用户（slaveuser为用户名和密码   “127.0.0.1”为远程服务器的地址，这里需要改成自己服务器的地址）

```
grant replication slave on *.* to 'slaveuser'@'127.0.0.1' identified by 'slaveuser';  
flush privileges;  
```

* 重启mariadb服务
* 在主服务器的数据库上查询主服务状态 

```
SHOW MASTER STATUS  
```

## 配置从数据库

* 用vim打开my.cnf，写入下面的配置

```
server-id=2   #这个id必须不能和主数据库相同  
read-only=on  #设置该数据库是只读状态  
relay-log=relay-bin  #日志  
```

* 重启mariadb服务,进入从服务器的数据库：master_host需改为自己的主服务器地址

```
change master to master_host='127.0.0.1',master_user='slaveuser',master_password='slaveuser', master_log_file='master-bin.000005',master_log_pos=882;  
START SLAVE;
show slave status\G  
```
> 查看Slave_IO_Running和Slave_SQL_Running是否都为yes（一定要全部为yes。否则就是你配置错了，再重新配置一遍从数据库）









