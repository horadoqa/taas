# Fluxo do Create

O comando `make create` realiza a criação da infraestrutura necessária para execução dos testes K6.

Ele utiliza:

- `.config.sh` para carregar as configurações do ambiente;
- inventários Ansible gerados no `prepare`;
- Terraform para provisionamento dos recursos;
- Ansible para orquestração da criação.

## Fluxo

```mermaid
flowchart TD

    A[Usuário executa<br/>make create] --> B[Makefile chama<br/>scripts/taas.sh -a create]

    B --> C[taas.sh carrega módulos]

    C --> D[ansible/create.sh]

    D --> E{Existe .config.sh?}

    E -->|Não| F[Erro:<br/>Configuração não encontrada]
    F --> G[Fim]

    E -->|Sim| H[source .config.sh]

    H --> I{Cloud configurada}

    I -->|GCP| J[Carrega inventory/gcp.yaml]

    I -->|AWS| K[Carrega inventory/aws_ec2.yaml]


    J --> L[Executa ansible-playbook<br/>create-enviroment.yaml]

    K --> M[Executa ansible-playbook<br/>create-enviroment.yaml]


    L --> N[Ansible chama Terraform GCP]

    M --> O[Ansible chama Terraform AWS]


    N --> P[Terraform init]
    P --> Q[Terraform plan]
    Q --> R[Terraform apply]


    O --> S[Terraform init]
    S --> T[Terraform plan]
    T --> U[Terraform apply]


    R --> V[Recursos GCP criados]

    U --> W[Recursos AWS criados]


    V --> X[Atualiza inventário Ansible]
    W --> X


    X --> Y[Infraestrutura disponível]

    Y --> Z[Fim do create]
````

````

## Resumo do fluxo

```text
make create
      |
      v
scripts/taas.sh -a create
      |
      v
ansible/create.sh
      |
      v
Carrega .config.sh
      |
      +----------------+
      |                |
      v                v
     GCP              AWS
      |                |
      v                v
inventory/gcp.yaml   inventory/aws_ec2.yaml
      |                |
      +----------------+
              |
              v
create-enviroment.yaml
              |
              v
        Terraform
              |
              +-- init
              |
              +-- plan
              |
              +-- apply
              |
              v
Infraestrutura criada
````

## Responsabilidades

| Componente          | Responsabilidade                  |
| ------------------- | --------------------------------- |
| `Makefile`          | Interface do usuário              |
| `taas.sh`           | Dispatcher dos comandos           |
| `ansible/create.sh` | Execução do processo de criação   |
| `.config.sh`        | Dados persistidos do ambiente     |
| `inventory/*.yaml`  | Descoberta dos recursos           |
| Terraform           | Provisionamento da infraestrutura |
| Ansible             | Orquestração da criação           |

Arquivo sugerido:

```text
docs/
└── flows/
    ├── prepare-flow.md
    └── create-flow.md
```

Um detalhe: no código atual o `create` chama diretamente o `ansible-playbook create-enviroment.yaml`, então o diagrama acima representa a arquitetura desejada. Se o Terraform estiver sendo executado dentro desse playbook, está correto; caso contrário, vale ajustar o fluxo para mostrar o ponto exato onde o Terraform é chamado.
