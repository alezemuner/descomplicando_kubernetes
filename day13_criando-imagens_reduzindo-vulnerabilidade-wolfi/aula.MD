
# 🐳 Descomplicando Kubernetes - Day 13: Criando Imagens e Reduzindo Vulnerabilidade com Wolfi

## Índice
- [Preparando o Ambiente](#preparando-o-ambiente)
- [Criando a Imagem Docker](#criando-a-imagem-docker)
- [Camadas de uma Imagem Docker](#camadas-de-uma-imagem-docker)
- [Imagens Base: Distroless vs Alpine](#imagens-base-distroless-vs-alpine)
- [Verificando Vulnerabilidades](#verificando-vulnerabilidades)
- [Assinando Imagens com Cosign](#assinando-imagens-com-cosign)

---

## Preparando o Ambiente

### Clonar o repositório do projeto

```bash
git clone https://github.com/badtuxx/giropops-senhas.git
cd giropops-senhas
```

### Criar um ambiente virtual e instalar as dependências

```bash
python3 -m venv venv        # Cria um ambiente virtual chamado "venv"
source venv/bin/activate   # Ativa o ambiente virtual (Linux/Mac)
deactivate                  # Desativa o ambiente virtual

pip install -r requirements.txt

export PATH="$HOME/.local/bin:$PATH"
flask run --host=0.0.0.0
```

### Configurar variável de ambiente para Redis

```bash
export REDIS_HOST=172.16.44.202  # ou 172.0.0.1 se estiver instalado localmente
```

---

## Criando a Imagem Docker

### Build da imagem

```bash
docker image build -t giropops-senhas:1.0 .
docker image ls
```

**Resultado:**

| IMAGE | ID | DISK USAGE | CONTENT SIZE | EXTRA |
|-------|-----|------------|---------------|-------|
| giropops-senhas:1.0 | 152356954c00 | 211MB | 52.1MB | |

### Executar o container

```bash
# Executar a aplicação
docker run -d --name giropops-senhas -p 5000:5000 --env REDIS_HOST=172.16.44.202 giropops-senhas:1.0

# Verificar logs
docker container logs giropops-senhas

# Executar o Redis
docker run -d --name redis -p 6379:6379 redis
curl localhost:6379

# Acessar o container
docker exec -it giropops-senhas bash
set  # Verifica as variáveis de ambiente dentro do container
```

### Remover o container

```bash
docker rm -f giropops-senhas
```

---

## Camadas de uma Imagem Docker

```bash
docker history giropops-senhas:1.0
```

Exibe o histórico de camadas da imagem, mostrando todas as camadas intermediárias criadas durante o build.

---

## Imagens Base: Distroless vs Alpine

### Distroless

**Imagem base mínima**, sem shell ou ferramentas de depuração, focada em segurança e desempenho.

- ✅ Reduz a chance de vulnerabilidades
- ✅ Tamanho menor
- ✅ Menos superfície de ataque

> **Chainguard** é um exemplo de empresa que formatam imagens distroless.
> - [Chainguard Images](https://www.chainguard.dev/)

| Tipo | Uso |
|------|-----|
| `latest` | Produção |
| `latest-dev` | Desenvolvimento (inclui shell e ferramentas) |

### Alpine

- Imagem base leve, baseada em musl libc
- Tamanho reduzido, mas inclui shell e ferramentas básicas

---

## Verificando Vulnerabilidades

### Trivy

Ferramenta de análise de vulnerabilidades para imagens Docker, capaz de identificar vulnerabilidades conhecidas em camadas de imagem e dependências.

**Instalação:**

```bash
cat << EOF | sudo tee -a /etc/yum.repos.d/trivy.repo
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://aquasecurity.github.io/trivy-repo/rpm/public.key
EOF
sudo yum -y update
sudo yum -y install trivy
```

**Uso:**

```bash
# Análise completa
trivy image giropops-senhas:1.0

# Primeiras 20 linhas
trivy image giropops-senhas:1.0 | head -n 20
```

### Docker Scout

```bash
# Análise de CVEs
docker scout cves giropops-senhas:1.0

# Recomendações de segurança
docker scout recommendations giropops-senhas:1.0
```

---

## Assinando Imagens com Cosign

### O que é Sigstore?

Projeto open source para assinatura e verificação de imagens, garantindo autenticidade e integridade.

- [Sigstore](https://www.sigstore.dev/)
- [Cosign](https://github.com/sigstore/cosign)

### Instalação

```bash
curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
sudo chmod +x /usr/local/bin/cosign
```

### Gerar par de chaves

```bash
cosign generate-key-pair
```

Gera um par de chaves para assinatura:
- **Chave privada:** Usada para assinar a imagem
- **Chave pública:** Usada para verificar a assinatura

### Assinar uma imagem

> ⚠️ **Pré-requisito:** A imagem deve estar em um registry (Docker Hub, etc.) para ser assinada.

```bash
# Fazer push da imagem para o registry
docker push alezemuner/ubuntu-curl:v1

# Assinar a imagem
cosign sign alezemuner/ubuntu-curl@sha256:hash-aqui --key cosign.key
```

### Verificar assinatura

```bash
# Verifica a assinatura usando a chave pública
cosign verify --key cosign.pub alezemuner/ubuntu-curl:v1

# Obter o digest da imagem
docker inspect --format='{{index .RepoDigests 0}}' alezemuner/ubuntu-curl:v1
```

---

## Referências

- [Docker Hub - Python](https://hub.docker.com/_/python)
- [Trivy Documentation](https://trivy.dev/docs/latest/getting-started/installation/)
- [Sigstore](https://www.sigstore.dev/)
- [Cosign](https://github.com/sigstore/cosign)
- [Chainguard Images](https://www.chainguard.dev/)