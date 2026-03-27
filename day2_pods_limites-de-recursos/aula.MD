# POD
Menor unidade de implantação do Kubernetes, um POD é um grupo de um ou mais containers, com armazenamento compartilhado e rede, e uma especificação para como executar os containers. Os containers em um POD são sempre co-localizados, co-agendados e executados em um contexto compartilhado. Um POD representa uma única instância de um processo em execução no cluster.

Dois Pods comunicação via IP
Um Pod com 2 containers, ambos compartilham o mesmo IP e podem se comunicar via localhost

# ATTACH
O comando `kubectl attach` é usado para se conectar a um container em execução em um Pod e interagir com ele. Ele permite que você veja a saída do container e envie comandos para ele, como se estivesse usando um terminal interativo.

# EXEC
O comando `kubectl exec` é usado para executar um comando em um container em execução em um Pod. Ele permite que você execute comandos dentro do container, como se estivesse usando um terminal interativo, mas sem a necessidade de se conectar ao container. Ele é útil para depuração e administração de containers em execução.

```bash
kubectl run --image nginx --port 80 nginx-pod #cria um pod com a imagem nginx e expõe a porta 80

kubectl describe pod nginx-pod:
Status:           Running
IP:               10.244.5.5
IPs:
  IP:  10.244.5.5

curl 10.244.5.5
```


```bash
kubectl run -it girus --image busybox

ps -ef #mostra os processos em execução no container
PID   USER     TIME  COMMAND
    1 root      0:00 sh
    8 root      0:00 ps -ef


kubectl run -it girus --image alpine

apk add --no-cache --allow-untrusted ca-certificates #instala o ca-certificates no container alpine
apk add curl #instala o curl no container alpine

curl 10.244.5.5 #faz uma requisição para o IP do pod nginx-pod, que está rodando a imagem nginx
```

```bash
kubectl attach girus -c girus -it

kubectl exec -it nginx -- bash #acessa o pod nginx via bash
root@nginx:/# cd /proc/1

root@nginx:/# cd /usr/share/nginx/html/

echo "Hello World NGINX" > index.html #cria um arquivo index.html com o conteúdo "Hello World"

```
curl 10.244.5.5
kubectl exec nginx -- cat /usr/share/nginx/html/index.html #mostra o conteúdo do arquivo index.html criado no container nginx

# POD MULTICONTAINER UTILIZANDO MANIFESTO
kubectl run girus-1 --image alpine --dry-run=client -o yaml > pod.yml # cria um arquivo pod.yml com a definição do pod girus-1, mas sem criar o pod no cluster
kubectl apply -f pod-girus.yml

kubectl logs girus -f #segue os logs em tempo real do pod girus, mostrando a saída dos containers nginx e apache
kubectl logs girus -c apache #mostra os logs do container apache do pod girus

# LIMITE DE RECURSOS CPU E MEMÓRIA
pod-limitado.yml

```bash
k apply -f pod-limitado.yml
k describe pod giropops
k exec -it giropops -- bash
ps -ef #mostra os processos em execução no container giropops
free -m #mostra a memória disponível no container giropops
```

```bash
apt update && apt install stress -y #instala o stress no container giropops para gerar carga de CPU e memória

stress --vm-bytes 130M --vm 1  (130m estourou a memoria)
root@giropops:/# stress --vm-bytes 130M --vm 1
stress: info: [191] dispatching hogs: 0 cpu, 0 io, 1 vm, 0 hdd
command terminated with exit code 137

❯ k get pods
NAME       READY   STATUS      RESTARTS       AGE
giropops   0/1     OOMKilled   1 (116s ago)   9m31s

stress --cpu 0.5 --vm 1  #
```
#outro terminal
k exec -it giropops -- bash
free -m #mostra a memória disponível no container giropops, que deve estar em torno de 64MB, conforme o limite definido no manifesto pod-limitado.yml


# VOLUME EMPTYDIR
Não é um volume que persiste os dados, ou seja, quando o pod é deletado, os dados armazenados no volume são perdidos. Ele é criado quando o pod é criado e é montado em um caminho específico dentro do container. O volume emptyDir é útil para armazenar dados temporários, como arquivos de log ou arquivos de cache, que não precisam ser persistidos após a exclusão do pod.
Definir o camimho onde o volume será montado dentro do container, e o nome do volume que será utilizado dentro de containers:
Definir o proprio volume.

```bash
k apply -f pod-emptydir.yml
k describe pod giropops
k exec -it giropops -- bash
cd /giropops
touch FUNCIONA
