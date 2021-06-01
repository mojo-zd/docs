最简单的pod调度策略`node selector` (will deprecated)
- attach label for nodes
```
kubectl label nodes k8s02 disktype=ssd
```

- apply yaml
```
kubectl apply -f node-selector.yaml
```
!!! Note: 此刻所有的pod都会调度到同一个node上,
如果replicas大于nodes count某些pod会调度到同一个node上。反之会每个node调度一个pod