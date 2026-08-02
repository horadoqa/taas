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