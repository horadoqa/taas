# TAAS K6

Ferramenta de teste de carga que utiliza a versão em código aberto do [K6](https://k6.io)

## Motivação

- Disponibilizar aos times de desenvolvimento um serviço que provisiona o ambiente para execução de testes de performance.

- O `k6` é uma ferramenta de teste de carga de código aberto criada para tornar o teste de carga uma prática fácil. Ao usá-lo, você poderá detectar a regressão e os problemas de desempenho mais cedo, permitindo que você crie sistemas resilientes e aplicativos robustos. 

Os principais recursos incluem:
- Ferramenta CLI
- Scripts em JavaScript
- Possibilidade de teste de carga automático

Os usuários do k6 geralmente são desenvolvedores, engenheiros de QA e DevOps. Eles usam o k6 para testar o desempenho de APIs, microsserviços e sites. Os casos de uso comuns do k6 são:

- Teste de carga: Projetado para executar testes com alta carga em ambientes de pré-produção e controle de qualidade.
- A menos que você precise de mais de 100.000 a 300.000 solicitações por segundo (6 a 12 milhões de solicitações por minuto), uma única instância do k6 provavelmente será suficiente para suas necessidades. [Executando testes grandes](https://k6.io/docs/testing-guides/running-large-tests/)
- Monitoramento: você pode executar testes com uma pequena quantidade de carga para monitorar continuamente o desempenho do seu ambiente de produção.

[Options reference](https://k6.io/docs/using-k6/k6-options/reference/)
- Duration
- Iterations
- Max redirects
- No connection reuse
- No cookies reset
- No summary
- No VU connection reuse
- Setup timeout
- Stages
- Summary export

## Pré-requisitos
____

## 1 - Ter um projeto no GCP

Caso não tenha:

- Efetuar a solicitação de criação pelo [Globo Service](https://globoservice.service-now.com/globoservice/)

Procure por:

- Administração do GCP - Google Cloud Platform

- Criação de novo projeto no GCP

## 2 - Ter uma subnet

Caso não tenha:

- Procurar por "Administração de subnet no GCP - Google Cloud Platform " no [Globo Service](https://globoservice.service-now.com/globoservice/)

## 3 - Instalar a CLI gcloud

- [GCP](https://cloud.google.com/sdk/docs/install)

- [BREW](https://formulae.brew.sh/cask/google-cloud-sdk)

- [Infra GLobo](https://infra.globoi.com/omnicloud/gcp/acesso_ssh/)

### Configurar o Login e efetuar a cota do projeto:
        $ gcloud auth application-default login && gcloud auth application-default set-quota-project ${PROJECT_ID}

### Fazer o Login
        $ gcloud auth login
        $ gcloud config set project PROJECT_ID

### Acessar as instâncias do GCP via SSH:

Faça o procedimento para acessar [suas instâncias via SSH.](https://infra.globoi.com/omnicloud/gcp/acesso_ssh/)

        $ gcloud compute os-login ssh-keys add --key-file=/home/user/.ssh/id_rsa.pub

### Provisionar infraestrutura

Preparar configuração para ambiente dentro de um provedor de cloud:

- [Configuração para provisionar ambiente na GCP ambiente](https://gitlab.globoi.com/devops/k6tt/-/tree/master/infra/terraform/gcp/README.md).

Para criar os recursos na cloud do Google, crie uma Service Account com os seguintes roles:
| Title | ID |
| :--- | :--- |
| Compute Instance Admin | roles/compute.instanceAdmin |
| Compute Network Viewer | roles/compute.networkViewer |
| Service Networking Service Agent | roles/servicenetworking.serviceAgent |
| Service Account User | roles/iam.serviceAccountUser |

A chave de sua Service Account será necessária para a subida do TAAS.

- [Configuração para provisionar ambiente na AWS ambiente](https://gitlab.globoi.com/devops/k6tt/-/tree/master/infra/terraform/aws/README.md).

`Obs:` Em casos de testes em produção será necessário entrar em contato com o time de SupSeg para a liberação do endereço público.

## 4 - Instalar Terraform

- [Versão => 1.0](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

`Obs:`Para mais informações relacionadas ao Terraform, favor acesse [Wiki](https://docs.devops.globoi.com/ferramentas/terraform/providers.html).

## 5 - Instalar Ansible

- [Versão => 2.11.6](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## 6 - Solicitar acesso ao projeto que executará o teste.

- [Acessos](https://acesso.g.globo/home.jsf)

- [Portal Azure](https://aad.portal.azure.com/)

## 7 - Liberar os seguintes acessos no [proxy]( https://libera3.globoi.com/gproxy/request/create)

![Proxy](docs/proxy.png?raw=true)

### copy/paste
sum.golang.org
proxy.golang.org
golang.org
jslib.k6.io
github.com
go.k6.io

## 8 - Liberação de ACL

[LIBERA3](https://libera3.globoi.com) - Plataforma para liberação de ACL.

Liberar acesso do Service Account do projeto para o IP do host de destino que será testado.

![acl](docs/acl.png?raw=true)

`OBS:` Caso não seja realizado este passo o k6 retornará o aviso de `TIMEOUT`.

## DevFinOps

- Por uma questão de organização dos recursos financeiros dos times, sugerimos que o TAAS seja implementado dentro do projeto do time que realizará o teste.## DevFinOps

- Por uma questão de organização dos recursos financeiros dos times, sugerimos que o TAAS seja implementado dentro do projeto do time que realizará o teste.

## Fork do Projeto

- O TAAS deve ser utilizado como um boilerplate pelos times interessados. Recomendamos que seja feito um fork e que seja configurado com base nas configuração de ambiente do projeto que será testado.

## Setup

O TAAS foi desenvolvido para ser executado para Multicloud, mas recomendamos fortemente que o projeto seja utilizado no GCP "DEVFINOPS". Você deve criar os [scripts com os cenários de teste](https://k6.io/docs/) e armazená-los em um repositório no [GitLab](https://gitlab.globoi.com). É recomendável começar com um pequeno número de usuários virtuais e, em seguida, aumentar gradualmente a carga do normal para o pico.

## Fluxo dos comandos

![K6 Template Workflow](docs/fluxo.jpg?raw=true)

## Comandos

Por meio do `make help` é possível acessar os comandos disponíveis

        ------------
        TAAS - K6
        ------------

        $ make clean: Realiza a limpeza do ambiente local.
        $ make cmd: Executa um comando ad hoc.
        $ make create: Cria os ambientes para execução.
        $ make destroy: Remove ambiente do TAAS.
        $ make help: Exibe os comandos disponíveis.
        $ make infracost: Verifica o custo do teste.
        $ make prepare: Configura o ambiente do TAAS.
        $ make setup: Configura os ambientes para execução.
        $ make update: Atualiza as informações modificadas para preparação do ambiente.
        $ make upload: Realiza o upload dos resultados para o report.

1. Configura o ambiente do TAAS e guarda as informações no arquivo: `.config.sh`.

        make prepare

2. Execute o comando para provisionar e configurar o serviço, baseado nas informações colhidas no `make prepare`.

        make create

3. Configurar os ambientes para execução:

        make setup

`OBS.:` A execução do teste poderá ser acompanhada em realtime pelo Grafana que recebe os dados do Prometheus do próprio TAAS ou pelo Grafana do projeto que está sendo testado.

4. Executa um comando ad hoc.

        make cmd

5. Realizar o upload dos resultados para o [report](https://report.apps.tsuru.gcp.i.globo/k6).

        make upload

6. Caso precise modificar algo no projeto, script de algum teste por exemplo, execute o `make update`.

        make uptade

7. Para destruir a infraestrutura do teste, execute o comando abaixo:

        make destroy

8. Realizar a limpeza do ambiente local, removerá o arquivo `.config.sh`:

        make clean

## Nosso canal

SLACK `=>` #TAAS-K6
