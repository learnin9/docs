处理办法
---

1. `echo "vm.swappiness=0" >>/etc/sysctl.conf`
2. `sysctl -p`
3. `swapoff -a && swapon -a`