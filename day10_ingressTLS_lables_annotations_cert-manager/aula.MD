# 🔒 Descomplicando Kubernetes - Day 10: Ingress TLS, Labels, Annotations e Cert-Manager

## Índice
- [Cert-Manager](#cert-manager)
- [Annotations](#annotations)
- [Labels](#labels)
- [Autenticação no Ingress](#autenticação-no-ingress)
- [Session Affinity](#session-affinity)
- [Canary Deploy](#canary-deploy)
- [Rate Limiting](#rate-limiting)

---

## Cert-Manager

### O que é

O **cert-manager** é um addon Kubernetes para gerenciar certificados TLS automaticamente, com integração ao **Let's Encrypt**.

| Recurso | Descrição |
|---------|-----------|
| **Issuer** | Solicita certificados (ACME ou CA) |
| **ClusterIssuer** | Issuer para todo o cluster |
| **Certificate** | Certificado solicitado |

### Documentação

📚 [Cert-Manager Installation](https://cert-manager.io/docs/installation/)
📚 [Cert-Manager ACME](https://cert-manager.io/docs/configuration/acme/)

### Modos de Uso

| Modo | Limite | Uso |
|------|--------|-----|
| **Staging** | 50 certificados/semana | Testes |
| **Production** | 300 certificados/semana | Produção |

> ⚠️ Use staging para testes e production para produção.

### Instalação

```bash
# Instalar o cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.19.2/cert-manager.yaml

# Em produção, instalar via Helm
# helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace

# Desinstalar
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.19.2/cert-manager.yaml
```

### Verificar Instalação

```bash
# Ver pods
k get pods -n cert-manager

# Ver todos os recursos
k get all -n cert-manager
```

### Criar Issuers

```bash
# Issuer Staging (testes)
k apply -f staging-issuer.yaml

# Issuer Production
k apply -f production-issuer.yaml

# Ver issuers
k get issuers
# NAME                  READY   AGE
# letsencrypt-staging   True    26s

k get clusterissuers
# NAME                READY   AGE
# letsencrypt-prod    True    34s
# selfsigned-issuer   True    79d

# Descrever issuer
k describe issuers letsencrypt-staging
```

### Criar Ingress com TLS

```bash
# Aplicar ingress com TLS
k apply -f ingress-encrypt.yaml
k get ingress
# NAME              CLASS   HOSTS               ADDRESS         PORTS     AGE
# giropops-senhas   nginx   giropops.nginx.io   172.16.44.240   80, 443   19m

# Ver certificados
k get certificate
# NAME                  READY   SECRET                AGE
# giropops-senhas-tls   True    giropops-senhas-tls   19m

# Ver certificate requests
k get certificaterequests
# NAME                    APPROVED   DENIED   READY   ISSUER              REQUESTER                                         AGE
# giropops-senhas-tls-1   True                True    selfsigned-issuer   system:serviceaccount:cert-manager:cert-manager   4m21s

# Descrever certificado
k describe certificate giropops-senhas-tls
```

> 💡 Os certificados são armazenados em **Secrets**.
pod/giropops-senhas-7bf67599dd-hcj9h   0/1     Terminating   0          24h

NAME                      TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
service/giropops-senhas   ClusterIP   10.102.92.8   <none>        5000/TCP   28h

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/giropops-senhas   2/2     2            2           24h

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/giropops-senhas-7bf67599dd   2         2         2       24h

---

## Labels

### O que são

**Labels** categorizam ou agrupam objetos do Kubernetes para seleção de recursos.

```bash
# Adicionar label
k label pods redis-deployment-6dcf7778b4-ntwt7 nome=alexandre
k describe pods redis-deployment-6dcf7778b4-ntwt7 #verificar os labels do pod redis
Labels:           app=redis
                  nome=alexandre
                  pod-template-hash=6dcf7778b4

k label pods redis-deployment-6dcf7778b4-ntwt7 nome=alexandre --overwrite #sobrescreve o label nome do pod redis para alexandre
k label pods redis-deployment-6dcf7778b4-ntwt7 nome- #remove o label app do pod redis

k get pods -L app # #listar os pods com a coluna do label app
NAME                                READY   STATUS        RESTARTS   AGE   APP
giropops-senhas-7bf67599dd-6xnj9    1/1     Running       0          24h   giropops-senhas
giropops-senhas-7bf67599dd-f75b7    1/1     Running       0          24h   giropops-senhas
giropops-senhas-7bf67599dd-hcj9h    0/1     Terminating   0          24h   giropops-senhas
redis-deployment-6dcf7778b4-ntwt7   1/1     Running       0          24h   redis                  


k get pods redis-deployment-6dcf7778b4-ntwt7 -o yaml > pod-redis.yaml #exporta a configuração do pod redis para um arquivo YAML
k get pods redis-deployment-6dcf7778b4-ntwt7 -o jsonpath='{.metadata.labels}' #exibe apenas os labels do pod redis
# {"app":"redis","nome":"alexandre","pod-template-hash":"6dcf7778b4"}%
```

---

## Autenticação no Ingress

### Basic Auth

```bash
# Instalar htpasswd (Fedora/RedHat/CentOS)
sudo dnf install httpd-tools -y

# Criar arquivo de senha
htpasswd -c auth alexandre

# Criar secret
k create secret generic giropops-senhas-users --from-file=auth
k get secrets
# NAME                         TYPE                             DATA   AGE
# giropops-senhas-users        Opaque                           1      4s
```

### Annotations para Autenticação

```yaml
# No Ingress, adicionar:
annotations:
  nginx.ingress.kubernetes.io/auth-type: basic
  nginx.ingress.kubernetes.io/auth-secret: "giropops-senhas-users"
  nginx.ingress.kubernetes.io/auth-realm: "Autenticacao Necessaria"
```

---

## Session Affinity

### Cookie Affinity

```yaml
# Annotations para afinidade de sessão
annotations:
  nginx.ingress.kubernetes.io/affinity: "cookie"
  nginx.ingress.kubernetes.io/session-cookie-name: "giropops-cookie"
```

```bash
# Testar
curl -I -k https://giropops.nginx.io:30547
# HTTP/2 200
# set-cookie: giropops-cookie=1776364833.244.1780.651533|...; Path=/; Secure; HttpOnly
```

### Hash-based

```yaml
# Hash baseado na URI
annotations:
  nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
```

---

## Canary Deploy

### Configuração

```yaml
# Ingress canary
annotations:
  nginx.ingress.kubernetes.io/canary: "true"
  nginx.ingress.kubernetes.io/canary-weight: "10"
```

```bash
# Criar aplicação canary
k run nginx --image nginx --port 80
k expose pod nginx --type NodePort --name nginx
# Acessar: http://172.16.44.240:31679/

# Aplicar ingress canary
k apply -f ingress-encrypt-canary.yaml
```

> 💡 10% do tráfego vai para a versão canary, 90% para a versão stable.

---

## Rate Limiting

### Limitando Requisições

```yaml
# Limitar RPS (requests per second)
annotations:
  nginx.ingress.kubernetes.io/limit-rps: "2"
```

```bash
# Testar rate limiting
for i in {1..10}; do curl -s -o /dev/null -w "%{http_code}\n" https://giropops.nginx.io:30547; done
```

---

> 💡 **Resumo:** O cert-manager automatiza certificados TLS com Let's Encrypt. Annotations e labels são essenciais para configuração avançada do Ingress. 
#inserir essas linhas no ingress-encrypt.yaml:
nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri" # Habilita hashing baseado na URI da requisição

k apply -f ingress-encrypt.yaml

k describe ingress giropops-senhas | grep Annotations -A 5 #verificar as anotações do ingress
```

# Canary deploy com o ingress

```bash
#inserir essas linhas no ingress-encrypt-canary.yaml:
    nginx.ingress.kubernetes.io/canary: "true" # Habilita o suporte a canary releases
    nginx.ingress.kubernetes.io/canary-weight: "10" # Define o peso do tráfego para o canary (10%)

k run nginx --image nginx --port 80 
k expose pod nginx --type NodePort --name nginx
k get svc
NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx             NodePort    10.106.97.253   <none>        80:31679/TCP   4s
http://172.16.44.240:31679/

k apply -f ingress-encrypt-canary.yaml

F5 na pagina https://giropops.nginx.io:30547/ ate aparecer o nginx canary, que é a versão canary do nginx, ou seja, a versão que recebe 10% do tráfego, e o restante do tráfego vai para a versão normal do nginx, que é a versão stable.
```

# Limitando requisições com o ingress
Uma forma de limitar o número de requisições que um usuário pode fazer em um determinado período de tempo, para evitar ataques de negação de serviço (DDoS) ou para evitar que um usuário abuse do sistema.
```bash
#inserir essas linhas no ingress-encrypt.yaml:
nginx.ingress.kubernetes.io/limit-rps: "2"

k apply -f ingress-encrypt.yaml

for i in {1..10}; do curl -s -o /dev/null -w "%{http_code}\n" https://giropops.nginx.io:30547; done # 
```