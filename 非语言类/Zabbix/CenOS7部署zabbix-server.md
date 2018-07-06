# Zabbix3.4.1 监控平台部署

---

**环境依赖**

* CentOS 7.3 + PHP5.4 + MariaDB + Nginx
* Zabbix Server 3.4.1

**环境要求**

* 12 CPU ，最少8 CPU
* 32G 内存，最少16G
* 1T 硬盘，最少500G，最好用RAID，如果监控的服务器数量较多，建议采用RAID10

**安装过程**

* 安装CentOS7.3，分区如下

```auto
/boot   500M
swap    16G
/       50G
/var    剩下所有空间，如果做了RAID，建议将RAID划分给 /var
```

* 关闭Firewalld和SElinux

```auto
# systemctl disable firewalld.service && systemctl stop firewalld.service
# sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
# setenforce 0
```

* 安装zabbix server YUM源

```auto
# yum -y install vim wget lsof net-tools -y
# wget http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm
# rpm -ivh zabbix-release-3.4-2.el7.noarch.rpm
# yum install zabbix-server-mysql zabbix-web-mysql -y
```

* 安装Nginx+PHP+MariaDB

```auto
# rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
# yum install php php-fpm mariadb mariadb-server nginx -y
```

* 复制www目录

```auto
# mkdir -p /data/html/zabbix
# cd /usr/share/zabbix/ && cp -r * /data/html/zabbix/
# chown -Rf apache:apache /data/html/zabbix/* && chmod -Rf 755 /data/html/zabbix/*
```

* 配置Nginx+HTTPS

```auto
生成自签名证书，先创建一个存放证书的目录
# mkdir -p /etc/nginx/cert && cd /etc/nginx/cert
创建服务器私钥，会提示输入一个口令
# openssl genrsa -des3 -out nginx.key 2048
创建签名请求的证书(CSR)
# openssl req -new -key nginx.key -out nginx.csr
加载SSL支持的Nginx并使用上述私钥时除去必须的口令
# cp nginx.key nginx.key.org
# openssl rsa -in nginx.key.org -out nginx.key
标记证书使用上述私钥和CSR
# openssl x509 -req -days 365 -in nginx.csr -signkey nginx.key -out nginx.crt
# openssl dhparam -out dhparams.pem 2048
备份默认配置文件
# cd /etc/nginx/conf.d/ && mv default.conf default.conf.back
编辑新的zabbix.conf
# vim /etc/nginx/conf.d/zabbix.conf
写入以下内容
···
#http
server {

        listen       80;
        server_name  localhost;
        rewrite ^(.*) https://192.168.1.1$1 permanent;     
        #为了安全起见，配置了80重定向到443,IP地址自己根据环境定义

        location / {
            root   /data/html/zabbix/;
            index  index.html index.htm index.php;
          }

       location ~ \.php$ {
         root           /data/html/zabbix/;
         fastcgi_pass   127.0.0.1:9000;
         fastcgi_index  index.php;
         fastcgi_param  SCRIPT_FILENAME  /data/html/zabbix/$fastcgi_script_name;
         include        fastcgi_params;
          }

}
#https
server {

         listen 443;
         server_name localhost;
         ssl on;
         ssl_certificate       /etc/nginx/cert/nginx.crt;
         ssl_certificate_key   /etc/nginx/cert/nginx.key;
         ssl_dhparam           /etc/nginx/cert/dhparams.pem;
         ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
         ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
         ssl_prefer_server_ciphers on;
         ssl_session_cache shared:SSL:20m;
         ssl_session_timeout 180m;

         location / {
            root /data/html/zabbix/;
            index index.html index.htm index.php;

        }

         error_page 404 /404.html;
         error_page 500 502 503 504 /50x.html;
         location = /50x.html {
             root /data/html;
        }

          location ~ \.php$ {
            root /data/html/zabbix/;
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME /data/html/zabbix/$fastcgi_script_name;
            include fastcgi_params;
       }

}
```

* 配置数据库

```auto
启动数据库
# systemctl start mariadb.service && systemctl enable mariadb.service
设置数据库root管理员的密码
# mysqladmin -u root password "Talent123"
登录数据库
# mysql -uroot -pTalent123
mysql> create database zabbix character set utf8;    //创建zabbix数据库
mysql> insert into mysql.user(Host,User,Password) values("localhost","zabbix",password("Talent123"));  //添加admin用户
mysql> flush privileges;     //刷新权限表
mysql> grant all privileges on zabbix.* to zabbix@localhost identified by 'Talent123';    //将zabbix授权给admin
mysql> flush privileges;    //刷新权限表
mysql> exit
# cd /usr/share/doc/zabbix-server-mysql-3.4.1
# gunzip create.sql.gz 
# mysql -uadmin -pTalent123 zabbix < create.sql
# systemctl restart mariadb.service
```

**提示**

上面导入初始数据库的方法可能存在问题，我是选取了最笨的办法，先下载了`zabbix-3.4.1.tar.gz`

```auto
# wget https://sourceforge.net/projects/zabbix/files/latest/zabbix-3.4.1.tar.gz
# tar -zxvf zabbix-3.4.1.tar.gz
# cd zabbix-3.4.1
导入数据
# mysql -uroot -p zabbix < database/mysql/schema.sql
# mysql -uroot -p zabbix < database/mysql/data.sql
# mysql -uroot -p zabbix < database/mysql/images.sql
# service mariadb restart
```

* 配置PHP，修改php.ini

```auto
# vim /etc/php.ini
···
date.timezone = Asia/Shanghai
upload_max_filesize 2M
max_execution_time = 300
max_input_time = 300
post_max_size = 32M
memory_limit = 128M
···
启动php-fpm
# service php-fpm start && chkconfig php-fpm on
启动nginx
# systemctl enable nginx.service && systemctl start nginx.service
```

* 配置zabbix\_server

```auto
# vim /etc/zabbix/zabbix_server.conf
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=Talent123
启动zabbix server
# service zabbix-server start && chkconfig zabbix-server on
```

* 安装zabbix-agent

```auto
RHEL6系列按照如下命令安装
# wget http://repo.zabbix.com/zabbix/3.4/rhel/6/x86_64/zabbix-agent-3.4.1-1.el6.x86_64.rpm
# yum install zabbix-agent-3.4.1-1.el6.x86_64.rpm -y
RHEL7系列按照如下命令安装
# wget http://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-agent-3.4.1-1.el7.x86_64.rpm
# yum install zabbix-agent-3.4.1-1.el7.x86_64.rpm -y
修改agent客户端的配置文件
# vim /etc/zabbix/zabbix_agentd.conf
修改y以下地方内容
···
Server=192.168.1.1
ServerActive=192.168.1.1
#Hostname和自己的主机名不一致没关系，但是必须和在zabbix监控平台添加时的主机名一致，否则会产生错误日志
Hostname=ad1.cloud.top
···
```

* 启动zabbix-agent客户端服务

```auto
# service zabbix-agent start && chkconfig zabbix-agent on
```
`vim /etc/sudoers`

```
Defaults:zabbix    !requiretty
zabbix  ALL=NOPASSWD:ALL
```

