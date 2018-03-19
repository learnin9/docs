### Nginx做文件下载服务器


> 添加如下的配置文件：

```
server {     
         listen        80;
         charset       utf-8;
         server_name   localhost;
         location / {    
         root   /var/ftp/;
         if ($request_filename ~* ^.*?\.(txt|doc|pdf|rar|gz|zip|docx|exe|xlsx|ppt|pptx)$){
            add_header Content-Disposition: 'attachment;';
            }        
         autoindex              on;
         autoindex_exact_size   off;
         autoindex_localtime    on;
         allow   192.168.34.0/24;         #允许34段的所有地址访问
         allow   192.168.35.0/24;         #允许35段的所有地址访问
         deny    all;                     #禁止全部
       }
} 
```
