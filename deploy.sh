#helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo rabbitmq-server bitnami/rabbitmq -f charts/rabbitmq/values.yaml
helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo rabbitmq-server stable/rabbitmq-ha -f charts/rabbitmq-ha/values.yaml
helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo prometheus stable/prometheus
helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo prometheus-adapter stable/prometheus-adapter -f charts/prometheus-adapter/config.yaml
helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo rabbitmq-agent-reciever charts/rabbitmq-agent
