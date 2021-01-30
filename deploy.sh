helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo rabbitmq-server bitnami/rabbitmq -f charts/rabbitmq/values.yaml
helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo prometheus prometheus-community/prometheus
helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo prometheus-adapter prometheus-community/prometheus-adapter -f charts/prometheus-adapter/config.yaml
helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo rabbitmq-agent-reciever charts/rabbitmq-agent
