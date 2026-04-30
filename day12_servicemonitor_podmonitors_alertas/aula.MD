# 📊 Descomplicando Kubernetes - Day 12: ServiceMonitor, PodMonitor e Alertas

## Índice
- [Custom Resource Definitions](#custom-resource-definitions)
- [ServiceMonitor](#servicemonitor)
- [PodMonitor](#podmonitor)
- [PrometheusRule](#prometheusrule)

---

## Custom Resource Definitions

**CRDs** estendem o Kubernetes para descobrir e monitorar serviços automaticamente.

| CRD | Descrição |
|-----|-----------|
| **ServiceMonitor** | Monitora serviços do cluster |
| **PodMonitor** | Monitora pods do cluster |
| **PrometheusRule** | Define regras de alerta |

📚 **Referência:** [prometheus-operator/prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)

---

## ServiceMonitor

### Listar CRDs e ServiceMonitors

```bash
# Listar CRDs instaladas
k get customresourcedefinitions.apiextensions.k8s.io
# servicemonitors.monitoring.coreos.com                   2026-01-30T16:24:47Z

# Listar ServiceMonitors
k get servicemonitors -A
# NAMESPACE    NAME                      AGE
# default      nginx-servicemonitor      67d
# monitoring   alertmanager-main         87d
# monitoring   grafana                   87d
# monitoring   kube-apiserver            87d
# ...
```

### Criar um ServiceMonitor

```bash
# Criar deployment
k apply -f nginx-deployment.yaml
k get deploy
# NAME           READY   UP-TO-DATE   AVAILABLE   AGE
# nginx-server   3/3     3            3           13m

# Criar configmap
k apply -f nginx-configmap.yaml
k get configmaps
# NAME               DATA   AGE
# nginx-config       1      13d

# Criar service
k apply -f nginx-service.yaml
k get svc
# NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
# nginx-svc    ClusterIP   10.99.44.245   <none>        9133/TCP   4s
```

### Verificar Métricas

```bash
# Acessar o pod
k exec -it nginx-server-57b9496d6-96cj6 -c nginx -- bash

# Ver métricas na porta padrão
curl localhost/metrics
# Active connections: 2 
# server accepts handled requests
#  3 3 77 

# Ver métricas do exporter
curl localhost:9113/metrics
# HELP nginx_connections_accepted Accepted client connections
# TYPE nginx_connections_accepted counter
nginx_connections_accepted 3
# HELP nginx_connections_active Active client connections
# TYPE nginx_connections_active gauge
nginx_connections_active 1
# ...
```

### Aplicar ServiceMonitor

```bash
# Criar ServiceMonitor
k apply -f nginx-servicemonitor.yaml

# Ver ServiceMonitor
k get servicemonitors
# NAME                   AGE
# nginx-servicemonitor   67d
```

### Acessar o Prometheus

```bash
# Via port-forward
k port-forward -n monitoring svc/prometheus-k8s 39090:9090

# Via NodePort
k expose svc -n monitoring prometheus-k8s --type NodePort --name prometheus-nodeport
k get svc -n monitoring
# NAME                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
# prometheus-nodeport     NodePort       10.99.252.200    <none>          9090:30445/TCP,8080:30319/TCP   26s

# Acessar: http://172.16.44.240:30445
```

---

## PodMonitor

### O que é

O **PodMonitor** permite monitorar pods diretamente, sem necessidade de Service.

```bash
# Criar pod
k apply -f nginx-pod.yaml
k get pods
# NAME                           READY   STATUS    RESTARTS      AGE
# nginx-pod                      2/2     Running   4 (90s ago)   2m14s

# Ver métricas
k exec -it nginx-pod -c nginx-container -- bash
curl localhost:9113/metrics

# Criar PodMonitor
k apply -f nginx-pod-monitor.yaml

# Ver PodMonitors
k get podmonitors
# NAME               AGE
# nginx-podmonitor   67d
```

---

## PrometheusRule

### O que é

O **PrometheusRule** define regras de alerta para o Prometheus.

```bash
# Criar regra de alerta
k apply -f nginx-prometheus-rule.yaml

# Ver regras
k get prometheusrules.monitoring.coreos.com -n monitoring

# Ver configmaps
k get configmaps -n monitoring
```

---

> 💡 **Resumo:** CRDs como ServiceMonitor, PodMonitor e PrometheusRule permitem estender o Kubernetes para monitoramento automático de serviços e pods.

k apply -f nginx-pod.yaml
k get pods
NAME                           READY   STATUS    RESTARTS      AGE
nginx-pod                      2/2     Running   4 (90s ago)   2m14s

k exec -it nginx-pod -c nginx-container -- bash
curl localhost:9113/metrics

k apply -f nginx-pod-monitor.yaml

k get podmonitors
NAME               AGE
nginx-podmonitor   67d
```

# PrometheusRule
Uma forma de criar regras de alerta para o Prometheus é utilizando o recurso `PrometheusRule` do Prometheus Operator. Ele permite que o Prometheus descubra e monitore os serviços do Kubernetes de forma automática.

```bash
k apply -f nginx-prometheus-rule.yaml


k get prometheusrules.monitoring.coreos.com -n monitoring
k get configmaps -n monitoring
```