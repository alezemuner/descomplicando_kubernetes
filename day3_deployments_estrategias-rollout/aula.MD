# 📦 Descomplicando Kubernetes - Day 3: Deployments e Estratégias de Rollout

## Índice
- [Deployment](#deployment)
- [Interação com Deployments](#interação-com-deployments)
- [Atualização de um Deployment](#atualização-de-um-deployment)
- [Estratégias de Rollout](#estratégias-de-rollout)
- [Rollback](#rollback)
- [Controle de Rollout](#controle-de-rollout)
- [Scaling](#scaling)

---

## Deployment

**O Deployment é o controller mais importante do Kubernetes para gerenciar aplicações.**

Quando um Deployment é criado, um **ReplicaSet também é criado automaticamente**.

### Responsabilidades do Deployment

| Responsabilidade | Descrição |
|-----------------|-----------|
| **Gerenciar ReplicaSets** | O Deployment controla os ReplicaSets, que por sua vez controlam os Pods |
| **Garantir réplicas** | Assegura que o número desejado de réplicas esteja sempre disponível |
| **Atualizar Pods** | Atualiza os Pods quando uma nova versão da aplicação é lançada |
| **Zero downtime** | Garante que a aplicação esteja sempre disponível, mesmo durante atualizações |

⚠️ **Hierarquia:** Deployment → ReplicaSet → Pods

### Comandos Essenciais

```bash
# Listar Pods gerenciados pelo Deployment
kubectl get pods -l app=nginx-deployment

# Listar todos os ReplicaSets
kubectl get replicaset

# Descrever informações do Deployment
kubectl describe deploy nginx-deployment

# Exportar configuração do Deployment
kubectl get deploy nginx-deployment -o yaml > temp.yaml

# Criar novo Deployment via CLI
kubectl create deployment --image nginx --replicas 3 nginx-deployment --dry-run=client -o yaml > novo-deployment.yaml
```

---

## Interação com Deployments

### Gerenciamento de Namespaces

```bash
# Listar todos os namespaces
k get namespace

# Criar namespace
k create namespace giropops

# Exportar namespace para YAML
k create namespace giropops --dry-run=client -o yaml > namespace.yaml

# Listar Deployments em um namespace específico
k get deployments.apps -n giropops

# Listar Pods em um namespace específico
k get pods -n giropops
```

---

## Atualização de um Deployment

### Como Funciona

Para atualizar um Deployment:

1. ✏️ Editar o arquivo de configuração do Deployment
2. 🚀 Aplicar as mudanças com `kubectl apply -f <arquivo-deployment.yaml>`
3. 🔄 O Kubernetes compara o estado atual com o estado desejado
4. 📦 Cria novos Pods com a nova configuração
5. 🗑️ Remove os Pods antigos gradualmente
6. ✅ Garante disponibilidade da aplicação durante toda a atualização

### Exemplo Prático: Atualização de Imagem

**Primeira atualização: nginx → nginx:1.15.0**

```bash
# Editar deployment.yml e aplicar
k apply -f deployment.yml

# O Kubernetes:
# 1. Cria novos Pods com nginx:1.15.0
# 2. Remove os Pods antigos gradualmente
# 3. Mantém a aplicação disponível o tempo todo
```

**Segunda atualização: nginx:1.15.0 → nginx:1.16.0**

```bash
# Aplicar novamente
k apply -f deployment.yml

# Verificar versão do nginx em um Pod
k exec -it -n giropops nginx-deployment-57d7979b99-86n4h -- nginx -v
```

---

## Estratégias de Rollout

Existem **duas estratégias** para atualizar um Deployment:

### Rolling Update (Padrão ⭐)

| Característica | Descrição |
|----------------|-----------|
| **Padrão** | Estratégia padrão do Kubernetes |
| **Gradual** | Atualiza os Pods gradualmente |
| **Disponibilidade** | A aplicação permanece sempre disponível |
| **Tempo de inatividade** | Mínimo ou nenhum |
| **Recomendado para** | A maioria dos casos |

✅ **Melhor para:** Atualizações sem impacto crítico

### Recreate

| Característica | Descrição |
|----------------|-----------|
| **Agressivo** | Recria todos os Pods de uma vez |
| **Tempo de inatividade** | Causa downtime da aplicação |
| **Velocidade** | Mais rápido, mas com interrupção |
| **Recomendado para** | Casos especiais |

⚠️ **Melhor para:** Mudanças incompatíveis que exigem reinicialização

### Verificando Status do Rollout

```bash
# Monitorar status da atualização
k rollout status deployment -n giropops nginx-deployment

# Saída esperada mostrará:
# - Número de réplicas atualizadas
# - Número de réplicas disponíveis
# - Número de réplicas não disponíveis
```

---

## Rollback

### O que é Rollback

**Rollback é o processo de reverter um Deployment para uma versão anterior.**

✨ **Kubernetes mantém um histórico de versões**, permitindo voltar rapidamente caso algo dê errado.

### Commandos de Rollback

```bash
# Reverter para a versão anterior
k rollout undo deployment -n giropops nginx-deployment

# Ver histórico de versões
k rollout history deployment -n giropops nginx-deployment

# Saída esperada:
# deployment.apps/nginx-deployment
# REVISION  CHANGE-CAUSE
# 2         <none>
# 3         <none>
# 4         <none>
```

### Detalhes de uma Revisão Específica

```bash
# Ver detalhes da revisão 2
k rollout history deployment -n giropops nginx-deployment --revision=2

# Voltar para uma revisão específica
k rollout undo deployment -n giropops nginx-deployment --to-revision=3
```

💡 **Dica:** Isso cria novos Pods com a configuração da revisão 3, mantendo a aplicação disponível.

---

## Controle de Rollout

### Pausar e Retomar

```bash
# Pausar o rollout durante uma atualização
k rollout pause deployment -n giropops nginx-deployment

# Investigar problemas sem afetar mais Pods...

# Retomar o rollout
k rollout resume deployment -n giropops nginx-deployment
```

✅ **Caso de uso:** Pausar para investigar problemas antes de continuar a atualização.

### Reiniciar Pods

```bash
# Reiniciar todos os Pods do Deployment
k rollout restart deployment -n giropops nginx-deployment

# ⚠️ Isso causa downtime temporário da aplicação
# Recomendado para:
# - Aplicar mudanças de configuração
# - Resolver problemas de desempenho
# - Forçar recarregamento de variáveis de ambiente
```

---

## Scaling

### Ajustar Número de Réplicas

```bash
# Escalar para 5 réplicas
k scale deployment -n giropops nginx-deployment --replicas 5

# Resultado:
# - 5 novos Pods são criados (ou 2 se havia 3)
# - Balanceador de carga distribui o tráfego
# - Maior capacidade de atender requisições
```

💡 **Scaling pode ser feito manualmente ou automaticamente com HPA (Horizontal Pod Autoscaler).**

