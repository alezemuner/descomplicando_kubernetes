# 🔐 Descomplicando Kubernetes - Day 18: RBAC

## Índice
- [O que é RBAC](#o-que-é-rbac)
- [Tipos de acesso](#tipos-de-acesso)
- [Role, RoleBinding, ClusterRole e ClusterRoleBinding](#role-rolebinding-clusterrole-e-clusterrolebinding)
- [Criando um usuário com certificado](#criando-um-usuário-com-certificado)
- [Api-resources e primeira Role](#api-resources-e-primeira-role)
- [RoleBinding](#rolebinding)
- [Configurando o usuário no kubeconfig](#configurando-o-usuário-no-kubeconfig)
- [Criando ClusterRole e ClusterRoleBinding](#criando-clusterrole-e-clusterrolebinding)

---

## O que é RBAC

RBAC (Role-Based Access Control) controla o acesso ao cluster Kubernetes e seus recursos.
É o nível de granularidade usado para permitir ou negar ações específicas.

Dois tipos de identidade:
- **Usuário**
- **Service Account**

Duas formas de autenticação no cluster Kubernetes:

### Tokens
Usados principalmente para aplicações.

### Certificados
Usados normalmente para usuários.

---

## Role, RoleBinding, ClusterRole e ClusterRoleBinding

### Role
Define o que pode ser acessado dentro de um namespace.

### RoleBinding
Associa uma `Role` a um usuário ou service account dentro de um namespace específico.

### ClusterRole
Define permissões que valem para o cluster inteiro.

### ClusterRoleBinding
Associa uma `ClusterRole` a um usuário ou service account com escopo de cluster.

---

## Criando um usuário com certificado

```bash
# criar o certificado do usuário developer para acessar o cluster
openssl genrsa -out developer.key 2048

# criar o CSR (Certificate Signing Request) que será enviado para o Kubernetes assinar
openssl req -new -key developer.key -out developer.csr -subj "/CN=developer"

# converter o arquivo developer.csr para base64 e remover a quebra de linha
cat developer.csr | base64 | tr -d '\n'

# copie o retorno do comando acima e cole em requests no arquivo developer.yaml
k apply -f developer.yaml

k get csr
NAME        AGE   SIGNERNAME                            REQUESTOR          REQUESTEDDURATION   CONDITION
developer   5s    kubernetes.io/kube-apiserver-client   kubernetes-admin   365d                Pending

# assinar/aprovar o certificado
kubectl certificate approve developer

k get csr
NAME        AGE    SIGNERNAME                            REQUESTOR          REQUESTEDDURATION   CONDITION
developer   2m4s   kubernetes.io/kube-apiserver-client   kubernetes-admin   365d                Approved,Issued

# salvar o certificado aprovado em um arquivo .crt
kubectl get csr developer -o jsonpath='{.status.certificate}' | base64 --decode > developer.crt
```

---

## Api-resources e primeira Role

```bash
k api-resources
k api-resources --namespaced=false
k api-resources --namespaced=false | grep roles
k api-resources -o wide | grep pods
k api-resources | grep certificatesigningrequests
NAME                                SHORTNAMES                                      APIVERSION                        NAMESPACED   KIND
certificatesigningrequests          csr                                             certificates.k8s.io/v1            false        CertificateSigningRequest
```

```bash
# criar o namespace dev
k create ns dev

# aplicar a Role no namespace dev
k apply -f developer-role.yaml

# verificar a Role criada
k get role -n dev
NAME        CREATED AT
developer   2026-05-07T14:50:17Z

k describe role -n dev developer
Name:         developer
Labels:       <none>
Annotations:  <none>
PolicyRule:
  Resources  Non-Resource URLs  Resource Names  Verbs
  ---------  -----------------  --------------  -----
  pods       []                 []              [get watch list update create delete]
```

---

## RoleBinding

```bash
k apply -f rolebinding-developer.yaml

k get rolebindings.rbac.authorization.k8s.io -n dev
NAME                   ROLE             AGE
DeveloperRoleBinding   Role/developer   58s

k describe rolebindings.rbac.authorization.k8s.io -n dev
Name:         DeveloperRoleBinding
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  Role
  Name:  developer
Subjects:
  Kind  Name       Namespace
  ----  ----       ---------
  User  developer
```

---

## Configurando o usuário no kubeconfig

```bash
# abrir o arquivo kubeconfig
nano ~/.kube/config

# adicionar o certificado do usuário ao kubeconfig
k config set-credentials developer --client-certificate developer.crt --client-key developer.key --embed-certs

# listar usuários no kubeconfig
kubectl config get-users
NAME
developer
kubernetes-admin

# listar clusters
k config get-clusters
NAME
kubernetes

# listar contextos
k config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
*         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin

# criar um contexto para o usuário developer
kubectl config set-context developer-contexto --cluster=kubernetes --namespace=dev --user=developer

# verificar contextos novamente
k config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
          developer-contexto            kubernetes   developer          dev
*         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin

# trocar para o contexto do usuário developer
k config use-context developer-contexto

# ver o que o usuário pode fazer
k auth can-i --list

# testar permissões com um pod no namespace dev
k run nginx --image nginx -n dev
k get pods
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          4s
k delete pod nginx
pod "nginx" deleted

# voltar para o contexto de admin
k config use-context kubernetes-admin@kubernetes
```

---

## Criando ClusterRole e ClusterRoleBinding

### Criando e assinando um certificado no Kubernetes

```bash
# criar o certificado do usuário platform para acessar o cluster
openssl genrsa -out platform.key 2048

# criar o CSR para o usuário platform
openssl req -new -key platform.key -out platform.csr -subj "/CN=platform"

# converter o arquivo platform.csr para base64 e remover a quebra de linha
cat platform.csr | base64 | tr -d '\n'

# copie o retorno do comando acima e cole em requests no arquivo platform.yaml
k apply -f platform.yaml

k get csr
NAME       AGE   SIGNERNAME                            REQUESTOR          REQUESTEDDURATION   CONDITION
platform   12s   kubernetes.io/kube-apiserver-client   kubernetes-admin   365d                Pending

# assinar/aprovar o certificado
kubectl certificate approve platform

k get csr
NAME       AGE   SIGNERNAME                            REQUESTOR          REQUESTEDDURATION   CONDITION
platform   41s   kubernetes.io/kube-apiserver-client   kubernetes-admin   365d                Approved,Issued

# salvar o certificado aprovado em um arquivo .crt
kubectl get csr platform -o jsonpath='{.status.certificate}' | base64 --decode > platform.crt
```

---

### Criar a ClusterRole

```bash
k apply -f platform-cluster-role.yaml
k get clusterroles
NAME                                                                   CREATED AT
platform                                                               2026-05-07T17:03:53Z
```

---

### ClusterRoleBinding

```bash
k apply -f cluster-binding-platform.yaml
k get clusterrolebindings
NAME                                                            ROLE                                                                               AGE
PlatformClusterBinding                                          ClusterRole/platform                                                               70s
```

## Configurando o usuário platform no kubeconfig

```bash
# adicionar o certificado do usuário ao kubeconfig
k config set-credentials platform --client-certificate platform.crt --client-key platform.key --embed-certs

# criar um contexto para o usuário platform
kubectl config set-context platform-contexto --cluster=kubernetes --user=platform
Context "platform-contexto" created.

#listar os contextos
k config get-contexts
CURRENT   NAME                          CLUSTER      AUTHINFO           NAMESPACE
          developer-contexto            kubernetes   developer          dev
*         kubernetes-admin@kubernetes   kubernetes   kubernetes-admin   
          platform-contexto             kubernetes   platform 

#trocar contexto platform-contexto
k config use-context platform-contexto


#trocar contexto para admin
k config use-context kubernetes-admin@kubernetes

k describe clusterrole cluster-admin
```

## Remover um usuário

```bash
# remover um usuário basta remover o CSR e o RoleBinding relacionado ao usuário
kubectl delete csr NOME-DO-CSR
kubectl delete rolebinding NOME-DO-ROLEBINDING

# remover do kubeconfig
kubectl config unset users.NOME-DO-USUARIO
```


# Utilizando tokens para Service Accounts

## Criar uma Service Account

```bash
k apply -f service-account.yaml
serviceaccount/pod-leitor created
k get serviceaccounts
NAME         SECRETS   AGE
default      0         276d
pod-leitor   0         6s
k describe serviceaccounts pod-leitor
Name:                pod-leitor
Namespace:           default
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   <none>
Tokens:              <none>
Events:              <none>
```


## Criando um Secret para o Service Account

```bash
k apply -f service-account-secret.yaml
k get secrets
NAME                            TYPE                                  DATA   AGE
service-account-example-token   kubernetes.io/service-account-token   3      84s

kubectl get secrets service-account-example-token -o yaml
  token: token.....

# pegar o token do service account ja decodificado
kubectl get secret service-account-example-token -o jsonpath='{.data.token}' | base64 --decode
copiar o token
```

## Criar uma Role para a Service Account

```bash
kubectl apply -f service-account-role.yaml
k get role
NAME                   CREATED AT
service-account-role   2026-05-07T18:12:03Z

kubectl apply -f rolebinding-service-account.yaml
k get rolebindings
NAME                          ROLE                        AGE
service-account-rolebinding   Role/service-account-role   43s
```

## Utilizando o token da Service Account

```bash
# criar um Pod que irá utilizar o token da Service Account para acessar o cluster
kubectl apply -f pod-service-account.yaml
k get pods
NAME                  READY   STATUS    RESTARTS   AGE
pod-service-account   1/1     Running   0          63s

# os tokens são montados dentro do container do Pod no caminho /var/run/secrets/kubernetes.io/serviceaccount
kubectl exec -it pod-service-account -- ls /var/run/secrets/kubernetes.io/serviceaccount
ca.crt     namespace  token

# conteúdo do arquivo token
kubectl exec -it pod-service-account -- cat /var/run/secrets/kubernetes.io/serviceaccount/token

# entrar no container do Pod
kubectl exec -it pod-service-account -- sh

# fazer a requisição utilizando o token da Service Account
curl -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc/api/v1/namespaces/default/pods

# se tentar listar os Pods de outro namespace, por exemplo giropops, não é permitido
curl -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc/api/v1/namespaces/giropops/pods

# se tentar listar os Services do namespace default, também não é permitido
curl -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc/api/v1/namespaces/default/services

exit

k run -it alpine --image alpine -- sh
# apk add curl
cat /var/run/secrets/kubernetes.io/serviceaccount/token
# comando abaixo dá erro
curl -k -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" https://kubernetes.default.svc/api/v1/namespaces/default/pods
```

## Removendo o Service Account
```bash
# basta remover o Service Account, o Secret e a RoleBinding relacionado ao Service Account
kubectl delete serviceaccount pod-leitor
kubectl delete secret service-account-example-token
kubectl delete rolebinding service-account-rolebinding

```