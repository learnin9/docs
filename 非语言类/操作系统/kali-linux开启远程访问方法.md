# kali-linux开启远程访问方法

* 修改/etc/ssh/sshd_conf

将将PermitRootLogin without-password修改为PermitRootLogin yes

* `service ssh restart`重启ssh服务


* `update-rc.d ssh enable` 开启ssh开机自启

* `vim /etc/apt.conf` 配置代理服务器（如果是无法直接访问互联网），写入一下内容

```
Acquire::http::Proxy "http://192.168.59.241:8888";
```


* 配置apt源，建议使用中科大kali源，`vim /etc/apt/sources.list`

```
deb http://mirrors.ustc.edu.cn/kali kali-rolling main non-free contrib
```

* 自动更新命令: `apt-get update && apt-get upgrade && apt-get dist-upgrade`

