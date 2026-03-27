# Deployment
Quando um Deployment é criado, um ReplicaSet também é criado.
O ReplicaSet é responsável por criar os Pods. O Deployment é responsável por gerenciar o ReplicaSet.
O Deployment é responsável por garantir que o número desejado de réplicas esteja sempre disponível.
O Deployment é responsável por atualizar os Pods quando uma nova versão da aplicação é lançada.
O Deployment é responsável por garantir que a aplicação esteja sempre disponível, mesmo durante as atualizações.

```bash
kubectl get pods -l app=nginx-deployment # lista os Pods que estão sendo gerenciados pelo Deployment, usando o label app=nginx-deployment
kubectl get replicaset # lista os ReplicaSets que estão sendo gerenciados pelo Deployment
kubectl describe deploy nginx-deployment # mostra informações detalhadas sobre o Deployment, incluindo o número de réplicas, a estratégia de rollout, as condições do Deployment e os eventos relacionados ao Deployment.
kubectl get deploy nginx-deployment -o yaml > temp.yaml
kubectl create deployment --image nginx --replicas 3 nginx-deployment --dry-run=client -o yaml > novo-deployment.yaml
```

## Atualização de um Deployment
Para atualizar um Deployment, basta editar o arquivo de configuração do Deployment e aplicar as mudanças usando o comando `kubectl apply -f <arquivo-deployment.yaml>`. O Kubernetes irá comparar o estado atual do Deployment com o estado desejado definido no arquivo de configuração e irá realizar as mudanças necessárias para atingir o estado desejado. O Kubernetes irá criar novos Pods com a nova configuração e irá remover os Pods antigos gradualmente, garantindo que a aplicação esteja sempre disponível durante a atualização.

```bash
k get namespace
k create namespace giropops
k create namespace giropops --dry-run=client -o yaml > namespace.yaml
k get deployments.apps -n giropops
k get pods -n giropops
```

Foi mudado no arquivo deployment.yml a imagem do container de nginx para nginx:1.15.0, e as mudanças foram aplicadas usando o comando `kubectl apply -f deployment.yml`. O Kubernetes criou novos Pods com a nova imagem e removeu os Pods antigos gradualmente, garantindo que a aplicação estivesse sempre disponível durante a atualização.

Mudado novamente para a imagem nginx:1.16.0, e as mudanças foram aplicadas usando o comando `kubectl apply -f deployment.yml`. O Kubernetes criou novos Pods com a nova imagem e removeu os Pods antigos gradualmente, garantindo que a aplicação estivesse sempre disponível durante a atualização. 

```bash
k exec -it -n giropops nginx-deployment-57d7979b99-86n4h -- nginx -v
```

# Estratégias de Rollout
Existem duas estratégias de rollout: Rolling Update e Recreate.
## Rolling Update (está estratégia é a padrão)
A estratégia de Rolling Update é a estratégia padrão. Ela atualiza os Pods gradualmente, garantindo que a aplicação esteja sempre disponível durante a atualização. O Rolling Update é recomendado para a maioria dos casos, pois minimiza o tempo de inatividade da aplicação.

## Recreate
A estratégia de Recreate é uma estratégia mais agressiva. Ela recria todos os Pods de uma vez, o que pode causar um tempo de inatividade da aplicação. O Recreate é recomendado para casos em que a aplicação não pode ser atualizada gradualmente, como quando há mudanças significativas na aplicação ou quando a aplicação não pode ser atualizada sem reiniciar os Pods.

```bash
k rollout status deployment -n giropops nginx-deployment # mostra o status do rollout do Deployment, incluindo o número de réplicas atualizadas, o número de réplicas disponíveis e o número de réplicas não disponíveis.
```

# Rollback
O rollback é o processo de reverter um Deployment para uma versão anterior. O Kubernetes mantém um histórico de versões do Deployment, permitindo que você faça rollback para uma versão anterior caso algo dê errado durante a atualização. Para fazer rollback, basta usar o comando `kubectl rollout undo deployment <nome-do-deployment>`. O Kubernetes irá reverter o Deployment para a versão anterior, criando novos Pods com a configuração da versão anterior e removendo os Pods da versão atual gradualmente, garantindo que a aplicação esteja sempre disponível durante o rollback.

```bash
k rollout undo deployment -n giropops nginx-deployment # reverte o Deployment para a versão anterior, criando novos Pods com a configuração da versão anterior e removendo os Pods da versão atual gradualmente, garantindo que a aplicação esteja sempre disponível durante o rollback.

k rollout history deployment -n giropops nginx-deployment # mostra o histórico de versões do Deployment, incluindo o número da versão, a imagem do container e a data de criação da versão.

deployment.apps/nginx-deployment 
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
4         <none>

k rollout history deployment -n giropops nginx-deployment --revision=2 # mostra os detalhes da versão 2 do Deployment, incluindo a imagem do container e a data de criação da versão.

k rollout undo deployment -n giropops nginx-deployment --to-revision=3 # reverte o Deployment para a versão 3, criando novos Pods com a configuração da versão 3 e removendo os Pods da versão atual gradualmente, garantindo que a aplicação esteja sempre disponível durante o rollback.

k rollout pause deployment -n giropops nginx-deployment # pausa o rollout do Deployment, impedindo que novas atualizações sejam aplicadas aos Pods até que o rollout seja retomado.
k rollout resume deployment -n giropops nginx-deployment # retoma o rollout do Deployment, permitindo que novas atualizações sejam aplicadas aos Pods.

k rollout restart deployment -n giropops nginx-deployment # reinicia os Pods do Deployment, causando downtime da aplicação. O rollout restart é recomendado para casos em que a aplicação precisa ser reiniciada para aplicar mudanças de configuração ou para resolver problemas de desempenho.

```
Com o pause e resume, é possível controlar o rollout do Deployment, permitindo que você pause o rollout para investigar problemas ou fazer ajustes antes de retomar o rollout. Isso é útil para garantir que a aplicação esteja sempre disponível durante o processo de atualização.

k scale deployment -n giropops nginx-deployment --replicas 5 # escala o número de réplicas do Deployment para 5, criando novos Pods para atender à demanda.

