# StatefulSet
O StatefulSet é um recurso do Kubernetes que gerencia o deployment e a escalabilidade de um conjunto de pods, garantindo a ordem e a identidade dos pods. Ele é especialmente útil para aplicações que requerem armazenamento persistente e uma identidade estável, como bancos de dados.

# Stateless vs Stateful
- **Stateless**: Aplicações que não mantêm estado entre as requisições. Elas podem ser escaladas facilmente, pois qualquer instância pode atender a qualquer requisição. Exemplo: servidores web.
- **Stateful**: Aplicações que mantêm estado entre as requisições. Elas exigem uma identidade estável e armazenamento persistente. Exemplo: bancos de dados.
O pod mantem um nome único e persistente, mesmo que seja reiniciado ou movido para outro nó. O StatefulSet garante que os pods sejam criados em ordem e que cada pod tenha um nome consistente, o que é crucial para aplicações stateful. Cria-se um PV para cada pod, garantindo que os dados sejam persistentes e associados ao pod correto, mesmo que ele seja reiniciado ou movido.

Antes de criar um statefulset é preciso resolver a criação de PV no cluster pois ele cria automaticamente um PV para cada pod criado (storageclass dinamico).
Ex: No EKS, necessário addon EBS CSI Driver, que permite criar volumes persistentes usando o Amazon EBS (Elastic Block Store) para armazenar dados de forma persistente.

```bash
k apply -f statefulset-nginx.yaml

k get pods
NAME      READY   STATUS    RESTARTS   AGE
nginx-0   1/1     Running   0          98s
nginx-1   1/1     Running   0          83s
nginx-2   1/1     Running   0          34s

k get statefulsets
NAME    READY   AGE
nginx   3/3     2m8s

k get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                 STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-5c76ab6c-4156-4b91-851c-4ef6f97fa0e2   1Gi        RWO            Delete           Bound       default/www-nginx-0   local-path     <unset>                          4m16s
pvc-b3fe7fcb-760a-49ee-8252-c39fdfdb2af0   1Gi        RWO            Delete           Bound       default/www-nginx-1   local-path     <unset>                          2m29s
pvc-f395e3c7-6235-4e1b-aca0-cf5dabb4d513   1Gi        RWO            Delete           Bound       default/www-nginx-2   local-path     <unset>                          100s

k get pvc
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
www-nginx-0   Bound    pvc-5c76ab6c-4156-4b91-851c-4ef6f97fa0e2   1Gi        RWO            local-path     <unset>                 4m40s
www-nginx-1   Bound    pvc-b3fe7fcb-760a-49ee-8252-c39fdfdb2af0   1Gi        RWO            local-path     <unset>                 2m53s
www-nginx-2   Bound    pvc-f395e3c7-6235-4e1b-aca0-cf5dabb4d513   1Gi        RWO            local-path     <unset>                 2m4s

```

Headless Service # Uma Headless Service no Kubernetes é um tipo especial de serviço que não atribui um endereço IP para os pods. Em vez disso, ele permite que os clientes se conectem diretamente aos pods usando seus nomes DNS. Isso é especialmente útil para StatefulSets, onde cada pod precisa ser acessível individualmente.

```bash 
k apply -f headless-svc-nginx.yaml
service/nginx-headless created

k get svc
NAME             TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
nginx            ClusterIP   None         <none>        80/TCP    18s

```bash
k exec -it nginx-0 -- bash

cd /usr/share/nginx/html/

curl localhost
<html>
<head><title>403 Forbidden</title></head>
<body>
<center><h1>403 Forbidden</h1></center>
<hr><center>nginx/1.29.7</center>
</body>
</html>

echo "GIROPOPS-0" > index.html

curl localhost
GIROPOPS-0
```

Logar no nginx-1 e verificar o conteúdo do index.html
```bash
k exec -it nginx-1 -- bash

curl nginx-0.nginx.default.svc.cluster.local
GIROPOPS-0

echo GIROPOPS-1 > /usr/share/nginx/html/index.html

```

Logar no nginx-2 e verificar o conteúdo do index.html
```bash
k exec -it nginx-2 -- bash

curl nginx-1.nginx.default.svc.cluster.local
GIROPOPS-1

curl nginx-0.nginx.default.svc.cluster.local
GIROPOPS-0
```


```

Service é o processo pelo qual os serviços em um cluster Kubernetes encontram e se comunicam uns com os outros. Com uma Headless Service, os pods podem ser descobertos diretamente através de seus nomes DNS, facilitando a comunicação entre eles.
Uma maneira de expor os pods inclusive externamente

Tipos de Service no Kubernetes:
ClusterIP # O ClusterIP é o tipo padrão de serviço no Kubernetes. Ele cria um endereço IP interno para o serviço, permitindo que os pods dentro do cluster se comuniquem entre si. No entanto, o ClusterIP não é acessível externamente ao cluster.

NodePort # O NodePort é um tipo de serviço que expõe o serviço em um número de porta específico em cada nó do cluster. Isso permite que o serviço seja acessado externamente ao cluster através do IP do nó e da porta designada.

LoadBalancer # O LoadBalancer é um tipo de serviço que cria um balanceador de carga externo para distribuir o tráfego entre os pods. Isso é útil para aplicativos que precisam ser acessados externamente e requerem balanceamento de carga.

ExternalName # O ExternalName é um tipo de serviço que mapeia o serviço para um nome DNS externo. Isso permite que os pods dentro do cluster acessem serviços externos usando um nome DNS, sem a necessidade de criar um serviço separado.

kubectl expose deployment MEU_DEPLOYMENT --port=80 --type=NodePort

k create deployment nginx --image nginx --port 80
k scale deployment nginx --replicas 3
k expose deployment nginx
k run -ti --rm debug --image busybox --restart Never -- sh
k expose deployment nginx --type NodePort # Expõe o deployment nginx usando o tipo NodePort para acessar externamente.
nginx        NodePort    10.107.112.50   <none>        80:32531/TCP   4s (a porta 32531 é a porta externa)
k get endpoints (Endpoints is deprecated in v1.33+)
k get EndpointSlice

k expose deployment nginx --type LoadBalancer # Expõe o deployment nginx usando o tipo LoadBalancer para criar um balanceador de carga externo.
k exec -ti nginx-86c57bc6b8-5cqdx -- bash
echo GIROPOPS > /usr/share/nginx/html/index.html
k get svc
nginx        LoadBalancer   10.98.0.1    172.16.44.245   80:31102/TCP   16m
http://172.16.44.245/

k create service externalname nome-externalname --external-name nome-definido-external.ip # Cria um serviço do tipo ExternalName que mapeia para o nome DNS externo "nome-definido-external.ip".
NAME                TYPE           CLUSTER-IP   EXTERNAL-IP                 PORT(S)   AGE
nome-externalname   ExternalName   <none>       nome-definido-external.ip   <none>    17s

Criando um service expondo outro service
kubectl expose deployment nginx --name opa --type NodePort --port 80 # Expõe o deployment nginx com o nome "opa" usando o tipo NodePort na porta 80.



