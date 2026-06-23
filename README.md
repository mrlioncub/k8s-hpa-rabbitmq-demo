# k8s-hpa-rabbitmq-demo

Demo Kubernetes Horizontal Pod Autoscaling based on RabbitMQ Queue (via Prometheus/VictoriaMetrics/KEDA)

## Requirements

  1. Kubernetes >= v1.23 (can use [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) or can use [MicroK8s](https://microk8s.io/docs))
  2. [Helm 3](https://helm.sh/docs/intro/install/)

### Check Kubernetes

Check Kubernetes server version:
```bash
kubectl version
```
Check Helm version:
```bash
helm version
```
Check autoscaling API version (v2.autoscaling):
```bash
kubectl get apiservices | grep "autoscaling"
```

## Deployment

__1.__ Get helm charts from repo (using git):
```bash
git clone --depth 1 https://github.com/mrlioncub/k8s-hpa-rabbitmq-demo.git
cd k8s-hpa-rabbitmq-demo
```
or (using wget)
```bash
wget https://github.com/mrlioncub/k8s-hpa-rabbitmq-demo/archive/master.zip
unzip master.zip
cd k8s-hpa-rabbitmq-demo-master
```
__2.__ Add Helm Repositories:
```bash
helm repo add helmforge https://repo.helmforge.dev
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add vm https://victoriametrics.github.io/helm-charts
helm repo add kedacore https://kedacore.github.io/charts
helm repo add k8s-hpa-rabbitmq-demo https://mrlioncub.github.io/k8s-hpa-rabbitmq-demo
helm repo update
```
__3.__ Run deploy (using helm 3). Choose 1 of the 3 options:

__3.1.__ with Prometheus and Prometheus Adapter
```bash
bash deploy-prometheus.sh
```

__3.2.__ with KEDA
```bash
bash deploy-keda.sh
```

__3.3.__ with KEDA and VictoriaMetrics
```bash
bash deploy-victoriametrics.sh
```

__4.__ Check

Check the queues from rabbitmq itself:
```bash
kubectl -n k8-hpa-rabbitmq-demo exec rabbitmq-server-0 -- rabbitmqctl list_queues -s
```
Check the rabbitmq metrics:
```bash
kubectl -n k8-hpa-rabbitmq-demo run curl -it --rm --image=alpine/curl --restart=Never -- curl -s http://rabbitmq-server:15692/metrics | grep 'rabbitmq_queue_messages{vhost="/",queue="task_queue"}'
```
Check hpa (after deployment rabbitmq-agent-reciever):
```bash
kubectl -n k8-hpa-rabbitmq-demo get hpa
```
Result:
```
NAME                  REFERENCE                            TARGETS  MINPODS   MAXPODS   REPLICAS   AGE
rabbitmq-server-hpa   Deployment/rabbitmq-agent-reciever   0/30     1         10        1          4m
```
TARGETS values:
- `0/30` - correct
- `<unknown>/30` - not correct (HPA is awaiting data)

(Only for Prometheus) Check api custom metrics (a few minutes after deployment prometheus-adapter):
```bash
kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1/namespaces/k8-hpa-rabbitmq-demo/pods/rabbitmq-server-0/rabbitmq_queue_messages | jq .
```
Result:
```json
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
(Only for KEDA) Check scaledobject (a few minutes after deployment KEDA):
```bash
kubectl -n k8-hpa-rabbitmq-demo get scaledobject
```
Result:
```
NAME                    SCALETARGETKIND      SCALETARGETNAME           MIN   MAX   READY   ACTIVE   FALLBACK   PAUSED   TRIGGERS   AUTHENTICATIONS   AGE
rabbitmq-scaledobject   apps/v1.Deployment   rabbitmq-agent-reciever   1     10    True    False    Unknown    False    rabbitmq                     108s
```

__5.__ Run sending messages:
```bash
kubectl --namespace k8-hpa-rabbitmq-demo run sender -it --rm --image=mrlioncub/rabbitmq-agent --restart=Never -- sender 50
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
kubectl -n k8-hpa-rabbitmq-demo get hpa -w
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
  
__Tests conducted on Azure, MicroK8s and Minikube__

## Errors

May occur when upgrading from Prometheus HPA to KEDA:
```
Error: UPGRADE FAILED: failed to create resource: admission webhook "vscaledobject.kb.io" denied the request: the workload 'rabbitmq-agent-reciever' of type 'apps/v1.Deployment' is already managed by the hpa 'rabbitmq-server-hpa'
```
Resolution:
```
kubectl delete hpa rabbitmq-server-hpa -n k8-hpa-rabbitmq-demo
# or
helm upgrade --install --create-namespace --namespace k8-hpa-rabbitmq-demo rabbitmq-agent-reciever charts/rabbitmq-agent --set autoscaling.enabled=false
```


## Links

https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/  
https://github.com/kubernetes-sigs/prometheus-adapter/blob/master/docs/config-walkthrough.md  
https://keda.sh/docs/latest/reference/scaledobject-spec/  
https://keda.sh/docs/latest/scalers/rabbitmq-queue/  
https://keda.sh/docs/latest/scalers/prometheus/  
https://www.rabbitmq.com/docs/monitoring  
https://helmforge.dev/docs/charts/rabbitmq/

https://ryanbaker.io/2019-10-07-scaling-rabbitmq-on-k8s/  
