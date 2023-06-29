- 介绍一下自己对kube-apiserver的内存优化，挑两个就可以了。
- 如果我们这边有一些客户就是会暴力的list pod如何确保apiserver不会oom
- 客户的业务具有潮汐的特性，某个时间发生大量的扩容。这些pod起来就会list pod，如何防止oom？
- 如果我要加一个用jsonpath来list对象的功能，需要加在kube-apiserver的哪个地方？
- 你是如何做到对k8s的代码级别理解，并且给k8s社区贡献有效的pr？
- 最大数的栈。
- CRD VS aggregator
    - kube-apiserver默认对核心的对象存储格式为PB，但是针对CRD这种类型的资源就只能使用JSON进行。JSON vs PB的对比结果在工程上差异很大，是3:1的时间空间消耗【时间和空间都需要3倍，这种效果对规模化的应用本身是很敏感的】（第三方应用为了保证架构简单会使用这种方式，但企业应用最好是去使用PB，也就是AA）
    - CRD当前的实现是在kube-apiserver内的，大量使用这种方式拓展kube-apiserver，会严重拖累kube-apiserver，影响到整个集群的稳定性
    - aggregator可以灵活的选择存储设备，鉴权方式，认证方式，打破之前核心API之间“无事务”的边界，
    - 整个apiserver接受请求的顺序【这里也可以看到，aa其实是一种非常高效的扩展方式】
        - aggregator首先进行服务
        - 【上一步NotFound】k8s核心的API
        - 【上一步NotFound】在CRD中找寻能够服务这个request的storage

## 参考文档:

- 最初的设计文档: https://docs.google.com/document/d/1q1UGAIfmOkLSxKhVg7mKknplq3OTDWAIQGWMJandHzg/edit
- KEP: https://github.com/kubernetes/enhancements/tree/master/keps/sig-api-machinery/555-server-side-apply
- 官方描述: https://kubernetes.io/docs/reference/using-api/server-side-apply/
- 博客: https://kubernetes.io/blog/2022/10/20/advanced-server-side-apply/
