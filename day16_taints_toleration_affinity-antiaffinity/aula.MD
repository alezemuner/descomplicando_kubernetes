# 🧲 Descomplicando Kubernetes - Day 16: Taints, Tolerations, Affinity e Anti-Affinity

## Índice
- [Taints](#taints)
- [Tipos de taints](#tipos-de-taints)
- [Exemplos de taints](#exemplos-de-taints)
- [Tolerations](#tolerations)
- [Affinity](#affinity)
- [Anti-Affinity](#anti-affinity)
- [Comportamento de Scheduling](#comportamento-de-scheduling)

---

## Taints

Uma **taint** é uma marcação aplicada a um nó que indica que ele não deve aceitar pods, a menos que os pods tenham uma toleration correspondente.

As taints são usadas para:
- Evitar que certos nós sejam usados por pods comuns
- Reservar nós para cargas específicas
- Isolar nós em manutenção ou com função especial

### Tipos de taints

| Tipo | Comportamento | Uso comum |
|------|--------------|-----------|
| `NoSchedule` | Evita agendamento de novos pods | Nó em manutenção ou dedicado |
| `NoExecute` | Remove pods existentes e impede novos agendamentos | Nó em manutenção ou com problema |
| `PreferNoSchedule` | Tenta evitar o nó, mas não obriga | Preferência de alocação |

### `NoSchedule`

No control-plane já existe uma taint padrão: `node.kubernetes.io/noSchedule`.
Ela impede que o nó de controle aceite pods comuns, mantendo-o reservado para funções do cluster.

### `NoExecute`

- Bloqueia o agendamento de novos pods no nó.
- Remove pods existentes e força a realocação.
- Útil para nós em manutenção.

### `PreferNoSchedule`

- Tenta evitar o nó, mas não é rígido.
- Se não houver outras opções, o pod pode ser agendado nele.

---

## Exemplos de taints

### Ver taints aplicadas no nó

```bash
k describe node master-node 
Taints:             node-role.kubernetes.io/control-plane:NoSchedule
```

### Criar deployment nginx e verificar pods

```bash
k apply -f deploy-nginx.yaml
k get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
nginx-86c57bc6b8-lxp94   1/1     Running   0          57s   10.244.30.65   worker02   <none>           <none>
nginx-86c57bc6b8-t5p4g   1/1     Running   0          57s   10.244.5.32    worker01   <none>           <none>
```

### Escalar deployment

```bash
k scale deployment nginx --replicas 4 
k get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE     IP             NODE       NOMINATED NODE   READINESS GATES
nginx-86c57bc6b8-8699j   1/1     Running   0          67s     10.244.30.84   worker02   <none>           <none>
nginx-86c57bc6b8-ksmjb   1/1     Running   0          67s     10.244.5.46    worker01   <none>           <none>
nginx-86c57bc6b8-lxp94   1/1     Running   0          3m47s   10.244.30.65   worker02   <none>           <none>
nginx-86c57bc6b8-t5p4g   1/1     Running   0          3m47s   10.244.5.32    worker01   <none>           <none>
```

### Exemplo `NoExecute`

```bash
# Adiciona uma taint ao nó worker01, indicando que ele está em manutenção e não deve aceitar pods. Os pods vão para outro workers
k taint node worker01 manutencao=true:NoExecute 
k get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE     IP             NODE       NOMINATED NODE   READINESS GATES
nginx-86c57bc6b8-4gzr2   1/1     Running   0          34s     10.244.30.87   worker02   <none>           <none>
nginx-86c57bc6b8-8699j   1/1     Running   0          3m5s    10.244.30.84   worker02   <none>           <none>
nginx-86c57bc6b8-d4j48   1/1     Running   0          33s     10.244.30.93   worker02   <none>           <none>
nginx-86c57bc6b8-lxp94   1/1     Running   0          5m45s   10.244.30.65   worker02   <none>           <none>
```

### Remover uma taint e reprogramar pods

```bash
# Remove a taint do nó worker01, permitindo que ele aceite pods novamente.
k taint node worker01 manutencao=true:NoExecute-
```

> Obs: após remover a taint o Kubernetes não redistribui os pods automaticamente.
> Para reprogramar os pods, reinicie o deployment.

```bash
k rollout restart deployment nginx 
k get pods -o wide
NAME                   READY   STATUS    RESTARTS   AGE   IP              NODE       NOMINATED NODE   READINESS GATES
nginx-6cff9556-2g7kb   1/1     Running   0          9s    10.244.30.112   worker02   <none>           <none>
nginx-6cff9556-bz475   1/1     Running   0          19s   10.244.30.109   worker02   <none>           <none>
nginx-6cff9556-jnkc4   1/1     Running   0          14s   10.244.5.6      worker01   <none>           <none>
nginx-6cff9556-xkn5f   1/1     Running   0          19s   10.244.5.27     worker01   <none>           <none>
```

### Exemplo `NoSchedule`

```bash
# Adiciona uma taint ao nó worker01, indicando que ele não deve aceitar pods, mas permite que eles sejam agendados.
k taint node worker01 manutencao=true:NoSchedule
k scale deployment nginx --replicas 6
k get pods -o wide
NAME                   READY   STATUS    RESTARTS   AGE    IP              NODE       NOMINATED NODE   READINESS GATES
nginx-6cff9556-2g7kb   1/1     Running   0          117s   10.244.30.112   worker02   <none>           <none>
nginx-6cff9556-bz475   1/1     Running   0          2m7s   10.244.30.109   worker02   <none>           <none>
nginx-6cff9556-d4rk6   1/1     Running   0          7s     10.244.30.117   worker02   <none>           <none>
nginx-6cff9556-jnkc4   1/1     Running   0          2m2s   10.244.5.6      worker01   <none>           <none>
nginx-6cff9556-xkn5f   1/1     Running   0          2m7s   10.244.5.27     worker01   <none>           <none>
nginx-6cff9556-zwg5r   1/1     Running   0          7s     10.244.30.115   worker02   <none>           <none>
```

```bash
# verificar a taint aplicada ao node
k describe node worker01
Taints:             manutencao=true:NoSchedule

# Exibe os nós do cluster e suas taints
kubectl describe nodes | grep -E "Name:|Taints:"
```

```bash
# Remove a taint do nó worker01, permitindo que ele aceite pods novamente.
k taint node worker01 manutencao=true:NoSchedule- 
```

---

## Tolerations

As **tolerations** permitem que pods sejam agendados em nós que possuem taints específicas.

- Definidas no manifesto do pod.
- Permitem que o pod seja considerado para agendamento.
- O pod precisa tolerar todas as taints do nó para ser agendado.

> Exemplo: se o nó tiver `manutencao=true:NoSchedule` e `gpu=true:NoSchedule`, o pod precisa tolerar ambas.

```bash
# Adiciona uma taint ao nó worker01 para GPU
k taint node worker01 gpu=true:NoSchedule
# Obs: a toleration gpu=true:NoSchedule tem que estar definida no YAML.
# Se o node também tiver manutencao=true:NoSchedule, o YAML precisa dessa toleration também.

k apply -f deploy-nginx-gpu.yaml 
k get pods -o wide
NAME                         READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
nginx-86c57bc6b8-glp9v       1/1     Running   0          33m   10.244.30.74   worker02   <none>           <none>
nginx-86c57bc6b8-tptwk       1/1     Running   0          33m   10.244.30.75   worker02   <none>           <none>
nginx-gpu-67d7748757-c2452   1/1     Running   0          36s   10.244.5.54    worker01   <none>           <none>
nginx-gpu-67d7748757-glrxk   1/1     Running   0          36s   10.244.30.88   worker02   <none>           <none>
nginx-gpu-67d7748757-hn48x   1/1     Running   0          36s   10.244.5.18    worker01   <none>           <none>
nginx-gpu-67d7748757-ql4v8   1/1     Running   0          36s   10.244.30.85   worker02   <none>           <none>
```

---

## Affinity

A **affinity** controla onde os pods são agendados com base em labels dos nós.

- `nodeAffinity` trabalha com labels do nó.
- Pode ser `required` (obrigatório) ou `preferred` (preferido).

### Exemplo de labels de nó

```bash
k label nodes worker01 region=sa-east-1
k label nodes worker01 az=sa-east-1a
k label nodes worker02 region=us-east-1
k label nodes worker02 az=us-east-1a 
```

### Ver labels dos nós

```bash
k get nodes worker01 --show-labels 
# Verifica labels no worker01
k get nodes worker02 --show-labels 
# Verifica labels no worker02

k get nodes -L region 
NAME          STATUS   ROLES           AGE    VERSION   REGION
master-node   Ready    control-plane   218d   v1.33.3   
worker01      Ready    <none>          218d   v1.33.3   sa-east-1
worker02      Ready    <none>          4h7m   v1.33.3   us-east-1
```

### Aplicar deployment com affinity

```bash
# aplicar um deploy com affinity region=sa-east-1
k apply -f deploy-nginx-affinity.yaml
k get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
nginx-85bffb769c-2rfhs   1/1     Running   0          11s   10.244.1.22   worker01   <none>           <none>
nginx-85bffb769c-fz4nx   1/1     Running   0          11s   10.244.1.25   worker01   <none>           <none>
nginx-85bffb769c-wbhs7   1/1     Running   0          11s   10.244.1.23   worker01   <none>           <none>
nginx-85bffb769c-wz7hp   1/1     Running   0          11s   10.244.1.24   worker01   <none>           <none>
```

---

## Anti-Affinity

A **anti-affinity** impede que pods sejam agendados em nós que atendem a determinados critérios.

- Evita que pods semelhantes fiquem no mesmo nó ou rack.
- Ajuda a distribuir a carga e aumentar disponibilidade.
- Pode ser `required` ou `preferred`.

### Exemplo de anti-affinity

```bash
k get nodes -L region
NAME          STATUS   ROLES           AGE    VERSION   REGION
master-node   Ready    control-plane   273d   v1.33.3   
worker01      Ready    <none>          273d   v1.33.3   sa-east-1
worker02      Ready    <none>          55d    v1.33.3   us-east-1

# deploy onde todos os pods com a labels app: nginx so pode ter um pod em cada region
k apply -f deploy-nginx-antiaffinity.yaml
k get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP             NODE       NOMINATED NODE   READINESS GATES
nginx-84dfc78466-66dtr   0/1     Pending   0          60s   <none>         <none>     <none>           <none>
nginx-84dfc78466-77td6   1/1     Running   0          60s   10.244.5.39    worker01   <none>           <none>
nginx-84dfc78466-wvrr7   1/1     Running   0          60s   10.244.30.83   worker02   <none>           <none>
nginx-84dfc78466-zsv6t   0/1     Pending   0          60s   <none>         <none>     <none>           <none>
```

```bash
k describe pods nginx-84dfc78466-66dtr
Events:
  Type     Reason            Age    From               Message
  ----     ------            ----   ----               -------
  Warning  FailedScheduling  3m59s  default-scheduler  0/3 nodes are available: 1 node(s) had untolerated taint {node-role.kubernetes.io/control-plane: }, 2 node(s) didn't match pod anti-affinity rules. preemption: 0/3 nodes are available: 1 Preemption is not helpful for scheduling, 2 No preemption victims found for incoming pod.
```

---

## Comportamento de Scheduling

- `requiredDuringSchedulingIgnoredDuringExecution` faz a regra valer como obrigatória no agendamento.
- `preferredDuringSchedulingIgnoredDuringExecution` tenta atender à regra, mas permite exceções quando não há recursos.

> Se você subir um deployment com 6 réplicas e a regra disser que deve haver um por nó, os pods extras podem ficar em `Pending` se só houver 3 nós.
