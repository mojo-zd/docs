分别向多个es实例添加数据:
```
curl -H 'Content-Type: application/x-ndjson' -XPOST localhost:9200/_bulk --data-binary @es_data.json
```

获取index
```
GET /cluster_*:test2/_search
{
  "query": {
    "match_all": {}
  }
}
```

添加remote cluster
```
PUT _cluster/settings
{
  "persistent": {
    "cluster": {
      "remote": {
        "cluster_one": {
          "seeds": [
            "127.0.0.1:9300"
          ]
        },
        "cluster_two": {
          "seeds": [
            "127.0.0.1:9301"
          ]
        },
        "cluster_three": {
          "seeds": [
            "127.0.0.1:9302"
          ]
        }
      }
    }
  }
}
```