Docker部署SonarQube
------------------

依赖
---

* CentOS 7.2+
* docker 1.13+
* docker-compose 1.20+

将下面文件内容另存为`docker-compose.yml`文件,执行`docker-compose up -d`进行启动服务

```
version: "2"

services:
  sonarqube:
    image: harbor.cloud.top/sonarqube/sonarqube:latest
    ports:
      - "80:9000"
    networks:
      - sonarnet
    environment:
      - SONARQUBE_JDBC_URL=jdbc:postgresql://db:5432/sonar
    volumes:
      - sonarqube_conf:/opt/sonarqube/conf
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_bundled-plugins:/opt/sonarqube/lib/bundled-plugins

  db:
    image: harbor.cloud.top/sonarqube/postgres:latest
    networks:
      - sonarnet
    environment:
      - POSTGRES_USER=sonar
      - POSTGRES_PASSWORD=sonar
    volumes:
      - postgresql:/var/lib/postgresql
      - postgresql_data:/var/lib/postgresql/data

networks:
  sonarnet:
    driver: bridge

volumes:
  sonarqube_conf:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_bundled-plugins:
  postgresql:
  postgresql_data:
```

之后的过程和二进制包安装无任何区别