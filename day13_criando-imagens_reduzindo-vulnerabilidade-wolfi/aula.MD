https://github.com/badtuxx/giropops-senhas.git
https://hub.docker.com/_/python
https://www.chainguard.dev/ # Imagem base minimalista e segura para aplicações Python, sem shell ou ferramentas de depuração.

# Criar um ambiente virtual e instalar as dependências
python3 -m venv venv # Cria um ambiente virtual chamado "venv"
source venv/bin/activate # Ativa o ambiente virtual (Linux/Mac)
deactivate # Desativa o ambiente virtual

pip install -r requirements.txt
flask run --host=0.0.0.0

export REDIS_HOST=172.16.44.202 ou 172.0.0.1 # se ja estiver instalado na maquina local, use o IP local, caso contrário, use o IP do contêiner Redis

# Criar a imagem Docker e executar os contêineres
docker image build -t giropops-senhas:1.0 . # Constrói a imagem Docker com a tag "giropops-senhas:1.0"

docker run -d --name giropops-senhas -p 5000:5000 --env REDIS_HOST=172.16.44.202 giropops-senhas:1.0 # Executa o contêiner Docker em segundo plano, mapeando a porta 5000

docker run -d --name redis -p 6379:6379 redis # Executa o contêiner Redis em segundo plano, mapeando a porta 6379
curl localhost:6379 # Verifica se o Redis está respondendo

docker exec -it giropops-senhas bash # Acessa o terminal do contêiner "giropops-senhas"
set # Verifica as variáveis de ambiente dentro do contêiner

docker rm -f giropops-senhas # Remove o contêiner "giropops-senhas"

docker history giropops-senhas:1.0 # Exibe o histórico de camadas da imagem "giropops-senhas:1.0"

# Distroless - Imagem base mínima, sem shell ou ferramentas de depuração, focada em segurança e desempenho.
# Alpine - Imagem base leve, baseada em musl libc, com um tamanho reduzido, mas ainda inclui um shell e ferramentas básicas.

# Trivy - 
Ferramenta de análise de vulnerabilidades para imagens Docker, capaz de identificar vulnerabilidades conhecidas em camadas de imagem e dependências.
https://trivy.dev/docs/latest/getting-started/installation/

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

# Analisa a imagem Docker "giropops-senhas:1.0" em busca de vulnerabilidades conhecidas, fornecendo um relatório detalhado sobre as descobertas.
trivy image giropops-senhas:1.0 

# Exibe apenas as primeiras 20 linhas do relatório de vulnerabilidades para uma visão rápida das descobertas mais críticas.
trivy image giropops-senhas:1.0 | head -n 20 


# Docker Scout
docker scout cves giropops-senhas:1.0 # Analisa a imagem Docker "giropops-senhas:1.0" em busca de vulnerabilidades conhecidas, fornecendo um relatório detalhado sobre as descobertas.

docker scout cves giropops-senhas:1.0


# Assinando uma imagem com cosign
https://www.sigstore.dev/
https://github.com/sigstore/cosign

https://docs.sigstore.dev/cosign/system_config/installation/

```bash
# Instalar o cosign
curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"
sudo mv cosign-linux-amd64 /usr/local/bin/cosign
sudo chmod +x /usr/local/bin/cosign
```  

# Gera um par de chaves para assinatura, onde a chave privada é usada para assinar a imagem e a chave pública é usada para verificar a assinatura.
cosign generate-key-pair 

# Exibe o digest da imagem Docker "alezmuner/ubuntu-curl:v1", que é um identificador único baseado no conteúdo da imagem, útil para garantir a integridade e autenticidade da imagem.
docker inspect --format='{{index .RepoDigests 0}}' alezemuner/ubuntu-curl:v1 

# Assina a imagem Docker "alezmuner/ubuntu-curl:v1" usando a chave privada "cosign.key", criando uma assinatura que pode ser verificada posteriormente para garantir a autenticidade da imagem.
cosign sign alezemuner/ubuntu-curl@sha256:hash-aqui --key cosign.key 

# Verifica a assinatura da imagem Docker "alezmuner/ubuntu-curl:v1" usando a chave pública "cosign.pub", garantindo que a imagem é autêntica e não foi alterada desde que foi assinada.
 cosign verify --key cosign.pub alezemuner/ubuntu-curl:v1 

