# Replica Set
Garantir que um número específico de réplicas de um pod esteja rodando a qualquer momento. Se um pod falhar, o ReplicaSet irá criar um novo para substituí-lo.
Caso ocorra um mudança no deployment, o ReplicaSet antigo deixara de ser utilizado e um novo ReplicaSet será criado para gerenciar as novas réplicas. O antigo ReplicaSet pode ser mantido para fins de histórico ou removido, dependendo da estratégia de implantação escolhida.

```bash
kubectl apply -f nginx-deployment.yaml

kubectl get replicasets
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-59c554d965   1         1         0       67s

kubectl get pods
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-59c554d965-rfwmh   1/1     Running   0          2m25s

# Apos uma mudança no deployment, um novo ReplicaSet é criado e o antigo ReplicaSet deixa de ser utilizado, mas ainda existe no cluster.
kubectl get replicasets
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-59c554d965   0         0         0       5m36s
nginx-deployment-6cc66967f    1         1         1       2m27s

kubectl rollout history deployment nginx-deployment
deployment.apps/nginx-deployment 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

kubectl rollout undo deployment nginx-deployment
deployment.apps/nginx-deployment rolled back

kubectl get replicasets
NAME                          DESIRED   CURRENT   READY   AGE
nginx-deployment-59c554d965   1         1         1       11m
nginx-deployment-6cc66967f    0         0         0       8m39s

#escalar o número de réplicas manualmente
kubectl scale deployment nginx-deployment --replicas=3
```

```bash
kubectl apply -f nginx-replicaset.yaml
kubectl get rs
NAME               DESIRED   CURRENT   READY   AGE
nginx-replicaset   3         3         3       2m4s
kubectl get pods
NAME                                READY   STATUS              RESTARTS   AGE
nginx-replicaset-qxlx2              0/1     ContainerCreating   0          21s
nginx-replicaset-wf8md              0/1     ContainerCreating   0          21s
nginx-replicaset-zxc9h              0/1     ContainerCreating   0          21s

kubectl describe pods nginx-replicaset-qxlx2| grep Image:
    Image:          nginx:1.19.1

#apos fazer uma mudança no replicaset, para a imagem do nginx:1.19.2 os pods aindam ficam com a versão anterior, pois o ReplicaSet não é atualizado automaticamente como o Deployment.
kubectl apply -f nginx-replicaset.yaml
kubectl get rs
NAME               DESIRED   CURRENT   READY   AGE
nginx-replicaset   3         3         3       3m6s
kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-replicaset-qxlx2   1/1     Running   0          3m31s
nginx-replicaset-wf8md   1/1     Running   0          3m31s
nginx-replicaset-zxc9h   1/1     Running   0          3m31s

kubectl describe pods nginx-replicaset-qxlx2| grep Image:
    Image:          nginx:1.19.1

# Caso delete o pod ai sim a criação do novo pod já será com a nova imagem, pois o ReplicaSet irá criar um novo pod para substituir o que foi deletado, e nesse processo ele irá usar a nova configuração do ReplicaSet.
kubectl delete pod nginx-replicaset-qxlx2

kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-replicaset-n79xt   1/1     Running   0          13m
nginx-replicaset-wf8md   1/1     Running   0          23m
nginx-replicaset-zxc9h   1/1     Running   0          23m

kubectl describe pods nginx-replicaset-n79xt| grep Image:
    Image:          nginx:1.19.2

```


# Daemon Set
Garantir que uma cópia de um pod esteja rodando em cada nó do cluster. Útil para tarefas como coleta de logs ou monitoramento.

# Probes
Permite verificar a saúde dos pods (health checks). Existem três tipos de probes:

- Liveness Probe: Verifica se o pod está vivo. Se falhar, o pod será reiniciado.
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

- Readiness Probe: Verifica se o pod está pronto para receber tráfego. Se falhar, o pod será removido do balanceamento de carga até que esteja pronto novamente.
```bash
k describe pod nginx-deployment-b45bf6bf-t9cxb

Events:
  Type     Reason     Age                 From               Message
  ----     ------     ----                ----               -------
  Normal   Scheduled  2m3s                default-scheduler  Successfully assigned default/nginx-deployment-b45bf6bf-t9cxb to worker02
  Normal   Pulled     2m2s                kubelet            Container image "nginx:1.19.1" already present on machine
  Normal   Created    2m2s                kubelet            Created container: nginx
  Normal   Started    2m2s                kubelet            Started container nginx
  Warning  Unhealthy  3s (x12 over 111s)  kubelet            Readiness probe failed:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
\r  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0curl: (7) Failed to connect to localhost port 81: Connection refused
```

- Startup Probe: Verifica se o pod iniciou corretamente. Se falhar, o pod será reiniciado. Útil para aplicações que demoram a iniciar.
```bash
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  50s                default-scheduler  Successfully assigned default/nginx-deployment-7fd4b86478-rr45d to worker02
  Normal   Pulled     10s (x4 over 50s)  kubelet            Container image "nginx:1.19.1" already present on machine
  Normal   Created    10s (x4 over 50s)  kubelet            Created container: nginx
  Normal   Started    10s (x4 over 50s)  kubelet            Started container nginx
  Warning  Unhealthy  0s (x4 over 40s)   kubelet            Startup probe failed: dial tcp 10.244.30.116:81: connect: connection refused
  Normal   Killing    0s (x4 over 40s)   kubelet            Container nginx failed startup probe, will be restarted
  Warning  BackOff    0s                 kubelet            Back-off restarting failed container nginx in pod nginx-deployment-7fd4b86478-rr45d_default(14a3515f-d3f9-4283-a7dc-5277348e1ba0)
```
k expose pods nginx-deployment-568764f849-sbv5q --type NodePort