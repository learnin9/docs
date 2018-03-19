鉴于Centos 默认yum源的php版本太低了，手动编译安装又有点一些麻烦，那么如何采用Yum安装的方案安装最新版呢。那么，今天我们就来学习下如何用yum安装php最新版。


1.检查当前安装的PHP包

```
yum list installed | grep php  
```

2.如果有安装的PHP包，先删除他们

```
yum remove php.x86_64 php-cli.x86_64 php-common.x86_64 php-gd.x86_64 php-ldap.x86_64 php-mbstring.x86_64 php-mcrypt.x86_64 php-mysql.x86_64 php-pdo.x86_64 
```

配置yum源

追加CentOS 6.5的epel及remi源

```
rpm -Uvh http://ftp.iij.ad.jp/pub/linux/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
```
以下是CentOS 7.0的源

```
yum install epel-release
rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
```

使用yum list命令查看可安装的包(Packege)

```
yum list --enablerepo=remi --enablerepo=remi-php56 | grep php
```

 	
安装PHP5.6.x

yum源配置好了，下一步就安装PHP5.6。

```
yum install --enablerepo=remi --enablerepo=remi-php56 php php-opcache php-devel php-mbstring php-mcrypt php-mysqlnd php-phpunit-PHPUnit php-pecl-xdebug php-pecl-xhprof
```

用PHP命令查看版本

```
# php --version
  PHP 5.6.0 (cli) (built: Sep  3 2014 19:51:31)
  Copyright (c) 1997-2014 The PHP Group
  Zend Engine v2.6.0, Copyright (c) 1998-2014 Zend Technologies
    with Zend OPcache v7.0.4-dev, Copyright (c) 1999-2014, by Zend Technologies
    with Xdebug v2.2.5, Copyright (c) 2002-2014, by Derick Rethans
```

安装PHP-fpm

```
yum install --enablerepo=remi --enablerepo=remi-php56 php-fpm  
```









