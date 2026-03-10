# Secrets 
Uma forma de guardar informações sensíveis no Kubernetes como tokens, senhas, chaves SSH, etc.
Armazenado no ETCD em base64 (não é criptografado por padrão, mas pode ser configurado para ser).

Pensar em formas de manter os secrets seguros:
- Usar RBAC para limitar o acesso aos secrets.
- Usar namespaces para isolar recursos.
- Habilitar a criptografia no ETCD para proteger os dados em repouso.

k get secrets -A
k describe secret <nome-do-secret> 
k get secrets -n <nome-do-namespace> <nome-do-secret>  -o yaml

echo -n "minha-senha-secreta" | base64 # codifica em base64

❯ echo -n "paocomovo" | base64
cGFvY29tb3Zv
❯ echo -n "alexandre" | base64
YWxleGFuZHJl

 k get secrets primeiro-secret -o yaml

 k create secret generic linha-comando-secret --from-literal=username=YWxleGFuZHJl --from-literal=password=cGFvY29tb3Zv # cria um secret via linha de comando

 k exec -ti nginx -- env # lista as variáveis de ambiente dentro do pod nginx

## Secret dockerconfigjson
Usado para armazenar credenciais de acesso a registries privados de imagens Docker.


# Login via Token de Acesso (Recomendado para VMs) 
Acesse hub.docker.com no seu PC e faça login.
Clique no seu perfil (canto superior direito) -> Account Settings.
Vá em Security -> New Access Token.
Dê um nome (ex: "OracleVM") e crie. Copie o token gerado (uma string longa de letras e números).
Na VM, use o comando especificando o usuário:
Bash
docker login -u SEU_USUARIO_DOCKER
Quando pedir o Password, cole o token que você gerou (ele não vai aparecer na tela quando você colar, é só dar Enter).
---

# Verificando o arquivo de configuração do Docker com as credenciais salvas
> docker login
> cd
> ls .docker
> cat .docker/config.json

base64 .docker/config.json # codifica o conteúdo do arquivo config.json em base64 para usar no secret

k -f apply dockerhub-secret.yaml

# Criando uma imagem e enviando para o Docker Hub
echo "FROM ubuntu" > Dockerfile
docker build -t alezemuner/ubuntu-curl:v1 .
docker push alezemuner/ubuntu-curl:v1

docker rmi alezemuner/ubuntu-curl:v1 # remove a imagem localmente

## Secret TLS
Usado para armazenar certificados TLS/SSL.

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout chave-privada.key -out certificado.crt # gera um certificado autoassinado

kubectl create secret tls meu-servico-web-tls-secret --cert=certificado.crt --key=chave-privada.key
k get secrets meu-servico-web-tls-secret -o yaml


## ConfigMaps
Usado para armazenar dados de configuração não sensíveis em pares chave-valor.

kubectl create configmap nginx-config --from-file=nginx.conf
 k get configmaps
 NAME               DATA   AGE
kube-root-ca.crt   1      158d
nginx-config       1      21s

k get configmaps nginx-config -o yaml > configmaps.yaml

k apply -f pod-configmap-secret.yaml 

k expose pod nginx
k expose pod nginx --name nginx-loadbalancer  --type LoadBalancer 

k port-forward services/nginx 4443:443