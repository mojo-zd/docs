### Start cluster
```
> docker-compose up -d
```
### Install sub、pub
```
go get github.com/nats-io/go-nats-examples/tools/nats-pub
go get github.com/nats-io/go-nats-examples/tools/nats-sub
```
### Connect
- subcribe
```
> nats-sub -s nats://127.0.0.1:14222 foo
```
- publish (validate cluster feature)
```
> nats-pub -s nats://127.0.0.1:24222 foo bar
> nats-pub -s nats://127.0.0.1:34222 foo bar
```

**Note:** nats-sub、nats-pub code need add auth option

reference: 

https://docs.docker.com/samples/library/nats/

https://github.com/nats-io/nats.go/blob/master/examples/nats-pub/main.go