# 记录一次MySQL5.7优化

> 先说一下为什么做这个优化吧，内部使用Testlink进行产品测试用例管理,安装的环境也是非常简单的，采用LNMP; PHP用的是5.6版本的，默认安装后发现查询用例非常慢，想着怎么给优化一下，MySQL使用了主从复制


* 不说了，先贴配置，下面是主库的配置文件

```
[mysqld]

innodb_buffer_pool_size = 1G
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = true
innodb_log_buffer_size = 512M
innodb_autoextend_increment = 256M
innodb_buffer_pool_instances = 8
innodb_log_files_in_group = 2
innodb_log_file_size = 256M
innodb_flush_method = O_DIRECT

datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

validate_password=off
skip_name_resolve=on

max_allowed_packet=500M
max_connections=10000

server_id=1
log_bin=/mysql-log/mysql-bin
expire_logs_days=7

symbolic-links=0

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
```

* 从库的配置文件:

```
[mysqld]

innodb_buffer_pool_size = 1G
innodb_flush_log_at_trx_commit = 2
innodb_file_per_table = true
innodb_log_buffer_size = 512M
innodb_autoextend_increment = 256M
innodb_buffer_pool_instances = 8
innodb_log_files_in_group = 2
innodb_log_file_size = 256M
innodb_flush_method = O_DIRECT

datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

validate_password=off
skip_name_resolve=on

max_allowed_packet=500M
max_connections=100

server_id=2
log_bin=/var/lib/mysql-log/mysql-bin
relay_log=/var/lib/mysql-log/mysql-replay-bin
log_slave_updates=1
read_only=1
expire_logs_days=7

symbolic-links=0

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
```

> 因为考虑到后面主业务服务器挂了，能快速切换，两个配置文件都差不多，修改了默认的my.cnf文件并重启库、重启服务器，发现确实查询速度快了不少