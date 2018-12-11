# /bin/bash!
# 仅适配于CenOS7_x86_64
yum -y install epel-release ; yum -y install vim wget ftp git python-pip libvirt-python libxml2-python python-websockify supervisor* nginx* gcc python-devel
yum -y groupinstall "Development Tools"
pip install numpy
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0
chkconfig iptables off && service iptables stop
chkconfig firewalld off && service firewalld stop
chkconfig nginx on && chkconfig supervisord on

mkdir -p /app
cd /app/ && git clone git://github.com/retspen/webvirtmgr.git
cd webvirtmgr
pip install -r requirements.txt

# Configuration database
echo "##########################################################################################################"
echo "#     You just installed Django's auth system, which means you don't have any superusers defined."
echo "#     Would you like to create one now? (yes/no): yes (Put: yes) "
echo "#     Username (Leave blank to use 'admin'): admin (Put: your username or login)"
echo "#     E-mail address: username@domain.local (Put: your email)"
echo "#     Password: xxxxxx (Put: your password)"
echo "#     Password (again): xxxxxx (Put: confirm password)"
echo "#     Superuser created successfully."
echo "##########################################################################################################"
echo "正在设置数据库,请按照上述例子输入相关信息...."
python manage.py syncdb
# Add Database administrator for webvirtmagr, no System administrator!
echo "###################################################"
echo "请输入数据库管理密码,注意,该用户并非WEB登录密码    "
echo "###################################################"
python manage.py collectstatic

#Create an Account, Account Login and Password Information
echo "#####################################################"
echo "           请输入管理员密码,用于WEB登录管理         "
echo "####################################################"

python manage.py createsuperuser

# setup nginx

touch  /etc/nginx/conf.d/webvirtmgr.conf

cat > /etc/nginx/conf.d/webvirtmgr.conf  << _BEOF
server {
    listen 80 default_server;

    server_name $hostname;
    access_log  off; 

    location /static/ {
        root /app/webvirtmgr;
        expires max;
    }

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-for $proxy_add_x_forwarded_for;
        proxy_set_header Host $host:$server_port;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 600;
        proxy_read_timeout 600;
        proxy_send_timeout 600;
        client_max_body_size 8192M; # Set higher depending on your needs 
    }
}

_BEOF


chown -R nginx:nginx /app/webvirtmgr

touch /etc/supervisord.d/webvirtmgr.ini

cat > /etc/supervisord.d/webvirtmgr.ini  << _EEOF
[program:webvirtmgr]
command=/usr/bin/python /app/webvirtmgr/manage.py run_gunicorn -c /app/webvirtmgr/conf/gunicorn.conf.py
directory=/app/webvirtmgr
autostart=true
autorestart=true
logfile=/dev/null
log_stderr=true
user=nginx

[program:webvirtmgr-console]
command=/usr/bin/python /app/webvirtmgr/console/webvirtmgr-console
directory=/data/www/webvirtmgr
autostart=true
autorestart=true
stdout_logfile=/dev/null
redirect_stderr=true
user=nginx

_EEOF

echo "正在给NGINX添加SSH私钥,请脚本如有停止请回车"
echo "正在给NGINX添加SSH私钥,请脚本如有停止请回车"
echo "正在给NGINX添加SSH私钥,请脚本如有停止请回车"

cd /var/lib/nginx
mkdir .ssh
chown -Rf nginx:nginx .ssh
chmod -Rf 700 .ssh
su - nginx -s /bin/bash <<_EOF
cd ~/.ssh/
echo | ssh-keygen -t rsa
#send "\r"
#send "\r"
#send "\r"
exit;
_EOF

service nginx restart && service supervisord restart 
echo "####################"
echo "   Install   OK！ "
echo "####################"
