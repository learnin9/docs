## CentOS6 部署 Tomcat

1. 安装java软件

```
yum install java-1.8.0* -y
```

2. 设置开机自启，在/etc/init.d/下新建 `tomcat` 写入以下内容：

```
#!/bin/bash
# /etc/rc.d/init.d/tomcat
# init script for tomcat precesses
# processname: tomcat
# description: tomcat is a j2se server
# chkconfig: 2345 86 16
# description: Start up the Tomcat servlet engine.

if [ -f /etc/init.d/functions ]; then
. /etc/init.d/functions
elif [ -f /etc/rc.d/init.d/functions ]; then
. /etc/rc.d/init.d/functions
else
echo -e "/atomcat: unable to locate functions lib. Cannot continue."
exit -1
fi

RETVAL=$?
CATALINA_HOME="/etc/tomcat"

case "$1" in
start)
if [ -f $CATALINA_HOME/bin/startup.sh ];
then
echo $"Starting Tomcat"
$CATALINA_HOME/bin/startup.sh
fi
;;
stop)
if [ -f $CATALINA_HOME/bin/shutdown.sh ];
then
echo $"Stopping Tomcat"
$CATALINA_HOME/bin/shutdown.sh
fi
;;
*)
echo $"Usage: $0 {start|stop}"
exit 1
;;
esac

exit $RETVAL
```


3. 保存后执行 `chkconfig --add tomcat`、`chmod +x tomcat`

4. 将tomcat的包拷贝到/etc/下进行解压重命名。然后执行`service tomcat start`启动tomcat服务，执行`chkconfig tomcat on`将tomcat加入到开机自启


5. 如果要设置使用nginx代理tomcat配置文件可参考下面的文件

```
# http
     server
     {
         listen  80;
         server_name  localhost;
         rewrite ^/(.*) https://172.19.30.101/$1 permanent;
         location / {
             proxy_pass        http://127.0.0.1:9000;
             proxy_set_header   Host             $host;
             proxy_set_header   X-Real-IP        $remote_addr;
             proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
         }
     }

# https
     server
     {
         listen  443 ssl;
         server_name  localhost;
         ssl_certificate     /etc/nginx/cert/tomcat/nginx.crt;
         ssl_certificate_key /etc/nginx/cert/tomcat/nginx.key;
         location / {
             proxy_pass        http://127.0.0.1:9000;
             proxy_set_header   Host             $host;
             proxy_set_header   X-Real-IP        $remote_addr;
             proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
         }
     }

```



## tomcat 管理员配置

需要修改`/etc/tomcat/conf/tomcat-users.xml`文件

```
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
   <role rolename="admin-gui"/>
   <role rolename="admin-script"/>
   <role rolename="manager-gui"/>
   <role rolename="manager-script"/>
   <role rolename="manager-jmx"/>
   <role rolename="manager-status"/>
   <user username="admin" password="admin" roles="manager-gui,manager-script,manager-jmx,manager-status,admin-script,admin-gui"/>
</tomcat-users>
```

上面的admin / admin 是用户名和密码，生产环境务必修改
