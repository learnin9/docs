#!/bin/bash
# Purpose: 使用mysqldump自动备份保存到本地，每30分钟备份一次,本地硬盘保留一周的备份数据，自动删除老旧备份
 
NOWDATE=`date +%Y-%m-%d`
OLDDATE=`date +%Y-%m-%d -d '-7 days'`
NOWTIME=`date +%Y%m%d%H%M%S`
MYSQLDUMP=/usr/bin/mysqldump
SOCKET=/var/lib/mysql/mysql.sock
 
#建立备份基本目录环境
BACKUPDIR=/backup/testlink-realtime-backup
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
