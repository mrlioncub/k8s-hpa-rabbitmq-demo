helm upgrade --create-namespace --namespace k8-hpa-rabbitmq-demo --install rabbitmq-server helmforge/rabbitmq -f charts/rabbitmq/values.yaml
helm upgrade --create-namespace --namespace k8-hpa-rabbitmq-demo --install prometheus prometheus-community/prometheus -f charts/prometheus/values.yaml
helm upgrade --create-namespace --namespace k8-hpa-rabbitmq-demo --install prometheus-adapter prometheus-community/prometheus-adapter -f charts/prometheus-adapter/values.yaml
helm upgrade --create-namespace --namespace k8-hpa-rabbitmq-demo --install rabbitmq-agent-reciever k8s-hpa-rabbitmq-demo/rabbitmq-agent --set autoscaling.enabled=true
