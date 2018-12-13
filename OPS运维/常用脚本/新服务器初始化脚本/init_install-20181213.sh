# /bin/bash!
# ------------------------------
# lizhaojun
# lizhaojun.ops@gmail.com
#------------------------------
echo "----------------------------------------------"
echo "  开始初始化服务器,这需要一些时间,请耐心等待"  
echo "----------------------------------------------"

echo "正在关闭防火墙,SELinux"
sudo service firewalld stop && sudo chkconfig firewalld off
sudo service iptables stop && sudo chkconfig iptables off
sudo service postfix stop && sudo chkconfig postfix off
sudo setenforce 0
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
echo "----------------------------------------------"
echo "更新一些必要的组件信息,如:SSH,TELNET,LRZSZ等"
echo "----------------------------------------------"
sudo yum install epel-release -y && sudo yum -y install net-tools ssh telnet mailx htop iotop iftop nload lsof ntp*
echo "----------------------------------------------"
echo      "正在安装开发者工具,请稍等一会儿....."
echo "----------------------------------------------"
sudo yum -y groupinstall "Development Tools"

sudo echo  > /etc/chrony.conf
sudo cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
sudo cat > /etc/chrony.conf  << _EEOF
server 0.centos.pool.ntp.org iburst
server 1.centos.pool.ntp.org iburst
server 2.centos.pool.ntp.org iburst
server 3.centos.pool.ntp.org iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony

_EEOF

echo "-------------------------------------------------------------"
echo "正在启动chronyd时间同步(等同于NTP,CentOS7版本已全线变更)服务"
echo "-------------------------------------------------------------"
sudo service chronyd restart && sudo chkconfig chronyd on


sudo echo  > /etc/security/limits.conf
sudo cat > /etc/security/limits.conf  << _BEOF
root soft nofile 65535
root hard nofile 65535
_BEOF


echo "-------------------------"
echo "   正在进行内核优化   "
echo "-------------------------"
echo " "
echo "######################################################"
echo " 注意:"
echo "     1. 该脚本在通用内核优化方案的基础上进行修改利用 " 
echo "     2. 如有需要,可以根据自己的需求进行修改          "  
echo "######################################################"
echo " "
echo " "
sleep 5s;

sudo echo  > /etc/sysctl.conf

sudo cat > /etc/sysctl.conf  << _FEOF
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
kernel.threads-max=65535
kernel.msgmni = 16384
kernel.msgmnb = 65535
kernel.msgmax = 65535
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
kernel.shmmni = 4096
kernel.sem = 5010 641280 5010 128
net.ipv4.tcp_max_tw_buckets = 6000000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.netdev_max_backlog = 200000
net.ipv4.tcp_no_metrics_save = 1
net.core.somaxconn = 65535
net.core.optmem_max = 10000000
net.ipv4.tcp_max_orphans = 32768
net.ipv4.tcp_max_syn_backlog = 655360
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_keepalive_probes=10
net.ipv4.tcp_keepalive_intvl=2
net.ipv4.ip_local_port_range = 10000 65535
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_congestion_control=cubic
net.ipv4.conf.lo.arp_ignore = 1
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
fs.aio-max-nr = 1024000
fs.file-max = 1024000
kernel.pid_max=327680
vm.swappiness = 0
vm.max_map_count=655360

_FEOF

sudo sysctl -p


