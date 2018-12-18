#/bin/bash!
# install iptables

echo "正在查询是否安装了iptables..."

i=iptables
x=`sudo rpm -qa | grep $i`

if [ `sudo rpm -qa | grep -c $i ` -gt 3 ];
 then
     echo -e "yes,the packet list: \n$x"
     echo "是否进行升级? 请输入'y'进行升级或者'n'退出"
     read bNum     
     case $bNum in
       y) echo "开始更新..."
           sudo yum install  iptables* -y
           sudo chkconfig iptables on
        ;;
       n) echo "已退出..."
          exit
        ;;
      esac
 else
     echo "no, start install iptables..."; 
     sudo yum install iptables* -y
     sudo chkconfig iptables on
     
fi  


