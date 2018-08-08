## Docker资源限制

在默认的情况下，docker没有对容器进行硬件资源的限制，当容器负载过高时会尽肯能第占用宿主机资源。在这基础上，docker提供了针对容器的内存，`CPU`，`IO`资源的控制方式。（真正可以控制的只有内存和cpu）
Docker内存控制`OOME`在linxu系统上，如果内核探测到当前宿主机已经没有可用内存使用，那么会抛出一个`OOME(Out Of Memory Exception:内存异常
)`，并且会开启killing去杀掉一些进程。
一旦发生`OOME`，任何进程都有可能被杀死，包括`docker daemon`在内，为此，docker特地调整了docker daemon的`OOM_Odj`优先级，以免他被杀掉，但容器的优先级并未被调整。经过系统内部复制的计算后，每个系统进程都会有一个`OOM_Score`得分，`OOM_Odj`越高，得分越高，（在`docker run`的时候可以调整`OOM_Odj`）得分最高的优先被`kill`掉，当然，也可以指定一些特定的重要的容器禁止被`OMM`杀掉，在启动容器时使用 `–oom-kill-disable=true`指定。
内存限制的部分参数

* `-m` : 指定容器内存

* `--memory-swap` : 设置容器交换分区大小，设置交换分区必须要设置 `-m`：依赖前者，容器内与交换分区的关系比较特别，如下：

| --memory-swap | --memory | 功能 |
| ------------- | -------- | ---- |  
| 正数S  | 正数M  | 容器可用总空间为S，其中ram为M,swap为(S-M),若S=M,则无可用swap资源 |
| O     | 正数M  | 相当于未设置swap (unset) |
| unset | 正数M  | 若主机(Docker Host)启用了swap,则容器的可用swap为2*M |
| -l    | 正数M  | 若主机(Docker Host)启用了swap,则容器的可使用最大值主机上的所有swap空间的swap资源 |

 **注意**：在容器内使用free命令可以看到的swap空间并不具有其所展现出的空间指示意义

* `--oom-kill-disable=true` : 禁止容器被`oom`杀掉，使用该参数要与`-m`一起使用

### CPU的限制

默认情况下，每一个容器可以使用宿主机上的所有cpu资源，但大多数系统使用的资源调度算法是`CFS`（完全公平调度器），它公平调度每一个工作进程。进程分`cpu密集型`和`io密集型`两类。系统内核会实时监测系统进程，当某个进程占用cpu资源时间过长时，内核会调整该进程的优先级。

#### CPU资源分配策略

### 共享cpu资源

* `--cpu-share`： cpu资源提供给一组容器使用，组内的容器按比例使用cpu资源，当容器处于空闲状态时，cpu资源被负载大的容器占用，（按压缩方式比例分配），当空闲进行运行起来时，cpu资源会被分配到其他容器
* `--cpus= value` ： 指定 cpu的核心数量，这种方式直接限定了容器可用的cpu资源
* `--cpuset-cpus`: 指定容器只能运行在哪个cpu核心上（绑定cpu）；核心使用0,1,2,3编号；`–cpu-share`会随机指定cpu

### 启动一个容器并限制资源

启动一个centos容器，限制其内存为1G ，可用cpu数为2

```
[root@localhost ~]# docker run --name os1 -it -m 1g --cpus=2 centos:latest bash
```

启动容器后，可以使用docker 的监控指令查看容器的运行状态
* docker top 容器名： 查看容器的进程，不加容器名即查看所有
* docker stats 容器名：查看容器的CPU，内存，IO 等使用信息

```
[root@localhost ~]# docker stats os1
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT   MEM %               NET I/O             BLOCK I/O           PIDS
f9420cbbd2a9        os1                 45.94%              47.09MiB / 1GiB     4.60%               54.6MB / 352kB      0B / 21.1MB         3
```

在容器中安装docker容器压测工具 stress

```
#先安装一些基础工具
[root@f9420cbbd2a9 /]# yum install wget gcc gcc-c++ make -y
#下载stress
[root@f9420cbbd2a9 ~]# wget http://people.seas.harvard.edu/~apw/stress/stress-1.0.4.tar.gz
#安装
[root@f9420cbbd2a9 ~]# tar zxf stress-1.0.4.tar.gz
[root@f9420cbbd2a9 ~]# cd stress-1.0.4
[root@f9420cbbd2a9 stress-1.0.4]./configure
[root@f9420cbbd2a9 stress-1.0.4]# make
[root@f9420cbbd2a9 stress-1.0.4]# make install
```

在容器使用stress指令进行负载压测

```
[root@f9420cbbd2a9 ~]# stress  -m 1204m --vm 2
#模拟出4个繁忙的进程消耗cpu，然后使用-m 模拟进程最大使用的内存数1024，使用--vm 指定进程数
#更多参数使用 stress --help查看
```

使用docker指令查看容器运行状态，可以os1容器的内存和cpu都得到了限制，即使给压测时超出了最大内存，也不会额外占用资源

```
[root@localhost ~]# docker stats os1
CONTAINER ID        NAME                CPU %               MEM USAGE / LIMIT   MEM %               NET I/O             BLOCK I/O           PIDS
f9420cbbd2a9        os1                 127.46%             319.7MiB / 1GiB     31.22%              54.8MB / 356kB      0B / 33.6MB         9
```
