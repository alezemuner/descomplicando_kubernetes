# Volume

# Emptydir
O EmptyDir é um tipo de volume que é criado quando um Pod é atribuído a um nó e existe enquanto o Pod estiver em execução nesse nó. Ele é usado para armazenar dados temporários que precisam ser compartilhados entre os contêineres de um Pod. O conteúdo do EmptyDir é excluído quando o Pod é excluído ou movido para outro nó.

# PersistenteVolume
O PersistentVolume (PV) é um recurso do Kubernetes que representa um pedaço de armazenamento provisionado por um administrador. Ele é independente do ciclo de vida dos Pods e pode ser usado para armazenar dados persistentes. Os PVs podem ser provisionados dinamicamente ou estaticamente, e os Pods podem solicitar acesso a eles usando PersistentVolumeClaims (PVCs).

## StorageClass
O StorageClass é um recurso do Kubernetes que define as classes de armazenamento disponíveis para os PersistentVolumes. Ele permite que os administradores definam diferentes tipos de armazenamento com base em suas características, como desempenho, custo e disponibilidade. Os usuários podem solicitar um tipo específico de armazenamento ao criar um PersistentVolumeClaim (PVC) usando a StorageClass.

É uma forma de catergorização e abstração dos tipos de armazenamento disponíveis, facilitando a escolha do tipo de armazenamento adequado para as necessidades específicas de um aplicativo. O StorageClass pode ser usado para provisionamento dinâmico de volumes, onde o Kubernetes cria automaticamente um PersistentVolume (PV) quando um PersistentVolumeClaim (PVC) é criado com uma StorageClass específica.

```bash
kubectl get storageclass
NAME         PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  78d

kubectl apply -f storageclass.yaml
storageclass.storage.k8s.io/giropops created

kubectl get storageclass
NAME         PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
giropops     kubernetes.io/no-provisioner   Retain          WaitForFirstConsumer   false                  31s
local-path   rancher.io/local-path          Delete          WaitForFirstConsumer   false                  78d


```

## PV (PersistentVolume)
O PersistentVolume (PV) é um recurso do Kubernetes que representa um pedaço de armazenamento provisionado por um administrador. Ele é independente do ciclo de vida dos Pods e pode ser usado para armazenar dados persistentes. Os PVs podem ser provisionados dinamicamente ou estaticamente, e os Pods podem solicitar acesso a eles usando PersistentVolumeClaims (PVCs).

ReadWriteOnce # Apenas um nó pode montar o volume para leitura e escrita
ReadWriteMany # Vários nós podem montar o volume para leitura e escrita
ReadOnlyMany # Vários nós podem montar o volume para leitura, mas não para escrita

```bash
kubectl get pv

kubectl apply -f pv.yaml

kubectl get pv
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
meu-pv   1Gi        RWO            Retain           Available           giropops       <unset>                          5s

```


### HostPath
O HostPath é um tipo de volume que monta um diretório do sistema de arquivos do nó onde o Pod está sendo executado. Ele é útil para casos em que um contêiner precisa acessar arquivos ou diretórios específicos do nó, como logs ou arquivos de configuração. No entanto, o HostPath deve ser usado com cuidado, pois pode levar a problemas de segurança e portabilidade, já que o conteúdo do HostPath é compartilhado entre os Pods que estão sendo executados no mesmo nó.

### NFS (Network File System)
O NFS (Network File System) é um tipo de volume que permite que os Pods acessem um sistema de arquivos compartilhado em uma rede. Ele é útil para casos em que vários Pods precisam acessar os mesmos dados, como em um cenário de cluster de banco de dados ou em um cenário de compartilhamento de arquivos. O NFS é um protocolo de rede que permite que os clientes acessem arquivos em um servidor remoto como se fossem arquivos locais, e o Kubernetes suporta o uso de volumes NFS para fornecer armazenamento persistente para os Pods.

Utilizar um diretório NFS como volume no Kubernetes envolve os seguintes passos:
# Instalar os utilitários de NFS
```bash
sudo dnf install nfs-utils -y #instalar nos workers também

sudo mkdir -p /mnt/nfs #Criar o ponto de montagem

#Montar manualmente testar se a conexão está funcionando.
mount -t nfs <IP_DO_SERVIDOR>:<CAMINHO_REMOTO> /mnt/nfs
sudo mount -t nfs 192.168.1.100:/dados /mnt/nfs #exemplo
df -h /mnt/nfs

#Configurar montagem automática (Persistência)
sudo nano /etc/fstab
#Adicione a seguinte linha ao final do arquivo:
192.168.1.100:/dados    /mnt/nfs    nfs    defaults    0 0


# 192.168.1.100:/dados: O servidor e a pasta de origem.
# /mnt/nfs: Onde será montado no seu Oracle Linux.
# nfs: O tipo do sistema de arquivos.
# defaults: Opções padrão de montagem.

#Para testar se o fstab está correto sem precisar reiniciar, use:
sudo mount -a

sudo systemctl enable --now nfs-server
nano /etc/exports
/mnt/nfs  *(rw,sync,no_root_squash,no_all_squash)

sudo exportfs -ar #Recarrega as exportações NFS para aplicar as alterações feitas no arquivo /etc/exports.
```


```bash
kubectl apply -f pv-nfs.yaml

kubectl get pv
NAME         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
meu-pv       1Gi        RWO            Retain           Available           giropops       <unset>                          18m
meu-pv-nfs   1Gi        RWO            Retain           Available           giropops       <unset>                          3s
```





### Iscsi (Internet Small Computer Systems Interface)
O iSCSI (Internet Small Computer Systems Interface) é um protocolo de rede que permite que os clientes acessem dispositivos de armazenamento em um servidor remoto como se fossem dispositivos locais. O Kubernetes suporta o uso de volumes iSCSI para fornecer armazenamento persistente para os Pods. O iSCSI é útil para casos em que os Pods precisam acessar um dispositivo de armazenamento específico, como um disco rígido ou um array de armazenamento, e pode ser usado em cenários de cluster de banco deados de dados ou em cenários de armazenamento de arquivos.

### Nuvem PVs
Além dos tipos de volumes mencionados acima, o Kubernetes também suporta o uso de volumes em nuvem, como os volumes do Amazon EBS (Elastic Block Store), Google Persistent Disks e Azure Disks. Esses volumes são provisionados dinamicamente e podem ser usados para fornecer armazenamento persistente para os Pods em ambientes de nuvem. Eles são úteis para casos em que os Pods precisam acessar um dispositivo de armazenamento específico em um ambiente de nuvem, e podem ser usados em cenários de cluster de banco de dados ou em cenários de armazenamento de arquivos.





## PVC (PersistentVolumeClaim)
O PersistentVolumeClaim (PVC) é um recurso do Kubernetes que representa uma solicitação de armazenamento feita por um usuário. Ele é usado para solicitar acesso a um PersistentVolume (PV) específico ou a um tipo de armazenamento definido por uma StorageClass. O PVC especifica a quantidade de armazenamento necessária e as características desejadas, como o tipo de acesso (leitura/gravação) e acessibilidade (local ou remota). O Kubernetes tenta vincular o PVC a um PV que atenda aos requisitos especificados, e uma vez vinculado, o PVC pode ser usado por um Pod para acessar o armazenamento persistente.


```bash
k apply -f pvc.yaml

k get pvc
NAME      STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
meu-pvc   Pending                                      giropops       <unset>                 15s

#Esperando o primeiro consumidor
k apply -f pod.yaml

k get pvc
NAME      STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
meu-pvc   Bound    meu-pv-nfs   1Gi        RWO            giropops       <unset>                 5m54s
```