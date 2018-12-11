#!/bin/bash

#--------------------------------------
# 为了方便自签证书创建编写
# Editer: lizhaojun
#  TEL:   15394045958
#   QQ:   2509500401
# 需要在该脚本同级目录下创建BACKUP目录
#---------------------------------------

read -p "Enter your server domain [www.baidu.com]: " SERVER

if [ ! -d $SERVER ]; then
   mkdir -p $SERVER
fi

if [ -f $SERVER ] ; then
  mv $SERVER  BACKUP/
fi

openssl genrsa -des3 -out $SERVER/nginx.key
openssl req -new -key $SERVER/nginx.key -out $SERVER/nginx.csr
echo "Remove password..."
cp $SERVER/nginx.key $SERVER/nginx.key.org
openssl rsa -in $SERVER/nginx.key.org -out $SERVER/nginx.key
echo "Sign SSL certificate..."
openssl ca -keyfile /etc/pki/CA/private/cakey.pem -cert /etc/pki/CA/cacert.pem -in $SERVER/nginx.csr -out $SERVER/nginx.crt
openssl dhparam -out dhparams.pem 2048
echo "##########################"
echo "#### Create Cert OK ! ####"
echo "##########################"

