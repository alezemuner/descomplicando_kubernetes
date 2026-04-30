# 📈 Descomplicando Kubernetes - Day 14: HPA e Metrics Server

## Índice
- [HPA - Horizontal Pod Autoscaler](#hpa---horizontal-pod-autoscaler)
- [Instalando o Metric Server](#instalando-o-metric-server)
- [Criando o HPA](#criando-o-hpa)
- [Locust](#locust)
- [ContainerResource com HPA](#containerresource-com-hpa)

---

## HPA - Horizontal Pod Autoscaler

Escala automaticamente os pods com base em métricas de uso de CPU, memória ou outras métricas personalizadas.

| Característica | Descrição |
|----------------|-----------|
| **Escalonamento automático** | Ajusta o número de réplicas baseado em métricas |
| **Métricas suportadas** | CPU, memória e métricas personalizadas |
| **Zero downtime** | Mantém a aplicação disponível durante escalonamento |

---

## Instalando o Metric Server

O Metric Server é um componente que coleta métricas de uso de recursos dos pods e nós do cluster. Ele é necessário para que o HPA possa tomar decisões de escalonamento com base nessas métricas.

> **Referência:** https://github.com/kubernetes-sigs/metrics-server

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

> **Nota:** Em produção utilizar o Helm para configurar o Metric Server com as opções adequadas para o ambiente.

### Confirme se o Metric Server está em execução

```bash
kubectl get pods -n kube-system
```

```
NAME                    READY   STATUS   RESTARTS   AGE
metrics-server-...      1/1     Running  2 (83m ago)  7d3h
```

### Verifique as métricas de uso

```bash
kubectl top nodes    # Métricas de uso dos nós
kubectl top pods     # Métricas de uso dos pods
```

> **Solução de problemas:** Caso o pod `metrics-server-...` ficar `0/1`, pode ser necessário adicionar a seguinte configuração para permitir que o Metric Server colete métricas de nós com certificados autoassinados:

```bash
kubectl edit deployment metrics-server -n kube-system
```

Adicione a seguinte linha na seção `args`:

```yaml
- --kubelet-insecure-tls
```

---

## Criando o HPA

### 1. Criar um deployment do nginx

```bash
kubectl apply -f deployment.yaml
kubectl get deploy
```

```
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   1/1     1            1           2m26s
```

### 2. Criar um service do tipo NodePort

```bash
kubectl expose deployment nginx-deployment --type=NodePort --name=nginx-nodeport
kubectl get svc
```

```
NAME             TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
nginx-nodeport   NodePort    10.99.23.146   <none>        80:31804/TCP   4s
```

> 🔗 Acesse o serviço em: `http://localhost:31804/`

### 3. Criar um service do tipo LoadBalancer

```bash
kubectl apply -f loadbalancer.yaml
kubectl get svc
```

```
NAME             TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)          AGE
nginx-lb         LoadBalancer   10.111.27.71   172.16.44.248   8888:32529/TCP   3s
```

> 🔗 Acesse o serviço em: `http://172.16.44.248:8888/`

### 4. Criar o HPA

```bash
kubectl apply -f primeiro-hpa.yaml
kubectl get hpa
```

```
NAME                   REFERENCE                     TARGETS                                    MINPODS   MAXPODS   REPLICAS   AGE
nginx-deployment-hpa   Deployment/nginx-deployment   cpu: 0%/50%, memory: 20%/70% + 1 more...   1         3         1          17s
```

---

## Locust

Stress testing tool para simular carga em aplicações e verificar o comportamento do HPA.

| Característica | Descrição |
|----------------|-----------|
| **Tipo** | Ferramenta de teste de carga |
| **Interface** | Web UI para configuração |
| **Escalabilidade** | Suporta milhares de usuários simulados |

### Instalação do Locust

```bash
# Cria e ativa a venv
python3 -m venv venv
source venv/bin/activate

# Para desativar a venv quando terminar
deactivate

# Instala o Locust
pip install locust
```

### Iniciar o Locust

```bash
locust -f locustfile.py
```

### Acesse a interface web do Locust

Abra um navegador no host e vá para: **http://localhost:8089**

Configure:
- **Users simulados:** 10000
- **Taxa de spawn:** 100
- **Host:** `http://172.16.44.202:31804/`

> Se o Locust estiver rodando como um pod dentro do cluster, utilize: `http://nginx.default.svc.cluster.local`

### Monitorando durante o teste

```bash
# Observar os logs do pod nginx
kubectl logs -f nginx-deployment-5c5dfd79d7-nxtmg

# Observar a criação de novos pods
kubectl get pods

# Verificar métricas e comportamento do HPA
kubectl describe hpa nginx-deployment-hpa

# Observar o número de réplicas aumentando
kubectl get deploy nginx-deployment -w
```

Exemplo de saída durante o teste:

```
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5c5dfd79d7-lgdhr   1/1     Running   0          4m52s
nginx-deployment-5c5dfd79d7-nxtmg   1/1     Running   0          21m
nginx-deployment-5c5dfd79d7-wzps2   1/1     Running   0          7s
```

✅ O HPA deve criar novos pods para atender à demanda, aumentando o número de réplicas do deployment.

---

## ContainerResource com HPA

Utilizar o HPA para monitorar um container específico dentro do pod (como o container nginx) e escalar com base no uso de CPU ou memória desse container.

| Tipo de Métrica | Descrição |
|----------------|-----------|
| **ContainerResource** | Monitora CPU/memória de containers específicos |
| **Sem métricas personalizadas** | Não requer configuração adicional |

Uma forma de configurar um tipo de métrica já configurada no Kubernetes, como CPU ou memória, é utilizando o **ContainerResource**. Ele permite que o HPA escale com base em métricas de uso de recursos dos containers, como CPU ou memória, sem a necessidade de configurar métricas personalizadas.

