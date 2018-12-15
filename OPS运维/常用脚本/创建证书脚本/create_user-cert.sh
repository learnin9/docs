#/bin/bash!
read -p "Enter User Nave [admin or other username]: " NAME

if [ ! -d $NAME ]; then
   mkdir -p $NAME
fi

if [ -f $NAME ] ; then
  mv $NAME  BACKUP/
fi

openssl genrsa -des3 -out $NAME/$NAME.key
openssl req -new -key $NAME/$NAME.key -out $NAME/$NAME.csr
cp $NAME/$NAME.key $NAME/$NAME.key.org
openssl rsa -in $NAME/$NAME.key.org -out $NAME/$NAME.key
openssl ca -keyfile /etc/pki/CA/private/cakey.pem -cert /etc/pki/CA/cacert.pem -in $NAME/$NAME.csr -out $NAME/$NAME.crt
echo "================================================================"
echo "  正在进行最后一步,生成可导入的.p12证书文件,请按照提示输入密码  "
echo "================================================================"
openssl pkcs12 -export -clcerts -in $NAME/$NAME.crt -inkey $NAME/$NAME.key -out $NAME/$NAME.p12

echo "###########################"
echo "### $NAME的证书创建完成 ###"
echo "###########################"

