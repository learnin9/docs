#!/bin/bash
# Purpose: 使用mysqldump自动备份mysql并上传数据到ftp
 
NOWDATE=`date +%Y-%m-%d`
OLDDATE=`date +%Y-%m-%d -d '-15 days'`
FTPOLDDATE=`date +%Y-%m-%d -d '-30 days'`
NOWTIME=`date +%Y%m%d%H%M%S`
MYSQLDUMP=/usr/bin/mysqldump
SOCKET=/var/lib/mysql/mysql.sock
 
#建立备份基本目录环境
BACKUPDIR=/backup/mysqldb
[ -d ${BACKUPDIR} ] || mkdir -p ${BACKUPDIR} 
[ -d ${BACKUPDIR}/${NOWDATE} ] || mkdir ${BACKUPDIR}/${NOWDATE} 
[ ! -d ${BACKUPDIR}/${OLDDATE} ] || rm -rf ${BACKUPDIR}/${OLDDATE} 
 
#mysqldump备份
USERNAME=backup
PASSWORD=backup
DATABASENAME=(mysql testlink)
 
for DBNAME in ${DATABASENAME[@]};
do
    ${MYSQLDUMP} --opt --add-drop-database --tz-utc=true --flush-logs --events -u${USERNAME} -p${PASSWORD} -S${SOCKET} ${DBNAME} | gzip -c -9 > ${BACKUPDIR}/${NOWDATE}/${DBNAME}-backup-${NOWTIME}.sql.gz 
    logger "${DBNAME} has been backup successful - ${NOWDATE}"
    /bin/sleep 10
done
 
#上传备份至FTP
HOST=1.1.1.1 
FTP_USERNAME=backup 
FTP_PASSWORD=backup 
  
cd ${BACKUPDIR}/${NOWDATE} 
  
ftp -i -n -v << EOF 
open ${HOST} 
user ${FTP_USERNAME} ${FTP_PASSWORD} 
bin 
cd ${FTPOLDDATE} 
mdelete * 
cd .. 
rmdir ${FTPOLDDATE} 
mkdir ${NOWDATE} 
cd ${NOWDATE} 
mput * 
bye 
EOF 
 
#使用备用方式删除旧备份文件
#find ${BACKUPDIR} -type f -ctime +2 -exec rm -fr {} \;
#find ${BACKUPDIR} -empty -exec rm -fr {} \;
