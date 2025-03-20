# Provisionar Ambiente na AWS

1. Configurar nome para [VPC e sub-rede padrão](https://docs.aws.amazon.com/pt_br/vpc/latest/userguide/default-vpc.html).


2. Para criar os recursos na cloud da Amazon, crie um usuário de serviço com a seguinte role:

```
AmazonEC2FullAccess
```
Armazene a access_key e secret_key.

3. Definir valores da infraestrutura nos arquivos `aws_ec2.yaml` e `terraform.tfvars` criados em sub-diretórios no `infra/ansible/playbooks/inventory` e `infra/terraform/aws/<nome do projeto>` respectivamente.

4. Criar um [par de chaves](https://docs.aws.amazon.com/pt_br/AWSEC2/latest/UserGuide/ec2-key-pairs.html) para acessar as máquinas via SSH
Obs: Forçar `.pem` na hora do download da chave

Após fazer o download do seu par de chave, defina as variáveis de ambiente `EC2_SSH_KEY_PATH` com seu o path.

5. Configurar AWS CLI com a access_key e secret_key
```
$ aws configure
```
