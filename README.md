# 1. Atividade Avaliativa – Deploy de Aplicação em Kubernetes
Esta atividade visa compreender e praticar como utilizar os principais componentes do kubernetes para realizar o deploy de uma aplicação que contém Backend, Frontend e armazenamento persistente em um banco de dados.

## 1.2 Alunos

- Edvan da Silva Oliveira - 20222380011
- Nelson Tulio de Menezes Lima - 20231380023

[Pular para a solução](#solucao)

## 1.1 Objetivo
Desafiar os alunos a realizar o deploy completo de uma aplicação fullstack (React + Flask + PostgreSQL) em um cluster Kubernetes, garantindo:

- Alta disponibilidade;
- Parâmetros de aplicação via ConfigMap e Secrets;
- Persistência de dados do banco;
- Comunicação via IngressController NGINX.

## 1.2 Tecnologias envolvidas
Kubernetes (Kind)
- **Frontend:**	Deployment + Service (ClusterIP)
- **Backend:**	Deployment + Service (ClusterIP)
- **PostgreSQL:**	StatefulSet + Service (ClusterIP) + PVC
- **Ingress:**	Ingress + IngressClass (nginx)
- **Configuração:**	ConfigMap para vars dos containers
- **Armazenamento:** PVC (PersistentVolumeClaim)
- **Segurança:** Secrets para credenciais do banco

## 1.3 Descrição da Aplicação
A aplicação consiste em:
- Frontend (React): consumindo a API via variável de ambiente.
- Backend (Flask): expõe endpoints REST (GET e POST) para mensagens.
- Banco de dados PostgreSQL: para persistência de mensagens.

![alt text](assets/image.png)

## 1.4 Requisitos de Configuração 

### 1.4.1. Deploy em Kubernetes
- Utilize `Deployment` para os pods do **frontend e backend**, garantindo réplicas para alta disponibilidade (mínimo de 2 réplicas).
- Utilize `StatefulSet` para o PostgreSQL.
- Garanta que os pods da aplicação fiquem em um **namespace específico** e o banco de dados em **outro namespace**.

> **Desafio**: Usar [PostgreSQL HA com Patroni ou Helm chart] para deploy (mais avançado).

### 1.4.2. Ingress Controller
- Configure o acesso externo à aplicação via NGINX IngressController.
- Os endpoints devem ser acessíveis por caminhos como:
```text
http://<domínio ou IP>/  → frontend
http://<domínio ou IP>/api/ → backend
```
> **Desafio**: Configurar certificados TLS no Ingress que podem ser integrados via cert-manager

### 1.4.3. Volumes Persistentes
- O banco de dados deve utilizar um PersistentVolumeClaim.
- Deve ser possível reiniciar o cluster sem perda de dados.

### 1.4.4. ConfigMap e Secrets
As seguintes variáveis devem vir de um **ConfigMap**:

- Para o backend Flask:
    - DB_HOST
    - DB_PORT
    - DB_NAME
    - API_HOST
    - API_PORT

- Para o frontend React:
    - VITE_API_URL

E como **Secret**, devem vir:
- Para o backend Flask:
    - DB_USER
    - DB_PASSWORD

- Para o banco Postgres:
    - POSTGRES_USER
    - POSTGRES_PASSWORD
    - POSTGRES_DB


## 1.5 Resumo dos Requisitos
| Recurso |	Detalhes|
|--|--|
|Backend Flask|	Deployment com 2+ réplicas, Service tipo ClusterIP|
|Frontend React| Deployment com 2+ réplicas, Service tipo ClusterIP|
|Banco PostgreSQL| Deployment ou StatefulSet com PVC|
|Configuração| ConfigMap com variáveis da aplicação|
|Senhas/usuários| Secret com DB_USER e DB_PASSWORD|
|Comunicação externa| IngressController nginx com regras / e /api|
|Volume Persistente| PVC para dados do PostgreSQL|
|Alta disponibilidade| Réplicas mínimas para frontend/backend|

# 2. O que deve ser entregue (Entregáveis do Projeto)

Cada grupo deve entregar os seguintes artefatos organizados em um repositório no github:

```plaintext
projeto-k8s-deploy/
├── README.md                        # Instruções de execução
├── frontend/
│   └── deployment.yaml              # Deployment + Service do React
├── backend/
│   ├── deployment.yaml              # Deployment + Service do Flask
│   └── configmap.yaml               # ConfigMap com variáveis de ambiente
├── database/
│   ├── statefulset.yaml             # StatefulSet ou Deployment do PostgreSQL
│   ├── pvc.yaml                     # PVC para volume persistente
│   └── secret.yaml                  # Secret com credenciais
├── ingress/
│   └── ingress.yaml                 # Regras de Ingress para acesso externo
└── namespace.yaml
```
Também devem utilizar o `dockerhub` com repositório **público** para armazenar as imagens da aplicação de frontend e backend que serão utilizados nos PODs do kubernetes.

## 2.1 Funcionalidades obrigatórias

1. Deploy completo da aplicação (frontend + backend + banco de dados)
2. Uso correto de ConfigMap e Secret para configurar variáveis da aplicação
3. IngressController configurado para expor o frontend e backend via rota /api/
4. Volume persistente para PostgreSQL, com PVC separado
5. Alta disponibilidade com pelo menos 2 réplicas para frontend e backend
6. Aplicação funcional após o deploy (acessível no browser e armazenando dados)

## 2.3 Instruções no README.md
O README.md deve conter:
- Integrantes da equipe
- Objetivo do projeto
- Passos para aplicar os arquivos (kubectl apply)
- Endereço de acesso esperado via Ingress (ex: http://localhost ou domínio simulado)
- Descrição breve da arquitetura

## 2.4 Critérios de Avaliação (Pontuação)
Serão realiza perguntas em cima dos seguintes temas e verificado o funcionamento correto do deploy da aplicação:

| Critério | Pontuação |
| --- |  --- |
| Deploy funcional de todos os componentes |  \_\_\_ / 30 |
| Uso correto de ConfigMap e Secret | \_\_\_ / 15 |
| Configuração adequada do IngressController |  \_\_\_ / 15 |
| Volume persistente para o PostgreSQL |  \_\_\_ / 15 |
| Alta disponibilidade (réplicas ≥ 2 frontend/backend) | \_\_\_ / 1,0 |
| Documentação (README claro e funcional) | \_\_\_ / 10 |
| Organização, boas práticas e clareza dos arquivos | \_\_\_ / 05 |
| Bonus: readiness/liveness probes, tls, ... | \_\_\_ / 10 |

Nota máxima: 100,0 pontos

Bonus: até 10 adicional

# 3. Dicas para os Alunos
- Testem localmente com **Docker Compose** antes de subir para o Kubernetes.
- Usem **kubectl port-forward** para testar backend e frontend separadamente.
- Documentem tudo com prints e comandos. Simples e direto.

# 4. Solução
<a name="solucao"></a>

Essa atividade foi feita considerando o que o cluster estará rodando no kind
com a mesma configuração exemplificada no material na parte de liberar o
IngressController.

```yaml
# kind-config.yaml

kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    extraPortMappings:
      - containerPort: 80
        hostPort: 7080
        protocol: TCP
      - containerPort: 443
        hostPort: 7443
        protocol: TCP
```

Como é possível observar, o kind faz um mapeamento de portas (NAT) direcionando
o tráfego da porta 7080 do host para a porta 80 do nó do cluster. O mesmo 
ocorre com a porta 7443 → 443. Nossa dupla optou por manter exatamente essa 
configuração para garantir consistência com a configuração usada em sala de aula.
Por esse motivo, não expomos a porta 5000 do backend, optando por não reproduzir
o comportamento do docker-compose fornecido na atividade.

Com essa configuração, todo o acesso externo ocorre exclusivamente por
``localhost:7080``, e não por portas individuais de cada serviço. Dentro do
cluster, o IngressController NGINX está configurado para escutar a porta 80 e
realizar o proxy reverso baseado no path:

- o backend recebe as requisições enviadas para ``/api``,
- o frontend responde às requisições feitas em ``/``.

Essa contextualização é importante porque a porta exposta pelo kind determina o
valor correto da variável VITE_API_URL. Em um cluster Kubernetes convencional,
a aplicação seria acessada diretamente pela porta 80, porém, no kind, o
navegador deve chamar o backend por meio da porta 7080, que é a porta realmente
exposta para o usuário final.

O nome de domínio definido para a aplicação é “localhost”. Isso evita que o
avaliador precise editar o arquivo ``/etc/hosts`` e dispensa a necessidade de
configuração de DNS fora do cluster.

# Instruções

## 1. Criar o cluster:

```bash
kind create cluster --config=projeto-k8s-deploy/kind-config.yaml
```

## 2. Criar kubeconfig:

```bash
mkdir -p ~/.kube
kind get kubeconfig > ~/.kube/config
```

## 3. Instalar o ingressController NGINX

```bash
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
```

## 4. Criar namespace

```bash
kubectl apply -f projeto-k8s-deploy/namespace.yaml
```

## 5. Deploy

```bash
kubectl apply -f projeto-k8s-deploy -R
```

## 6. Acessando a aplicação

Após uns 2 minutos, que é o tempo que leva para a criação do statefulset
``db-0``, é possível acessar a aplicação pelo endereço
[http://localhost:7080](http://localhost:7080)
