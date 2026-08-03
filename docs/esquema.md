# Esquema do projeto

```bash
.
├── Makefile
├── README.md
├── config.sh
├── docs
│   ├── fluxo.jpg
│   └── grafana
│       └── dashboard_template.json
├── fluxos
│   ├── clean.md
│   ├── cmd.md
│   ├── create.md
│   ├── destroy.md
│   ├── fluxos.md
│   ├── prepare.md
│   ├── run.md
│   ├── update.md
│   └── upload.md
├── infra
│   ├── ansible
│   │   ├── playbooks
│   │   │   ├── ansible.cfg
│   │   │   ├── create-enviroment.yaml
│   │   │   ├── destroy-enviroment.yaml
│   │   │   ├── inventory
│   │   │   │   ├── aws_ec2.yaml
│   │   │   │   ├── aws_ec2_template.yaml
│   │   │   │   └── gcp_template.yaml
│   │   │   ├── performance-tests.yaml
│   │   │   ├── setup-enviroment.yaml
│   │   │   ├── setup-prometheus.yaml
│   │   │   └── update-tests.yaml
│   │   └── roles
│   │       ├── k6
│   │       │   ├── tasks
│   │       │   │   ├── configure_k6.yaml
│   │       │   │   ├── configure_k6_extensions.yaml
│   │       │   │   ├── configure_k6_tests.yaml
│   │       │   │   ├── create_machines.yaml
│   │       │   │   ├── destroy_machines.yaml
│   │       │   │   ├── main.yaml
│   │       │   │   └── run_k6_tests.yaml
│   │       │   └── templates
│   │       │       └── etc
│   │       │           ├── profile.d
│   │       │           │   └── golang.sh.j2
│   │       │           └── sysctl.conf.j2
│   │       └── prometheus
│   │           ├── files
│   │           │   └── var
│   │           │       └── lib
│   │           │           └── grafana
│   │           │               └── grafana.db
│   │           ├── tasks
│   │           │   └── main.yaml
│   │           └── templates
│   │               └── etc
│   │                   ├── prometheus
│   │                   │   └── prometheus.yml.j2
│   │                   └── systemd
│   │                       └── system
│   │                           └── prometheus.service.j2
│   └── terraform
│       ├── aws
│       │   ├── README.md
│       │   ├── ambiente-de-exemplo
│       │   │   ├── main.tf
│       │   │   ├── terraform.tfvars
│       │   │   └── variables.tf
│       │   └── gglobo-taas-k6
│       │       ├── main.tf
│       │       ├── terraform.tfvars
│       │       └── variables.tf
│       └── gcp
│           ├── README.md
│           └── ambiente-de-exemplo
│               ├── main.tf
│               ├── terraform.tfvars
│               └── variables.tf
├── manual.md
└── scripts
    ├── ansible
    │   ├── setup.sh
    │   └── update.sh
    ├── config
    │   ├── config_manager.sh
    │   └── wizard.sh
    ├── k6
    │   ├── cmd.sh
    │   ├── run.sh
    │   └── upload.sh
    ├── lib
    │   ├── config.sh
    │   ├── constants.sh
    │   ├── help.sh
    │   └── utils.sh
    ├── providers
    │   ├── aws.sh
    │   └── gcp.sh
    ├── taas.sh
    ├── terraform
    │   ├── cleanup.sh
    │   ├── configure.sh
    │   ├── create.sh
    │   ├── destroy.sh
    │   ├── infracoast.sh
    │   └── prepare.sh
    └── utils
        └── help.sh

38 directories, 70 files

```