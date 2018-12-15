#!/bin/sh
# create self-signed server certificate:
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
openssl dhparam -out $SERVER/dhparams.pem 2048
echo "##########################"
echo "#### Create Cert OK ! ####"
echo "##########################"
