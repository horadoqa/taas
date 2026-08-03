configure(){

    load_config

    if [ "$CLOUD" = "gcp" ]
    then
        configure_gcp
    elif [ "$CLOUD" = "aws" ]
    then
        configure_aws
    fi

}