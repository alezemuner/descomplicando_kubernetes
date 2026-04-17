# Prometheus via kube-prometheus

📚 Referência: [prometheus-operator/prometheus-operator](https://github.com/prometheus-operator/prometheus-operator)

## Sobre o kube-prometheus

O `kube-prometheus` é um conjunto de manifestos do Kubernetes que nos permite ter:
- Prometheus Operator
- Grafana
- AlertManager
- Node Exporter
- Kube-State-Metrics
- Prometheus-Adapter

Tudo instalado, configurado e com alta disponibilidade. Oferece uma visão completa do cluster Kubernetes, monitorando componentes como:
- kube-scheduler
- kube-controller-manager
- kubelet
- kube-proxy
- E muito mais

---

## Instalação Kube-Prometheus

### 1️⃣ Clonar o repositório

```bash
git clone https://github.com/prometheus-operator/kube-prometheus
```

### 2️⃣ Criar o namespace e CRDs

```bash
kubectl create -f ./manifests/setup
```

Verificar:
```bash
kubectl get namespaces
NAME                 STATUS   AGE
monitoring           Active   76d

```

### 3️⃣ Aplicar os manifestos

```bash
kubectl apply -f ./manifests
```

Verificar pods:
```bash
kubectl get servicemonitors -A
NAMESPACE    NAME                      AGE
default      nginx-servicemonitor      56d
monitoring   alertmanager-main         76d
monitoring   blackbox-exporter         76d
monitoring   coredns                   76d
monitoring   grafana                   76d
monitoring   kube-apiserver            76d
monitoring   kube-controller-manager   76d
monitoring   kube-scheduler            76d
monitoring   kube-state-metrics        76d
monitoring   kubelet                   76d
monitoring   node-exporter             76d
monitoring   prometheus-adapter        76d
monitoring   prometheus-k8s            76d
monitoring   prometheus-operator       76d

kubectl get pods -n monitoring
NAME                                  READY   STATUS        RESTARTS        AGE
alertmanager-main-0                   2/2     Running       14 (43h ago)    21d
alertmanager-main-1                   2/2     Running       14 (43h ago)    21d
alertmanager-main-2                   0/2     Terminating   16 (42h ago)    21d
blackbox-exporter-5d9798dd66-zpmn9    3/3     Running       21 (43h ago)    21d
grafana-8567bc6ff9-8f6dx              1/1     Running       7 (43h ago)     21d
kube-state-metrics-8c555bb67-rkbtr    3/3     Running       21 (43h ago)    21d
node-exporter-5g5nz                   2/2     Running       22 (43h ago)    35d
node-exporter-9plkd                   2/2     Running       268 (42h ago)   35d
node-exporter-9vw7h                   2/2     Running       30 (42h ago)    35d
prometheus-adapter-548fc6f964-rdrkp   1/1     Running       7 (43h ago)     21d
prometheus-adapter-548fc6f964-wj9t2   1/1     Running       7 (43h ago)     21d
prometheus-k8s-0                      2/2     Running       14 (43h ago)    21d
prometheus-k8s-1                      0/2     Terminating   16 (42h ago)    21d
prometheus-operator-57c6954d7-hv26g   2/2     Running       14 (43h ago)    21d
```

---

## Acessando o Grafana

### Opção 1: Port Forward (localhost apenas)

```bash
kubectl port-forward -n monitoring svc/grafana 3000:3000 # 
```

Acesse: `http://localhost:3000`

### Opção 2: LoadBalancer

Criar arquivo `grafana-lb.yaml` e aplicar:

```bash
kubectl apply -f grafana-lb.yaml
```

Verificar IP atribuído:
```bash
kubectl get svc grafana-lb -n monitoring
```

**Exemplo de saída:**
```
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)           AGE
grafana-lb   LoadBalancer   10.108.13.4   endereco-ip     33000:31376/TCP   88s
```

Acesse: `http://endereco-ip:33000/`

Caso nao carregue a pagina do grafana, criar uma NetworkPolicy para liberar o acesso:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: grafana-allow-external
  namespace: monitoring
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: grafana
  policyTypes:
    - Ingress
  ingress:
    - ports:
        - protocol: TCP
          port: 3000
```

Criar arquivo `grafana-allow-external.yaml` e aplicar:

```bash
kubectl apply -f grafana-allow-external.yaml
```


### Opção 3: NodePort

```bash     
k expose svc grafana -n monitoring --type NodePort --name grafana-nodeport
k get svc -n monitoring
NAME                    TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
grafana                 ClusterIP   10.107.37.47     <none>        3000/TCP                     76d
grafana-nodeport        NodePort    10.111.165.93    <none>        3000:31620/TCP               50s *
```

--- 

## Acessando o Prometheus

### LoadBalancer

Criar arquivo `prometheus-lb.yaml` e aplicar:

```bash
kubectl apply -f prometheus-lb.yaml
```

Verificar IP atribuído:
```bash
kubectl get svc prometheus-lb -n monitoring
```

**Exemplo de saída:**
```
NAME            TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)           AGE
prometheus-lb   LoadBalancer   10.99.185.44   endereco-ip     33001:31556/TCP   13s
```

Verificar endpoints:
```bash
kubectl get endpoints prometheus-lb -n monitoring
```

**Exemplo de saída:**
```
NAME            ENDPOINTS                          AGE
prometheus-lb   10.244.1.13:9090,10.244.2.9:9090   6m9s
```

Caso nao carregue a pagina do prometheus, criar uma NetworkPolicy para liberar o acesso:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: prometheus-allow-external
  namespace: monitoring
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: prometheus
  policyTypes:
    - Ingress
  ingress:
    - ports:
        - protocol: TCP
          port: 9090
```

Criar arquivo `prometheus-allow-external.yaml` e aplicar:

```bash
kubectl apply -f prometheus-allow-external.yaml
```
---

## Acessando o AlertManager

### LoadBalancer

Criar arquivo `alertmanager-lb.yaml` e aplicar:

```bash
kubectl apply -f alertmanager-lb.yaml
```

Verificar serviço:
```bash
kubectl get svc alertmanager-lb -n monitoring
```

**Exemplo de saída:**
```
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)           AGE
alertmanager-lb   LoadBalancer   10.97.155.127   endereco-ip     33002:31658/TCP   24s
```

Verificar endpoints:
```bash
kubectl get endpointslice alertmanager-lb -n monitoring
```

**Exemplo de saída:**
```
NAME              ENDPOINTS                                          AGE
alertmanager-lb   10.244.1.12:9093,10.244.2.7:9093,10.244.2.8:9093   76s
```

Caso nao carregue a pagina do alertmanager, criar uma NetworkPolicy para liberar o acesso:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: alertmanager-allow-external
  namespace: monitoring
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: alertmanager
  policyTypes:
    - Ingress
  ingress:
    - ports:
        - protocol: TCP
          port: 9093
```

Criar arquivo `alertmanager-allow-external.yaml` e aplicar:

```bash
kubectl apply -f alertmanager-allow-external.yaml
---

## ServiceMonitor

O `ServiceMonitor` é um recurso personalizado (CRD) do Prometheus Operator que permite definir como o Prometheus deve descobrir e monitorar serviços automaticamente no cluster Kubernetes.

### Comandos úteis

Listar todos os ServiceMonitors:
```bash
kubectl get servicemonitors -n monitoring
```

Ver detalhes do ServiceMonitor do Grafana:
```bash
kubectl get servicemonitors grafana -n monitoring -o yaml
```
