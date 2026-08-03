load_config(){

    echo "CONFIG_FILE=$CONFIG_FILE"

    if [ -f "$CONFIG_FILE" ]
    then
        echo "Arquivo de configuração encontrado."

        source "$CONFIG_FILE"

        echo "Configuração carregada."

    else
        echo "Arquivo de configuração não encontrado."
        return 1
    fi

}