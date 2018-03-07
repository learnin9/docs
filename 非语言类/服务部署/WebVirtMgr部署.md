# System Optimization(Only CentOS6.X\)

```auto
# sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
# LANG=en
# for root in `chkconfig --list|grep 3:on|awk '{print $1}'`;do chkconfig --level 3 $root off;done
# for root in crond network rsyslog sshd;do chkconfig --level 3 $root on;done
# chkconfig --list|grep 3:on
```

# Install WebVirtMgr

## 1. Installation

### CentOS/RHEL 6.x


```
# yum -y install epel-release
# yum -y install vim wget ftp git python-pip libvirt-python libxml2-python python-websockify supervisor nginx
```

### CentOS 7.x



```
# yum -y install epel-release
# yum -y install vim wget ftp git python-pip libvirt-python libxml2-python python-websockify supervisor nginx  
# yum -y install gcc python-devel
# pip install numpy
```

## 2. Install python requirements and setup Django environment



```
# git clone git://github.com/retspen/webvirtmgr.git
# cd webvirtmgr
# pip install -r requirements.txt
# ./manage.py syncdb          //Configuration database
# ./manage.py collectstatic   //Add Database administrator for webvirtmagr, no System administrator!
```

Enter the user information:

```
You just installed Django's auth system, which means you don't have any superusers defined.
Would you like to create one now? (yes/no): yes (Put: yes)
Username (Leave blank to use 'admin'): admin (Put: your username or login)
E-mail address: username@domain.local (Put: your email)
Password: xxxxxx (Put: your password)
Password (again): xxxxxx (Put: confirm password)
Superuser created successfully.
```

### Adding additional superusers



```
# ./manage.py createsuperuser     //Create an Account, Account Login and Password Information
```

## 3. Setup Nginx

**Warning**: Usually WebVirtMgr is only available from localhost on port 8000. This step will make WebVirtMgr available to everybody on port 80. The webinterface is also unprotected \(no https\), which means that everybody in between you and the server \(people on the same wifi, your local router, your provider, the servers provider, backbones etc.\) can see your login credentials in clear text!

Instead you can also skip this step completely + uninstall nginx. By simply redirecting port 8000 to your local machine via SSH. This is much safer because WebVirtMgr is not available to the public any more and you can only access it over an encrypted connection.

Example:

```
# ssh user@server:port -L localhost:8000:localhost:8000 -L localhost:6080:localhost:6080
```

You should be able to access WebVirtMgr by typing localhost:8000 in your browser after completing the install. Port 6080 is forwarded to make noVNC work.

If you really know what you are doing, feel free to ignore the warning and continue setting up the redirect with nginx:

```
# cd ..  
# mkdir -p /data/www
# mv webvirtmgr /data/www/
```

Add file `webvirtmgr.conf` in `/etc/nginx/conf.d`

```
server {
    listen 80 default_server;

    server_name $hostname;
    access_log  off; 

    location /static/ {
        root /data/www/webvirtmgr;
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
        client_max_body_size 1024M; # Set higher depending on your needs 
    }
}
```

Delete `default.conf`

```auto
# cd /etc/nginx/conf.d && rm -rf default.conf
```

Open nginx.conf out of `/etc/nginx/nginx.conf` \(in Ubuntu 14.04 LTS the configuration is in `/etc/nginx/sites-enabled/default`\):

```
# vim /etc/nginx/nginx.conf
```

Comment the Server Section as it is shown in the example:

```
#    server {
#        listen       80 default_server;
#        server_name  localhost;
#        root         /usr/share/nginx/html;
#
#        #charset koi8-r;
#
#        #access_log  /var/log/nginx/host.access.log  main;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        location / {
#        }
#
#        # redirect server error pages to the static page /40x.html
#        #
#        error_page  404              /404.html;
#        location = /40x.html {
#        }
#
#        # redirect server error pages to the static page /50x.html
#        #
#        error_page   500 502 503 504  /50x.html;
#        location = /50x.html {
#        }
#    }
```

Restart nginx service:

```
# service nginx restart && chkconfig nginx on
```

Update SELinux policy

```
# setsebool httpd_can_network_connect true
```

make it permanet service:

```
# chkconfig supervisord on
```

## 4. Setup Supervisor

### CentOS, RedHat, Fedora



```
# chown -R nginx:nginx /data/html/webvirtmgr
```

Open supervisord.conf in `/etc/supervisord.conf` with following content:

```
[program:webvirtmgr]
command=/usr/bin/python /data/www/webvirtmgr/manage.py run_gunicorn -c /data/www/webvirtmgr/conf/gunicorn.conf.py
directory=/data/www/webvirtmgr
autostart=true
autorestart=true
logfile=/var/log/supervisor/webvirtmgr.log
log_stderr=true
user=nginx

[program:webvirtmgr-console]
command=/usr/bin/python /data/www/webvirtmgr/console/webvirtmgr-console
directory=/data/www/webvirtmgr
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/webvirtmgr-console.log
redirect_stderr=true
user=nginx
```

### Restart supervisor daemon

```auto
# service supervisord restart && chkconfig supervisord on
```

### WebVirtMgr :Make it permanet service

```
# vim /etc/rc.d/rc.local
...
nohup ./data/www/webvirtmgr/manage.py runserver 0.0.0.0:8000 & 
...
```

### Reboot System

# Setup SSH Authorization

---

# For new versions of webvirtmgr

1. Create SSH private key and ssh config options \(On system where WebVirtMgr is installed\):

```auto
# cd /var/cahce/nginx
# mkdir .ssh 
# chown -Rf nginx:nginx .ssh 
# chmod -Rf 700 .ssh
# su - nginx -s /bin/bash
```

```auto
$ ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (path-to-id-rsa-in-nginx-home):   Just hit Enter here!
$ touch ~/.ssh/config && echo -e "StrictHostKeyChecking=no\nUserKnownHostsFile=/dev/null" >> ~/.ssh/config
$ chmod -Rf 0600 ~/.ssh/config
```

1. Copy public key to qemu-kvm/libvirt host server:

```auto
# su - nginx -s /bin/bash
$ ssh-copy-id root@emu-kvm-libvirt-host
if you changed the default SSH port use:
$ ssh-copy-id -P YOUR_SSH_PORT root@qemu-kvm-libvirt-host

Now you can test the connection by entering:
$ ssh root@qemu-kvm-libvirt-host
```

# Setup TCP Authorization

---

### Setup Host Server

### Supported Linux distributions

CentOS 6.3, RedHat 6.3 and above

Fedora 18 and above

Debian Testing, Ubuntu 12.04 and above

### Setup libvirt and KVM

```
# curl http://retspen.github.io/libvirt-bootstrap.sh | sudo sh
```

or if haven't `curl`

```
# wget -O - http://retspen.github.io/libvirt-bootstrap.sh | sudo sh
```

### Configuring the firewall

#### CentOS 6, Fedora 18, RedHat EL6

Open access to libvirt port

```
# iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 16509 -j ACCEPT
```

#### CentOS 7, Fedora 19+, RedHat EL7 \(and other distributions utilizing firewalld\)

Find your firewalld zones:

```
# firewall-cmd --get-active-zones
```

The zone for the interface which connects the libvirt host and the webvirtmgr host is in the public zone by default, so the command is:

```
# firewall-cmd --zone=public --add-port 16509/tcp --permanent
```

```
# firewall-cmd --reload
```

Otherwise substitute --zone=public in the above for the correct zone.

Adding users and setting their passwords is done with the `saslpasswd2` command. When running this command it is important to tell it that the appname is `libvirt`. As an example, to add a user `admin`, run

```
# saslpasswd2 -a libvirt admin
Password: xxxxxx
Again (for verification): xxxxxx
```

To see a list of all accounts the `sasldblistusers2` command can be used. This command expects to be given the path to the libvirt user database, which is kept in `/etc/libvirt/passwd.db`

```
# sasldblistusers2 -f /etc/libvirt/passwd.db
admin@webvirtmgr.net: userPassword
```

To disable a user's access, use the command `saslpasswd2` with the `-d`

```
# saslpasswd2 -a libvirt -d admin
```

### Verify settings

Before you add the ip address of your server in the control center perform the following test

```
# virsh -c qemu+tcp://IP_address/system nodeinfo
Please enter your authentication name: admin
Please enter your password: xxxxxx
CPU model:           x86_64
CPU(s):              2
CPU frequency:       2611 MHz
CPU socket(s):       1
Core(s) per socket:  2
Thread(s) per core:  1
NUMA cell(s):        1
Memory size:         2019260 kB
```

If you have same error:

```
# virsh -c qemu+tcp://IP_address/system nodeinfo
Please enter your authentication name: admin
Please enter your password:
error: authentication failed: authentication failed
error: failed to connect to the hypervisor
```

Try input login with domain \(hostname\):

```
# sasldblistusers2 -f /etc/libvirt/passwd.db
admin@webvirtmgr.net: userPassword
```



