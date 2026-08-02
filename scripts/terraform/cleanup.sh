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