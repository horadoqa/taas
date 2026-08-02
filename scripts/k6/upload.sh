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