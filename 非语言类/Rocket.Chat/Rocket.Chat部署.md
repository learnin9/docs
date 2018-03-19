# Rocket.Chat
---
官方给出的文档也个人觉得太麻烦了，并且对ubuntu的支持程度远高于CentOS，自己就折腾写了个安装的笔记

官方文档：https://rocket.chat/docs/installation/manual-installation/centos/

**环境依赖**
* CentOS6.5
* Nginx
* Mongodb v2

**安装步骤**

* 安装Nginx

```auto
rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
yum -y install nginx
```
* 安装Mongodb

```auto
vim /etc/yum.repos.d/mongodb.repo
```

写入以下内容

```auto
[mongodb]
name=MongoDB Repository
baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/
gpgcheck=0
enabled=1
```

Run

```auto
yum -y install epel-release curl GraphicsMagick gcc-c++ mongodb-org
```
提前配置数据库

```auto
mongo
>use rocketchat     //添加数据库
>exit
service mongod restart
```
* 安装node.js

这里就按照官方给出的文档安装了，那个有点麻烦

```auto
curl --silent --location https://rpm.nodesource.com/setup_4.x | bash -
yum -y install nodejs
```
* 安装Rocket.Chat

```auto
cd /opt

curl -L https://rocket.chat/releases/latest/download -o rocket.chat.tgz
tar zxvf rocket.chat.tgz

mv bundle Rocket.Chat
cd Rocket.Chat/programs/server

npm install

cd ../..
```

配置 PORT, ROOT_URL and MONGO_URL:

```auto
export PORT=3000
export ROOT_URL=http://your-host-name.com-as-accessed-from-internet:3000/
export MONGO_URL=mongodb://localhost:27017/rocketchat
```

启动服务

```auto
service mongod restart && chkconfig mongod on
service nginx start && chkconfig nginx on
```

* 启动服务

```auto
node main.js
```
现在就能登录`http://your-host-name.com-as-accessed-from-internet:3000/`进行访问了

## 配置Nginx+SSL代理

* 安装nginx

```auto
 rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
yum -y install nginx
```
CentOS7下运行下面的命令安装Nginx

```auto
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
yum -y install nginx
```

* 配置Nginx

创建自签证书

```auto
首先，创建证书和私钥的目录
# mkdir -p /etc/nginx/cert
# cd /etc/nginx/cert
创建服务器私钥，命令会让你输入一个口令：
# openssl genrsa -des3 -out nginx.key 2048
创建签名请求的证书（CSR）：
# openssl req -new -key nginx.key -out nginx.csr
在加载SSL支持的Nginx并使用上述私钥时除去必须的口令：
# cp nginx.key nginx.key.org
# openssl rsa -in nginx.key.org -out nginx.key
最后标记证书使用上述私钥和CSR：
# openssl x509 -req -days 365 -in nginx.csr -signkey nginx.key -out nginx.crt
```

配置rocketchat.conf

vim /etc/nginx/nginx.d/rocketchat.conf  
注意将默认的default.conf删除掉，不然影响80端口

```auto
# Upstreams
upstream backend {
    server 127.0.0.1:3000;
}

# Redirect Options
server {
  listen 80;
  server_name im.mydomain.com;
  # enforce https
  rewrite ^(.*) https://$server_name$request_uri;
}

# HTTPS Server
server {
    listen 443;
    server_name im.mydomain.com;

    error_log /var/log/nginx/rocketchat.access.log;

    ssl on;
    ssl_certificate /etc/nginx/cert/nginx.crt;
    ssl_certificate_key /etc/nginx/cert/nginx.key;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

    location / {
        proxy_pass http://127.0.0.1:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;

        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forward-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forward-Proto http;
        proxy_set_header X-Nginx-Proxy true;

        proxy_redirect off;
    }
}
```

##  Auto Start Rocket.Chat

* CentOS7

CentOS7下推荐如下配置，添加一个服务项：

```auto
[Unit]
  Description=The Rocket.Chat server
  After=network.target remote-fs.target nss-lookup.target nginx.target mongod.target
  [Service]
  ExecStart=/usr/local/bin/node /opt/Rocket.Chat/main.js
  StandardOutput=syslog
  StandardError=syslog
  SyslogIdentifier=rocketchat
  User=root
  Environment=MONGO_URL=mongodb://localhost:27017/rocketchat ROOT_URL=http://your-host-name.com-as-accessed-from-internet:3000/ PORT=3000
  [Install]
  WantedBy=multi-user.target
```

Now you can enable this service by running:

```auto
systemctl enable rocketchat.service
systemctl start  rocketchat.service
```

* CentOS6

CentOS6下推荐使用Supervisor服务,需要我们写个脚本来自动执行，这样的话就能免去很多步骤
```auto
vim /opt/Rocket.Chat/start.sh
脚本内容如下：
···
#/bin/bash
cd /opt/Rocket.Chat

```

安装supervisor

```auto
yum install supervisor
```
编辑脚本并添加执行全权限

vim /opt/Rocket.Chat/start.sh
chmod +x /opt/Rocket.Chat/start.sh
脚本内容如下

```auto
export PORT=3000
export ROOT_URL=http://your-host-name.com-as-accessed-from-internet:3000/    //根据自己的环境修改配置
export MONGO_URL=mongodb://localhost:27017/rocketchat
node /opt/Rocket.Chat/main.js
```
创建存放日志的目录

```auto
mkdir -p /var/log/supervisor/
```

配置supervisord服务

```auto
vim /etc/supervisord.conf
```

在最后添加一下内容

```auto
[program:rocketchat]
command=bash /opt/Rocket.Chat/start.sh
directory=/opt/Rocket.Chat
autostart=true
autorestart=true
logfile=/var/log/supervisor/rocketchat.log
log_stderr=true
user=root
```

启动supervisor

```auto
service supervisord start && chkconfig supervisord on
```
此时rocket也就一起起来了
