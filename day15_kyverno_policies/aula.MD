# 🛡️ Descomplicando Kubernetes - Day 15: Kyverno Policies

## Índice
- [O que é o Kyverno](#o-que-é-o-kyverno)
- [Métodos de Aplicação](#métodos-de-aplicação)
- [Funções do Kyverno](#funções-do-kyverno)
- [Instalação do Helm](#instalação-do-helm)
- [Instalação do Kyverno](#instalação-do-kyverno)
- [Tipos de Policies](#tipos-de-policies)
- [Validate](#validate)
- [Mutate](#mutate)
- [Generate](#generate)
- [Polices de Segurança](#policies-de-segurança)
- [Usando Exclude em Policies](#usando-exclude-em-policies)

---

## O que é o Kyverno

Kyverno é uma ferramenta de gerenciamento de políticas para Kubernetes que permite criar, validar e aplicar políticas de segurança, conformidade e governança em clusters Kubernetes. Ele é projetado para ser fácil de usar e integrar-se bem com o ecossistema Kubernetes.

| Ferramenta | Complexidade | Integração |
|------------|--------------|------------|
| **Kyverno** | Baixa | Nativa com Kubernetes |
| **OPA** | Alta | Requer configuração adicional |

> Criar as policies através dos manifestos do Kubernetes.

---

## Métodos de Aplicação

| Método | Descrição |
|--------|-----------|
| **Enforcement** | As policies são aplicadas no momento da criação ou atualização dos recursos. Se um recurso violar uma policy, a ação será bloqueada e o recurso não será criado ou atualizado. |
| **Audit** | As policies são aplicadas de forma passiva, ou seja, elas não bloqueiam a criação ou atualização dos recursos. Em vez disso, elas apenas registram as violações em logs ou relatórios para que os administradores possam revisar e tomar medidas corretivas posteriormente. |

---

## Funções do Kyverno

| Função | Descrição |
|--------|-----------|
| **Generate** | Cria recursos adicionais do Kubernetes com base nas políticas definidas. Por exemplo, pode gerar NetworkPolicies para cada novo Namespace criado. |
| **Mutate** | Modifica automaticamente os recursos do Kubernetes para atender às políticas definidas. Por exemplo, pode adicionar automaticamente labels específicos a todos os novos Pods. |
| **Validate** | Verifica se os recursos do Kubernetes estão em conformidade com as políticas definidas. Por exemplo, pode garantir que todos os Pods tenham limites de CPU e memória definidos. |

> ⚠️ **Nota:** Necessário Helm para instalação do Kyverno.

---

## Instalação do Helm

> **Referência:** https://helm.sh/docs/intro/install/

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
chmod 700 get_helm.sh
./get_helm.sh
```

---

## Instalação do Kyverno

> **Referência:** 
> - https://kyverno.io/docs/installation/installation/
> - https://kyverno.io/docs/installation/#security-vs-operability

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno --namespace kyverno --create-namespace
```

### Verifique se o Kyverno está em execução

```bash
kubectl get pods -n kyverno
```

```
NAME                                             READY   STATUS    RESTARTS   AGE
kyverno-admission-controller-676f6698dc-cq47h    1/1     Running   0          12m
kyverno-background-controller-86b4d8d955-56mfm   1/1     Running   0          12m
kyverno-cleanup-controller-54c6787758-bppc6      1/1     Running   0          12m
kyverno-reports-controller-65d8bbfbc8-264qv      1/1     Running   0          12m
```

---

## Tipos de Policies

| Tipo | Escopo |
|------|--------|
| **ClusterPolicy** | Para todo o cluster |
| **Policy** | Somente para o namespace específico |

---

## Validate

Policy que verifica se os recursos do Kubernetes estão em conformidade com as políticas definidas.

### Exemplo: Obrigar limites de CPU e Memória

```bash
kubectl apply -f require-resources-limits.yaml
kubectl get clusterpolicies
```

```
NAME                        ADMISSION   BACKGROUND   READY   AGE   MESSAGE
require-cpu-memory-limits   true        true         True    56s   Ready
```

### Testando a Policy

Vamos tentar subir um pod sem especificar limites de recursos:

```bash
kubectl apply -f pod.yaml
```

**Erro esperado:**

```
Error from server: error when creating "pod.yaml": admission webhook "validate.kyverno.svc-fail" denied the request: 

resource Pod/default/exemplo-pod was blocked due to the following policies 

require-cpu-memory-limits:
  validate-limits: 'validation error: Obrigatório definir recursos de CPU e Memória.
    rule validate-limits failed at path /spec/containers/0/resources/limits/'
```

---

## Mutate

Policy que modifica automaticamente os recursos do Kubernetes para atender às políticas definidas.

### Exemplo: Adicionar label ao Namespace

A política `add-label-namespace.yaml` tem a função de adicionar um label a um namespace caso ele não tenha.

```bash
kubectl apply -f add-label-namspace.yaml
kubectl get clusterpolicies
```

```
NAME                        ADMISSION   BACKGROUND   READY   AGE   MESSAGE
add-label-namespace         true        true         True    7s    Ready
```

> A label que será adicionada é: `ambiente: producao`

### Criando um Namespace

Ao criar um namespace sem a label, o Kyverno irá adicionar automaticamente:

```bash
kubectl create namespace exemplo
kubectl describe ns exemplo
```

```
Name:         exemplo
Labels:       ambiente=producao
              kubernetes.io/metadata.name=exemplo
Annotations:  <none>
Status:       Active
```

---

## Generate

Policy que cria recursos adicionais do Kubernetes com base nas políticas definidas.

### Exemplo: Criar ConfigMap para cada Namespace

A política `generate-configmap-for-namespace.yaml` tem a função de criar um ConfigMap para cada namespace criado. O ConfigMap conterá informações sobre o namespace, como seu nome e data de criação.

Ela "fica observando" o cluster. Sempre que um novo recurso do tipo Namespace é criado, a policy é ativada.

```bash
kubectl apply -f generete-configmap-for-namespace.yaml
kubectl get clusterpolicies
```

```
NAME                               ADMISSION   BACKGROUND   READY   AGE   MESSAGE
generate-configmap-for-namespace   true        true         True    27s   Ready
```

### Criando um Namespace

```bash
kubectl create ns politica-generate
kubectl get configmaps -n politica-generate
```

```
NAME               DATA   AGE
configmap-padrao   2      50s
```

### Verificar o conteúdo do ConfigMap

```bash
kubectl describe configmap -n politica-generate configmap-padrao
```

```
Data
====
key1:
----
value1

key2:
----
value2
```

> O ConfigMap é criado exatamente no namespace que acabou de ser gerado, graças à variável `{{request.object.metadata.name}}`.

---

## Policies de Segurança

### Proibir execução como root

```bash
kubectl apply -f disallow-root-user.yaml
kubectl get clusterpolicies
```

```
NAME                               ADMISSION   BACKGROUND   READY   AGE   MESSAGE
disallow-root-user                 true        true         True    20s   Ready
```

**Erro ao tentar criar pod:**

```bash
kubectl apply -f pod.yaml
```

```
Error from server: error when creating "pod.yaml": admission webhook "validate.kyverno.svc-fail" denied the request: 

resource Pod/default/exemplo-pod was blocked due to the following policies 

disallow-root-user:
  nao-permitido-root: 'validation error: Não é permitido executar como root. Set runAsNonRoot
    to true. rule nao-permitido-root failed at path /spec/containers/0/securityContext/'
```

### Permitir apenas imagens de registry confiável

```bash
kubectl apply -f registry-allowed.yaml
kubectl get policies -n exemplo
```

```
NAME                              ADMISSION   BACKGROUND   READY   AGE   MESSAGE
ensure-images-from-trusted-repo   true        true         True    21s   Ready
```

#### Imagem não permitida

```bash
kubectl run nginx --image nginx --namespace exemplo
```

**Erro:**

```
ensure-images-from-trusted-repo:
  trusted-repo-check: 'validation error: Somente imagens do repo da Chainguard. rule
    trusted-repo-check failed at path /spec/containers/0/image/'
```

#### Imagem permitida

```bash
kubectl run nginx --image cgr.dev/chainguard/nginx --namespace exemplo
```

✅ Deve funcionar corretamente.

---

## Usando Exclude em Policies

Usado para excluir algo que não seja parte da policy.

```bash
kubectl apply -f disallow-root-user-exclude.yaml
```