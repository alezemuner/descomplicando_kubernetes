StatefulSet é um recurso do Kubernetes usado para gerenciar aplicativos com estado. Diferente dos Deployments, que são usados para aplicativos sem estado, os StatefulSets garantem que cada pod tenha uma identidade única e persistente, o que é crucial para aplicativos que precisam manter dados entre reinicializações.

Cada pod precisa de um PV (Persistent Volume) para armazenar seus dados. O StatefulSet cria e gerencia esses volumes automaticamente, garantindo que cada pod tenha acesso ao seu próprio armazenamento persistente.

Stateless Applications vs Stateful Applications

Stateless Applications são aplicativos que não mantêm estado entre requisições. Eles não precisam de armazenamento persistente e podem ser escalados horizontalmente sem preocupações com dados compartilhados.

Stateful Applications são aplicativos que mantêm estado e precisam de armazenamento persistente. Eles requerem identidades únicas e ordem específica de inicialização e desligamento, o que é garantido pelos StatefulSets.

Headless Service # Uma Headless Service no Kubernetes é um tipo especial de serviço que não atribui um endereço IP para os pods. Em vez disso, ele permite que os clientes se conectem diretamente aos pods usando seus nomes DNS. Isso é especialmente útil para StatefulSets, onde cada pod precisa ser acessível individualmente.

Service é o processo pelo qual os serviços em um cluster Kubernetes encontram e se comunicam uns com os outros. Com uma Headless Service, os pods podem ser descobertos diretamente através de seus nomes DNS, facilitando a comunicação entre eles.
Uma maneira de expor os pods inclusive externamente

Tipos de Service no Kubernetes:
ClusterIP # O ClusterIP é o tipo padrão de serviço no Kubernetes. Ele cria um endereço IP interno para o serviço, permitindo que os pods dentro do cluster se comuniquem entre si. No entanto, o ClusterIP não é acessível externamente ao cluster.

NodePort # O NodePort é um tipo de serviço que expõe o serviço em um número de porta específico em cada nó do cluster. Isso permite que o serviço seja acessado externamente ao cluster através do IP do nó e da porta designada.

LoadBalancer # O LoadBalancer é um tipo de serviço que cria um balanceador de carga externo para distribuir o tráfego entre os pods. Isso é útil para aplicativos que precisam ser acessados externamente e requerem balanceamento de carga.

ExternalName # O ExternalName é um tipo de serviço que mapeia o serviço para um nome DNS externo. Isso permite que os pods dentro do cluster acessem serviços externos usando um nome DNS, sem a necessidade de criar um serviço separado.
