# Cluster Multi-Nodes
Um cluster multi-nodes é um cluster Kubernetes que consiste em vários nós, onde um nó atua como o plano de controle (control plane) e os outros nós atuam como nós de trabalho (worker nodes). O plano de controle é responsável por gerenciar o estado do cluster, enquanto os nós de trabalho são responsáveis por executar as aplicações. A configuração de um cluster multi-nodes envolve a instalação do kubeadm em cada nó, a inicialização do plano de controle e a adição dos nós de trabalho ao cluster usando o comando `kubeadm join`. O kubeadm gera um token de acesso que é usado para autenticar os nós de trabalho ao se juntarem ao cluster. Após a configuração, o cluster multi-nodes pode ser gerenciado usando o kubectl, permitindo a implantação e o gerenciamento de aplicações em todo o cluster.

# Kubeadm
O kubeadm é uma ferramenta que facilita a configuração e o gerenciamento de clusters Kubernetes. Ele é projetado para ser simples de usar e é recomendado para a criação de clusters de produção. O kubeadm automatiza muitas das tarefas necessárias para configurar um cluster Kubernetes, como a geração de certificados, a configuração do plano de controle e a adição de nós ao cluster.

# Kubespray
O kubespray é uma ferramenta de automação de cluster Kubernetes que utiliza Ansible para provisionar e gerenciar clusters Kubernetes em ambientes de nuvem, bare-metal ou virtualizados. Ele oferece uma abordagem flexível e personalizável para a criação e manutenção de clusters Kubernetes, permitindo que os usuários definam suas próprias configurações e opções de implantação. O kubespray suporta uma ampla variedade de provedores de nuvem e sistemas operacionais, tornando-o uma escolha popular para a implantação de clusters Kubernetes em ambientes heterogêneos. Ele também inclui recursos avançados, como suporte para alta disponibilidade, balanceamento de carga e integração com ferramentas de monitoramento e registro.

# Cloud Provider
Um provedor de nuvem é uma empresa que oferece serviços de computação em nuvem,como infraestrutura como serviço (IaaS), plataforma como serviço (PaaS) e software como serviço (SaaS). Exemplos de provedores de nuvem incluem Amazon Web Services (AWS), Microsoft Azure, Google Cloud Platform (GCP) e DigitalOcean. Os provedores de nuvem oferecem uma variedade de serviços, como máquinas virtuais, armazenamento, bancos de dados, redes e serviços de segurança, que podem ser usados para criar e gerenciar clusters Kubernetes. A escolha do provedor de nuvem pode depender de fatores como custo, desempenho, recursos disponíveis e suporte para Kubernetes.

# Cluster Gerenciado
Um cluster gerenciado é um cluster Kubernetes que é provisionado e gerenciado por um provedor de nuvem. O provedor de nuvem é responsável por configurar, manter e atualizar o cluster, permitindo que os usuários se concentrem na implantação e no gerenciamento de suas aplicações. Exemplos de clusters gerenciados incluem Amazon Elastic Kubernetes Service (EKS), Google Kubernetes Engine (GKE) e Azure Kubernetes Service (AKS). Os clusters gerenciados geralmente oferecem recursos adicionais, como integração com outros serviços de nuvem, suporte para alta disponibilidade e escalabilidade automática, além de atualizações regulares para garantir a segurança e o desempenho do cluster. No entanto, os clusters gerenciados podem ter limitações em termos de personalização e controle, e podem ser mais caros do que os clusters não gerenciados, dependendo do uso e dos recursos necessários.

# Cluster Não Gerenciado
Um cluster não gerenciado é um cluster Kubernetes que é provisionado e gerenciado pelo usuário ou pela equipe de operações. O usuário é responsável por configurar, manter e atualizar o cluster, o que pode exigir mais conhecimento técnico e esforço em comparação com um cluster gerenciado. Os clusters não gerenciados oferecem maior flexibilidade e controle sobre a configuração e a personalização do cluster, permitindo que os usuários escolham suas próprias opções de implantação, como o sistema operacional, a rede e os recursos de hardware. No entanto, os clusters não gerenciados podem ser mais difíceis de configurar e manter, especialmente para usuários que não têm experiência prévia com Kubernetes, e podem exigir mais tempo e recursos para garantir a segurança, o desempenho e a disponibilidade do cluster. Exemplos de clusters não gerenciados incluem clusters criados usando kubeadm, kubespray ou outras ferramentas de automação, bem como clusters criados manualmente em ambientes de nuvem ou on-premises.

 
# Recomendações para criar um Cluster
Pelo menos 2GB de RAM por nó (4GB recomendado para produção) 2 CPUs por nó (4 CPUs recomendado para produção) Pelo menos 10GB de espaço em disco por nó (20GB recomendado para produção) Conexão de rede confiável entre os nós do cluster. Configuração de firewall adequada para permitir a comunicação entre os componentes do Kubernetes. Configuração de DNS adequada para resolver os nomes dos serviços e pods dentro do cluster. Configuração de segurança adequada, incluindo autenticação e autorização, para proteger o cluster contra acessos não autorizados. Monitoramento e registro adequados para garantir a visibilidade e a solução de problemas do cluster. Backup regular dos dados do etcd para garantir a recuperação em caso de falhas. Atualizações regulares do Kubernetes e dos componentes do cluster para garantir a segurança e o desempenho do cluster.

# Portas dos componentes do Kubernetes
- API Server: 6443 (HTTPS) - tcp
- etcd: 2379-2380 - tcp
- Kubelet: 10250 - tcp
- Scheduler: 10251 - tcp
- Controller Manager: 10252 - tcp
- Kube Proxy: 10256 - tcp
#recomendado liberar 10250 ate 10259 para o kubelet e outros componentes do cluster
- NodePort: 30000-32767 - tcp

# Plugin de rede (CNI - Container Network Interface)
O plugin de rede é um componente essencial em um cluster Kubernetes, responsável por fornecer conectividade de rede entre os pods e os serviços dentro do cluster. Ele implementa a especificação de rede do Kubernetes, permitindo que os pods se comuniquem entre si e com o mundo externo. Existem vários plugins de rede disponíveis para Kubernetes, cada um com suas próprias características e funcionalidades. Alguns dos plugins de rede mais populares incluem Calico, Flannel, Weave Net e Cilium. A escolha do plugin de rede pode depender de fatores como desempenho, escalabilidade, segurança e compatibilidade com o ambiente de implantação. O plugin de rede é configurado durante a criação do cluster e pode ser atualizado ou alterado posteriormente, se necessário. É importante escolher um plugin de rede que atenda às necessidades do seu cluster e que seja compatível com os outros componentes do Kubernetes para garantir uma comunicação eficiente e segura entre os pods e os serviços.

# TABELA COMPARATIVA DE PLUGINS DE REDE (CNI)
| Plugin de Rede | Descrição | Vantagens | Desvantagens |
|----------------|-----------|-----------|--------------|
| Calico         | Um plugin de rede baseado em roteamento que oferece alta performance e segurança. | - Alta performance<br>- Suporte a políticas de rede avançadas<br>- Compatível com ambientes on-premises e em nuvem | - Configuração mais complexa<br>- Pode ser mais difícil de depurar |
| Flannel         | Um plugin de rede simples que utiliza VXLAN para fornecer conectividade entre os pods. | - Fácil de configurar<br>- Boa performance para clusters pequenos<br>- Compatível com ambientes on-premises e em nuvem | - Pode ter problemas de performance em clusters grandes<br>- Não suporta políticas de rede avançadas |
| Weave Net       | Um plugin de rede que utiliza uma abordagem de malha para fornecer conectividade entre os pods. | - Fácil de configurar<br>- Boa performance para clusters pequenos e médios<br>- Suporte a políticas de rede avançadas | - Pode ter problemas de performance em clusters grandes<br>- Pode ser mais difícil de depurar |
| Cilium          | Um plugin de rede baseado em eBPF que oferece alta performance e segurança. | - Alta performance<br>- Suporte a políticas de rede avançadas<br>- Compatível com ambientes on-premises e em nuvem | - Configuração mais complexa<br>- Pode ser mais difícil de depurar |
