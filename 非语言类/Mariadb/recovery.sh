#/bin/bash!
#If the testlink master server was wrong, run this script!
#edit by li_zhaojun
echo -----------STOPPING SERVICES----------
service mariadb stop
echo -----------RECOVERY SETTINS-----------
mv /etc/my.cnf /etc/my.cnf.oldsave
mv /etc/my.cnf.back /etc/my.cnf
mv /etc/sysconfig/network-scripts/ifcfg-eno16780032 /etc/sysconfig/network-scripts/ifcfg-eno16780032.oldback
mv /etc/sysconfig/network-scripts/ifcfg-eno16780032.back /etc/sysconfig/network-scripts/ifcfg-eno16780032

echo -------------RESTART SERVICES--------------
service network restart
service mariadb restart
chkconfig nginx on
chkconfig php-fpm on
chkconfig mariadb on
chkconfig ntpd on
chkconfig iptables on
service php-fpm restart
service nginx restart

echo -------------ALL SETTINGS IS OK!--------------

