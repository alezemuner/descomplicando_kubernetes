# HPA - Horizontal Pod Autoscaler
Escala automaticamente os pods com base em métricas de uso de CPU, memória ou outras métricas personalizadas.

# Instalando o Metric Server
O Metric Server é um componente que coleta métricas de uso de recursos dos pods e nós do cluster. Ele é necessário para que o HPA possa tomar decisões de escalonamento com base nessas métricas.

https://github.com/kubernetes-sigs/metrics-server
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```
# Confirme se o Metric Server está em execução:
```bash
k get pods -n kube-system
```

obs: caso o pod metrics-server-..... ficar 0/1, pode ser necessário adicionar a seguinte configuração para permitir que o Metric Server colete métricas de nós com certificados autoassinados:

kubectl edit deployment metrics-server -n kube-system 
e Adicione a seguinte linha na seção args:
- --kubelet-insecure-tls

k apply -f deployment.yaml
k apply -f loadbalancer.yaml

k get svc

k apply -f primeiro-hpa.yaml
k get hpa

# Locust
Stress testing tool para simular carga em aplicações e verificar o comportamento do HPA.

# Instalação do Locust
```bash
# Cria e ativa a venv
python3 -m venv venv
source venv/bin/activate

deactivate # Para desativar a venv quando terminar

# Instala o Locust
pip install locust
```

# Crie o script locustfile.py
```python
from locust import HttpUser, task, between

class NginxTeste(HttpUser):
    wait_time = between(1, 3)

    @task
    def acessar_pagina_inicial(self):
        self.client.get("/")
```

# Inicie o Locust
```bash
locust -f locustfile.py
```

# Acesse a interface web do Locust
Abra um navegador e vá para http://localhost:8089. Configure o número de usuários simulados e a taxa de spawn, e inicie o teste para gerar carga na aplicação.  

em host: http://nginx.default.svc.cluster.local
http://172.16.44.248:8888

# Observe o número de réplicas aumentando conforme a carga aumenta.
k get deploy nginx-deployment -w 

# ContainerResource com HPA
