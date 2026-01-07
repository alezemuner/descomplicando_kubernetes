O problema está no PROVISIONER: kubernetes.io/no-provisioner.

Essa StorageClass (giropops) é do tipo Estática. Foi criada para casos onde cria o disco manualmente antes (o PV) e o Kubernetes apenas o "entrega" para o Pod. Ela não consegue criar discos automaticamente (Dynamic Provisioning).

Como o StatefulSet usa volumeClaimTemplates, ele está "pedindo" para o Kubernetes criar 3 discos novos.

Ele fica esperando (Pending) até que crie manualmente 3 PersistentVolumes (PVs) que atendam aos requisitos.

Instalar um Provisionador Dinâmico (Local Path Provisioner).

kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

Verifique se a nova classe apareceu:
kubectl get sc
# Deve aparecer uma chamada "local-path" com provisioner "rancher.io/local-path"

Ajustar o YAML do StatefulSet: No volumeClaimTemplates, para essa nova classe:

volumeClaimTemplates:
- metadata:
    name: www
  spec:
    accessModes: [ "ReadWriteOnce" ]
    storageClassName: local-path  # <--- Mude isso aqui
    resources:
      requests:
        storage: 1Gi