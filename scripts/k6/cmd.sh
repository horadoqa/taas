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