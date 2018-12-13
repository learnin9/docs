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


