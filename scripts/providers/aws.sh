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