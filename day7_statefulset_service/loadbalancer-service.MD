No ambiente virtual necessario instalar o MetalLB. Ele é um balanceador via software que atribui um IP da sua rede local para o serviço, fazendo o Kubernetes simularLoadBalancer de verdade.

1. Habilite o Strict ARP
O MetalLB precisa disso para funcionar corretamente com o kube-proxy.

Bash
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

2. Instale o MetalLB
Vamos instalar os manifestos oficiais:

Bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
Aguarde os pods subirem (pode levar 1 minutinho):

Bash
kubectl get pods -n metallb-system -w
(Você precisa ver os pods "controller" e "speaker" rodando).

3. Configure o Pool de IPs
O MetalLB precisa de uma faixa de IPs da sua rede local (a mesma das VMs) que não esteja sendo usada por outras máquinas (fora do DHCP).

kubectl get nodes -o wide, no meu caso as VMs usam a rede 172.16.44.x.

Master: 172.16.44.202
Workers: 172.16.44.240 e 172.16.44.241

Utilizar uma faixa livre, por exemplo, do final .245 ao .250.

Crie um arquivo chamado metallb-config.yaml com o conteúdo abaixo:

YAML

apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: meu-pool-ips
  namespace: metallb-system
spec:
  addresses:
  - 172.16.44.245-172.16.44.250 # <--- Ajuste se esses IPs ja estiverem em uso!
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: meu-anuncio-l2
  namespace: metallb-system
spec:
  ipAddressPools:
  - meu-pool-ips
  
Aplique a configuração:

Bash
kubectl apply -f metallb-config.yaml

kubectl get svc nginx