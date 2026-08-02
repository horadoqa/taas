if [ "$1" = "setup" ]
    then
        source $CONFIG_FILE
        if [ "$CLOUD" = "gcp" ]
        then
            echo "Executa o ansible na GCP."
            if [ -z "$ANSIBLE_USER" ]
            then
                read -p "Informe o nome do usuário que executará o ansible (ex: usuario_g_globo): " ANSIBLE_USER
                read -p "Informe o repositório no Gitlab com os testes (ex: globoid/globoid-k6.git): " K6_REPO_TEST
                read -p "Informe a branch no Gitlab com os testes (ex: master): " K6_REPO_BRANCH
                read -p "Informe o diretório onde está localizado os testes (ex: k6): " K6_SOURCE_DIR
                echo "export ANSIBLE_USER=$ANSIBLE_USER" >> $CONFIG_FILE
                echo "export K6_REPO_TEST=$GITLAB_URL:$K6_REPO_TEST" >> $CONFIG_FILE
                echo "export K6_REPO_BRANCH=$K6_REPO_BRANCH" >> $CONFIG_FILE
                echo "export K6_SOURCE_DIR=$K6_SOURCE_DIR" >> $CONFIG_FILE
                export K6_REPO_TEST="$GITLAB_URL:$K6_REPO_TEST"
            fi
            cd $ANSIBLE_PATH/playbooks

            if [ "$REGION" = "southamerica-east1" ]
            then
                GCP_PROXY=$PROXY_GCP_SA
            elif  [ "$REGION" = "us-east1" ]
            then
                GCP_PROXY=$PROXY_GCP_E1
            else
                echo "Região da GCP não suportada pelo Proxy da Globo."
                exit 1
            fi
            ansible-playbook setup-enviroment.yaml -u $ANSIBLE_USER -e k6_proxy=$GCP_PROXY -e k6_instances_cloud_provider=gcp -e k6_repo_tests=$K6_REPO_TEST -e k6_repo_branch=$K6_REPO_BRANCH -e k6_tests_path=$K6_SOURCE_DIR -i inventory/gcp.yaml
            echo "Iniciando a subida do Grafana e Prometheus"
            ansible-playbook setup-prometheus.yaml -u $ANSIBLE_USER -e k6_instances_cloud_provider=gcp -i inventory/gcp.yaml
        elif [ "$CLOUD" = "aws" ]
        then
                echo "Executa o ansible na AWS."
                read -p "Informe a localização da chave do EC2 (ex: ~/Downloads/k6-ansible.pem): " ANSIBLE_USER
                read -p "Informe o repositório no Gitlab com os testes (ex: globoid/globoid-k6.git): " K6_REPO_TEST
                read -p "Informe a branch no Gitlab com os testes (ex: master): " K6_REPO_BRANCH
                read -p "Informe o diretorio onde esta localizado os testes (ex: k6): " K6_SOURCE_DIR
                echo "export ANSIBLE_USER=$ANSIBLE_USER" >> $CONFIG_FILE
                echo "export K6_REPO_TEST=$GITLAB_URL:$K6_REPO_TEST" >> $CONFIG_FILE
                echo "export K6_REPO_BRANCH=$K6_REPO_BRANCH" >> $CONFIG_FILE
                echo "export K6_SOURCE_DIR=$K6_SOURCE_DIR" >> $CONFIG_FILE
                export K6_REPO_TEST="$GITLAB_URL:$K6_REPO_TEST"
                cd $ANSIBLE_PATH/playbooks
                ansible-playbook setup-enviroment.yaml --key $ANSIBLE_USER -u ubuntu -e k6_instances_cloud_provider=aws -e k6_repo_tests=$K6_REPO_TEST -e k6_repo_branch=$K6_REPO_BRANCH -e k6_tests_path=$K6_SOURCE_DIR -i inventory/aws_ec2.yaml
        fi
    fi