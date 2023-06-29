提高golang开发效率

- 本地进行远程调试
1. 被调试服务为可执行文件
2. 被调试服务以容器方式运行

为了描述简洁，我们被调试服务称为`server`, dlv的服务端称为`dlv server`, dlv的客户端称为`dlv client`

## 本地进行远程调试
远程调试依赖`delv`工具.

### 远程调试流程概述
1. `dlv server`启动`server`
```
// 下面有两种方式启动目标服务
// 1. dlv启动server
dlv --listen=:3306 --headless=true --api-version=2 --accept-multiclient exec ./console-apiserver server

// 2. dlv attach到server
dlv --listen=:3306 --headless=true --api-version=2 --accept-multiclient attach {server-pid}
```

2. `dlv client`连接到`dlv server`. goland可以直接配置`go remote`. 配置时候指定`remote ip、remote port`进行保存
3. goland运行时选择配置好的`go remote`并进行`debug`方式运行.
4. 在goland中设置断点并请求`server`相关接口触发断点处代码执行


## TODO LIST
- 存在跳板机的情况应该怎么debug (待验证ssh端口转发)
```
ssh -L 31088:10.8.128.3:31088 -J root@100.124.0.250,root@10.8.128.28 root@10.20.128.4
```
- 容器化的时候应该怎么debug
