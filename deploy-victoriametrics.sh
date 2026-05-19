helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo rabbitmq-server helmforge/rabbitmq -f charts/rabbitmq/values.yaml
helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo victoriametrics vm/victoria-metrics-single -f charts/victoriametrics/values.yaml
helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo keda kedacore/keda
helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo rabbitmq-agent-reciever charts/rabbitmq-agent --set kedavm.enabled=true
