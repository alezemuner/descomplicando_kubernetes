# 📋 Descomplicando Kubernetes - Day 4: ReplicaSets, DaemonSets e Probes

## Índice
- [ReplicaSet](#replicaset)
- [DaemonSet](#daemonset)
- [Probes (Health Checks)](#probes-health-checks)

---

## ReplicaSet

### O que é ReplicaSet

**Garante que um número específico de réplicas de um pod esteja rodando a qualquer momento.**

| Responsabilidade | Descrição |
|-----------------|-----------|
| **Monitorar Pods** | Constantemente verifica quantos Pods estão rodando |
| **Substituir falhos** | Se um Pod falhar, cria um novo para substituí-lo |
| **Manter réplicas** | Mantém sempre o número desejado de réplicas |
| **Histórico** | Preserva histórico quando há mudanças no Deployment |

### ReplicaSet vs Deployment

⚠️ **Diferença importante:** 
- **ReplicaSet** não atualiza automaticamente os Pods quando há mudanças
- **Deployment** gerencia ReplicaSets e atualiza Pods automaticamente

### Criando e Gerenciando ReplicaSets

```bash
# Aplicar manifesto de deployment
kubectl apply -f nginx-deployment.yaml

# Ver ReplicaSets
kubectl get replicasets
# NAME                          DESIRED   CURRENT   READY   AGE
# nginx-deployment-59c554d965   1         1         0       67s

# Ver Pods gerenciados
kubectl get pods
# NAME                                READY   STATUS    RESTARTS   AGE
# nginx-deployment-59c554d965-rfwmh   1/1     Running   0          2m25s
```

### Mudanças no Deployment

Quando há uma mudança no Deployment:

1. 🆕 Um novo ReplicaSet é criado
2. 🔄 O antigo ReplicaSet deixa de ser utilizado
3. 📦 Mantém a versão antiga para fins de histórico

```bash
# Após mudança no Deployment
kubectl get replicasets
# NAME                          DESIRED   CURRENT   READY   AGE
# nginx-deployment-59c554d965   0         0         0       5m36s    ❌ Antigo (0 réplicas)
# nginx-deployment-6cc66967f    1         1         1       2m27s    ✅ Novo (1 réplica)

# Ver histórico de revisões
kubectl rollout history deployment nginx-deployment
# deployment.apps/nginx-deployment
# REVISION  CHANGE-CAUSE
# 1         <none>
# 2         <none>

# Fazer rollback
kubectl rollout undo deployment nginx-deployment
# deployment.apps/nginx-deployment rolled back

# Após rollback, o ReplicaSet antigo volta a ser usado
kubectl get replicasets
# NAME                          DESIRED   CURRENT   READY   AGE
# nginx-deployment-59c554d965   1         1         1       11m     ✅ Ativo novamente
# nginx-deployment-6cc66967f    0         0         0       8m39s   ❌ Inativo
```

### Scaling Manual

```bash
# Aumentar número de réplicas para 3
kubectl scale deployment nginx-deployment --replicas=3
```

### Exemplo: Criando ReplicaSet Diretamente

```bash
# Aplicar ReplicaSet
kubectl apply -f nginx-replicaset.yaml

# Ver ReplicaSets criados
kubectl get rs
# NAME               DESIRED   CURRENT   READY   AGE
# nginx-replicaset   3         3         3       2m4s

# Ver Pods
kubectl get pods
# NAME                     READY   STATUS    RESTARTS   AGE
# nginx-replicaset-qxlx2   1/1     Running   0          21s
# nginx-replicaset-wf8md   1/1     Running   0          21s
# nginx-replicaset-zxc9h   1/1     Running   0          21s

# Verificar versão da imagem
kubectl describe pods nginx-replicaset-qxlx2 | grep Image:
# Image: nginx:1.19.1
```

### ⚠️ Importante: ReplicaSet Não Atualiza Automaticamente

Diferente do Deployment, o ReplicaSet **não atualiza automaticamente** os Pods existentes:

```bash
# Se você atualizar a imagem de nginx:1.19.1 para nginx:1.19.2
kubectl apply -f nginx-replicaset.yaml

# Os Pods existentes AINDA terão a versão anterior
kubectl describe pods nginx-replicaset-qxlx2 | grep Image:
# Image: nginx:1.19.1  ❌ Ainda com versão antiga

# Os Pods novos apenas terão a nova versão após serem deletados
kubectl delete pod nginx-replicaset-qxlx2

# Novo Pod é criado com a versão atualizada
kubectl describe pods nginx-replicaset-n79xt | grep Image:
# Image: nginx:1.19.2  ✅ Versão atualizada
```

💡 **Solução:** Use **Deployment** para atualizações automáticas, não ReplicaSet diretamente.

---

## DaemonSet

### O que é DaemonSet

**Garante que uma cópia de um pod esteja rodando em cada nó do cluster.**

✨ **Automaticamente executado em todos os nós** (ou nós selecionados)

| Caso de Uso | Descrição |
|-----------|-----------|
| **Coleta de Logs** | Agente de logs em cada nó |
| **Monitoramento** | Coletor de métricas em cada nó |
| **Rede** | CNI (Container Network Interface) em cada nó |
| **Segurança** | Agente de segurança em cada nó |

🎯 **Exemplo:** Um DaemonSet com 5 nós cria automaticamente 5 Pods (um em cada nó).

---

## Probes (Health Checks)

### O que são Probes

**Permitem verificar a saúde dos Pods** através de health checks.

Existem **3 tipos** de Probes:

---

### Liveness Probe

**Verifica se o Pod está vivo.**

| Característica | Descrição |
|----------------|-----------|
| **Função** | Verificar se a aplicação ainda está respondendo |
| **Falha** | Pod será **reiniciado** |
| **Caso de uso** | Detectar travamentos ou deadlocks |

🔄 **Se a verificação falhar, o kubelet reinicia o container.**

#### Exemplo de Falha

```bash
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  43s                default-scheduler  Successfully assigned default/nginx-deployment-7dcb4bcd7f-x5w68 to worker02
  Normal   Pulled     13s (x2 over 43s)  kubelet            Container image "nginx:1.19.1" already present on machine
  Normal   Created    13s (x2 over 43s)  kubelet            Created container: nginx
  Normal   Started    13s (x2 over 43s)  kubelet            Started container nginx
  Normal   Killing    13s                kubelet            Container nginx failed liveness probe, will be restarted
  Warning  Unhealthy  3s (x4 over 33s)   kubelet            Liveness probe failed: HTTP probe failed with statuscode: 404
```

❌ **Status Code 404:** A aplicação não está respondendo corretamente, então o Pod é reiniciado.

---

### Readiness Probe

**Verifica se o Pod está pronto para receber tráfego.**

| Característica | Descrição |
|----------------|-----------|
| **Função** | Verificar se a aplicação está pronta para receber requisições |
| **Falha** | Pod é **removido do balanceador de carga** |
| **Caso de uso** | Evitar enviar requisições para Pods que ainda estão inicializando |

⚠️ **Se a verificação falhar, o Pod fica offline, mas não é reiniciado.**

#### Exemplo de Falha

```bash
k describe pod nginx-deployment-b45bf6bf-t9cxb

Events:
  Type     Reason     Age                 From               Message
  ----     ------     ----                ----               -------
  Normal   Scheduled  2m3s                default-scheduler  Successfully assigned default/nginx-deployment-b45bf6bf-t9cxb to worker02
  Normal   Pulled     2m2s                kubelet            Container image "nginx:1.19.1" already present on machine
  Normal   Created    2m2s                kubelet            Created container: nginx
  Normal   Started    2m2s                kubelet            Started container nginx
  Warning  Unhealthy  3s (x12 over 111s)  kubelet            Readiness probe failed: HTTP probe failed with statuscode: 7
```

❌ **Connection refused:** Tentando conectar na porta errada, Pod removido do Load Balancer.

---

### Startup Probe

**Verifica se o Pod iniciou corretamente.**

| Característica | Descrição |
|----------------|-----------|
| **Função** | Dar tempo para aplicações lentas inicializarem |
| **Falha** | Pod será **reiniciado** |
| **Caso de uso** | Aplicações que demoram tempo para iniciar |

⏱️ **Pausa outras probes até que a startup probe tenha sucesso.**

#### Exemplo de Falha

```bash
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  50s                default-scheduler  Successfully assigned default/nginx-deployment-7fd4b86478-rr45d to worker02
  Normal   Pulled     10s (x4 over 50s)  kubelet            Container image "nginx:1.19.1" already present on machine
  Normal   Created    10s (x4 over 50s)  kubelet            Created container: nginx
  Normal   Started    10s (x4 over 50s)  kubelet            Started container: nginx
  Warning  Unhealthy  0s (x4 over 40s)   kubelet            Startup probe failed: dial tcp 10.244.30.116:81: connect: connection refused
  Normal   Killing    0s (x4 over 40s)   kubelet            Container nginx failed startup probe, will be restarted
  Warning  BackOff    0s                 kubelet            Back-off restarting failed container nginx in pod
```

❌ **Connection refused:** Porta 81 não está respondendo, Pod reiniciado.

---

### Resumo Comparativo

| Probe | Verificação | Falha | Caso de Uso |
|-------|-----------|-------|-----------|
| **Liveness** | Pod está vivo? | Reinicia | Detectar travamentos |
| **Readiness** | Pronto para tráfego? | Remove do LB | Não enviar requisições |
| **Startup** | Iniciou corretamente? | Reinicia | Apps lentas |

---

### Expondo Pods com NodePort

```bash
# Expor um Pod específico como NodePort
kubectl expose pods nginx-deployment-568764f849-sbv5q --type NodePort
```

💡 **Isso permite acessar o Pod de fora do cluster na porta do Node.**