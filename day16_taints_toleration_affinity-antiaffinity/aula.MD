## Taints ##
Uma taint é uma marcação aplicada a um nó que indica que ele não deve aceitar pods, a menos que os pods tenham uma tolerância correspondente. As taints são usadas para evitar que certos nós sejam usados para executar determinados tipos de pods, como aqueles que exigem recursos específicos ou que precisam ser isolados por motivos de segurança

# noSchedule
No control-plane ja existe uma taint (node.kubernetes.io/noSchedule) que impede que ele seja usado para executar pods comuns, garantindo que ele seja dedicado apenas para as funções de controle do cluster.  

# noExecute: 
Impede que os pods sejam executados no nó, mas permite que eles sejam agendados. Isso é útil para nós que estão em manutenção ou que precisam ser reservados para tarefas específicas.

# PreferNoSchedule:
Indica que o Kubernetes deve evitar agendar pods no nó, mas não é uma regra rígida. O Kubernetes tentará agendar os pods em outros nós, mas se não houver opções disponíveis, ele poderá agendar os pods no nó com a taint PreferNoSchedule.

# Exibe as taints aplicadas ao nó master-node
k describe node master-node 

Taints:             node-role.kubernetes.io/control-plane:NoSchedule

# Cria um arquivo YAML para o deployment nginx com 4 réplicas, mas não o aplica ainda.
k create deployment nginx --image=nginx --replicas=4 --port=80 --dry-run=client -o yaml > deploy-nginx.yaml 

# Escala o deployment nginx para 8 réplicas, o que pode resultar em pods sendo agendados em nós disponíveis, dependendo das taints e tolerâncias configuradas.
k scale deployment nginx --replicas 8 

# Adiciona uma taint ao nó master-node, indicando que ele está em manutenção e não deve aceitar pods.
k taint node master-node manutencao=true:NoExecute 
# Remove a taint do nó worker01, permitindo que ele aceite pods novamente.
k taint node worker01 manutencao=true:NoExecute 
# Remove a taint do nó worker01, permitindo que ele aceite pods novamente.
k taint node worker01 manutencao=true:NoExecute-

# Reinicia os pods do deployment nginx para que eles sejam reprogramados e possam ser agendados em nós disponíveis.
k rollout restart deployment nginx 

# Adiciona uma taint ao nó worker01, indicando que ele não deve aceitar pods, mas permite que eles sejam agendados.
k taint node worker01 manutencao=true:NoSchedule
# Remove a taint do nó worker01, permitindo que ele aceite pods novamente.
k taint node worker01 manutencao=true:NoSchedule- 

# Exibe os nós do cluster e suas taints, filtrando apenas as linhas que contêm "Name:" ou "Taints:" para facilitar a leitura.
kubectl describe nodes | grep -E "Name:|Taints:" 

## Tolerations ##
As tolerâncias são usadas para permitir que os pods sejam agendados em nós com taints específicas. Elas são definidas no manifesto do pod e indicam que o pod pode tolerar a taint aplicada ao nó. Por exemplo, se um nó tiver a taint "manutencao=true:NoSchedule", um pod com a tolerância correspondente "manutencao=true:NoSchedule" poderá ser agendado nesse nó, mesmo que ele tenha a taint.

# Adiciona uma taint ao nó worker01, indicando que ele não deve aceitar pods, mas permite que eles sejam agendados.
k taint node worker01 gpu=true:NoSchedule

## Affinity ##
A afinidade (affinity) e a anti-afinidade (anti-affinity) são usadas para controlar onde os pods são agendados com base em regras de afinidade. A afinidade permite que os pods sejam agendados em nós que atendam a critérios específicos, como ter um rótulo específico ou estar em uma zona de disponibilidade específica. A anti-afinidade, por outro lado, impede que os pods sejam agendados em nós que atendam a critérios específicos, como ter um rótulo específico ou estar em uma zona de disponibilidade específica. Essas regras são definidas no manifesto do pod e podem ser usadas para garantir que os pods sejam agendados em nós que atendam a requisitos específicos de desempenho, segurança ou disponibilidade.

# Adiciona um rótulo "region=sa-east-1" ao nó worker01, indicando que ele está localizado na região de São Paulo (sa-east-1).
k label nodes worker01 region=sa-east-1
k label nodes worker01 region=sa-east-1-
# Adiciona um rótulo "az=sa-east-1a" ao nó worker01, indicando que ele está localizado na zona de disponibilidade "sa-east-1a" dentro da região de São Paulo. 
k label nodes worker01 az=sa-east-1a
k label nodes worker01 az=sa-east-1a- 

# Adiciona um rótulo "region=us-east-1" ao nó worker02, indicando que ele está localizado na região de Virgínia (us-east-1).
k label nodes worker02 region=us-east-1
# Adiciona um rótulo "az=us-east-1a" ao nó worker02, indicando que ele está localizado na zona de disponibilidade "us-east-1a" dentro da região de Virgínia.
k label nodes worker02 az=us-east-1a 

# Exibe as informações do nó worker01, incluindo os rótulos aplicados a ele, para verificar se os rótulos "region=sa-east-1" e "az=sa-east-1a" foram adicionados corretamente.
k get nodes worker01 --show-labels 
# Exibe as informações do nó worker02, incluindo os rótulos aplicados a ele, para verificar se os rótulos "region=us-east-1" e "az=us-east-1a" foram adicionados corretamente.
k get nodes worker02 --show-labels 

# Exibe os nós do cluster e suas regiões, usando a opção "-L" para mostrar a coluna "region" com base nos rótulos aplicados aos nós.
k get nodes -L region 
NAME          STATUS   ROLES           AGE    VERSION   REGION
master-node   Ready    control-plane   218d   v1.33.3   
worker01      Ready    <none>          218d   v1.33.3   sa-east-1
worker02      Ready    <none>          4h7m   v1.33.3   us-east-1

k apply -f deploy-nginx-affinity.yaml
deployment.apps/nginx created

k get pods -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
nginx-85bffb769c-2rfhs   1/1     Running   0          11s   10.244.1.22   worker01   <none>           <none>
nginx-85bffb769c-fz4nx   1/1     Running   0          11s   10.244.1.25   worker01   <none>           <none>
nginx-85bffb769c-wbhs7   1/1     Running   0          11s   10.244.1.23   worker01   <none>           <none>
nginx-85bffb769c-wz7hp   1/1     Running   0          11s   10.244.1.24   worker01   <none>           <none>


## Anti-Affinity ##
A anti-afinidade (anti-affinity) é usada para impedir que os pods sejam agendados em nós que atendam a critérios específicos, como ter um rótulo específico ou estar em uma zona de disponibilidade específica. Isso é útil para garantir que os pods sejam distribuídos de forma equilibrada entre os nós do cluster, evitando que todos os pods sejam agendados em um único nó, o que pode levar a problemas de desempenho e disponibilidade. As regras de anti-afinidade são definidas no manifesto do pod e podem ser usadas para garantir que os pods sejam agendados em nós que atendam a requisitos específicos de desempenho, segurança ou disponibilidade.

EX: nao quero dois pods no mesmo no.
    não pode no mesmo rack.






 