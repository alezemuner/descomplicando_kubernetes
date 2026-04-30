# 🌐 Descomplicando Kubernetes - Day 9: Ingress

## Índice
- [O que é Ingress](#o-que-é-ingress)
- [Instalação do Nginx Ingress](#instalação-do-nginx-ingress)
- [Criando Ingress Resources](#criando-ingress-resources)
- [Host-based Routing](#host-based-routing)

---

## O que é Ingress

**Ingress** é um recurso do Kubernetes que gerencia o acesso externo aos serviços em um cluster, geralmente via HTTP.

| Característica | Descrição |
|----------------|-----------|
| **Balanceamento de carga** | Distribui requisições entre pods |
| **Terminação SSL** | HTTPS termination |
| **Hospedagem virtual** | Virtual hosting baseado em nome |
| **Roteamento** | Uma regra por serviço, múltiplos hosts possíveis |

### Recursos Adicionais

- 🔐 TLS/SSL
- 🔑 Autenticação e autorização
- 📝 Rewrites e redirecionamentos

📚 **Documentação oficial:**
- [Ingress Nginx](https://github.com/kubernetes/ingress-nginx/blob/main/README.md)
- [Deploy Guide](https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal-clusters)

---

## Instalação do Nginx Ingress

### Bare Metal (kubectl)

```bash
# Instalar o Nginx Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.14.0/deploy/static/provider/baremetal/deploy.yaml

# Verificar os Pods
kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --watch
```

### Verificar o Service

```bash
# Ver serviços do Ingress Controller
kubectl get svc -n ingress-nginx

# NAME                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
# ingress-nginx-controller             NodePort    10.99.247.191   <none>        80:31479/TCP,443:30547/TCP   93d
# ingress-nginx-controller-admission   ClusterIP   10.101.90.18    <none>        443/TCP                      93d
```

---

## Criando Ingress Resources

### Preparar Aplicação

```bash
# Subir deployment da aplicação
k apply -f app-deployment.yaml
k get pods
# NAME                               READY   STATUS    RESTARTS   AGE
# giropops-senhas-7bf67599dd-2c6nd   1/1     Running   0          91s
# giropops-senhas-7bf67599dd-crfdh   1/1     Running   0          91s

# Criar service
k apply -f app-service.yaml
k get svc
# NAME              TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
# giropops-senhas   ClusterIP   10.102.92.8   <none>        5000/TCP   5s
# kubernetes        ClusterIP   10.96.0.1     <none>        443/TCP    253d

# Ver EndpointSlice
k get EndpointSlice
# NAME                    ADDRESSTYPE   PORTS   ENDPOINTS                   AGE
# giropops-senhas-f5jk2   IPv4          5000    10.244.30.102,10.244.5.27   47s
```

---

### Redis (exemplo adicional)

```bash
# Deployment Redis
k apply -f redis-deployment.yaml
k get pods
# NAME                                READY   STATUS    RESTARTS   AGE
# giropops-senhas-7bf67599dd-2c6nd    1/1     Running   0          7m36s
# redis-deployment-6dcf7778b4-lwbnt   1/1     Running   0          2m5s

# Service Redis
k apply -f redis-service.yaml
k get svc
# NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
# redis-service     ClusterIP   10.104.17.174   <none>        6379/TCP   4s
```

### Expor Service como NodePort

```bash
# Expor um service através de outro service
k expose service giropops-senhas --name teste --type=NodePort
k get svc
# NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
# teste             NodePort    10.105.239.77   <none>        5000:30262/TCP   5s

# Port-forward para testar
k port-forward services/giropops-senhas 5000:5000
```

---

### Ingress 1 - Path Básico

```bash
# Aplicar o Ingress
k apply -f ingress-1.yaml

# Ver o Ingress
k get ingress
# NAME              CLASS   HOSTS   ADDRESS         PORTS   AGE
# giropops-senhas   nginx   *       172.16.44.240   80      32s

# Acessar: http://172.16.44.240:31479/giropops-senhas

# Descrever o Ingress
k describe ingress giropops-senhas
```

### Ingress 2 - Múltiplos Paths

```bash
k apply -f ingress-2.yaml
k get ingress
# NAME                     CLASS   HOSTS   ADDRESS         PORTS   AGE
# giropops-senhas          nginx   *       172.16.44.240   80      21m
# giropops-senhas-static   nginx   *       172.16.44.240   80      2m2s
```

### Ingress 3 - Rewrite

```bash
k apply -f ingress-3.yaml
k get ingress
# NAME              CLASS   HOSTS   ADDRESS         PORTS   AGE
# giropops-senhas   nginx   *       172.16.44.240   80      79s
```

---

## Host-based Routing

### Criar Aplicação de Teste

```bash
# Criar Pod Nginx
k run nginx --image nginx --port 80

# Expor como Service
k expose pod nginx
```

### Ingress 4 - Host Específico

```bash
# Aplicar Ingress com host
k apply -f ingress-4.yaml

k get ingress
# NAME              CLASS   HOSTS               ADDRESS         PORTS   AGE
# giropops-senhas   nginx   *                   172.16.44.240   80      11m
# nginx             nginx   giropops.nginx.io                   80      7s
```

### Configurar /etc/hosts

```bash
# Adicionar entrada no /etc/hosts
sudo nano /etc/hosts

# Adicionar:
127.0.0.1   giropops.nginx.io

# Acessar:
http://giropops.nginx.io
```

### Ingress 5 - Múltiplos Hosts

```bash
k apply -f ingress-5.yaml
k get ingress
# NAME              CLASS   HOSTS                ADDRESS         PORTS   AGE
# giropops-senhas   nginx   giropops-senhas.io   172.16.44.240   80      49m
# nginx             nginx   giropops.nginx.io    172.16.44.240   80      38m
```

---

## Monitoramento

### Ver Logs do Ingress Controller

```bash
# Acompanhar requisições
k logs -f ingress-nginx-controller-7c7497fd7b-blw6d -n ingress-nginx
```

---

> 💡 **Resumo:** O Ingress é a forma recomendada para expor serviços HTTP/HTTPS em um cluster Kubernetes, permitindo roteamento baseado em path e host, terminação SSL, e muito mais.