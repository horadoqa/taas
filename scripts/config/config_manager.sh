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