# 🔒 Descomplicando Kubernetes - Day 17: Network Policies no EKS

## Índice
- [Instalando o EKS com EKSCTL](#instalando-o-eks-com-eksctl)
- [Instalando Nginx Ingress](#instalando-nginx-ingress)
- [Subindo o Deployment e Services](#subindo-o-deployment-e-services)
- [Ingress](#ingress)
- [Testando conexão interna](#testando-conexão-interna)
- [Criando Network Policy](#criando-network-policy)
  - [Bloquear pods de outras namespaces se comuniquem com o Redis](#bloquear-pods-de-outras-namespaces-se-comuniquem-com-o-redis)

---

## Instalando o EKS com EKSCTL

Instalar o EKSCTL e awsCLI.

---

## Instalando Nginx Ingress

Ver `day09_ingress/aula.MD`.

```bash
k get pods -n ingress-nginx
NAME                                        READY   STATUS    RESTARTS        AGE
ingress-nginx-controller-7c7497fd7b-fgfff   1/1     Running   2 (4h29m ago)   5h4m

k get svc -n ingress-nginx
NAME                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             NodePort    10.99.247.191   <none>        80:31479/TCP,443:30547/TCP   112d
ingress-nginx-controller-admission   ClusterIP   10.101.90.18    <none>        443/TCP                      112d

k get ingressclasses.networking.k8s.io
NAME    CONTROLLER             PARAMETERS   AGE
nginx   k8s.io/ingress-nginx   <none>       112d
```

---

## Subindo o Deployment e Services

```bash
k apply -f deploy-giropops-senhas.yaml
k apply -f deploy-redis.yaml

k get pods -n giropops
NAME                                      READY   STATUS    RESTARTS   AGE
giropops-senhas-deploy-65d7c9bf4c-d4vdk   1/1     Running   0          11m
giropops-senhas-deploy-65d7c9bf4c-d64rx   1/1     Running   0          11m
redis-deployment-6dcf7778b4-kpl6h         1/1     Running   0          4m5s

k get svc -n giropops
NAME                  TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
giropops-senhas-svc   ClusterIP   10.100.152.5    <none>        5000/TCP   8m40s
redis-svc             ClusterIP   10.97.209.131   <none>        6379/TCP   2m13s

# Expor um svc NodePort para ficar acessível na rede
k expose svc giropops-senhas-svc -n giropops --type NodePort --name giropops-nodeport

k get svc -n giropops
NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
giropops-nodeport     NodePort    10.103.136.190   <none>        5000:31702/TCP   3s

# Para testar localhost
k port-forward -n giropops svc/giropops-senhas-svc 5000:5000
# localhost:5000
```

---

## Ingress

```bash
kubectl apply -f ingress-giropops-senhas.yaml

k get ingress -n giropops
NAME               CLASS   HOSTS               ADDRESS   PORTS   AGE
giropops-ingress   nginx   giropops.nginx.io             80      18s

# Adicionar entrada no /etc/hosts da VM master-node
sudo nano /etc/hosts

# Adicionar:
127.0.0.1   giropops.nginx.io

kubectl get svc -n ingress-nginx
NAME                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             NodePort    10.99.247.191   <none>        80:31479/TCP,443:30547/TCP   112d
ingress-nginx-controller-admission   ClusterIP   10.101.90.18    <none>        443/TCP                      112d

# http://giropops.nginx.io:31479/
```

---

## Testando conexão interna

```bash
# Subir um container Alpine
k run -it alpine --image alpine -- sh

apk add curl
curl giropops-senhas-svc.giropops.svc.cluster.local:5000

curl redis-svc.giropops.svc:6379

apk add redis
redis-cli -h redis-svc.giropops.svc ping
PONG
```

---

## Criando Network Policy

### Bloquear pods de outras namespaces se comuniquem com o Redis

```bash
k get netpol

k apply -f primeira-network-policy.yaml
networkpolicy.networking.k8s.io/primeira-netpol created

k get netpol -n giropops
NAME              POD-SELECTOR   AGE
primeira-netpol   app=redis      19s

k exec -it alpine -- sh
apk add curl
curl giropops-senhas-svc.giropops.svc.cluster.local:5000  # Funciona

apk add redis
redis-cli -h redis-svc.giropops.svc ping  # Não funciona, pois está bloqueado pela policy; qualquer pod fora da namespace giropops não pode acessar o Redis

# Testar na mesma namespace: a comunicação deve funcionar
k run -it alpine --image alpine -n giropops -- sh
apk add curl
curl giropops-senhas-svc.giropops.svc.cluster.local:5000 # funciona
apk add redis
redis-cli -h redis-svc.giropops.svc ping # funciona
```

## Bloquear todos os pods que não estao na namespace giropops
```bash
k apply -f segunda-network-policy.yaml
networkpolicy.networking.k8s.io/segunda-netpol created

k delete netpol -n giropops primeira-netpol #deletar a primeria não conflitar

k exec -it alpine -- sh
apk add curl
curl giropops-senhas-svc.giropops.svc.cluster.local:5000 # não funciona
apk add redis
redis-cli -h redis-svc.giropops.svc ping # não funciona
```

## Liberar acesso ao namespace ingress-nginx
```bash
k delete netpol -n giropops segunda-netpol #deletar a segunda não conflitar
k apply -f terceira-network-policy.yaml
networkpolicy.networking.k8s.io/terceira-netpol created

k exec -it alpine -- sh
apk add curl
curl giropops-senhas-svc.giropops.svc.cluster.local:5000 # não funciona
apk add redis
redis-cli -h redis-svc.giropops.svc ping # não funciona
```

## Bloqueia ingress todo
```bash
k delete netpol -n giropops terceira-netpol #deletar a terceira não conflitar
k apply -f 01-bloqueia-ingress-todo-policy.yaml
k apply -f 02-libera-entre-redis-app-policy.yaml
k apply -f 03-libera-ingress-policy.yaml
k apply -f 04-ajusta-egress-policy.yaml
k apply -f 05-ajusta-egress-dentro-ns.yaml  
k apply -f 06-bloqueando-redes-policy.yaml

k get netpol -n giropops
NAME                   POD-SELECTOR   AGE
allow-app-to-redis     <none>         4m10s
allow-dns              <none>         14m
allow-ingress          <none>         19m
allow-redis-app-only   app=redis      19m
default-deny-all       <none>         20m

#no meu ambiente funcionou atraves do yaml:
k apply -f funciona-no-meu-cluster.policy.yaml
```