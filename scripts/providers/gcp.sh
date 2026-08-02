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