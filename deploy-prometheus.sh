helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo rabbitmq-server helmforge/rabbitmq -f charts/rabbitmq/values.yaml
helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo prometheus prometheus-community/prometheus -f charts/prometheus/values.yaml
helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo prometheus-adapter prometheus-community/prometheus-adapter -f charts/prometheus-adapter/values.yaml
helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo rabbitmq-agent-reciever charts/rabbitmq-agent --set autoscaling.enabled=true
