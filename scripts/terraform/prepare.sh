prepare(){

    if [ -f "$CONFIG_FILE" ]
    then
        echo "Arquivo de configuração já existe"

        read -p "Deseja carregar as configurações (s/n): " OPTION

        if [ "$OPTION" = "s" ]
        then
            load_config
        else
            rm "$CONFIG_FILE"

            ask_config
            read -p "Deseja salvar as configurações (s/n): " SAVE

            if [ "$SAVE" = "s" ]
            then
                save_config
            fi
        fi

    else

        ask_config

        read -p "Deseja salvar as configurações (s/n): " SAVE

        if [ "$SAVE" = "s" ]
        then
            save_config
        fi

    fi

}