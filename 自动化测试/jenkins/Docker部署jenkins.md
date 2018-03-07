## Dokcer部署Jenkins

* 安装docker环境

```
yum -y install docker
```

* 创建jenkins所需的挂载目录并设置为ID为1000,并向/etc/docker/certs.d中导入harbor的证书

```
mkdir -p /jenkins
chown -R 1000:1000 /jenkins
```

根据经验如果不自定义jenkins的时间,jenkins的时间总是和正确时间差了8小时，按照如下方法修改即可

```
vim /etc/timezone
写入Asia/Shanghai即可
```

* 拉取镜像开始启动：

```
docker run -itd -p 8080:8080 -p 50000:50000 --name jenkins --privileged=true -v /jenkins:/var/jenkins_home -v /etc/localtime:/etc/localtime:ro -v /etc/timezone:/etc/timezone -d harbor.cloud.top/jenkins/jenkins:2.89.2TLS 
```

* 查看密码

```
cat /jenkins/secrets/initialAdminPassword
```