## docker api访问
默认情况下docker访问方式通过unix sock访问, 如果我们需要调试docker接口怎么办呢。我们可以使用curl命令来处理.

dockerd启动时如果没有修改启动端口默认是2375(非安全端口), 因为我们基于2375端口开启curl方式请求docker接口吧.
```
curl --unix-sock /var/run/docker.sock -v http://localhost:2375/containers/json
```
