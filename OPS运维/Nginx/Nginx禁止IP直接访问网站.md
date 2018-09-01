> 禁止别人直接通过IP访问网站，在nginx的server配置文件前面加上如下的配置，如果有通过IP直接访问的，直接拒绝连接(需要去掉别的server下的default_server)。

```
server {
    listen   80 default_server;
    listen   [::]:80 default_server;
    server_name  _;
    return 444;
}
```
