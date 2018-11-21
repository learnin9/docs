#!/bin/sh
# ---------------------------------------------
# config:$RUN_DIR/conf/
# pidfile:$RUN_DIR/
# ---------------------------------------------

JAVA_HOME=/opt/java/jdk1.7.0_45
CLASSPATH=.:$JAVA_HOME/lib/tools.jar
export JAVA_HOME CLASSPATH PATH

RUN_DIR=$(cd `dirname $0`; pwd)
CLASSPATH=$CLASSPATH:/weblogic/wls/wlserver_10.3/server/lib/weblogic.jar
PART_LIST=$*
PART_T()
{
#参数获取
x=1 # 初始化参数
for n in `echo "$*"`
  do
        case "$n" in
          -i|i|-I|I)
              eval IP_LIST=\${$(($x+1))}
              ;;
          -u|u|-U|U)
              eval USER=\${$(($x+1))}
              ;;
          -p|p|-P|P)
              eval PWD=\${$(($x+1))}
              ;;
          -t|t|-T|T)
              eval TO_DIR=\${$(($x+1))}
              ;;
          -f|f|-F|F)
              eval FROM_DIR=\${$(($x+1))}
              ;;
	  -n|n|-N|N)
              eval SERVER_LIST=\${$(($x+1))}
              ;;
          -w|w)
              eval WAR_NAME=\${$(($x+1))}
              ;;
          -h|h|-H|H|help)
              HELP
              ;;
             *)
              x=$(($x+1))
              continue
        esac
        x=$(($x+1))
  done
}

SCP()
{
   for IP in `echo "${IP_LIST}"|awk -F, 'BEGIN{OFS=" "}{$1=$1;printf("%s",$0);}'`
      do
        for NAME in `echo "${SERVER_LIST}" |awk -F, 'BEGIN{OFS=" "}{$1=$1;printf("%s",$0);}'`
          do
            if [ ! -f $FROM_DIR ]
              then
                echo "复制源文件或者目录不存在"
                exit
              else
                IF_ID=`sshpass -p ${PWD} ssh -o StrictHostKeyChecking=no ${USER}@${IP} "if [ -d ${TO_DIR}/${NAME} ]; then echo yes;else echo no;fi"`
                if [ "${IF_ID}x" == "yesx" ]
                  then
                    IF_DIR=`sshpass -p ${PWD} ssh -o StrictHostKeyChecking=no ${USER}@${IP} "if [ -d ${TO_DIR}/${NAME}/appdir ]; then echo yes;else echo no;fi"`
                    if [ "${IF_DIR}x" == "yesx" ]
                      then
                        if [ -x ${RUN_DIR}/fbauto.sh ]
                          then
                            nohup sh ${RUN_DIR}/fbauto.sh ${IP} ${NAME} >/dev/null &
                        fi
                        echo "${USER}@${IP} cd ${TO_DIR}/${NAME}/appdir;mv ${WAR_NAME} ./bak/${WAR_NAME}_$(date +%Y%m%d%H);rm -rf ${WAR_NAME%.*}"
                        sshpass -p  ${PWD} ssh -o StrictHostKeyChecking=no ${USER}@${IP} "cd ${TO_DIR}/${NAME}/appdir;mv ${WAR_NAME} ./bak/${WAR_NAME}_$(date +%Y%m%d%H);rm -rf ${WAR_NAME%.*};rm -rf ${TO_DIR}/${NAME}/webapps/ROOT"
                        echo scp -r ${FROM_DIR} ${USER}@${IP}:${TO_DIR}/${NAME}/appdir/.
                        sshpass -p ${PWD} scp -r -o StrictHostKeyChecking=no -P22 ${FROM_DIR} ${USER}@${IP}:${TO_DIR}/${NAME}/appdir/.
                        echo "${USER}@${IP} ${NAME} restart"
                        sshpass -p  ${PWD} ssh -o StrictHostKeyChecking=no ${USER}@${IP} "source ~/.bash_profile  > /dev/null 2>&1;${NAME} restart -w ${WAR_NAME} &"
                      else
                        if [ -x ${RUN_DIR}/fbauto.sh ]
                          then
                            nohup sh ${RUN_DIR}/fbauto.sh ${IP} ${NAME} >/dev/null &
                        fi
                        echo "${USER}@${IP} cd ${TO_DIR}/${NAME}/webapps;mv ${WAR_NAME} ./bak/${WAR_NAME}_$(date +%Y%m%d%H);rm -rf ${WAR_NAME%.*}"
                        sshpass -p  ${PWD} ssh -o StrictHostKeyChecking=no ${USER}@${IP} "cd ${TO_DIR}/${NAME}/webapps;mv ${WAR_NAME} ./bak/${WAR_NAME}_$(date +%Y%m%d%H);rm -rf ${WAR_NAME%.*};rm -rf ${TO_DIR}/${NAME}/webapps/ROOT"
                        echo scp -r ${FROM_DIR} ${USER}@${IP}:${TO_DIR}/${NAME}/webapps/.
                        sshpass -p ${PWD} scp -r -o StrictHostKeyChecking=no -P22 ${FROM_DIR} ${USER}@${IP}:${TO_DIR}/${NAME}/webapps/.
                        echo "${USER}@${IP} ${NAME} restart -w ${WAR_NAME}"
                        sshpass -p  ${PWD} ssh -o StrictHostKeyChecking=no ${USER}@${IP} "source ~/.bash_profile  > /dev/null 2>&1;${NAME} restart &"
                    fi
                fi
            fi
          done
      done
      if [[ "${NAME}x" =~ _[0-6] ]]
        then
          SERVER_NAME=${NAME%_*}
        else
          SERVER_NAME=${NAME}
      fi
      if [ -x ${RUN_DIR}/fbauto.sh ]
        then
          nohup sh ${RUN_DIR}/fbauto.sh fbjs ${SERVER_NAME} >/dev/null &
	  sleep 2
      fi
}


if [ "$*x" != "x" ]
  then
    echo 传参举例，参数为 -i 192.168.1.1 -u user -p password -f fromdir -t todir -n servername
    PART_T ${PART_LIST}
  else
    IP_LIST=""
    USER=""
    PWD=""
    TO_DIR=""
    FROM_DIR=""
    SERVER_LIST=""
    if [ "${IP_LIST}x" == "x" ] && [ "${USER}x" == "x" ] && [ "${PWD}x" == "x" ]
      then
        echo 请正确传递参数，参数为 -i 192.168.1.1 -u user -p password -f fromdir -t todir -n servername
        exit
    fi
fi

#echo IP_LIST=${IP_LIST}    USER=${USER}    PWD=${PWD}    TO_DIR=${TO_DIR}    FROM_DIR=${FROM_DIR}    SERVER_LIST=${SERVER_LIST}
SCP
