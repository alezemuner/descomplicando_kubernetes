https://cert-manager.io/docs/installation/
https://cert-manager.io/docs/configuration/acme/

# Instalação do cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.19.2/cert-manager.yaml
# obs: em produção instalar via helm

k get issuers
k get clusterissuers
k get ingress
k get certificate
k get secret
k describe certificate giropops-senhas-tls

kubectl get svc -n ingress-nginx #verificar o EXTERNAL-IP do LoadBalancer

# Annotations
annotations #quando eu quero passar alguma configuração/informação extra para a aplicação
k annotate pods redis-deployment-6dcf7778b4-7qxqp description="banco de dados" #adiciona uma anotação description no pod redis
k annotate pods redis-deployment-6dcf7778b4-7qxqp description- #remove a anotação description do pod redis
k describe pod redis | grep Annotations -A 2 #verifica as anotações

# Labels 
label #quando eu quero categorizar ou agrupar recursos

k get all --selector=app=giropops-senhas #listar todos os recursos com o label app=giropops-senhas
k label pods redis-deployment-6dcf7778b4-7qxqp app- #remove o label app do pod redis
k get pods -L app #listar os pods com a coluna do label app

k get pods redis-deployment-6dcf7778b4-7qxqp -o yaml > pod-redis.yaml #exporta a configuração do pod redis para um arquivo YAML
k get pods redis-deployment-6dcf7778b4-7qxqp -o jsonpath='{.metadata.labels}' #exibe apenas os labels do pod redis

# htpasswd installation
sudo dnf install httpd-tools -y  #para sistemas baseados em Fedora/RedHat/CentOS
htpasswd -c auth alexandre #cria o arquivo auth com o usuário alexandre

k create secret generic giropops-senhas-users --from-file=auth #cria o secret giropops-senhas-users a partir do arquivo auth
k describe secrets giropops-senhas-users

# cookie session affinity
curl -I giropops.nginx.io

k run nginx --image nginx --port 80 
k expose pod nginx --type ClusterIP --name nginx