restql可以合并微服务http请求的返回内容,假设当前我们有10个微服务,并且提供了10 api. restql可以通过restql-http服务并发请求所有的api接口并根据请求限制(eg: only resource. name, resource.url)返回指定的内容
### 实践restql
1. 添加配置restql.yml http://docs.restql.b2w.io/#/restql/resource-mappings
2. 启动restql-http服务

### Architecture
```sequence

```

### docker run 
```
docker run -d -p 9000:9000 -v /root/restql/restql.yml:/etc/restql/restql.yml -e JAVA_OPTS="-Drestql-config-file=/etc/restql/restql.yml"  --name restql b2wdigital/restql-http:latest
```

### docker-compose run 
```
docker-compose up -d
```

### example restql.yml
```
mappings:
  resource-manager: "http://10.100.64.109:9908/api/environments"
  orch: "http://10.96.95.4:9902/api/:tenant/application?currentPage=1&pageSize=16"
```
request:
```
from resource-manager
   only data.prometheusUrl, data.hostNum

from orch
   with tenant=1
   only data.data.name, data.data.istio
   ignore-errors
```
