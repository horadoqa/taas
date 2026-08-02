# Fluxo do Destroy

O comando `make destroy` remove a infraestrutura criada pelo TAAS.

Ele utiliza:

- `.config.sh` para identificar a cloud e o ambiente;
- inventários Ansible existentes;
- Ansible para executar a rotina de destruição;
- Terraform para remover os recursos provisionados.

## Fluxo

```mermaid
flowchart TD

    A[Usuário executa<br/>make destroy] --> B[Makefile chama<br/>scripts/taas.sh -a destroy]

    B --> C[taas.sh carrega módulos]

    C --> D[ansible/destroy.sh]

    D --> E{Existe .config.sh?}

    E -->|Não| F[Erro:<br/>Configuração não encontrada]
    F --> G[Fim]

    E -->|Sim| H[source .config.sh]

    H --> I{Cloud configurada}

    I -->|GCP| J[Carrega inventory/gcp.yaml]

    I -->|AWS| K[Carrega inventory/aws_ec2.yaml]


    J --> L[Executa ansible-playbook<br/>destroy-enviroment.yaml]

    K --> M[Executa ansible-playbook<br/>destroy-enviroment.yaml]


    L --> N[Ansible executa Terraform Destroy GCP]

    M --> O[Ansible executa Terraform Destroy AWS]


    N --> P[Terraform init]

    P --> Q[Terraform destroy]

    Q --> R[Remove recursos GCP]


    O --> S[Terraform init]

    S --> T[Terraform destroy]

    T --> U[Remove recursos AWS]


    R --> V[Limpeza de arquivos temporários]

    U --> V


    V --> W[Remove arquivos temporários<br/>/tmp/k6*]

    W --> X[Fim do destroy]
```

## Resumo do fluxo

```text
make destroy
      |
      v
scripts/taas.sh -a destroy
      |
      v
ansible/destroy.sh
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
destroy-enviroment.yaml
              |
              v
        Terraform
              |
              +-- init
              |
              +-- destroy
              |
              v
Infraestrutura removida
              |
              v
Limpeza de temporários
````

## Responsabilidades

| Componente           | Responsabilidade                  |
| -------------------- | --------------------------------- |
| `Makefile`           | Interface para executar o destroy |
| `taas.sh`            | Encaminha o comando               |
| `ansible/destroy.sh` | Executa a rotina de remoção       |
| `.config.sh`         | Identifica ambiente e cloud       |
| `inventory/*.yaml`   | Define os recursos alvo           |
| Terraform            | Remove os recursos provisionados  |
| Ansible              | Orquestra a execução              |

Estrutura da documentação:

```text
docs/
└── flows/
    ├── prepare-flow.md
    ├── create-flow.md
    └── destroy-flow.md
```

Uma observação: no seu código atual existe um `rm -rf /tmp/k6*` no final da função `ansible_func()`. Eu manteria isso documentado como **limpeza pós-destroy**, mas futuramente separaria para um comando próprio (`clean`) para evitar que uma falha parcial do destroy apague artefatos de diagnóstico.
