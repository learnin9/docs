# 使用apt-mirror部署自己的Ubuntu源 

> 一个偶然的需求,公司内部需要使用ubuntu系统做devops平台支撑,需要自己部署个镜像站用来同步需要的镜像,清华镜像站的源接近2T,太大没地搁，只要筛选了

## CentOS7

**提示**
 
*  由于公司内的镜像站已经跑在centos7了,懒得折腾ubuntu,改NGINX配置也比较麻烦,就沿用了老服务器

### INSTALL

* 默认官方的yum源是无法搜到`apt-mirror这个鬼玩意儿的,就在[这里](http://rpmfind.net/linux/rpm2html/search.php?)搜索寻找了一波，还真有~~~233
* 下载链接: wget http://rpmfind.net/linux/epel/6/x86_64/Packages/a/apt-mirror-0.5.1-1.git420c3ec.el6.noarch.rpm

直接进行安装,会在`/etc`下自动生成一个`apt-mirror.list`的文件；我们只需要 `vim /etc/apt-mirror.list` 配置这个文件即可.

```
# 自定义存储的路径,下面的配置是根据这个基础路径自动匹配的
set base_path      /app/project/mirrors/ubuntu

# 镜像文件下载地址
set mirror_path    $base_path/mirror

#临时索引下载文件目录，也就是存放软件仓库的dists目录下的文件（默认即可）
set skel_path      $base_path/skel

# 配置日志（默认即可）
set var_path      $base_path/var

# clean脚本位置
set cleanscript $var_path/clean.sh

# 下载线程数
set nthreads      20
set _tilde         0

# 架构配置，i386/amd64，默认的话会下载跟本机相同的架构的源
set defaultarch amd64

# 清华镜像站（这里没有添加deb-src的源）
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ trusty main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ trusty-security main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ trusty-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ trusty-proposed main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ trusty-backports main restricted universe multiverse

clean https://mirrors.tuna.tsinghua.edu.cn/ubuntu

```

### 开始同步

```
执行 apt-miiror
```

然后等待很长时间（该镜像差不多100G左右，具体时间看网络环境），同步的镜像文件目录为`/app/project/mirrors/ubuntu/mirror/mirrors.tuna.tsinghua.edu.cn/ubuntu/`，当然如果增加了其他的源，在`/app/project/mirrors/ubuntu/mirror/`目录下还有其他的地址为名的目录。

注意：当apt-mirror 被意外中断时，只需要重新运行即可，apt-mirror支持断点续存；另外，意外关闭，需要在/app/project/mirrors/ubuntu/var目录下面删除 apt-mirror.lock文件`rm apt-mirror.lock`，之后执行`apt-mirror`重新启动


* 配置自动同步

使用crond任务可以实现自动同步,脚本的执行目录一定要根据自己的情况做修改啊!!!

```
echo "0  */6  *  *  *  cd /app/project/mirrors/ubuntu/var/ ; rm -rf apt-mirror.lock ; apt-mirror > /dev/null 2>&1; sh /app/project/mirrors/ubuntu/var/clean.sh" >> /var/spool/cron/root
```
这样就可以每六个小时自动同步一次，并且可以自动通过`clean.sh`脚本更新镜像;


### 配置NGINX

由于以前已经安装了NGINX，所以此次就不需要再安装了，只需要创建一条软连接即可

```
ln -s /app/project/mirrors/ubuntu/mirror/mirrors.tuna.tsinghua.edu.cn/ubuntu /var/www/html/ubuntu
```

然后就可以通过如下地址访问了

```
http://[host]:[port]/ubuntu   #ip和port是自己本机的，其中端口默认为80
```

### 客户端配置(谁想用就改谁的配置)


编辑/etc/apt/source.list，加入以下内容

```
# Local Source 　　　　 #ip和port是自己本机的，其中端口默认为80
deb [arch=amd64] http://[host]:[port]/ubuntu/ trusty main restricted universe multiverse
deb [arch=amd64] http://[host]:[port]/ubuntu/ trusty-security main restricted universe multiverse
deb [arch=amd64] http://[host]:[port]/ubuntu/ trusty-updates main restricted universe multiverse  
deb [arch=amd64] http://[host]:[port]/ubuntu/ trusty-proposed main restricted universe multiverse
deb [arch=amd64] http://[host]:[port]/ubuntu/ trusty-backports main restricted universe multiverse
```

更新apt-get源

```
apt-update　　　　#这步很重要
```


