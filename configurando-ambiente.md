# Passo a passo: Conectar a uma VM (Oracle Linux) via VS Code e instalar ferramentas para usar KIND

## Preparação (opcional)
> Esse passo altera apenas o visual, mas ajuda na produtividade. Obrigatório se usar o plugin Powerlevel10k.

### Instalar as fontes (MesloLGS NF)
Baixe e instale estes 4 arquivos no seu Windows ou Mac:

- https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%2520NF%2520Regular.ttf
- https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%2520NF%2520Bold.ttf
- https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%2520NF%2520Italic.ttf
- https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%2520NF%2520Bold%2520Italic.ttf

### Configurar o VS Code (fonte do terminal)
1. Abra o VS Code.
2. Pressione `Ctrl+,` (Configurações).
3. Busque por "terminal font".
4. Em *Terminal > Integrated: Font Family*, insira: `MesloLGS NF`.

---

## FASE 1: Conexão SSH (VS Code -> Servidor)

1. Instale a extensão **Remote - SSH** no VS Code.
2. Pressione `F1` > digite `Remote-SSH: Open Configuration File` > selecione o primeiro arquivo.
3. Configure seu host no arquivo de configuração, por exemplo:

```
Host NOME_DO_HOST
    HostName IP_DO_SERVIDOR
    User SEU_USUARIO
    Port 22
```

4. Conecte-se clicando no canto inferior esquerdo > *Connect to Host* > `NOME_DO_HOST`.

---

## FASE 2: Instalação das Ferramentas (No Servidor)

### 1) Atualizar e instalar Git (se necessário)
```bash
sudo dnf update -y
sudo dnf install git -y
```

### 2) Instalar Docker (método oficial)
> Observação: o Oracle Linux pode ter conflito com o Podman. Usamos o repositório oficial do Docker CE.

```bash
sudo dnf install -y dnf-utils zip unzip
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Iniciar e habilitar
sudo systemctl start docker
sudo systemctl enable docker

# Adicionar seu usuário ao grupo docker (evita usar sudo sempre)
sudo usermod -aG docker $USER
```

### 3) Instalar kubectl
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

### 4) Instalar kind
```bash
# Detecta arquitetura e baixa a versão correta
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-arm64

chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

---

## FASE 3: Shell e Visual (Zsh + Oh My Zsh + Powerlevel10k)

### 1) Instalar Zsh
```bash
sudo dnf install zsh util-linux-user -y
# Define o Zsh como shell padrão
chsh -s $(which zsh)
```

### 2) Instalar Oh My Zsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 3) Instalar tema Powerlevel10k
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### 4) Baixar plugins de produtividade
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

---

## FASE 4: Configuração Final
Agora vamos configurar o autocomplete do Kubernetes, o alias `k` e o tema.

Abra o arquivo de configuração:

```bash
nano ~/.zshrc
```

- Alteração 1 (Tema): Mude a linha `ZSH_THEME="..."` para:

```bash
ZSH_THEME="powerlevel10k/powerlevel10k"
```

- Alteração 2 (Plugins): Procure a linha `plugins=(...)` e substitua por esta lista:

```bash
plugins=(
  git
  docker
  kubectl
  zsh-autosuggestions
  zsh-syntax-highlighting
)
```

Salve (Ctrl+O, Enter) e saia (Ctrl+X).

Aplique as configurações:

```bash
source ~/.zshrc
```

O assistente do Powerlevel10k (`p10k`) deve iniciar automaticamente; siga as instruções interativas. Se não iniciar, rode:

```bash
p10k configure
```

### Forçar o VS Code a usar o Zsh
No VS Code: abra as configurações (`Ctrl+,`) e busque `terminal.integrated.defaultProfile.linux`. Selecione `zsh`.

---

## Observações finais
- Revise permissões e políticas do servidor antes de instalar pacotes.
- Reinicie o VS Code/terminal se alterações de shell não tiverem efeito imediato.
