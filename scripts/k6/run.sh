if [ "$1" = "run" ]
    then
        source $CONFIG_FILE
        if [ "$CLOUD" = "gcp" ]
        then
            echo "Executa o ansible na GCP para Bateria de testes"
            read -p "Informe se a configuação esta presente no teste (ex: VUs, Duracao) (s/n): " K6_CONFIG_TEST
            if [ "$K6_CONFIG_TEST" = "s" ]
            then
                read -p "Informe os cenários de execução (ex: healtcheck.js,login.js): " K6_CENARIOS
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
                ansible-playbook performance-tests.yaml -u $ANSIBLE_USER -e k6_proxy=$GCP_PROXY -e k6_script_config=true -e k6_execution_tests=$K6_CENARIOS -i inventory/gcp.yaml
            else
                read -p "Informe a quantidade de VUs na execução do teste (ex: 1): " K6_VUS
                read -p "Informe a dureção do teste (ex: 5m): " K6_DURATION
                read -p "Informe os cenários de execução (ex: healtcheck.js,login.js): " K6_CENARIOS
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
                ansible-playbook performance-tests.yaml -u $ANSIBLE_USER -e k6_proxy=$GCP_PROXY -e k6_vus=$K6_VUS -e k6_duration=$K6_DURATION -e k6_execution_tests=$K6_CENARIOS -i inventory/gcp.yaml
            fi
        elif [ "$CLOUD" = "aws" ]
        then
            echo "Executa o ansible na AWS para Bateria de testes"
            read -p "Informe se a configuação esta presente no teste (ex: VUs, Duracao) (s/n): " K6_CONFIG_TEST
            if [ "$K6_CONFIG_TEST" = "s" ]
            then
                read -p "Informe os cenários de execucao (ex: healtcheck.js,login.js): " K6_CENARIOS
                cd $ANSIBLE_PATH/playbooks
                ansible-playbook performance-tests.yaml --key $ANSIBLE_USER -u ubuntu -e k6_script_config=true -e k6_execution_tests=$K6_CENARIOS -i inventory/aws_ec2.yaml
            else
                read -p "Informe a quantidade de VUs na execução do teste (ex: 1): " K6_VUS
                read -p "Informe a duração do teste (ex: 5m): " K6_DURATION
                read -p "Informe os cenários de execução (ex: healtcheck.js,login.js): " K6_CENARIOS
                cd $ANSIBLE_PATH/playbooks
                ansible-playbook performance-tests.yaml --key $ANSIBLE_USER -u ubuntu -e k6_vus=$K6_VUS -e k6_duration=$K6_DURATION -e k6_execution_tests=$K6_CENARIOS -i inventory/aws_ec2.yaml
            fi
        fi
    fi