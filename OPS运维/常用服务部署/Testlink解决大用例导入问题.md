
> 最近公司同事需要将别的testlink的用例迁移过来，由于现在新的服务器也在使用，不能使用数据库导入的办法，只能用xml文件进行导入，不过在导入的时候出现了个没遇到的问题，报错文件太大，无法上传。

----
解决办法:
 
* 修改`/etc/nginx/nginx.conf`,加入如下几行
```
fastcgi_connect_timeout 600;
fastcgi_send_timeout 600;
fastcgi_read_timeout 600;
client_max_body_size 100M;
```

 `nginx.conf`如下所示：

```
user nginx;
worker_processes auto;
worker_rlimit_nofile 65535;
error_log  off;
pid /var/run/nginx.pid;
include /usr/share/nginx/modules/*.conf;
events {
    worker_connections  2048;
    multi_accept on;
    use epoll;
}
http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    server_tokens       off;
    access_log          off;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    fastcgi_connect_timeout 600;
    fastcgi_send_timeout 600;
    fastcgi_read_timeout 600;
    types_hash_max_size  2048;
    client_max_body_size 100M;
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;
    include /etc/nginx/conf.d/*.conf;
}
```

* 修改`config.ini.php`,将下面两行上传大小增大
```
$tlCfg->import_file_max_size_bytes = '40960000';
$tlCfg->import_max_row = '100000'; 
```

* 修改`/etc/php.ini`
```
upload_max_filesize 100M
max_execution_time = 600
max_input_time = 600
post_max_size = 100M
memory_limit = 128M
```

* 调整mysql：MySQL根据配置文件会限制Server接受的数据包大小。有时候大的插入和更新会受 max_allowed_packet 参数限制,导致写入或者更新失败。 在`my.cnf`中加入

```
max_allowed_packet=500M
```

* 重启mysql、php-fpm、nginx服务(推荐直接重启系统，测试过程中重启后才会生效)