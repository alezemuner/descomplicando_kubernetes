# 🖧 Descomplicando Kubernetes - Day 5: Cluster Multi-Nodes

## Índice
- [Cluster Multi-Nodes](#cluster-multi-nodes)
- [Ferramentas de Provisionamento](#ferramentas-de-provisionamento)
- [Tipos de Cluster](#tipos-de-cluster)
- [Recomendações para Criação](#recomendações-para-criação)
- [Portas dos Componentes](#portas-dos-componentes)
- [Plugin de Rede (CNI)](#plugin-de-rede-cni)

---

## Cluster Multi-Nodes

### O que é

Um **cluster multi-nodes** é um cluster Kubernetes que consiste em vários nós:

| Componente | Função |
|------------|--------|
| **Control Plane** | Gerencia o estado do cluster (API Server, etcd, Scheduler, Controller Manager) |
| **Worker Nodes** | Executam as aplicações (Kubelet, Kube Proxy, Container Runtime) |

### Configuração

```bash
# 1. Instalar kubeadm em cada nó
# 2. Inicializar o plano de controle
kubeadm init

# 3. Adicionar nós de trabalho ao cluster
kubeadm join <token>
```

📚 **Documentação oficial:** [Creating a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

---

## Ferramentas de Provisionamento

### Kubeadm

Ferramenta nativa do Kubernetes para configuração simplificada de clusters.

| Característica | Descrição |
|----------------|-----------|
| **Tipo** | Ferramenta nativa do Kubernetes |
| **Uso** | Recomendado para clusters de produção |
| **Automação** | Geração de certificados, configuração do control plane |

```bash
# Inicializar cluster
kubeadm init

# Adicionar nó worker
kubeadm join <token>
```

### Kubespray

Ferramenta de automação que utiliza **Ansible** para provisionar clusters.

| Característica | Descrição |
|----------------|-----------|
| **Tipo** | Automação com Ansible |
| **Ambiente** | Nuvem, bare-metal, virtualizado |
| **Recursos** | Alta disponibilidade, balanceamento de carga |

📚 **Documentação:** [Kubespray](https://kubespray.io/)

---

## Tipos de Cluster

### Cluster Gerenciado

Cluster provisionado e gerenciado por um provedor de nuvem.

| Provedor | Serviço |
|----------|----------|
| **AWS** | EKS (Elastic Kubernetes Service) |
| **Google Cloud** | GKE (Google Kubernetes Engine) |
| **Azure** | AKS (Azure Kubernetes Service) |
| **DigitalOcean** | DOKS |

| Vantagens | Desvantagens |
|-----------|---------------|
| ✅ Managedo pelo provedor | ❌ Menor personalização |
| ✅ Atualizações automáticas | ❌ Custo adicional |
| ✅ Suporte a alta disponibilidade | ❌ Limitações de configuração |

### Cluster Não Gerenciado

Cluster provisionado e gerenciado pelo usuário.

| Vantagens | Desvantagens |
|-----------|---------------|
| ✅ Total controle e flexibilidade | ❌ Requer mais conhecimento técnico |
| ✅ Menor custo (sem intermediário) | ❌ Mais esforço de manutenção |
| ✅ Personalização completa | ❌ Responsabilidade total |

 
---

## Recomendações para Criação

| Recurso | Mínimo | Produção (Recomendado) |
|---------|--------|-------------------------|
| **RAM** | 2GB/nó | 4GB/nó |
| **CPU** | 2 CPUs/nó | 4 CPUs/nó |
| **Disco** | 10GB/nó | 20GB/nó |

### Requisitos de Infraestrutura

- ✅ Conexão de rede confiável entre os nós
- ✅ Firewall configurado para permitir comunicação entre componentes
- ✅ DNS configurado para resolver nomes de serviços e pods
- ✅ Autenticação e autorização configuradas
- ✅ Monitoramento e logging adequados
- ✅ Backup regular dos dados do etcd
- ✅ Atualizações regulares do Kubernetes

---

## Portas dos Componentes

| Componente | Porta | Protocolo |
|------------|-------|-----------|
| **API Server** | 6443 | TCP |
| **etcd** | 2379-2380 | TCP |
| **Kubelet** | 10250 | TCP |
| **Scheduler** | 10251 | TCP |
| **Controller Manager** | 10252 | TCP |
| **Kube Proxy** | 10256 | TCP |
| **NodePort** | 30000-32767 | TCP |

> 💡 **Recomendado:** Liberar portas 10250-10259 para o kubelet e outros componentes do cluster.

---

## Plugin de Rede (CNI)

**CNI (Container Network Interface)** é um componente essencial que fornece conectividade de rede entre pods e serviços.

### Plugins Populares

| Plugin | Descrição |
|--------|-----------|
| **Calico** | Baseado em roteamento, alta performance e segurança |
| **Flannel** | Simples, usa VXLAN, fácil de configurar |
| **Weave Net** | Abordagem de malha, boa escalabilidade |
| **Cilium** | Baseado em eBPF, alta performance e segurança |

### Tabela Comparativa

| Plugin | Vantagens | Desvantagens |
|--------|-----------|--------------|
| **Calico** | Alta performance, políticas de rede avançadas | Configuração mais complexa |
| **Flannel** | Fácil de configurar, bom para clusters pequenos | Sem políticas de rede avançadas |
| **Weave Net** | Fácil, suporte a políticas de rede | Performance em grandes clusters |
| **Cilium** | Alta performance, eBPF | Configuração complexa |

📚 **Documentação:** [Kubernetes Network Plugins](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
