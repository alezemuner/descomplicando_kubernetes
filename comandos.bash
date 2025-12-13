# COMANDOS

kubectl get nodes #lista os nodes
kubectl get namespaces #lista os namespaces
kubectl get pods -A #lista todos os pods de todos os namespaces
kubectl get pods -o wide #retorna mais informações
kubectl get pods -L nome_label #retorna as labels dos pods
kubectl get pods -n kube-system #lista os pods no namespace kube-system
kubectl get pods -n kube-system -o wide #lista os pods no namespace kube-system com mais informações
kubectl get pods --all-namespaces #lista os pods de todos os namespaces
kubectl get pods nome-pod -o yaml (yaml) #retorna o pod em formato yaml

kubectl describe pods nome_pod (descreve o pod) #retorna informações detalhadas do pod

kubectl get deploy -A #lista todos os deployments de todos os namespaces
kubectl get svc -A #lista todos os serviços de todos os namespaces
kubectl get replicaset -A #lista todos os replicasets de todos os namespaces

# LOG
kubectl logs -n kube-system kube-proxy-sr2xb #retorna os logs do pod kube-proxy no namespace kube-system
kubectl logs licao-casa -c wordpress #retorna os logs do container wordpress do pod licao-casa
kubectl logs -n treinamento-ch2 pod-comportado -c polinux-stress #retorna os logs do container polinux-stress do pod pod-comportado no namespace treinamento-ch2
kubectl logs -f nome-pod #segue os logs em tempo real do pod especificado

# RUN
kubectl run nome_pod --image nginx --port 80 #cria um pod com a imagem nginx e expõe a porta 80
kubectl delete pod nome_pod #deleta o pod especificado

kubectl expose pods nome_pod #expõe o pod como um serviço
kubectl expose pods nome_pod --type NodePort #expõe o pod como um serviço do tipo NodePort
kubectl delete svc nginx #deleta o serviço nginx

kubectl exec -ti nginx -- bash #acessa o pod nginx via bash

# DRY RUN

kubectl run --image nginx --port 80 nginx --dry-run=client -o yaml > pod.yaml #simula a criação do pod e devolve em um yaml
kubectl apply -f pod.yaml #cria o pod a partir do arquivo yaml

#KUBECTL ATTACH (conecta ao container no pod) e KUBECTL EXEC (executa comandos dentro do pod)
kubectl run -it girus --image alpine #cria o pod girus com a imagem alpine
ps -f #lista os processos em execução no pod
apk add curl #instala o curl
curl google.com #testa o curl

kubectl attach girus2 -c girus2 -it #entro no pod girus2 no container girus2


kubectl exec -it strigus -- bash #entro no pod strigus via bash
kubectl exec -it girus2 -- apk add curl #instalo o curl no pod girus2
kubectl exec -it strigus -- cat /usr/share/nginx/html/index.html #visualizo o conteúdo do arquivo index.html
cd /proc/1/ #entro no diretório do processo 1
cat cmdline #vejo o comando que iniciou o processo 1
root@strigus:/usr/share/nginx/html# echo "GIROPOS STRIGUS GIRUS" > index.html #modifico o arquivo index.html

#POD MULTICONTAINER UTILIZANDO MANIFESTO
kubectl run girus-1 --image alpine --dry-run=client -o yaml > pod.yml #crio o manifesto do pod girus-1
kubectl apply -f pod.yml #crio o pod girus-1
kubectl delete -f pod.yml
k get pods -w #acompanha em tempo real os eventos dos pods
kubectl describe pod girus #vejo os detalhes do pod girus
kubectl logs girus #vejo os logs do pod girus
kubectl logs girus -f #
kubectl logs girus -c apache #vejo os logs do container apache do pod girus

#LIMITANDO RECURSOS DE PODS CPU E MEMÓRIA
    resources:
      limits:
        cpu: "1.5"
        memory: "128Mi"
      requests:
        cpu: "0.3"
        memory: "64Mi"

k exec -it girus -- bash
apt update
apt install stress
stress --vm-bytes 64M --vm 1
stress --cpu 1 --vm 1

#VOLUME EMPITYDIR
    volumeMounts: #montagem do volume no container
    - mountPath: /giropops #caminho dentro do container
      name: primeiro-emptydir #nome do volume

  volumes: #definição do volume no pod
  - name: primeiro-emptydir #nome do volume
    emptyDir: #tipo do volume
      sizeLimit: 256Mi #limite de tamanho do volume

#DEPLOYMENT E ESTRATÉGIAS DE ROLLOUT
kubectl create deployment nome-deployment --image=nginx #cria o deployment
kubectl get deployments #lista os deployments
kubectl get pods -l app=nginx-deployment #lista os pods do deployment nginx-deployment
kubectl get replicasets #lista os replicasets
kubectl describe deploy nginx-deployment #detalha o deployment nginx-deployment
kubectl get deploy nginx-deployment -o yaml #retorna o deployment nginx-deployment em formato yaml
kubectl get deploy nginx-deployment -o yaml > temp.yml   #salva o deployment em um arquivo temp.yml
kubectl delete -f deployment.yml #deleta o deployment a partir do manifesto
kubectl create deploy --image nginx --replicas 3 nginx-deployment --dry-run=client -o yaml > novo-deploymeent.yml #cria o deployment com 3 réplicas
kubectl create namespace giropops
kubectl apply -f deployment.yml 
kubectl get pods -n giropops
kubectl exec -it -n giropops nginx-deployment-865fbd567f-4hvx6 -- nginx -v #verifica a versão do nginx dentro do pod
kubectl rollout status deploy -n giropops nginx-deployment #verifica o status do rollout
kubectl rollout undo deploy -n giropops nginx-deployment #reverte para a versão anterior
kubectl rollout history deploy -n giropops nginx-deployment #lista o histórico de rollouts
kubectl rollout history deploy -n giropops nginx-deployment --revision 5
kubectl rollout undo deploy -n giropops nginx-deployment --to-revision 5 #reverte para a revisão 5
kubectl rollout pause deploy -n giropops nginx-deployment #pausa o rollout
kubectl rollout resume deploy -n giropops nginx-deployment #retoma o rollout pausado
kubectl rollout restart deploy -n giropops nginx-deployment # reinicia o deployment


#DEPLOYMENT E REPLICASET
kubectl get deployments
kubectl get replicasets
kubectl describe replicaset nginx-deployment #detalha o replicaset
kubectl rollout undo deployment nginx-deployment #reverte o deployment para a versão anterior
kubectl scale deploy nginx-deployment --replicas 3 #altera o número de réplicas do deployment para 3

#DAEMONSET
kubectl get daemonset
kubectl get pods -l app=node-exporter-daemonset
kubectl get pods -o wide -l app=node-exporter-daemonset
kubectl describe daemonset node-exporter-daemonset

#PROBES
