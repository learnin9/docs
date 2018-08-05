# Nginx负载均衡

> nginx监听本地的80端口，并将请求转发到localhost:18080，localhost:18081和localhost:18082三个app中的一个，映射的策略是ip_hash，这个策略会对请求的ip进行hash运算并将结果映射到其中一个app，它能确保一个确定的请求ip会被映射到一个确定的服务，这样就连session的问题也不用考虑了。

* 可以添加一个.conf文件，格式大体上和下面差不多，如果是代理后端的其它服务器，可以根据具体的需求进行修改地址

```
upstream myapp1 {
        ip_hash;
            server localhost:18080;
            server localhost:18081;
            server localhost:18082;
}
server {
            listen 80;
            location / {
                proxy_pass http://myapp1;
                proxy_set_header   Host             $host;
                proxy_set_header   X-Real-IP        $remote_addr;
                proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
        }
}
```
