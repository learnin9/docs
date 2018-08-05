双向SSL验证
---


证书生成操作：
```
openssl genrsa -des3 -out client.key
openssl req -new -key client.key -out client.csr
cp client.key client.key.org
openssl rsa -in client.key.org -out client.key
openssl ca -keyfile /etc/pki/CA/private/cakey.pem -cert /etc/pki/CA/cacert.pem -in client.csr -out client.crt
openssl pkcs12 -export -clcerts -in client.crt -inkey client.key -out client.p12
```


nginx配置

```
ssl on;
ssl_certificate /etc/nginx/cert/server/nginx.crt;
ssl_certificate_key /etc/nginx/cert/server/nginx.key;
ssl_client_certificate  /etc/pki/CA/cacert.pem;
ssl_protocols SSLv3 SSLv2 TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers ALL:!ADH:!EXPORT56:RC4+RSA:+HIGH:+MEDIUM:+LOW:+SSLv2:+EXP;
ssl_prefer_server_ciphers on;
ssl_verify_depth 2;
ssl_verify_client       on;
ssl_session_cache shared:SSL:20m;
ssl_session_timeout 180m;
```