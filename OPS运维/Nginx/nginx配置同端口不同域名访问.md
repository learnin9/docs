# Nginx设置相同端口不同域名访问的站点

```
server {
   listen    80;
   server_name www.abc.com;
   location / {
       root  html/abc;
       index index.html index.htm
   }
}

server {
   listen    80;
   server_name www.abd.com;
   location / {
       root  html/abd;
       index index.html index.htm
   }
}

server {
   listen    80;
   server_name www.abe.com;
   location / {
       root  html/abe;
       index index.html index.htm
   }
}
```
