```
[mysqld]

datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock

validate_password_policy=0

character-set-server=utf8
collation-server=utf8_unicode_ci

max_allowed_packet=500M
max_connections = 1000
symbolic-links=0

default-storage-engine=INNODB
innodb_log_file_size=2GB

log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
```
