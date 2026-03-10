# ServiceMonitor
Uma forma de monitorar os serviços do cluster é utilizando o recurso `ServiceMonitor` do Prometheus Operator. Ele permite que o Prometheus descubra e monitore os serviços do Kubernetes de forma automática.

```bash
k get customresourcedefinitions.apiextensions.k8s.io # 

k exec -it nginx-server-57b9496d6-7rp5b -c nginx -- bash

k get servicemonitors.monitoring.coreos.com
```

# ServicePodMonitor
Uma outra forma de monitorar os serviços do cluster é utilizando o recurso `PodMonitor` do Prometheus Operator. Ele permite que o Prometheus descubra e monitore os pods do Kubernetes de forma automática.

```bash
k get podmonitors.monitoring.coreos.com
```

# PrometheusRule
Uma forma de criar regras de alerta para o Prometheus é utilizando o recurso `PrometheusRule` do Prometheus Operator. Ele permite que o Prometheus descubra e monitore os serviços do Kubernetes de forma automática.

```bash
k get prometheusrules.monitoring.coreos.com -n monitoring
```