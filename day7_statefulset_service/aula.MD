# 🏗️ Descomplicando Kubernetes - Day 7: StatefulSet e Service

## Índice
- [StatefulSet](#statefulset)
- [Stateless vs Stateful](#stateless-vs-stateful)
- [Headless Service](#headless-service)
- [Service](#service)
- [Tipos de Service](#tipos-de-service)

---

## StatefulSet

### O que é

O **StatefulSet** é um recurso do Kubernetes que gerencia o deployment e a escalabilidade de um conjunto de pods, garantindo a **ordem e a identidade** dos pods.

| Característica | Descrição |
|----------------|-----------|
| **Identidade estável** | Cada Pod tem nome único e persistente |
| **Ordem de criação** | Pods são criados em ordem sequencial |
| **Armazenamento persistente** | Cria um PV para cada Pod |
| **Caso de uso** | Bancos de dados, aplicações stateful |

⚠️ **Pré-requisito:** Antes de criar um StatefulSet, é preciso ter um StorageClass configurado no cluster para criação automática de PVs.

💡 **Exemplo (EKS):** É necessário instalar o addon **EBS CSI Driver** para criar volumes persistentes usando o Amazon EBS.

---

## Stateless vs Stateful

### Comparativo

| Característica | Stateless | Stateful |
|----------------|-----------|----------|
| **Estado** | Não mantém estado | Mantém estado entre requisições |
| **Escalabilidade** | Fácil - qualquer instância pode atender | Complexa - exige identidade estável |
| **Armazenamento** | Temporário ou nenhum | Persistente e associado ao Pod |
| **Exemplo** | Servidores web | Bancos de dados |
| **Controller** | Deployment | StatefulSet |

### Características do StatefulSet

- ✅ **Nome único e persistente:** O Pod mantém o mesmo nome mesmo após reinício ou migração
- ✅ **Ordem garantida:** Pods são criados em ordem (0, 1, 2, ...)
- ✅ **PV por Pod:** Cria um PersistentVolume para cada Pod
- ✅ **DNS estável:** Cada Pod acessível pelo nome DNS

```bash
k apply -f statefulset-nginx.yaml

k get pods
NAME      READY   STATUS    RESTARTS   AGE
nginx-0   1/1     Running   0          98s
nginx-1   1/1     Running   0          83s
nginx-2   1/1     Running   0          34s

k get statefulsets
NAME    READY   AGE
nginx   3/3     2m8s

k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                 STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-5c76ab6c-4156-4b91-851c-4ef6f97fa0e2   1Gi        RWO            Delete           Bound       default/www-nginx-0   local-path     <unset>                          4m16s
pvc-b3fe7fcb-760a-49ee-8252-c39fdfdb2af0   1Gi        RWO            Delete           Bound       default/www-nginx-1   local-path     <unset>                          2m29s
pvc-f395e3c7-6235-4e1b-aca0-cf5dabb4d513   1Gi        RWO            Delete           Bound       default/www-nginx-2   local-path     <unset>                          100s

k get pvc
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
www-nginx-0   Bound    pvc-5c76ab6c-4156-4b91-851c-4ef6f97fa0e2   1Gi        RWO            local-path     <unset>                 4m40s
www-nginx-1   Bound    pvc-b3fe7fcb-760a-49ee-8252-c39fdfdb2af0   1Gi        RWO            local-path     <unset>                 2m53s
www-nginx-2   Bound    pvc-f395e3c7-6235-4e1b-aca0-cf5dabb4d513   1Gi        RWO            local-path     <unset>                 2m4s

```

### Exemplo de StatefulSet

```bash
# Criar StatefulSet
k apply -f statefulset-nginx.yaml

# Ver pods criados em ordem
k get pods
# NAME      READY   STATUS    RESTARTS   AGE
# nginx-0   1/1     Running   0          98s
# nginx-1   1/1     Running   0          83s
# nginx-2   1/1     Running   0          34s

# Ver StatefulSets
k get statefulsets
# NAME    READY   AGE
# nginx   3/3     2m8s

# Ver PVs criados automaticamente
k get pv
# NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                 STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
# pvc-5c76ab6c-4156-4b91-851c-4ef6f97fa0e2   1Gi        RWO            Delete           Bound       default/www-nginx-0   local-path     <unset>                          4m16s
# pvc-b3fe7fcb-760a-49ee-8252-c39fdfdb2af0   1Gi        RWO            Delete           Bound       default/www-nginx-1   local-path     <unset>                          2m29s
# pvc-f395e3c7-6235-4e1b-aca0-cf5dabb4d513   1Gi        RWO            Delete           Bound       default/www-nginx-2   local-path     <unset>                          100s

# Ver PVCs associados
k get pvc
# NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
# www-nginx-0   Bound    pvc-5c76ab6c-4156-4b91-851c-4ef6f97fa0e2   1Gi        RWO            local-path     <unset>                 4m40s
# www-nginx-1   Bound    pvc-b3fe7fcb-760a-49ee-8252-c39fdfdb2af0   1Gi        RWO            local-path     <unset>                 2m53s
# www-nginx-2   Bound    pvc-f395e3c7-6235-4e1b-aca0-cf5dabb4d513   1Gi        RWO            local-path     <unset>                 2m4s
```

---

## Headless Service

### O que é

Uma **Headless Service** é um tipo especial de serviço que **não atribui um endereço IP** para os pods.

| Característica | Descrição |
|----------------|-----------|
| **ClusterIP** | `None` (não há IP atribuído) |
| **DNS** | Clientes se conectam diretamente aos pods pelo nome DNS |
| **Uso** | StatefulSets onde cada Pod precisa ser acessível individualmente |

### Exemplo de Uso

```bash
# Criar Headless Service
k apply -f headless-svc-nginx.yaml
# service/nginx-headless created

# Verificar - note que o CLUSTER-IP é None
k get svc
# NAME             TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
# nginx            ClusterIP   None         <none>        80/TCP    18s
```

### Acessando Pods por DNS

```bash
# Acessar nginx-0
k exec -it nginx-0 -- bash

# Dentro do pod, navegar até o diretório web
cd /usr/share/nginx/html/

# Testar localhost
curl localhost
# <html>
# <head><title>403 Forbidden</title></head>
# <body>
# <center><h1>403 Forbidden</h1></center>
# <hr><center>nginx/1.29.7</center>
# </body>
# </html>

# Criar arquivo customizado
echo "GIROPOPS-0" > index.html

# Verificar
curl localhost
# GIROPOPS-0
```

#### Comunicação entre Pods

```bash
# Logar no nginx-1 e acessar nginx-0 via DNS
k exec -it nginx-1 -- bash

# Acessar nginx-0 pelo nome DNS completo
curl nginx-0.nginx.default.svc.cluster.local
# GIROPOPS-0

# Criar conteúdo no nginx-1
echo GIROPOPS-1 > /usr/share/nginx/html/index.html
```

```bash
# Logar no nginx-2 e testar comunicação
k exec -it nginx-2 -- bash

# Acessar nginx-1
curl nginx-1.nginx.default.svc.cluster.local
# GIROPOPS-1

# Acessar nginx-0
curl nginx-0.nginx.default.svc.cluster.local
# GIROPOPS-0
```

💡 **Padrão DNS:** `{pod-name}.{service-name}.{namespace}.svc.cluster.local`

---

## Service

### O que é

**Service** é o processo pelo qual os serviços em um cluster Kubernetes encontram e se comunicam entre si.

| Função | Descrição |
|--------|-----------|
| **Exposição** | Expor pods internamente ou externamente |
| **Descoberta** | Permitir que pods se encontrem via DNS |
| **Balanceamento** | Distribuir tráfego entre pods |
| **Endpoint** | Criar IP e porta para acessar os pods |

---

## Tipos de Service

### Comparativo

| Tipo | Descrição | Acesso Externo | Caso de Uso |
|------|-----------|----------------|-------------|
| **ClusterIP** | IP interno do cluster | ❌ Não | Comunicação interna |
| **NodePort** | Porta específica em cada nó | ✅ Sim | Desenvolvimento, testes |
| **LoadBalancer** | Balanceador de carga externo | ✅ Sim | Produção em nuvem |
| **ExternalName** | Mapeia para nome DNS externo | ⏭️ Proxy | Acessar serviços externos |

---

### ClusterIP (Padrão)

O **ClusterIP** cria um endereço IP interno para o serviço.

```bash
# Criar deployment
k create deployment nginx --image nginx --port 80

# Ver deployment
k get deploy
# NAME    READY   UP-TO-DATE   AVAILABLE   AGE
# nginx   1/1     1            1           7s

# Expor como ClusterIP (padrão)
k expose deployment nginx

# Ver serviços
k get svc
# NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
# kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP   252d
# nginx        ClusterIP   10.109.128.200   <none>        80/TCP    4s
```

#### Testar comunicação interna

```bash
# Criar pod de debug
k run -ti --rm debug --image busybox --restart Never -- sh

# Acessar serviço nginx internamente
wget -O- 10.109.128.200
# <!DOCTYPE html>
# <html>
# <head>
# <title>Welcome to nginx!</title>
# <style>
```

```bash
# Remover serviço
k delete svc nginx
```

---

### NodePort

O **NodePort** expõe o serviço em uma porta específica em cada nó do cluster.

```bash
# Expor deployment como NodePort
kubectl expose deployment nginx --type=NodePort

# Ver serviços - note a porta externa (ex: 32167)
k get svc
# NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
# kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP        252d
# nginx        NodePort    10.103.180.129   <none>        80:32167/TCP   5s
```

#### Ver EndpointSlice

```bash
# Ver endpoints do serviço
k get EndpointSlice
# NAME          ADDRESSTYPE   PORTS   ENDPOINTS       AGE
# kubernetes    IPv4          6443    172.16.44.202   252d
# nginx-2tlqs   IPv4          80      10.244.30.88    2m49s
```

#### Escalar e verificar

```bash
# Escalar deployment
k scale deployment nginx --replicas 3

# Ver pods
k get pods
# NAME                     READY   STATUS    RESTARTS   AGE
# nginx-86c57bc6b8-s5h2q   1/1     Running   0          2s
# nginx-86c57bc6b8-vfx5v   1/1     Running   0          14s
# nginx-86c57bc6b8-zmww6   1/1     Running   0          2s

# Ver endpoints atualizados
k get EndpointSlice
# NAME          ADDRESSTYPE   PORTS   ENDPOINTS                               AGE
# kubernetes    IPv4          6443    172.16.44.202                           252d
# nginx-2tlqs   IPv4          80      10.244.30.84,10.244.5.62,10.244.30.85   6m8s
```

⚠️ **Portas NodePort:** 30000-32767

---

### LoadBalancer

O **LoadBalancer** cria um balanceador de carga externo.

💡 **Pré-requisito:** Em cluster local (minikube/kind), é necessário ter o **MetalLB** instalado.

```bash
# Expor como LoadBalancer
k expose deployment nginx --type LoadBalancer

# Ver serviços - note o EXTERNAL-IP
k get svc
# NAME         TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)        AGE
# kubernetes   ClusterIP      10.96.0.1     <none>          443/TCP        252d
# nginx        LoadBalancer   10.105.8.79   172.16.44.245   80:32550/TCP   19s
```

#### Testar o LoadBalancer

```bash
# Ver pods
k get pods
# NAME                     READY   STATUS    RESTARTS   AGE
# nginx-86c57bc6b8-qltd8   1/1     Running   0          2m54s

# Acessar e modificar conteúdo
k exec -ti nginx-86c57bc6b8-qltd8 -- bash
echo GIROPOPS > /usr/share/nginx/html/index.html

# Ver serviços
k get svc
# NAME         TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)        AGE
# kubernetes   ClusterIP      10.96.0.1     <none>          443/TCP        252d
# nginx        LoadBalancer   10.105.8.79   172.16.44.245   80:32550/TCP   19s
```

🌐 **Acessar:** `http://172.16.44.245:32550`

---

### ExternalName

O **ExternalName** mapeia o serviço para um nome DNS externo.

```bash
# Criar serviço ExternalName
k create service externalname nginx --external-name nome.definido.external.com.br

# Ver serviços
k get svc
# NAME         TYPE           CLUSTER-IP   EXTERNAL-IP                     PORT(S)   AGE
# kubernetes   ClusterIP      10.96.0.1    <none>                          443/TCP   252d
# nginx        ExternalName   <none>       nome.definido.external.com.br   <none>    4s
```

💡 **Uso:** Acessar serviços externos usando um nome DNS interno.

---

## Criando Services via YAML

### Exemplo Completo

```bash
# Criar deployment
k apply -f deployment-nginx.yaml

# Ver pods
k get pods
# NAME                    READY   STATUS    RESTARTS   AGE
# nginx-f7b799bb8-6p578   1/1     Running   0          50s
# nginx-f7b799bb8-96gcj   1/1     Running   0          50s
# nginx-f7b799bb8-pz89k   1/1     Running   0          50s
```

#### ClusterIP

```bash
# Criar serviço ClusterIP
k apply -f clusterip-nginx.yaml

# Ver serviços
k get svc
# NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
# kubernetes      ClusterIP   10.96.0.1        <none>        443/TCP   252d
# svc-clusterip   ClusterIP   10.108.232.175   <none>        80/TCP    4s
```

#### NodePort

```bash
# Criar serviço NodePort
k apply -f nodeport-nginx.yaml

# Ver serviços
k get svc
# NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
# kubernetes      ClusterIP   10.96.0.1        <none>        443/TCP        252d
# svc-clusterip   ClusterIP   10.108.232.175   <none>        80/TCP         2m7s
# svc-nodeport    NodePort    10.108.83.42     <none>        80:32000/TCP   14s
```

#### LoadBalancer

```bash
# Criar serviço LoadBalancer
k apply -f loadbalancer-nginx.yaml

# Ver todos os serviços
k get svc
# NAME               TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)        AGE
# kubernetes         ClusterIP      10.96.0.1        <none>          443/TCP        252d
# svc-clusterip      ClusterIP      10.108.232.175   <none>          80/TCP         4m15s
# svc-loadbalancer   LoadBalancer   10.98.7.137      172.16.44.245   80:32525/TCP   11s
# svc-nodeport       NodePort       10.108.83.42     <none>          80:32000/TCP   2m22s
```

---

## Expondo um Service existente

```bash
# Criar serviço inicial
kubectl expose deployment nginx

# Ver serviços
k get svc
# NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
# kubernetes   ClusterIP   10.96.0.1     <none>        443/TCP   252d
# nginx        ClusterIP   10.107.1.51   <none>        80/TCP    3s

# Expor o serviço como NodePort (para troubleshooting)
kubectl expose service nginx --name expondo-nginx --type NodePort --port 80

# Ver resultado
k get svc
# NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
# expondo-nginx   NodePort    10.96.101.56   <none>        80:30752/TCP   6s
# kubernetes      ClusterIP   10.96.0.1      <none>        443/TCP        252d
# nginx           ClusterIP   10.107.1.51    <none>        80/TCP         4m12s
```

💡 **Dica:** Útil para troubleshooting quando você precisa acessar um serviço internamente de fora do cluster.