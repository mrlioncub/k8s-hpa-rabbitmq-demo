helm delete --namespace k8-hpa-rabbitmq-demo rabbitmq-agent-reciever
helm delete --namespace k8-hpa-rabbitmq-demo prometheus
helm delete --namespace k8-hpa-rabbitmq-demo prometheus-adapter
helm delete --namespace k8-hpa-rabbitmq-demo victoriametrics
helm delete --namespace k8-hpa-rabbitmq-demo keda
kubectl delete --namespace k8-hpa-rabbitmq-demo secrets kedaorg-certs
helm delete --namespace k8-hpa-rabbitmq-demo rabbitmq-server
