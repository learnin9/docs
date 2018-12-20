运行参数调整
---

### 运行目录,加速地址,非SSL仓库

* 通过修改`vim /etc/docker/daemon.json`进行调整

```
{
  "graph":"/app/docker",  #运行目录
  "registry-mirrors": ["http://harbor.test.com"], #镜像加速地址
  "insecure-registries": ["harbor.test.com","registry.cn-shenzhen.aliyuncs.com"], # Docker如果需要从非SSL源管理镜像，这里加上。
  "max-concurrent-downloads": 10
}
```


### Docker网络调整 

* 

```

```
