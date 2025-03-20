# Provisionar Ambiente na GCP

1. Criar subnet no GCP por meio de [chamado no Service Now](https://globoservice.service-now.com/nav_to.do?uri=%2Fcom.glideapp.servicecatalog_cat_item_view.do%3Fv%3D1%26sysparm_id%3D5fc2c9731b16ac10a34ea6cae54bcb69%26sysparm_link_parent%3Db0ad86c31b56a410a34ea6cae54bcb86%26sysparm_catalog%3D6ee2487cdba344105c1163901496194f%26sysparm_catalog_view%3Dcatalog_default%26sysparm_view%3Dtext_search).

2. Definir valores da infraestrutura nos arquivos `gcp.yaml` e `terraform.tfvars` criados em sub-diretórios no `infra/ansible/playbooks/inventory` e `infra/terraform/gcp/<nome do projeto>` respectivamente.

3. Para criar os recursos na cloud do Google, crie uma Service Account com os seguintes roles:

| Title | ID |
|----|----|
| Compute Instance Admin | roles/compute.instanceAdmin |
| Compute Network Viewer | roles/compute.networkViewer |
| Service Networking Service Agent | roles/servicenetworking.serviceAgent |
| Service Account User | roles/iam.serviceAccountUser |

Após fazer o download da chave de sua Service Account, defina as variáveis de ambiente `GOOGLE_APPLICATION_CREDENTIALS` e `GCP_SERVICE_ACCOUNT_FILE` com seu o path.

4. Faça o procedimento para [acessar suas instâncias via SSH](https://infra.globoi.com/omnicloud/gcp/acesso_ssh/).

5. Liberar acesso [via proxy](https://libera3.globoi.com/gproxy/request/create) e [acesso interno](https://libera3.globoi.com/gcp/access/create) para os repositórios auxiliares:
- Proxy

```
.golang.org
proxy.golang.org
jslib.k6.io
github.com
go.k6.io
```

- Acesso Interno

```
10.143.244.198/32
```
