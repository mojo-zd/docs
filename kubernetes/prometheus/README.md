- [ ] 记录prometheus以[docker-compose](https://github.com/mojo-zd/docs/tree/master/docker-compose/prometheus)和kubernetes的启动配置，demo中集成了prometheus, grafana, VictoriaMetrics。并以cadvisor作为采集对象进行demo演示.高可用demo可以参考
github.com/mojo-zd/docs/kubernetes/prometheus/high-availability

- prometheus 监控数据采集工具
- grafana prometheus 监控数据展示工具
- VictoriaMetrics 监控数据持久化工具
- cadvisor 主机容器信息采集

- [ ] 部署
- `kubectl apply -f prometheus.yaml` 文件中包含了prometheus需要的权限定义(clusterrole, cluster, serviceaccount), prometheus采集配置, prometheus相关资源部署deployment

ChangeLog

- integration prometheus、grafana、VictoriaMetrics
- VictoriaMetrics High Availability

```
# replace job_name to service name
- source_labels: [__meta_kubernetes_service_name]
  regex: (.*)
  target_label: job
  replacement: ${1}
  action: replace
```