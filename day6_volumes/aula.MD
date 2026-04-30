# 💾 Descomplicando Kubernetes - Day 6: Volumes

## Índice
- [EmptyDir](#emptydir)
- [PersistentVolume (PV)](#persistentvolume-pv)
- [StorageClass](#storageclass)
- [Tipos de Volumes](#tipos-de-volumes)
- [PersistentVolumeClaim (PVC)](#persistentvolumeclaim-pvc)

---

## EmptyDir

### O que é

O **EmptyDir** é um tipo de volume que é criado quando um Pod é atribuído a um nó e existe **enquanto o Pod estiver em execução** nesse nó.

| Característica | Descrição |
|----------------|-----------|
| **Criação** | Automática quando o Pod é agendado |
| **Persistência** | Dados existem enquanto o Pod está rodando |
| **Compartilhamento** | Compartilhado entre contêineres do mesmo Pod |
| **Remoção** | Excluído quando o Pod é excluído ou movido |

💡 **Caso de uso:** Dados temporários que precisam ser compartilhados entre contêineres de um Pod.

---

## PersistentVolume (PV)

### O que é

O **PersistentVolume (PV)** é um recurso do Kubernetes que representa um **pedaço de armazenamento provisionado por um administrador**.

| Característica | Descrição |
|----------------|-----------|
| **Ciclo de vida** | Independente dos Pods |
| **Provisionamento** | Dinâmico ou estático |
| **Acesso** | Solicitado via PersistentVolumeClaim (PVC) |

### Modos de Acesso

| Modo | Descrição |
|------|-----------|
| **ReadWriteOnce (RWO)** | Apenas um nó pode montar para leitura e escrita |
| **ReadWriteMany (RWX)** | Vários nós podem montar para leitura e escrita |
| **ReadOnlyMany (ROX)** | Vários nós podem montar para leitura, mas não escrita |

---

## StorageClass

### O que é

O **StorageClass** é um recurso que define as **classes de armazenamento disponíveis** para os PersistentVolumes.

✨ **Propósito:** Categorização e abstração dos tipos de armazenamento

| Benefício | Descrição |
|-----------|-----------|
| **Flexibilidade** | Múltiplos tipos de armazenamento |
| **Provisionamento dinâmico** | Criação automática de PVs |
| **Performance** | Diferentes níveis de desempenho |
| **Custo** | Opções para diferentes orçamentos |

### Exemplo de Uso

```bash
# Listar StorageClasses disponíveis
kubectl get storageclass
# NAME         PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
# local-path   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  78d

# Criar um StorageClass
kubectl apply -f storageclass.yaml
# storageclass.storage.k8s.io/giropops created

# Verificar novamente
kubectl get storageclass
# NAME         PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
# giropops     kubernetes.io/no-provisioner   Retain          WaitForFirstConsumer   false                  31s
# local-path   rancher.io/local-path          Delete          WaitForFirstConsumer   false                  78d
```

⚠️ **Parâmetros importantes:**
- **Provisioner:** Define quem cria o volume
- **ReclaimPolicy:** Delete (apaga) ou Retain (mantém)
- **VolumeBindingMode:** Immediate ou WaitForFirstConsumer

## StorageClass

O **StorageClass** é um recurso do Kubernetes que define as **classes de armazenamento disponíveis** para os PersistentVolumes.

✨ **Propósito:** Categorização e abstração dos tipos de armazenamento

| Benefício | Descrição |
|-----------|-----------|
| **Flexibilidade** | Múltiplos tipos de armazenamento |
| **Provisionamento dinâmico** | Criação automática de PVs |
| **Performance** | Diferentes níveis de desempenho |
| **Custo** | Opções para diferentes orçamentos |

### Exemplo de Uso

```bash
# Listar StorageClasses disponíveis
kubectl get storageclass
# NAME         PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
# local-path   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  78d

# Criar um StorageClass
kubectl apply -f storageclass.yaml
# storageclass.storage.k8s.io/giropops created

# Verificar novamente
kubectl get storageclass
# NAME         PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
# giropops     kubernetes.io/no-provisioner   Retain          WaitForFirstConsumer   false                  31s
# local-path   rancher.io/local-path          Delete          WaitForFirstConsumer   false                  78d
```

⚠️ **Parâmetros importantes:**
- **Provisioner:** Define quem cria o volume
- **ReclaimPolicy:** Delete (apaga) ou Retain (mantém)
- **VolumeBindingMode:** Immediate ou WaitForFirstConsumer

---

## Tipos de Volumes

### HostPath

O **HostPath** é um tipo de volume que monta um diretório do sistema de arquivos do nó onde o Pod está sendo executado.

| Característica | Descrição |
|----------------|-----------|
| **Origem** | Sistema de arquivos do nó |
| **Caso de uso** | Acessar logs, arquivos de configuração |
| **⚠️ Cuidado** | Problemas de segurança e portabilidade |

💡 **Atenção:** O conteúdo é compartilhado entre Pods no mesmo nó.

---

### NFS (Network File System)

O **NFS** é um tipo de volume que permite que os Pods acessem um sistema de arquivos compartilhado em uma rede.

| Característica | Descrição |
|----------------|-----------|
| **Protocolo** | NFS (Network File System) |
| **Acesso** | Múltiplos Pods podem acessar os mesmos dados |
| **Caso de uso** | Clusters de banco de dados, compartilhamento de arquivos |

#### Configuração do NFS

**1. Instalar utilitários NFS (nos workers também):**
```bash
sudo dnf install nfs-utils -y
```

**2. Criar ponto de montagem:**
```bash
sudo mkdir -p /mnt/nfs
```

**3. Montar manualmente para testar:**
```bash
# Sintaxe: mount -t nfs <IP_SERVIDOR>:<CAMINHO_REMOTO> <PONTO_LOCAL>
sudo mount -t nfs 192.168.1.100:/dados /mnt/nfs
df -h /mnt/nfs
```

**4. Configurar montagem automática (persistência):**
```bash
sudo nano /etc/fstab
# Adicionar linha:
192.168.1.100:/dados    /mnt/nfs    nfs    defaults    0 0
```

**5. Testar sem reiniciar:**
```bash
sudo mount -a
```

**6. Configurar servidor NFS:**
```bash
sudo systemctl enable --now nfs-server
nano /etc/exports
/mnt/nfs  *(rw,sync,no_root_squash,no_all_squash)
sudo exportfs -ar
```

#### Criar PV com NFS no Kubernetes

```bash
kubectl apply -f pv-nfs.yaml

kubectl get pv
# NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
# meu-pv       1Gi        RWO            Retain           Available           giropops       <unset>                          18m
# meu-pv-nfs   1Gi        RWO            Retain           Available           giropops       <unset>                          3s
```

---

### iSCSI

O **iSCSI (Internet Small Computer Systems Interface)** é um protocolo de rede que permite que os clientes acessem dispositivos de armazenamento em um servidor remoto como se fossem dispositivos locais.

| Característica | Descrição |
|----------------|-----------|
| **Protocolo** | iSCSI |
| **Caso de uso** | Acessar dispositivos de armazenamento específicos |
| **Aplicação** | Clusters de banco de dados, armazenamento de arquivos |

---

### Volumes em Nuvem

O Kubernetes suporta volumes em nuvem para armazenamento persistente:

| Provedor | Tipo de Volume |
|----------|---------------|
| **AWS** | EBS (Elastic Block Store) |
| **GCP** | Google Persistent Disks |
| **Azure** | Azure Disks |

| Característica | Descrição |
|----------------|-----------|
| **Provisionamento** | Dinâmico |
| **Caso de uso** | Ambientes de nuvem |
| **Aplicação** | Clusters de banco de dados, armazenamento de arquivos |

---

## PersistentVolumeClaim (PVC)

### O que é

O **PersistentVolumeClaim (PVC)** é uma solicitação de armazenamento feita por um usuário.

| Componente | Descrição |
|------------|-----------|
| **Quantidade** | Tamanho de armazenamento necessário |
| **Acesso** | Leitura/gravação (RWO, RWX, ROX) |
| **StorageClass** | Tipo de armazenamento desejado |

### Ciclo de Vida do PVC

1. 📝 **Pending:** PVC criado, mas ainda não vinculado
2. 🔗 **Bound:** PVC vinculado a um PV
3. 🗑️ **Released:** PV liberado (dados podem permanecer)

### Exemplo de Uso

```bash
# Criar PVC
k apply -f pvc.yaml

# Ver status - deve estar Pending
k get pvc
# NAME      STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
# meu-pvc   Pending                                      giropops       <unset>                 15s

# Criar Pod que consome o PVC (esperando primeiro consumidor)
k apply -f pod.yaml

# Verificar - agora deve estar Bound
k get pvc
# NAME      STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
# meu-pvc   Bound    meu-pv-nfs   1Gi        RWO            giropops       <unset>                 5m54s
```

💡 **Dica:** O PVC é vinculado automaticamente a um PV que atenda aos requisitos especificados.