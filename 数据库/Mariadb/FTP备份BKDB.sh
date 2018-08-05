#!/bin/bash
# Purpose: 使用mysqldump自动备份mysql并上传数据到ftp
 
NOWDATE=`date +%Y-%m-%d`
OLDDATE=`date +%Y-%m-%d -d '-3 days'`
FTPOLDDATE=`date +%Y-%m-%d -d '-7 days'`
NOWTIME=`date +%Y%m%d%H%M%S`
FTPDIR=/tsc_backup/testlink
MYSQLDUMP=/usr/bin/mysqldump
SOCKET=/var/lib/mysql/mysql.sock
 
#建立备份基本目录环境
BACKUPDIR=/backup/mysqldb
[ -d ${BACKUPDIR} ] || mkdir -p ${BACKUPDIR} 
[ -d ${BACKUPDIR}/${NOWDATE} ] || mkdir ${BACKUPDIR}/${NOWDATE} 
[ ! -d ${BACKUPDIR}/${OLDDATE} ] || rm -rf ${BACKUPDIR}/${OLDDATE} 
 
#mysqldump备份
USERNAME=root
PASSWORD=Talent123
DATABASENAME=(testlink)
 
for DBNAME in ${DATABASENAME[@]};
do
    ${MYSQLDUMP} --opt --add-drop-database --tz-utc=true --flush-logs --events -u${USERNAME} -p${PASSWORD} -S${SOCKET} ${DBNAME} | gzip -c -9 > ${BACKUPDIR}/${NOWDATE}/${DBNAME}-backup-${NOWTIME}.sql.gz 
    logger "${DBNAME} has been backup successful - ${NOWDATE}"
    /bin/sleep 5
done
 
#上传备份至FTP
HOST=172.19.2.253
FTP_USERNAME=gao_li
FTP_PASSWORD=talent
  
cd ${BACKUPDIR}/${NOWDATE} 
  
ftp -i -n -v  << EOF 
open ${HOST} 
user ${FTP_USERNAME} ${FTP_PASSWORD} 
bin
cd ${FTPDIR}
cd ${FTPOLDDATE} 
mdelete * 
cd ..
rmdir ${FTPOLDDATE} 
mkdir ${NOWDATE} 
cd ${NOWDATE} 
mput * 
bye 
EOF 
