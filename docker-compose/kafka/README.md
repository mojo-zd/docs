- run kafka with sasl
```
docker-compose up -d
```


./kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181,localhost:2182,localhost:2183 --add --allow-principal User:alice --operation Read --operation Write --topic sean-security
