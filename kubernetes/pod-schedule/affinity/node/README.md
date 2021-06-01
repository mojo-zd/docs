### node affinity
- 给指定node添加label
```
kubectl label nodes k8s02 disktype=ssd
```

- 指定`affinity.yaml`
```
kubectl apply -f affinity.yaml
```

!!! Note: 所有的pod都调度到同一个node上了

- 删除 `k8s02`上的 `disktype=ssd`标签
kubectl edit node k8s02

- 查看pod是否被驱逐
```
kubectl get po -w -o wide
```

reference: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/