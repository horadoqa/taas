# Fluxo do Prepare

O comando `make prepare` inicializa a configuração do ambiente TAAS.

Ele é responsável por:

- coletar configurações da cloud;
- persistir variáveis no `.config.sh`;
- preparar arquivos Terraform;
- gerar inventários Ansible;
- opcionalmente iniciar a criação da infraestrutura.

## Fluxo

```mermaid
flowchart TD
    A[Usuário executa<br/>make prepare] --> B[Makefile chama<br/>scripts/taas.sh -p]

    B --> C[taas.sh carrega módulos]
    
    C --> D[config/load.sh]
    C --> E[config/wizard.sh]
    C --> F[terraform/configure.sh]

    D --> G{Existe .config.sh?}

    G -->|Sim| H[Pergunta:<br/>Carregar configuração existente?]

    H -->|Sim| I[source .config.sh]
    I --> J[Monta configArray]
    J --> F

    H -->|Não| K[Remove .config.sh]
    K --> E

    G -->|Não| E

    E --> L[Solicita configurações básicas]
    
    L --> M{Cloud escolhida}

    M -->|GCP| N[ask_config_gcp]
    M -->|AWS| O[ask_config_aws]

    N --> P[Coleta dados GCP]
    O --> Q[Coleta dados AWS]

    P --> R[Monta configArray]
    Q --> R

    R --> S[Pergunta:<br/>Salvar configurações?]

    S -->|Sim| T[config/save.sh]
    T --> U[Gera .config.sh]

    S -->|Não| V[Continua execução sem persistir]

    U --> F
    V --> F

    F --> W{Cloud}

    W -->|GCP| X[terraform/gcp.sh]
    W -->|AWS| Y[terraform/aws.sh]

    X --> Z[Copia ambiente-de-exemplo]
    Y --> Z

    Z --> AA[Atualiza terraform.tfvars]

    AA --> AB[Substitui variáveis<br/>###PLACEHOLDER###]

    AB --> AC[Gera inventário Ansible]

    AC --> AD[Exibe terraform.tfvars]

    AD --> AE[Pergunta:<br/>Executar create?]

    AE -->|Sim| AF[make create]
    AE -->|Não| AG[Fim do prepare]

    AF --> AH[ansible/create.sh]
```

### Resumo do fluxo

```text
make prepare
      |
      v
taas.sh -p
      |
      v
Carrega configuração
      |
      +-- existe .config.sh?
      |       |
      |       +-- sim -> reutiliza configuração
      |
      +-- não -> wizard pergunta dados
                    |
                    +-- GCP
                    |     |
                    |     +-- dados de rede, projeto, VM
                    |
                    +-- AWS
                          |
                          +-- dados de VPC, subnet, credenciais

      |
      v
Salva .config.sh (opcional)
      |
      v
Configura Terraform
      |
      +-- cria ambiente
      +-- altera terraform.tfvars
      +-- gera inventário Ansible
      |
      v
Pergunta se cria infraestrutura
```

Eu colocaria essa documentação em algo como:

```text
docs/
└── flows/
    └── prepare-flow.md
```


Esse desenho também ajuda a validar a separação dos arquivos: se um bloco do diagrama não tem um arquivo correspondente, provavelmente ainda existe alguma responsabilidade misturada.

