#### 安装过程:

1. 将bin和conf文件夹放入:c:\program\zabbix\下面，没有zabbix手动创建
2. 根据自己的zabbix服务器IP修改conf下的zabbix_server.conf
3. 根据自己的电脑系统选择客户端位数，以超级管理员权限运行cmd，执行 c:\program\zabbix\bin\zabbix-agent64.exe -c c:\program\zabbix\conf\zabbix_server.conf -i 将zabbix加入开机自启
4. 执行c:\program\zabbix\bin\zabbix-agent64.exe -c c:\program\zabbix\conf\zabbix_server.conf -s 启动zabbix服务