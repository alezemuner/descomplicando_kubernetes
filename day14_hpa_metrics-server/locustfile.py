from locust import HttpUser, task, between

class NginxTeste(HttpUser):
    wait_time = between(1, 3)

    @task
    def acessar_pagina_inicial(self):
        self.client.get("/")
