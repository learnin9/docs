# ---------
Nginx的upstream模块相当于是建立一个函数库一样，把后端的服务器地址放在了一个池子里，而proxy模块则是从这个池子里调用了这些服务器。
http_proxy_module模块常用参数：
proxy_set_header：让后端服务器能获取到前端用户真实IP，而不只是代理服务器的IP
proxy_set_header Host $host;   
#当后端服务器配置多个web站点时，该选项可以让服务器识别出具体要访问的是哪个站点，而不会将第一个站点作为默认站点传递给用户
proxy_set_header X-Forwarded-For $remote_addr;   
#如果后端服务器需要获取用户的真实IP，需要该选项
client_body_buffer_size：客户端请求主体缓冲区大小
proxy_connect_timeout：代理服务器和后端真实服务器握手连接超时时间
proxy_send_timeout：后端服务器回传数据给Nginx的时间，需要在设置的时间范围内发送完所有数据，否则Nginx将断开连接
proxy_read_timeout：代理服务器和后端服务器连接成功后，等待后端服务器响应时间
前端Nginx反向代理，如何获取客户端真实IP？
#转发动态页面给Tomcat处理

```
location ~ \.(jsp|jspx|do)?$ {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://tomcat_server;
```
