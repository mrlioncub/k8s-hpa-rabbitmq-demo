helm upgrade --create-namespace --namespace k8-hpa-rabbitmq-demo --install rabbitmq-server helmforge/rabbitmq -f charts/rabbitmq/values.yaml
helm upgrade --create-namespace --namespace k8-hpa-rabbitmq-demo --install keda kedacore/keda
helm upgrade --create-namespace --namespace k8-hpa-rabbitmq-demo --install rabbitmq-agent-reciever k8s-hpa-rabbitmq-demo/rabbitmq-agent --set keda.enabled=true
