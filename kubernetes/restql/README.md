### prepare restql.yml(this is used to create cm of restql.yml)
```
kubectl create cm restql-config --from-file restql.yml
```

### create restql deploy
```
kubectl apply -f restql-deploy.yaml
```

### validate
```
curl -d "from rmgrSupperPanel" -H "Content-Type: text/plain" 10.97.156.127:9000/run-query
```