# 🔐 Descomplicando Kubernetes - Day 8: Secrets e ConfigMaps

## Índice
- [Secrets](#secrets)
- [Tipos de Secrets](#tipos-de-secrets)
- [ConfigMaps](#configmaps)
- [Boas Práticas](#boas-práticas)

---

## Secrets

### O que é

**Secrets** é uma forma de guardar informações sensíveis no Kubernetes como:
- 🔑 Tokens
- 🔒 Senhas
- 🗝️ Chaves SSH
- 📄 Certificados

| Característica | Descrição |
|----------------|-----------|
| **Armazenamento** | ETCD em base64 |
| **Criptografia** | Não é criptografado por padrão, mas pode ser configurado |
| **Segurança** | Usar RBAC, namespaces e criptografia no ETCD |

📚 **Documentação oficial:** [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

---

### Boas Práticas de Segurança

| Prática | Descrição |
|---------|-----------|
| **RBAC** | Limitar o acesso aos secrets via RoleBasedAccessControl |
| **Namespaces** | Isolar recursos em namespaces específicos |
| **Criptografia ETCD** | Habilitar criptografia no ETCD para proteger dados em repouso |

### Criando e Gerenciando Secrets

#### Codificação Base64

```bash
# Listar todos os secrets
k get secrets -A

# Descrever um secret específico
k describe secrets -n default dockerhub-secret

# Ver secret em formato YAML
k get secrets -n default giropops-senhas-users -o yaml
# apiVersion: v1
# data:
#   auth: YWxleGFuZHJlOiRhcHIxJHRyWXgxaTJ6JHh5YlNGOGZvNnVsRldhUDlJOTl6ZC8K
# kind: Secret
# metadata:
#   creationTimestamp: "2026-01-26T18:10:03Z"
#   name: giropops-senhas-users
#   namespace: default
# type: Opaque

# Decodificar base64
echo -n "YWxleGFuZHJlOiRhcHIxJHRyWXgxaTJ6JHh5YlNGOGZvNnVsRldhUDlJOTl6ZC8K" | base64 -d
# alexandre:$apr1$trYx1i2z$xybSF8fo6ulFWaP9I99zd/
```

#### Secret Opaque (Genérico)

```bash
# Codificar valores em base64
echo -n "giropops" | base64
# Z2lyb3BvcHM=

echo -n "alexandre" | base64
# YWxleGFuZHJl

# Criar secret via arquivo YAML
k apply -f primeiro-secret.yaml

# Ver secrets criados
k get secret
# NAME                  TYPE                             DATA   AGE
# primeiro-secret       Opaque                           2      79s

# Ver detalhes do secret
k get secret primeiro-secret -o yaml
# apiVersion: v1
# data:
#   password: Z2lyb3BvcHM=
#   username: YWxleGFuZHJl
# kind: Secret
# metadata:
#   annotations: ...
# type: Opaque

# Deletar secret
k delete secret primeiro-secret
```

#### Criar Secret via CLI

```bash
# Criar secret genérico via linha de comando
k create secret generic primeiro-secret \
  --from-literal=username=YWxleGFuZHJl \
  --from-literal=password=Z2lyb3BvcHM=
```

---

### Usando Secrets como Variáveis de Ambiente

```bash
# Criar Pod com secret
k apply -f pod-secret.yaml

# Ver Pods
k get pods
# NAME    READY   STATUS    RESTARTS   AGE
# nginx   1/1     Running   0          8s

# Descrever o pod para ver as variáveis de ambiente
k describe pods nginx
# Environment:
#   USERNAME:  <set to the key 'username' in secret 'primeiro-secret'>  Optional: false
#   PASSWORD:  <set to the key 'password' in secret 'primeiro-secret'>  Optional: false

# Acessar o pod e verificar as variáveis
k exec -it nginx -- bash
root@nginx:/# set | grep USERNAME
# USERNAME=YWxleGFuZHJl
root@nginx:/# set | grep PASSWORD
# PASSWORD=Z2lyb3BvcHM=

# Ou simplesmente
k exec -it nginx -- env
```

💡 **Dica:** Para criar o base64 de uma senha:
```bash
echo -n "minha-senha-secreta" | base64
```

---

## Tipos de Secrets

### Secret dockerconfigjson

Usado para armazenar **credenciais de acesso a registries privados** de imagens Docker.

#### Criar Secret para Docker Hub

```bash
# Verificar configuração do Docker com credenciais salvas
docker login
# Authenticating with existing credentials... [Username: alezemuner]
# Login Succeeded

# Ver arquivo de configuração
cd
ls .docker
cat .docker/config.json

# Codificar em base64 para usar no secret
base64 .docker/config.json
```

#### Criar e Aplicar o Secret

```bash
# Criar secret com credenciais do Docker Hub
k apply -f dockerhub-secret.yaml

# Verificar
k get secret
# NAME                  TYPE                             DATA   AGE
# dockerhub-secret      kubernetes.io/dockerconfigjson   1      45s
```

#### Testar Pull de Imagem Privada

```bash
# Primeiro teste: sem imagePullSecrets (deve falhar)
k apply -f pod-imagem-privada.yaml

# Ver pod
k get pods
# NAME          READY   STATUS             RESTARTS   AGE
# pod-privado   0/1     ImagePullBackOff   0          77s

# Ver eventos do erro
k describe pods pod-privado
# Events:
#   Type     Reason     Age                From               Message
#   ----     ------     ----               ----               -------
#   Normal   Scheduled  96s                default-scheduler  Successfully assigned default/pod-privado to worker02
#   Warning  Failed     94s                kubelet            Failed to pull image "alezemuner/ubuntu-curl:v1": failed to pull and unpack image "docker.io/alezemuner/ubuntu-curl:v1": failed to resolve reference "docker.io/alezemuner/ubuntu-curl:v1": failed to authorize: failed to fetch anonymous token: Get "https://auth.docker.io/token?scope=repository%3Aalezemuner%2Fubuntu-curl%3Apull&service=registry.docker.io": tls: failed to verify certificate: x509: certificate signed by unknown authority

# Deletar e aplicar com imagePullSecrets
k delete -f pod-imagem-privada.yaml
k apply -f pod-imagem-privada.yaml
```

#### Criar Imagem e Enviar para Docker Hub

```bash
# Criar Dockerfile simples
echo "FROM ubuntu" > Dockerfile

# Build da imagem
docker build -t alezemuner/ubuntu-curl:v1 .

# Enviar para Docker Hub
docker push alezemuner/ubuntu-curl:v1

# Remover imagem localmente
docker rmi alezemuner/ubuntu-curl:v1
```

#### Login via Token de Acesso (Recomendado para VMs)

1. Acesse **hub.docker.com** e faça login
2. Clique no seu perfil → **Account Settings**
3. Vá em **Security** → **New Access Token**
4. Dê um nome (ex: "OracleVM") e crie
5. Copie o token gerado

```bash
# Na VM, fazer login com token
docker login -u SEU_USUARIO_DOCKER
# Quando pedir o Password, cole o token (não aparece na tela)
```

---

### Secret TLS

Usado para armazenar **certificados TLS/SSL**.

```bash
# Gerar certificado autoassinado
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout chave-privada.key -out certificado.crt

# Criar secret TLS
kubectl create secret tls meu-servico-web-tls-secret \
  --cert=certificado.crt --key=chave-privada.key

# Ver secrets
k get secrets
# NAME                         TYPE                             DATA   AGE
# meu-servico-web-tls-secret   kubernetes.io/tls                2      8s

# Ver detalhes
k get secrets meu-servico-web-tls-secret -o yaml
```

---

## ConfigMaps

### O que é

**ConfigMaps** é um recurso do Kubernetes usado para armazenar **dados de configuração não sensíveis** em pares chave-valor.

| Característica | Descrição |
|----------------|-----------|
| **Tipo de dados** | Não sensíveis (configurações, variáveis de ambiente, arquivos) |
| **Armazenamento** | ETCD (sem criptografia) |
| **Atualização** | ⚠️ Mudanças não se aplicam automaticamente - requer reiniciar os pods |

---

### Criando ConfigMaps

```bash
# Criar ConfigMap a partir de arquivo
kubectl create configmap nginx-config --from-file=nginx.conf

# Listar ConfigMaps
k get configmaps
#  NAME               DATA   AGE
# kube-root-ca.crt   1      158d
# nginx-config       1      21s

# Descrever ConfigMap
k describe configmaps nginx-config

# Exportar para YAML
k get configmaps nginx-config -o yaml > configmaps.yaml
```

---

### Usando ConfigMaps em Pods

```bash
# Criar Pod com ConfigMap
k apply -f pod-configmap-secret.yaml

# Ver Pod
k get pods
# NAME    READY   STATUS    RESTARTS   AGE
# nginx   1/1     Running   0          4s

# Expor o Pod
k expose pod nginx

# Expor como LoadBalancer
k expose pod nginx --name nginx-loadbalancer --type LoadBalancer

# Ver serviços
k get svc
# NAME                 TYPE           CLUSTER-IP     EXTERNAL-IP     PORT(S)                      AGE
# kubernetes           ClusterIP      10.96.0.1      <none>          443/TCP                      253d
# nginx-loadbalancer   LoadBalancer   10.103.77.64   172.16.44.245   80:32195/TCP,443:30540/TCP   4s

# Port-forward para testar
k port-forward services/nginx 4443:443
```

⚠️ **Nota importante:** Mudanças em Secrets e ConfigMaps não se aplicam aos pods automaticamente. É necessário **reiniciar os pods** para que as mudanças sejam aplicadas.