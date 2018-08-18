## Nginx主配置优化模板

vim /etc/nginx/nginx.cong修改为如下即可

```
user nginx;
worker_processes auto;
worker_rlimit_nofile 65535;
error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections  2048;
    multi_accept on;
    use epoll;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    
    server_tokens       off;
    access_log          off;
    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    include /etc/nginx/conf.d/*.conf;
}

```



通用加了缓存优化的模板:
```
user nginx;
worker_processes auto;
worker_rlimit_nofile 65535;
error_log /var/log/nginx/error.log error;
pid /var/run/nginx.pid;
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections  2048;
    multi_accept on;
    use epoll;
}

# load modules compiled as Dynamic Shared Object (DSO)
#
#dso {
#    load ngx_http_fastcgi_module.so;
#    load ngx_http_rewrite_module.so;
#}

http {
  include       mime.types;
  default_type  application/octet-stream;
  charset utf-8;  
  server_names_hash_bucket_size 128;
  client_header_buffer_size 32k;
  large_client_header_buffers 4 32k;
  client_max_body_size 10m; 
  sendfile on;
  tcp_nopush     on;
  send_timeout  180s;
  keepalive_timeout 10;
  server_tag       WAWA;
  server_tokens    off;
  tcp_nodelay on;
  types_hash_max_size 2048;
  add_header Server-ID $hostname;
  fastcgi_connect_timeout 600;
  fastcgi_send_timeout 600;
  fastcgi_read_timeout 600;
  fastcgi_buffer_size 256k;
  fastcgi_buffers 2 256k;
  fastcgi_busy_buffers_size 256k;
  fastcgi_temp_file_write_size 256k;
  fastcgi_intercept_errors on;
# add for compress
  gzip on;
  gzip_min_length   1k;
  gzip_buffers     4 16k;
  gzip_http_version 1.0;
  gzip_comp_level 6;
  gzip_types  text/plain application/x-javascript text/css  application/xml;
  gzip_vary on;
  postpone_output 1460;
  gzip_proxied        any;
  gzip_disable        "MSIE [1-6]\.";
  client_body_buffer_size  512k;
  proxy_connect_timeout    60;
  proxy_read_timeout       600;
  proxy_send_timeout       600;
  proxy_buffer_size        32k;
  proxy_buffers            32 128k;
  proxy_busy_buffers_size 256k;
  proxy_temp_file_write_size 256k;
  proxy_headers_hash_max_size 51200;
  proxy_headers_hash_bucket_size 6400;
  proxy_temp_path   /tmp/proxy_temp_dir;
  proxy_cache_path  /tmp/proxy_cache_dir  levels=1:2   keys_zone=cache_one:500m inactive=1d max_size=30g;
 
  proxy_set_header        Host $host;
  proxy_set_header        X-Real-IP $remote_addr;
  proxy_set_header        X-Forwarded-For $remote_addr;
  proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header        X-Forwarded-For $http_x_forwarded_for;
  proxy_set_header        X-Forwarded-Proto  $scheme;

  proxy_pass_request_headers      on;
  underscores_in_headers          on;
  log_format nginxjson '{"@timestamp":"$time_iso8601",'
	       '"@fields": { '
	       '"@version":"1",'
	       '"host":"$server_addr",'
	       '"remote_addr":"$remote_addr",'
	       '"http_x_forwarded_for":"$http_x_forwarded_for",'
	       '"request_method":"$request_method",'
	       '"domain":"$host",'
	       '"url.raw":"$uri",'
	       '"url":"$scheme://$http_host$request_uri",'
	       '"status":"$status",'
	       '"server_protocol":"$server_protocol",'
	       '"size":$body_bytes_sent,'
	       '"responsetime":$request_time,'
	       '"http_referer":"$http_referer",'
	       '"upstr_addr": "$upstream_addr",'
	       '"upstr_status": "$upstream_status",'
	       '"ups_resp_time": "$upstream_response_time",'
	       '"x_clientOs":"$http_x_clientOs",'
	       '"x_access_token":"$http_x_access_token",'
	       '"accept":"$http_accept",'
	       '"agent": "$http_user_agent"}}';

        log_format main '^=^ [$time_local] ^=^ $http_x_forwarded_for ^=^ $remote_addr ^=^ $remote_user ^=^ $http_user_agent ^=^ $upstream_addr ^=^ $status ^=^ $body_bytes_sent ^=^ $http_cookie ^=^ $request_time ^=^ $upstream_response_time ^=^ $http_host ^=^ $request ^=^ $http_referer ^=^ $uid_got ^=^ $uid_set ^=^ $http_riskflag ^=^ $server_addr ^=^ $ssl_protocol';
        log_format mainhttps '^=^ [$time_local] ^=^ $remote_addr ^=^ $remote_addr ^=^ $remote_user ^=^ $http_user_agent ^=^ $upstream_addr ^=^ $status ^=^ $body_bytes_sent ^=^ $http_cookie ^=^ $request_time ^=^ $upstream_response_time ^=^ $http_host ^=^ $request ^=^ $http_referer ^=^ $uid_got ^=^ $uid_set ^=^ $http_riskflag ^=^ $server_addr ^=^ $ssl_protocol';

        log_format access '^=^ [$time_local] ^=^ $http_x_forwarded_for ^=^ $remote_addr ^=^ $remote_user ^=^ $http_user_agent ^=^ $upstream_addr ^=^ $status ^=^ $body_bytes_sent ^=^ $http_cookie ^=^ $request_time ^=^ $upstream_response_time ^=^ $http_host ^=^ $request ^=^ $http_referer ^=^ $uid_got ^=^ $uid_set ^=^ $http_riskflag ^=^ $server_addr ^=^ $ssl_protocol';
        log_format accesshttps '^=^ [$time_local] ^=^ $remote_addr ^=^ $remote_addr ^=^ $remote_user ^=^ $http_user_agent ^=^ $upstream_addr ^=^ $status ^=^ $body_bytes_sent ^=^ $http_cookie ^=^ $request_time ^=^ $upstream_response_time ^=^ $http_host ^=^ $request ^=^ $http_referer ^=^ $uid_got ^=^ $uid_set ^=^ $http_riskflag ^=^ $server_addr ^=^ $ssl_protocol';
  access_log   /var/log/nginx/access.log main; 
  include      conf.d/*.conf;

}
```
