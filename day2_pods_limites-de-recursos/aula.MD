# 🐳 Descomplicando Kubernetes - Day 2: Pods e Limites de Recursos

## Índice
- [POD](#pod)
- [Interação com Pods](#interação-com-pods)
- [Pods Multi-container](#pods-multi-container)
- [Limites de Recursos](#limites-de-recursos)
- [Volume EmptyDir](#volume-emptydir)

---

## POD

**Menor unidade de implantação do Kubernetes**, um POD é um grupo de um ou mais containers, com:
- 💾 Armazenamento compartilhado
- 🌐 Rede compartilhada
- 📋 Especificação para como executar os containers

Os containers em um POD são sempre:
- **Co-localizados:** Vivem no mesmo host
- **Co-agendados:** São iniciados e parados juntos
- **Executados em contexto compartilhado:** Compartilham recursos

Um POD representa uma **única instância de um processo** em execução no cluster.

### Comunicação Entre Pods

| Cenário | Descrição |
|---------|-----------|
| **Dois Pods** | Comunicação via IP |
| **Um Pod com 2 containers** | Ambos compartilham o mesmo IP e podem se comunicar via `localhost` |

---

## Interação com Pods

### ATTACH

O comando **`kubectl attach`** é usado para:
- ✅ Conectar a um container em execução em um Pod
- 👁️ Ver a saída do container
- ⌨️ Enviar comandos de forma interativa

Permite interação como em um **terminal interativo**.

### EXEC

O comando **`kubectl exec`** é usado para:
- ✅ Executar um comando em um container em execução
- ⌨️ Interagir com um terminal sem se conectar ao container
- 🔧 Útil para depuração e administração

### Exemplos Práticos

#### Criando e Acessando um Pod com NGINX

```bash
# Criar um pod com nginx expondo a porta 80
kubectl run --image nginx --port 80 nginx-pod

# Descrever o pod
kubectl describe pod nginx-pod
# Status:           Running
# IP:               10.244.5.5

# Fazer requisição para o pod
curl 10.244.5.5
```

#### Explorando com BusyBox e Alpine

```bash
# Iniciar pod interativo com busybox
kubectl run -it girus --image busybox

# Listar processos
ps -ef
# PID   USER     TIME  COMMAND
#   1   root      0:00 sh
#   8   root      0:00 ps -ef
```

```bash
# Usar imagem alpine (mais leve)
kubectl run -it girus --image alpine

# Instalar certificados
apk add --no-cache --allow-untrusted ca-certificates

# Instalar curl
apk add curl

# Fazer requisição para o pod nginx
curl 10.244.5.5
```

#### Modificando Arquivo em Container NGINX

```bash
# Conectar ao pod nginx via bash
kubectl exec -it nginx -- bash

# Navegar até o diretório de conteúdo
root@nginx:/# cd /usr/share/nginx/html/

# Criar arquivo index.html customizado
root@nginx:/# echo "Hello World NGINX" > index.html

# Sair do bash
root@nginx:/# exit
```

```bash
# Fazer requisição do outro terminal
curl 10.244.5.5
# Hello World NGINX

# Ou verificar o arquivo diretamente
kubectl exec nginx -- cat /usr/share/nginx/html/index.html
# Hello World NGINX
```

---

## Pods Multi-container

### Criando Pod Multi-container via Manifesto

```bash
# Gerar YAML de um pod (sem criar no cluster)
kubectl run girus-1 --image alpine --dry-run=client -o yaml > pod.yml

# Aplicar o manifesto
kubectl apply -f pod-girus.yml
```

### Visualizando Logs

```bash
# Seguir logs em tempo real de todos os containers
kubectl logs girus -f

# Ver logs de um container específico
kubectl logs girus -c apache
```

---

## Limites de Recursos

### CPU e Memória

A definição de limites de recursos é **crítica** para garantir que os pods não consumam mais recursos que o disponível no cluster.

⚠️ **Importante:** Usar o arquivo `pod-limitado.yml` como referência para aplicar limites.

### Testando Limites

```bash
# Aplicar pod com limites
k apply -f pod-limitado.yml

# Descrever o pod
k describe pod giropops

# Acessar o pod
k exec -it giropops -- bash

# Verificar processos
ps -ef

# Verificar memória disponível
free -m
```

### Gerando Carga com Stress

```bash
# Instalar stress tool
apt update && apt install stress -y

# Testar limite de memória (130M > limite)
stress --vm-bytes 130M --vm 1

# Resultado esperado:
# stress: info: [191] dispatching hogs: 0 cpu, 0 io, 1 vm, 0 hdd
# command terminated with exit code 137
```

### Verificando Status do Pod

```bash
# Em outro terminal
k get pods

# Output esperado:
# NAME       READY   STATUS      RESTARTS       AGE
# giropops   0/1     OOMKilled   1 (116s ago)   9m31s
```

💡 **O status `OOMKilled` indica que o pod foi eliminado por exceder o limite de memória (Out of Memory).**

### Testando Limite de CPU

```bash
# Dentro do pod
stress --cpu 0.5 --vm 1
```

```bash
# Em outro terminal
k exec -it giropops -- bash

# Verificar memória disponível
free -m
# Deve estar em torno de 64MB, conforme o limite no manifesto
```

---

## Volume EmptyDir

### Características

O **emptyDir** é um tipo de volume que:
- ❌ **NÃO persiste dados:** Quando o pod é deletado, os dados são perdidos
- ✅ **Temporário:** Criado quando o pod é criado
- 📁 **Montado em caminho específico:** Dentro do container
- 💾 **Útil para:** Logs temporários, cache, dados intermediários

### Como Usar

**Dois passos essenciais:**

1. **Definir o caminho** onde o volume será montado dentro do container
2. **Definir o nome** do volume que será utilizado nos containers
3. **Definir o próprio volume** em `spec.volumes`

### Exemplo Prático

```bash
# Aplicar manifesto com emptyDir
k apply -f pod-emptydir.yml

# Descrever o pod
k describe pod giropops

# Acessar o pod
k exec -it giropops -- bash

# Navegar até o volume
cd /giropops

# Criar um arquivo de teste
touch FUNCIONA
```

✅ **O arquivo criado estará disponível enquanto o pod estiver em execução.**
