source ~/.bash_profile
base_dir=$(pwd)
#部署应用
ip_list=""
US=''
set +x
PW=''

for IP in `echo "${ip_list}"|awk -F, 'BEGIN{OFS=" "}{$1=$1;printf("%s",$0);}'`
    do
     echo "${IP}" 
   sshpass -p ${PW} scp -r -o StrictHostKeyChecking=no -P22 ${base_dir}/dist/*  ${US}@${IP}:/gomeo2o/data/nginx/html/wap/.
    done
