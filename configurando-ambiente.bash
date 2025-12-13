# Passo a passo de como se conectar a uma VM (Oracle Linux) via VS Code e instalar as ferramentadas necessárias para utilizar o KIND:

# Preparação (esse passo é opcional pois so altera o visual mas ajuda na produtividade mas é obrigatório se utilizar o plugin P10k do passo 3)
- Instalar as Fontes (MesloLGS NF) baixe e instale estes 4 arquivos no seu Windows ou Mac:
https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%2520NF%2520Regular.ttf
https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%2520NF%2520Bold.ttf
https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%2520NF%2520Italic.ttf
https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%2520NF%2520Bold%2520Italic.ttf

- Configurar o VS Code
Abra o VS Code.
Pressione Ctrl+ , (Configurações).
Busque por terminal font.
Em Terminal > Integrated: Font Family, insira: MesloLGS NF

# FASE 1: Conexão SSH (VS Code -> Servidor)
Instale a extensão Remote - SSH no VS Code.
Pressione F1 > Digite Remote-SSH: Open Configuration File > Selecione o primeiro arquivo.
Configure seu host:
-----------------------------
	Host NOME_DO_HOST
    HostName IP_DO_SERVIDOR
    User SEU_USUARIO
    Port 22
------------------------------
Conecte-se clicando no ícone >< (canto inferior esquerdo) > Connect to Host > NOME_DO_HOST.

# FASE 2: Instalação das Ferramentas (No Servidor)
1. Atualizar e Instalar Git (caso não tenha):

sudo dnf update -y
sudo dnf install git -y

2. Instalar Docker (Método Oficial) O Oracle Linux pode ter conflito com o Podman, então usamos o repo oficial do Docker CE:

sudo dnf install -y dnf-utils zip unzip
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Inicia e Habilita
sudo systemctl start docker
sudo systemctl enable docker

# Adiciona seu usuário ao grupo docker (Evita usar sudo sempre)
sudo usermod -aG docker $USER

3. Instalar Kubectl

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

4. Instalar Kind

# Detecta arquitetura e baixa a versão correta
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-arm64

chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# FASE 3: Shell e Visual (Zsh + Oh My Zsh + P10k)
1. Instalar Zsh

sudo dnf install zsh util-linux-user -y
# Define o Zsh como shell padrão
chsh -s $(which zsh)

2. Instalar Oh My Zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

3. Instalar Tema Powerlevel10k

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

4. Baixar Plugins de Produtividade

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# FASE 4: Configuração Final (Onde a mágica acontece)
Agora vamos configurar o autocomplete do Kubernetes, o alias k e o tema.
Abra o arquivo de configuração:

nano ~/.zshrc
Alteração 1 (Tema): Mude a linha ZSH_THEME="..." para:

ZSH_THEME="powerlevel10k/powerlevel10k"

Alteração 2 (Plugins): Procure a linha plugins=(...) e substitua por esta lista completa. O plugin kubectl aqui é o segredo: ele cria o alias k e configura o autocomplete automaticamente.

plugins=(
  git
  docker
  kubectl
  zsh-autosuggestions
  zsh-syntax-highlighting
)
Salve (Ctrl+O, Enter) e saia (Ctrl+X).

Aplique as configurações:


source ~/.zshrc

Assistente P10k: O assistente de configuração deve iniciar automaticamente. Siga as instruções respondendo (y/n) para deixar personalizar o terminal. Se não iniciar, digite p10k configure.

Forçar no VS Code a usar o zsh
No VS Code, abra as configurações (Ctrl + ,).
Digite na busca: terminal.integrated.defaultProfile.linux.
Selecione zsh.