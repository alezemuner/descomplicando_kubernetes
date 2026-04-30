# 📦 Descomplicando Kubernetes - Day 1

## Índice
- [Container](#container)
- [Cgroups (Control Groups)](#cgroups-control-groups)
- [Namespaces do Kernel](#namespaces-do-kernel)
- [Container Engine e Runtime](#container-engine-e-runtime)
- [OCI (Open Container Initiative)](#oci-open-container-initiative)
- [Kubernetes](#kubernetes)
- [Arquitetura do Kubernetes](#arquitetura-do-kubernetes)
- [Recursos do Kubernetes](#recursos-do-kubernetes)
- [Service](#service)

---

## Container

Isolamento de recursos, como **CPU**, **memória**, **rede** e **armazenamento**, para garantir que os aplicativos sejam executados de forma consistente em diferentes ambientes.

Utiliza o kernel do Host para compartilhar recursos, o que os torna mais leves e rápidos do que as máquinas virtuais tradicionais.

---

## Cgroups (Control Groups)

Mecanismo do kernel do Linux que **limita, contabiliza e isola o uso de recursos** (CPU, memória, disco, rede) para um grupo de processos.

---

## Namespaces do Kernel

Mecanismo do kernel do Linux que **isola o espaço de nomes** de processos, permitindo que diferentes grupos de processos tenham suas próprias visões dos recursos do sistema.

---

## Container Engine e Runtime

Quando estamos utilizando containers, precisamos ter o **container engine** e o **container runtime**.

### Container Engine

Responsável pela criação do **container**, gerenciamento de imagens, redes e volumes. Ele fornece uma interface para os usuários interagirem com os containers.

- ❌ Não conversa com o Kernel diretamente
- ✅ Comunica-se com o container runtime para executar os containers

**Exemplos:** Docker, Podman, CRI-O

### Container Runtime

Responsável por **executar os containers**, interagindo diretamente com o kernel para criar e gerenciar os namespaces e cgroups necessários para isolar os recursos do container.

**Exemplos:** containerd, runc, cri-o

### Tipos de Containers

#### Low-level
Containers que são executados diretamente no kernel como o **runc**, **crun** e **runsc**.

#### High-level
Containers que são executados por um container engine, como **containerd**, **cri-o** e **Podman**.

---

## OCI (Open Container Initiative)

**Organização:** vmware, Google, Microsoft, Red Hat, IBM

Define padrões abertos para containers, incluindo:
- Formato de imagem
- Runtime de containers
- Garantindo interoperabilidade entre diferentes ferramentas e plataformas de containerização

---

## Kubernetes

Plataforma de **orquestração de containers** que automatiza:
- ✨ Implantação
- 📊 Dimensionamento
- 🔧 Gestão de aplicativos em contêineres

**Exemplo:** Se uma aplicação falhar em um nó, o Kubernetes pode automaticamente reiniciar o contêiner ou movê-lo para outro nó saudável.

**Origem:** Desenvolvido pela Google, em GO e com o nome de Borg. Agora é um projeto de código aberto mantido pela **Cloud Native Computing Foundation (CNCF)**.

---

## Arquitetura do Kubernetes

### Control Plane

Responsável por **gerenciar o estado do cluster**, tomar decisões de agendamento e monitorar os nós.

**Componentes:**

| Componente | Responsabilidade |
|-----------|------------------|
| **API Server** | Interface de comunicação entre os usuários e o cluster. Único que se comunica com o etcd. |
| **Scheduler** | Responsável por alocar/agendar os pods nos nós disponíveis. |
| **Controller Manager** | Gerencia os controladores que garantem que o estado do cluster corresponda ao estado desejado. (Ex: ReplicaSet, Deployment, StatefulSet, DaemonSet, Job, CronJob) |
| **etcd** | Armazena o estado do cluster de forma consistente e distribuída (banco de dados chave-valor). |

⚠️ **Importante:** 
- Fazer backup do etcd é crucial para a recuperação do cluster em caso de falhas
- Criptografar os dados do etcd é importante para proteger informações sensíveis, como segredos e configurações do cluster

### Workers

Responsáveis por **executar as aplicações**.

**Componentes:**

| Componente | Responsabilidade |
|-----------|------------------|
| **Kubelet** | Agente que garante que os contêineres estejam em execução e saudáveis. Está em todo node do cluster e se comunica com o API Server. |
| **Container Runtime** | Responsável por executar os contêineres, como containerd ou cri-o. |
| **Kube Proxy** | Gerencia a rede e o balanceamento de carga para os serviços dentro do cluster. |

### Portas dos Componentes

| Componente | Porta | Protocolo |
|-----------|-------|-----------|
| API Server | 6443 | HTTPS - tcp |
| etcd | 2379-2380 | tcp |
| Kubelet | 10250 | tcp |
| Scheduler | 10251 | tcp |
| Controller Manager | 10252 | tcp |
| Kube Proxy | 10256 | tcp |
| NodePort | 30000-32767 | tcp |

---

## Recursos do Kubernetes

### POD

Menor unidade de implantação no Kubernetes, que pode conter um ou mais contêineres. Os contêineres dentro de um pod compartilham:
- Mesmo namespace de rede
- Armazenamento
- IP
- Portas

### Deployment (Controller)

Controla a **criação e atualização de pods**, garantindo que o número desejado de réplicas esteja sempre em execução. Responsável por gerenciar o ciclo de vida dos pods, incluindo:
- Criação
- Atualização
- Exclusão

### ReplicaSet (Controller)

Garante que um **número específico de réplicas** de um pod esteja em execução de acordo com a definição do Deployment. 

Quando há mudanças no Deployment, o ReplicaSet irá:
1. Criar outro replicaSet para gerenciar as novas réplicas
2. Manter o antigo ReplicaSet gerenciando as réplicas antigas
3. Gradualmente substituir as réplicas antigas pelas novas

### StatefulSet (Controller)

Gerencia a **implantação e dimensionamento de conjuntos de pods com estado**, garantindo que cada pod tenha um identificador único e persistente.

**Caso de uso:** Aplicativos que exigem armazenamento persistente e ordenação, como bancos de dados.

### DaemonSet (Controller)

Garante que um pod seja executado em **todos os nós** (ou em um subconjunto de nós) do cluster.

**Caso de uso:** Implantar serviços de infraestrutura, como agentes de monitoramento ou coleta de logs, que precisam ser executados em todos os nós.

---

## Service

Garante que os pods sejam **acessíveis por meio de um endereço IP estável** e um nome DNS, independentemente de onde os pods estejam sendo executados no cluster.

**Propósito:** Expor os pods para outros serviços dentro do cluster ou para o mundo externo.

### Tipos de Service

#### ClusterIP
Expõe o serviço **apenas dentro do cluster**.

#### NodePort
Expõe o serviço em uma **porta específica em cada nó** do cluster, permitindo o acesso externo.

> Se você pegar o IP do nó e a porta, é possível acessar o serviço de fora do cluster.

**Exemplo:**
```bash
kubectl expose pods nginx --type NodePort

kubectl get svc
NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP        226d
nginx        NodePort    10.104.246.171   <none>        80:32732/TCP   2m8s
```

#### LoadBalancer
Expõe o serviço por meio de um **balanceador de carga externo**, geralmente fornecido por um provedor de nuvem, para acesso externo.

#### ExternalName
Expõe o serviço por meio de um **nome DNS externo**, que é resolvido para um endereço IP externo, permitindo o acesso a serviços fora do cluster.


