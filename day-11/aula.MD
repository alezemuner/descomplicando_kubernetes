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

## Instalação

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
kubectl get servicemonitors
```

### 3️⃣ Aplicar os manifestos

```bash
kubectl apply -f ./manifests
```

Verificar pods:
```bash
kubectl get pods -n monitoring
```

---

## Acessando o Grafana

### Opção 1: Port Forward (localhost apenas)

```bash
kubectl port-forward -n monitoring svc/grafana 3000:3000
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
