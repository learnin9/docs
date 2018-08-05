CentOS7下修改系统时间的最佳操作
```
rm -rf /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```