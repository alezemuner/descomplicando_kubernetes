# Configurando Ingress (Nginx Ingress Controller)
O Ingress é um recurso do Kubernetes que gerencia o acesso externo aos serviços em um cluster, geralmente HTTP. Ele fornece balanceamento de carga, terminação SSL e hospedagem virtual baseada em nome.

https://github.com/kubernetes/ingress-nginx/blob/main/README.md 
https://kubernetes.github.io/ingress-nginx/deploy/#bare-metal-clusters 

## Passo 1: Instalar o Nginx Ingress Controller
Podemos instalar o Nginx Ingress Controller usando o Helm ou kubectl. Usaremos o kubectl para aplicar o manifesto oficial.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.14.0/deploy/static/provider/baremetal/deploy.yaml
```

Aguarde alguns instantes e verifique se os Pods estão rodando. O Ingress Controller cria um namespace chamado ingress-nginx.

```bash 
kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --watch  
```

 k port-forward services/giropops-senhas 5000:5000 # Exemplo de port-forward para um serviço específico

  k get ingress

  k describe ingress giropops-senhas

  k run nginx --image nginx --port 80
  k expose pod nginx

   sudo nano /etc/hosts
