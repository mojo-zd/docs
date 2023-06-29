kubernetes



## storage

pv

```mermaind
grapth LR
Storage--> hostPath
Sotrage--> local-pv
```

## Pod QOS

- Guaranteed
1. 所有container必须包含内存、CPU的limit、request设置
2. 所有container的内存、CPU limit和request必须相等

- Burstable
- BestEffort
