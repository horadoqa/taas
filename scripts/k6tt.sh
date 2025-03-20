#!/bin/sh

# Script que realiza as configuracoes do ambiente do K6tt na GCP e AWS.

TERRAFORM_PATH="infra/terraform"
ANSIBLE_PATH="infra/ansible"
CONFIG_FILE=".config.sh"
PROXY_GCP_SA="http://proxy-sa-e1.gcp.i.globo:3128"
PROXY_GCP_E1="http://proxy-us-e1.gcp.i.globo:3128"
NO_PROXY_HOSTS="localhost,127.0.0.1,10.,.globoi.com,i.s3.glbimg.com,.googleapis.com,.apps.g.globo,.apps.tsuru.dev.gcp.i.globo,.globo.com,.apps.tsuru.gcp.i.globo"
GITLAB_URL="gitlab@gitlab.globoi.com"
K6_PREFFIX="/tmp/k6_results"
K6_TEMP="k6-temp"
K6_SCRIPTS="/tmp/k6-performance-tests/"
K6_CMD_COMMOM="/usr/local/sbin/k6"
K6_SUMMARY="--summary-export /tmp/k6_results"
REPORT_URL="https://qacreport-api.sre.hdg.hub.gcp.i.globo/k6tt"
INFRACOST_CREDENTIALS="$HOME/.config/infracost/credentials.yml"
LOG_DIR="logs"
CMD_COMMON="sudo -u root bash -c 'cd ${K6_SCRIPTS} ; export NO_PROXY=\"${NO_PROXY_HOSTS}\" ; "

#Funcao que gera as perguntas para iniciar o projeto.
ask_config(){
    read -p "Informe a Cloud a ser utilizada (gcp/aws): " CLOUD
    read -p "Informe o ambiente da exeucao: (dev/qa/prod): " ENVIRONMENT
    read -p "Informe o número de instancias do K6 (ex: 1): " NUMBER_INSTANCES
    read -p "Informe a área (ex: GloboID): " REPORT_AREA
    read -p "Informe o projeto (ex: Glive): " REPORT_PROJECT

    if [ "$CLOUD" = "gcp" ]
    then
        ask_config_gcp
    elif [ "$CLOUD" = "aws" ]
    then
        ask_config_aws
    else
        "Cloud ainda não suportada."
        exit 1
    fi

    read -p "Deseja salvar as configuracoes (s/n) : " SAVE

    configArray=("CLOUD=$CLOUD" "ENVIRONMENT=$ENVIRONMENT" "NUMBER_INSTANCES=$NUMBER_INSTANCES" "REPORT_AREA=$REPORT_AREA" "REPORT_PROJECT=$REPORT_PROJECT"   
                "NETWORK_NAME=$NETWORK_NAME" "NETWORK_PROJECT_ID=$NETWORK_PROJECT_ID" "SUBNETWORK_NAME=$SUBNETWORK_NAME" "EXTERNAL_NETWORK=$EXTERNAL_NETWORK" "PROVISIONING_MODEL=$PROVISIONING_MODEL" "REGION=$REGION" "ZONE=$ZONE" "MACHINE_TYPE=$MACHINE_TYPE" "PROJECT_ID=$PROJECT_ID"
                "MANAGED_ZONE=$PROJECT_ID" "SERVICE_ACCOUNT=$SERVICE_ACCOUNT" "GCP_SERVICE_ACCOUNT_FILE"=$GCP_SERVICE_ACCOUNT_FILE "AWS_ACCESS_KEY"=$AWS_ACCESS_KEY "AWS_SECRET_KEY"=$AWS_SECRET_KEY)
}

ask_config_gcp(){
    read -p "Informe o nome da rede (ex: vpc-hdg-prod): " NETWORK_NAME
    read -p "Informe o nome o id da rede (ex: gglobo-network-hdg-spk-prod): " NETWORK_PROJECT_ID
    read -p "Informe o nome da subrede (ex: sb-k6-qa-sa-e1-hdg-prd): " SUBNETWORK_NAME
    read -p "Informe se sera utilizado ip publico (s/n): " EXTERNAL_NETWORK
    read -p "Informe se sera utilizado vms spot (s/n): " PROVISIONING_MODEL
    read -p "Informe o nome da região (ex: southamerica-east1): " REGION
    read -p "Informe o nome da zona (ex: southamerica-east1-a): " ZONE
    read -p "Informa o modelo de máquina (ex: e2-standard-4): " MACHINE_TYPE
    read -p "Informe o id do projeto (ex: gglobo-k6-qa-hdg-prd): " PROJECT_ID
    read -p "Informe o nome a Service Account (ex: sa-k6-qa@gglobo-k6-qa-hdg-prd.iam.gserviceaccount.com): " SERVICE_ACCOUNT
    read -p "Informe a localização da chave da Service Account ( ex: ~/Downloads/gglobo-k6-qa-hdg-prd-0d884a3c3c93.json)": GCP_SERVICE_ACCOUNT_FILE
}

ask_config_aws(){
    read -p "Informe o aws aws access key: " AWS_ACCESS_KEY
    read -p "Informe o aws aws secret key: " AWS_SECRET_KEY
    read -p "Informe o nome da rede (ex: VPC_CORP): " NETWORK_NAME
    read -p "Informe o nome da subrede (ex: Private_B_CORP): " SUBNETWORK_NAME
    read -p "Informe o nome da regiao (ex: us-east-1): " REGION
    read -p "Informe o nome da zona (ex: us-east-1-a): " ZONE
    read -p "Informa o modelo de máquina (ex: t2.xlarge): " MACHINE_TYPE
    read -p "Informe o nome do projeto (ex: gglobo-taas-k6): " PROJECT_ID
    read -p "Informe o nome a Service Account (ex: k6-qa): " SERVICE_ACCOUNT
}

#Funcao que realiza a configuracao do ambiente.
configure(){
    read_config

    if [ "$CLOUD" = "gcp" ]
    then
        configure_gcp
    elif [ "$CLOUD" = "aws" ]
    then
        configure_aws
    else
        echo "Cloud não suportada."
    fi

    if [ "$SAVE" = "s" ]
    then
        for i in "${configArray[@]}"
        do
            echo "export $i" >> $CONFIG_FILE
        done
        if [ "$RUN_ANSIBLE" = "s" ]
        then
            make create
        fi
    fi
}

#Configura o ambiente se for GCP.
configure_gcp(){
    TERRAFORM_PATH="$TERRAFORM_PATH/$CLOUD"
    
    if [ ! -d "$TERRAFORM_PATH/$PROJECT_ID" ]
    then
        echo "Cria o diretório no terraform com base no modelo."
        cp -R $TERRAFORM_PATH/ambiente-de-exemplo $TERRAFORM_PATH/$PROJECT_ID
    else
        rm $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars
        cp -R $TERRAFORM_PATH/ambiente-de-exemplo/terraform.tfvars $TERRAFORM_PATH/$PROJECT_ID
    fi

    if [ "$EXTERNAL_NETWORK" = "s" ]
        then
            sed "s/###//g" $TERRAFORM_PATH/$PROJECT_ID/main.tf > $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp
            mv  $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp $TERRAFORM_PATH/$PROJECT_ID/main.tf
    fi


    for i in "${configArray[@]}"
    do
        KEY=`echo $i | cut -d "=" -f1 | tr -d "\n"`
        VALUE=`echo $i | cut -d "=" -f2 | tr -d "\n"`

        if [ "$KEY" = "PROJECT_ID" ]
        then
            sed "s/###$KEY###/$VALUE/g" $ANSIBLE_PATH/playbooks/inventory/gcp_template.yaml > $ANSIBLE_PATH/playbooks/inventory/gcp.yaml.tmp
            mv $ANSIBLE_PATH/playbooks/inventory/gcp.yaml.tmp $ANSIBLE_PATH/playbooks/inventory/gcp.yaml
            sed "s/###$KEY###/$VALUE/g" $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars > $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp
            mv  $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars
        elif [ "$KEY" = "GCP_SERVICE_ACCOUNT_FILE" ]
        then
            :
        elif [ "$KEY" = "MANAGED_ZONE" ]
        then
            MANAGED_ZONE=`echo $VALUE | cut -d "-" -f2- | sed 's/-prd//g'`
            MANAGED_ZONE="$MANAGED_ZONE-gcp-i-globo"
            sed "s/###$KEY###/$MANAGED_ZONE/g" $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars > $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp
            mv  $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars
        elif [ "$KEY" = "PROVISIONING_MODEL" ]
        then
            if [ "$PROVISIONING_MODEL" = "s" ]
            then
                sed "s/###$KEY###/SPOT/g" $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars > $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp
                mv  $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars
                sed "s/###PREEMPTIBLE###/true/g" $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars > $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp
                mv  $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars
                sed "s/###AUTOMATIC_RESTART###/false/g" $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars > $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp
                mv  $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars
            else
                sed "s/###$KEY###/STANDARD/g" $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars > $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp
                mv  $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars
                sed "s/###PREEMPTIBLE###/false/g" $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars > $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp
                mv  $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars
                sed "s/###AUTOMATIC_RESTART###/true/g" $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars > $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp
                mv  $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars
            fi
        else
            sed "s/###$KEY###/$VALUE/g" $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars > $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp
            mv  $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars
        fi
        done
        echo "Exibe o arquivo de configuração $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars"
        cat $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars
        echo ""
        read -p "Deseja subir a infraestrutura (s/n) : " RUN_ANSIBLE
}


#Configura o ambiente se for AWS.
configure_aws(){
    TERRAFORM_PATH="$TERRAFORM_PATH/$CLOUD"
    
    if [ ! -d "$TERRAFORM_PATH/$PROJECT_ID" ]
    then
        echo "Cria o diretório no terraform com base no modelo."
        cp -R $TERRAFORM_PATH/ambiente-de-exemplo $TERRAFORM_PATH/$PROJECT_ID
    else
        rm $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars
        cp -R $TERRAFORM_PATH/ambiente-de-exemplo/terraform.tfvars $TERRAFORM_PATH/$PROJECT_ID
    fi
    cp $ANSIBLE_PATH/playbooks/inventory/aws_ec2_template.yaml $ANSIBLE_PATH/playbooks/inventory/aws.yaml.tmp
    for i in "${configArray[@]}"
    do
        KEY=`echo $i | cut -d "=" -f1 | tr -d "\n"`
        VALUE=`echo $i | cut -d "=" -f2 | tr -d "\n"`

        if [ "$KEY" = "AWS_ACCESS_KEY" ] || [ "$KEY" = "AWS_SECRET_KEY" ]
        then
            cat $ANSIBLE_PATH/playbooks/inventory/aws.yaml.tmp | awk -v k="###$KEY###" -v v="$VALUE" '{gsub(k,v); print}' > $ANSIBLE_PATH/playbooks/inventory/aws_ec2.yaml
            cp $ANSIBLE_PATH/playbooks/inventory/aws_ec2.yaml $ANSIBLE_PATH/playbooks/inventory/aws.yaml.tmp
        elif [ "$KEY" = "REGION" ]
        then
            cat $ANSIBLE_PATH/playbooks/inventory/aws.yaml.tmp | awk -v k="###$KEY###" -v v="$VALUE" '{gsub(k,v); print}' > $ANSIBLE_PATH/playbooks/inventory/aws_ec2.yaml
            cp $ANSIBLE_PATH/playbooks/inventory/aws_ec2.yaml $ANSIBLE_PATH/playbooks/inventory/aws.yaml.tmp
            sed "s/###$KEY###/$VALUE/g" $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars > $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp
            mv  $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars
        else
            sed "s/###$KEY###/$VALUE/g" $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars > $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp
            mv  $TERRAFORM_PATH/$PROJECT_ID/terraform.tmp $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars
        fi
        done
        rm $ANSIBLE_PATH/playbooks/inventory/aws.yaml.tmp
        echo "Exibe o arquivo de configuração $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars"
        cat $TERRAFORM_PATH/$PROJECT_ID/terraform.tfvars
        echo ""
        read -p "Deseja subir a infraestrutura (s/n) : " RUN_ANSIBLE
}


# Realiza a execucao os playbooks do Ansible.
ansible_func(){
    if [ "$1" = "create" ]
    then
        source $CONFIG_FILE
        if [ "$CLOUD" = "gcp" ]
        then
            echo "Executa o ansible na GCP."
            cd $ANSIBLE_PATH/playbooks 
            ansible-playbook create-enviroment.yaml -e k6_instances_cloud_provider=gcp -e k6_terraform_env_path=$PROJECT_ID -i inventory/gcp.yaml
        elif [ "$CLOUD" = "aws" ]
        then
            echo "Executa o ansible na AWS."
            cd $ANSIBLE_PATH/playbooks
            ansible-playbook create-enviroment.yaml -e k6_instances_cloud_provider=aws -e k6_terraform_env_path=$PROJECT_ID -i inventory/aws_ec2.yaml
        fi
    fi

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

    if [ "$1" = "cmd" ]
    then
        source $CONFIG_FILE
        HOST_ANSIBLE=`ansible-inventory -i $ANSIBLE_PATH/playbooks/inventory/gcp.yaml --graph k6_instances`
        HOST_LIST=()
        for i in $HOST_ANSIBLE
        do
            if [ $i != "@k6_instances:" ]
            then
                HOST_LIST+=(`echo $i | cut -d "-" -f 3`)
            fi
        done

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

        HOST_COUNT=`echo "${#HOST_LIST[@]}"`
        read -p "Em quantos geradores de carga voce deseja executar( atualmente sao ${HOST_COUNT}): " HOST_LIMIT
        read -p "Informa o nome do cenario: " K6_SCENERY
        read -p "Informe o comando a ser executado nos geradores de carga (ex: run -u 10 -d 5m workon.js): " K6_CMD

        if [ ! -d $LOG_DIR ]
        then
            mkdir $LOG_DIR
        fi

        if [ ! -d $LOG_DIR/$K6_SCENERY ]
        then
            mkdir $LOG_DIR/$K6_SCENERY
        fi

        K6_CMD=`echo "${CMD_COMMON} export HTTP_PROXY=\"${GCP_PROXY}\" ; export HTTPS_PROXY=\"${GCP_PROXY}\" ; ${K6_CMD_COMMOM} ${K6_CMD} ${K6_SUMMARY}/${K6_SCENERY}.json"\'`
    
        count=0
        while [ $count -lt $HOST_LIMIT ]
        do
            if [ $count -eq "0"  ]
            then
                ssh -t -t -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -oLogLevel=quiet $ANSIBLE_USER@${HOST_LIST[$count]} "$K6_CMD" | tee $LOG_DIR/$K6_SCENERY/${HOST_LIST[$count]}-$K6_SCENERY.log &
            else
                ssh -t -t -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -oLogLevel=quiet $ANSIBLE_USER@${HOST_LIST[$count]} "$K6_CMD" > $LOG_DIR/$K6_SCENERY/${HOST_LIST[$count]}-$K6_SCENERY.log 2>&1 &
            fi
            let count++
        done
    fi

    if [ "$1" = "update" ]
    then
        source $CONFIG_FILE
        if [ "$CLOUD" = "gcp" ]
        then
            cd $ANSIBLE_PATH/playbooks
            ansible-playbook update-tests.yaml -u $ANSIBLE_USER -e k6_instances_cloud_provider=gcp -e k6_repo_tests=$K6_REPO_TEST -e k6_repo_branch=$K6_REPO_BRANCH -e k6_tests_path=$K6_SOURCE_DIR -i inventory/gcp.yaml 
        elif [ "$CLOUD" = "aws" ]
        then
            cd $ANSIBLE_PATH/playbooks
            ansible-playbook update-tests.yaml --key $ANSIBLE_USER -u ubuntu -e k6_instances_cloud_provider=aws -e k6_repo_tests=$K6_REPO_TEST -e k6_repo_branch=$K6_REPO_BRANCH -e k6_tests_path=$K6_SOURCE_DIR -i inventory/aws_ec2.yaml 
        fi
    fi

    if [ "$1" = "upload" ]
    then
        if [ ! -d $K6_TEMP ]
        then
            mkdir $K6_TEMP
        fi

        source $CONFIG_FILE

        HOST_ANSIBLE=`ansible-inventory -i infra/ansible/playbooks/inventory/gcp.yaml --graph k6_instances`
        HOST_LIST=()
        for i in $HOST_ANSIBLE
        do
            if [ $i != "@k6_instances:" ]
            then
                HOST_LIST+=(`echo $i | cut -d "-" -f 3`)
            fi
        done

        scp $ANSIBLE_USER@$HOST_LIST:/tmp/k6_results/* $K6_TEMP > /dev/null

        echo "Lista de cenários executados:"
        echo ""
        RESULT_DIR=`ls $K6_TEMP`
        echo $RESULT_DIR
        echo ""
        read -p "Escolha o cenário que será enviado para o report): " CENARIO
        echo $CENARIO
        
        RESULT_TIME=`stat -f "%Sm" -t "%d/%m/%Y - %H:%M:%S" $K6_TEMP`
        RESULT_CENARIO=`echo $CENARIO | cut -d "." -f 1`
        echo "{" > $K6_TEMP/temp.json
        echo "\"colecao\": \"$REPORT_AREA\"," >> $K6_TEMP/temp.json
        echo "\"projeto\": \"$REPORT_PROJECT\"," >> $K6_TEMP/temp.json
        echo "\"name\": \"$RESULT_CENARIO\"," >> $K6_TEMP/temp.json
        echo "\"timestamp\": \"$RESULT_TIME\"," >> $K6_TEMP/temp.json
        echo "\"resultado\": {" >> $K6_TEMP/temp.json
        cat $K6_TEMP/$CENARIO | sed '1,1d' >> $K6_TEMP/temp.json
        echo "" >> $K6_TEMP/temp.json
        echo "}" >> $K6_TEMP/temp.json
        curl  -X POST -H "Content-Type: application/json" -d @$K6_TEMP/temp.json $REPORT_URL
        echo ""
    fi

    if [ "$1" = "infracost" ]
    then
        source $CONFIG_FILE
        TERRAFORM_PATH="$TERRAFORM_PATH/$CLOUD"
        INFRACOST_BIN=`whereis infracost | awk '{ print $2 }'`

        if [ -z $INFRACOST_BIN ]
        then
            echo "Binário do infracost nao localizado."
            read -p "Deseja realizar a instalação do infracost (s/n): " INFRACOST_INSTALL

            if [ "$INFRACOST_INSTALL" = "s" ]
            then
                SO_CHECK=`uname -s`

                if [ "$SO_CHECK" = "Darwin" ]
                then
                    echo "Realiza a instalação via brew no MacOS"
                    brew update
                    brew install infracost
                else
                    echo "Realiza a instalação via script para outros Sistemas Operacionais"
                    curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
                fi
            fi
        fi

        if [ ! -f "$INFRACOST_CREDENTIALS" ]
        then
            echo "Arquivo de Credenciais do Infracost não localizado, realizado o processo de registro."
            infracost register
        fi 
        infracost breakdown --path $TERRAFORM_PATH/$PROJECT_ID --terraform-var-file terraform.tfvars
    fi

    if [ "$1" = "destroy" ]
    then
        source $CONFIG_FILE
        if [ "$CLOUD" = "gcp" ]
        then
            TERRAFORM_PATH="$TERRAFORM_PATH/$CLOUD"
            echo "Executa o ansible na GCP."
            cd $ANSIBLE_PATH/playbooks 
            ansible-playbook destroy-enviroment.yaml -e k6_instances_cloud_provider=gcp -e k6_terraform_env_path=$PROJECT_ID -i inventory/gcp.yaml
        elif [ "$CLOUD" = "aws" ]
        then
            echo "Executa o ansible na AWS."
            cd $ANSIBLE_PATH/playbooks
            ansible-playbook destroy-enviroment.yaml -e k6_instances_cloud_provider=aws -e k6_terraform_env_path=$PROJECT_ID -i inventory/aws_ec2.yaml
        fi
    fi
    rm -rf /tmp/k6*
}

read_config(){
    if [ -f "$CONFIG_FILE" ]
    then
        echo "Arquivo de configuracao já existe"
        read -p "Deseja carregar as configuracoes (s/n): " SAVE_RUN
        if [ "$SAVE_RUN" = "s" ]
        then
            source $CONFIG_FILE
            configArray=("CLOUD=$CLOUD" "ENVIRONMENT=$ENVIRONMENT" "NUMBER_INSTANCES=$NUMBER_INSTANCES" "REPORT_AREA=$REPORT_AREA" "REPORT_PROJECT=$REPORT_PROJECT"   
                "NETWORK_NAME=$NETWORK_NAME" "NETWORK_PROJECT_ID=$NETWORK_PROJECT_ID" "SUBNETWORK_NAME=$SUBNETWORK_NAME" "REGION=$REGION" "ZONE=$ZONE" "MACHINE_TYPE=$MACHINE_TYPE" "PROJECT_ID=$PROJECT_ID"
                "SERVICE_ACCOUNT=$SERVICE_ACCOUNT" "GCP_SERVICE_ACCOUNT_FILE"=$GCP_SERVICE_ACCOUNT_FILE "AWS_ACCESS_KEY"=$AWS_ACCESS_KEY "AWS_SECRET_KEY"=$AWS_SECRET_KEY)
        elif [ "$SAVE_RUN" = "n" ]
        then
            rm $CONFIG_FILE
            ask_config
        else
            echo "Parametros incorretos."
            exit 1
        fi
    else
            ask_config
    fi
}

#Limpa o ambiente.
clean_environment(){
    if [ ! -f "$CONFIG_FILE" ]
    then
        echo "Arquivo de configuração não encontrado, realizar a limpeza manual."
        exit 1
    else
        source $CONFIG_FILE
        rm $CONFIG_FILE
        TERRAFORM_PATH="$TERRAFORM_PATH/$CLOUD"
        rm -rf $TERRAFORM_PATH/$PROJECT_ID

        if [ "$CLOUD" = "gcp" ]
        then
            rm $ANSIBLE_PATH/playbooks/inventory/gcp.yaml
        elif [ "$CLOUD" = "aws" ]
        then
            rm $ANSIBLE_PATH/playbooks/inventory/aws_ec2.yaml
        else
            echo "Cloud ainda não suportada."
        fi
    fi
}

# Funcao que exibe o help do script.
help(){
    
    echo "Os parametros do script k6tt."
    echo
    echo "Syntax: k6tt [|-h|-p|-c|-a|]"
    echo "options:"
    echo "-a Execução do Ansible."
    echo "-h Exibe o Help."
    echo "-p Prepara o Ambiente para Execução."
    echo "-c Execucao da limpeza do ambiente."
    echo
}

# Main 
while getopts ":hpca:" option; do
   case $option in
      h)
         help
         exit;;
      c)
         clean_environment
         exit;;
      p)
         configure
         exit;;
      a)
        ANSIBLE_ARGS=$OPTARG
        ansible_func $ANSIBLE_ARGS
        exit;; 
     \?) 
         echo "Error: Opção Inválida."
         exit;;
   esac
done
