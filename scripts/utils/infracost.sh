#!/usr/bin/env bash

terraform_cost(){

    source "$CONFIG_FILE"

    TERRAFORM_PATH="$TERRAFORM_PATH/$CLOUD"

    INFRACOST_BIN=$(command -v infracost | awk '{ print $2 }')

    if [ -z "$INFRACOST_BIN" ]
    then
        echo "Binário do infracost não localizado."

        read -p "Deseja realizar a instalação do infracost (s/n): " INFRACOST_INSTALL

        if [ "$INFRACOST_INSTALL" = "s" ]
        then
            SO_CHECK=$(uname -s)

            if [ "$SO_CHECK" = "Darwin" ]
            then
                sudo apt update
                sudo apt install infracost
            else
                curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
            fi
        fi
    fi


    if [ ! -f "$INFRACOST_CREDENTIALS" ]
    then
        echo "Arquivo de Credenciais do Infracost não localizado."
        infracost register
    fi

    command infracost breakdown --path "$TERRAFORM_PATH/$PROJECT_ID" --terraform-var-file terraform.tfvars
}