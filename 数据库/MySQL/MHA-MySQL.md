```
[program:mysql-mha]
command=masterha_manager --conf=/etc/masterha_default.cnf
directory=/root/
autostart=true
autorestart=true
logfile=/dev/null
log_stderr=true
user=root
```

```

[server default]
user=mhroot
password=7F@MYPCKEY
manager_workdir=/data/masterha/app
manager_log=/data/masterha/app/manager.log
remote_workdir=/data/masterha/app
ssh_user=root
repl_user=mhadmin
repl_password=7F@MYPCKEY
ping_interval=1

[server1]
hostname=db1
ssh_port=22
candidate_master=1

[server2]
hostname=db2
ssh_port=22
no_master=1

[server3]
hostname=db3
ssh_port=22
no_master=1

```
