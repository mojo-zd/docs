kubectl delete cm nginx
kubectl create cm nginx --from-file=default.conf
kubectl delete po $(kubectl get po | grep c- | awk '{print $1}') --force --grace-period=0