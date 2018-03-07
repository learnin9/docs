#### Robot-Framework介绍

Robot Framework 是一款基于 Python 的功能自动化测试框架。它具备良好的可扩展性，支持关键字驱动，可以同时测试多种类型的客户端或者接口，可以进行分布式测试执行。主要用于轮次很多的验收测试和验收测试驱动开发（ATDD）。

使用手册可以参考[这里](http://robotframework.org/robotframework/#user-guide)

#### 安装与配置

##### Linux
  * CentOS7(推荐):

```
yum install epel-release -y && yum install python-pip -y && pip install robotframework
pip install robotframework-selenium2library
pip install robotframework-archivelibrary
pip install robotframework-SSHLibrary
pip install robotframework-ftplibrary
```

  * 其它发行版参考安装

##### Windows7/8/10

[下载安装包](ftp://172.19.2.253/Public/Software/RobotFramewor_install.rar)
  * 安装Python64位(推荐2.7.X的64位版本，上面下载的包安装时推荐勾选add python.exe to path，后续就不用自己配置环境变量)
  * 安装pip：依次解压setuptools-38.2.3.zip与pip-9.0.1.tar.gz并进入到解压后的目录CMD后执行`python setup.py install`
  * 安装WxPython
  * 安装 PyCrypto
  * 安装 Robot Framwork
  * 安装 robotframework-ride
  * 安装需要的 Library,如 selenium2library ,archivelibrary,SSHLibrary ,ftplibrary 等。

```
pip install robotframework-selenium2library
pip install robotframework-archivelibrary
pip install robotframework-SSHLibrary
pip install robotframework-ftplibrary
```
#### Jenkins介绍

Jenkins是一个功能强大的应用程序，允许持续集成和持续交付项目，无论用的是什么平台。这是一个免费的源代码，可以处理任何类型的构建或持续集成。集成Jenkins可以用于一些测试和部署技术。

#### Jenkins安装与配置

***环境配置*** 
* 内存 8G
* CPU  4核
* 硬盘 100G
* CentOS-7.2-x86_64


推荐使用Docker环境部署，比较容易

```
yum -y install docker && yum -y install java-1.8.0* 
mkdir -p /etc/docker/certs.d/harbor.cloud.top
service docker start && chkconfig docker on
```
docker证书找测试部获取并导入到`/etc/docker/certs.d/harbor.cloud.top`目录下,并在/etc/hosts中写入`172.19.30.251  harbor.cloud.top`这么一行
登录harbor

```
docker login harbor.cloud.top 
```

执行`./install.sh`进行安装

拷贝密码进行剩下的安装，安装过程中的插件安装代理地址找测试部获取



