# Kyverno 
Kyverno é uma ferramenta de gerenciamento de políticas para Kubernetes que permite criar, validar e aplicar políticas de segurança, conformidade e governança em clusters Kubernetes. Ele é projetado para ser fácil de usar e integrar-se bem com o ecossistema Kubernetes. 

# Obs: Necessário Helm para instalação do Kyverno.

# Instalação do Helm
https://helm.sh/docs/intro/install/

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
```
# Instalação do Kyverno
https://kyverno.io/docs/installation/installation/
https://kyverno.io/docs/installation/#security-vs-operability

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace
```

# Verifique se o Kyverno está em execução
```bash     
k get pods -n kyverno
NAME                                             READY   STATUS    RESTARTS   AGE
kyverno-admission-controller-676f6698dc-cq47h    1/1     Running   0          12m
kyverno-background-controller-86b4d8d955-56mfm   1/1     Running   0          12m
kyverno-cleanup-controller-54c6787758-bppc6      1/1     Running   0          12m
kyverno-reports-controller-65d8bbfbc8-264qv      1/1     Running   0          12m
```

# Verifique se as políticas de cluster estão disponíveis
```bash
k get clusterpolicies
NAME                        ADMISSION   BACKGROUND   READY   AGE   MESSAGE
require-cpu-memory-limits   true        true         True    56s   Ready
```

# Policie tipo Mutate
A politica add-label-namespace.yaml tem a função de adicionar um label a um namespace (Kinds) caso ele não tenha.
```yaml 
k apply -f add-label-namspace.yaml
```
No caso a label que será adicionado é o seguinte:  environment: production

Ao criar um namespace sem a label environment: production, o Kyverno irá adicionar automaticamente essa label ao namespace criado.

# Policie tipo Generate
A politica generate-configmap-for-namespace.yaml tem a função de criar um ConfigMap para cada namespace criado. O ConfigMap conterá informações sobre o namespace, como seu nome e data de criação.

Ela "fica observando" o cluster. Sempre que um novo recurso do tipo Namespace é criado, a policy é ativada.
Assim que o Namespace é criado, o Kyverno gera automaticamente um ConfigMap dentro dele.
O ConfigMap é criado exatamente no namespace que acabou de ser gerado, graças à variável {{request.object.metadata.name}}.

k create ns politica-generate

```bash
k get cm -n politica-generate
NAME                DATA   AGE
default-configmap   2      3s
kube-root-ca.crt    1      4s
```
# Para verificar o conteúdo do ConfigMap criado
kubectl describe configmap -n politica-generate default-configmap 

# Policie para proibir a criação de pods usando root

