为npm设置代理
---

```
$ npm config set proxy http://server:port
$ npm config set https-proxy http://server:port
```
如果代理需要认证的话可以这样来设置。
```
$ npm config set proxy http://username:password@server:port
$ npm config set https-proxy http://username:pawword@server:port
```
如果代理不支持https的话需要修改npm存放package的网站地址。
```
$ npm config set registry "http://registry.npmjs.org/"
```