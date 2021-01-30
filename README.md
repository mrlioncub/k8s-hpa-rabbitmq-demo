# k8s-hpa-rabbitmq-demo

Demo Kubernetes Horizontal Pod Autoscale based on Rabbitmq Queue (Custom Metrics)

## Requirements

  1. Kubernetes >= 1.16 (can use [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) with [enable addon metrics-server](https://kubernetes.io/docs/tutorials/hello-minikube/#enable-addons) or can use [MicroK8s](https://microk8s.io/docs) with [metrics-server](https://microk8s.io/docs/addons))
  2. [Helm 3](https://helm.sh/docs/intro/install/)

### Check kubernetes

Check version server kubernetes:
```bash
kubectl version
```
Check metrics-server:
```bash
kubectl get svc -n kube-system metrics-server
```
Check version helm:
```bash
helm version
```
Check version api autoscaling (v2beta2.autoscaling):
```bash
kubectl get apiservices | grep "autoscaling"
```



## Deployment

__1.__ Get helm charts from repo (using git):
```bash
git clone --depth 1 https://github.com/mrlioncub/k8s-hpa-rabbitmq-demo.git
```
or (using wget)
```bash
wget https://github.com/mrlioncub/k8s-hpa-rabbitmq-demo/archive/master.zip
unzip master.zip
```
__2.__ Get Repo Info
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```
__3.__ Run deploy (using helm 3)
```bash
cd k8s-hpa-rabbitmq-demo
bash deploy.sh
```
Default deploying with rabbitmq-ha. For deploying with bitnami/rabbitmq change deploy.sh (comment/uncomment):
```bash
helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo rabbitmq-server bitnami/rabbitmq -f charts/rabbitmq/values.yaml
#helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo rabbitmq-server stable/rabbitmq-ha -f charts/rabbitmq-ha/values.yaml
```
__4.__ Check
Check api custom metrics (a few minutes after deployment prometheus-adapter):
```bash
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1/namespaces/k8-hpa-rabbitmq-demo/pods/rabbitmq-server-0/rabbitmq_queue_messages | jq .
```
Result:
```xml
{
  "kind": "MetricValueList",
  "apiVersion": "custom.metrics.k8s.io/v1beta1",
  "metadata": {
    "selfLink": "/apis/custom.metrics.k8s.io/v1beta1/namespaces/k8-hpa-rabbitmq-demo/pods/rabbitmq-server-0/rabbitmq_queue_messages"
  },
  "items": [
    {
      "describedObject": {
        "kind": "Pod",
        "namespace": "k8-hpa-rabbitmq-demo",
        "name": "rabbitmq-server-0",
        "apiVersion": "/v1"
      },
      "metricName": "rabbitmq_queue_messages",
      "timestamp": "2020-07-13T17:50:13Z",
      "value": "0",
      "selector": null
    }
  ]
}
```
Check hpa (after deployment rabbitmq-agent-reciever):
```bash
kubectl get hpa -n k8-hpa-rabbitmq-demo
```
Result:
```
NAME                  REFERENCE                            TARGETS  MINPODS   MAXPODS   REPLICAS   AGE
rabbitmq-server-hpa   Deployment/rabbitmq-agent-reciever   0/30     1         10        1          4m
```
__5.__ Run sending messages:
```bash
kubectl --namespace k8-hpa-rabbitmq-demo run sender -it --rm --image=mrlioncub/rabbitmq-agent --restart=Never sender 50
```
Result:
```
 [x] Sent 'Message #0..'
...
 [x] Sent 'Message #49.......'
pod "sender" deleted
```
__6.__ Get info hpa:
```bash
kubectl get hpa -n k8-hpa-rabbitmq-demo -w
```
Result:
```
NAME                  REFERENCE                            TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
rabbitmq-server-hpa   Deployment/rabbitmq-agent-reciever   50/30     1         10        1          61s
rabbitmq-server-hpa   Deployment/rabbitmq-agent-reciever   50/30     1         10        2          61s
rabbitmq-server-hpa   Deployment/rabbitmq-agent-reciever   50/30     1         10        4          76s
rabbitmq-server-hpa   Deployment/rabbitmq-agent-reciever   50/30     1         10        7          92s
rabbitmq-server-hpa   Deployment/rabbitmq-agent-reciever   17/30     1         10        10         107s
rabbitmq-server-hpa   Deployment/rabbitmq-agent-reciever   0/30      1         10        10         2m48s
rabbitmq-server-hpa   Deployment/rabbitmq-agent-reciever   0/30      1         10        10         6m37s
rabbitmq-server-hpa   Deployment/rabbitmq-agent-reciever   0/30      1         10        6          6m52s
rabbitmq-server-hpa   Deployment/rabbitmq-agent-reciever   0/30      1         10        6          7m37s
rabbitmq-server-hpa   Deployment/rabbitmq-agent-reciever   0/30      1         10        1          7m52s
```
  
  
__Tests conducted on Azure, MicroK8s and Minicube__

## Links

https://github.com/kubernetes-sigs/prometheus-adapter/blob/master/docs/config-walkthrough.md  
https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/  
https://www.rabbitmq.com/prometheus.html  
https://github.com/bitnami/charts/blob/master/bitnami/rabbitmq/values.yaml  
https://ryanbaker.io/2019-10-07-scaling-rabbitmq-on-k8s/  
