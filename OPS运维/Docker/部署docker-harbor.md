```
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ca.key -x509 -days 3650 -out ca.crt    #CA服务器上执行
openssl req -newkey rsa:4096 -nodes -sha256 -keyout harbor.key out harbor.csr              #harbor服务器上执行
openssl x509 -req -days 3650 -in harbor.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out harbor.crt    #CA服务器上进行签署
cp harbor.crt /etc/cert/
cp harbor.key /etc/cert/ 
cp ca.crt /etc/docker/certs.d/harbor.cloud.top/
cp harbor.crt /etc/pki/ca-trust/source/anchors/harbor.cloud.top.crt
update-ca-trust

hostname： harbor.cloud.top
ui_url_protocol: http or https(我这边使用https，如果使用http后面证书部分可以忽略)
db_password = password（mysql数据库密码）
ssl_cert = /etc/cert/harbor.crt
ssl_cert_key = /etc/cert/harbor.key


docker login registry.xxx.com
```