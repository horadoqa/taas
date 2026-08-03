#!/bin/sh

ask_config() {
    read -p "Informe a Cloud a ser utilizada (gcp/aws): " CLOUD
    read -p "Informe o ambiente da execução (dev/qa/prod): " ENVIRONMENT
    read -p "Informe o número de instâncias do K6: " NUMBER_INSTANCES
    read -p "Informe a área: " REPORT_AREA
    read -p "Informe o projeto: " REPORT_PROJECT

    case "$CLOUD" in
        gcp)
            ask_config_gcp
            ;;
        aws)
            ask_config_aws
            ;;
        *)
            echo "Cloud ainda não suportada."
            exit 1
            ;;
    esac

}


ask_config_gcp() {
    read -p "Nome da rede: " NETWORK_NAME
    read -p "Projeto da rede: " NETWORK_PROJECT_ID
    read -p "Subrede: " SUBNETWORK_NAME
    read -p "Usar IP público (s/n): " EXTERNAL_NETWORK
    read -p "Usar VM Spot (s/n): " PROVISIONING_MODEL
    read -p "Região: " REGION
    read -p "Zona: " ZONE
    read -p "Tipo da máquina: " MACHINE_TYPE
    read -p "Projeto GCP: " PROJECT_ID
    read -p "Service Account: " SERVICE_ACCOUNT
    read -p "Arquivo JSON da Service Account: " GCP_SERVICE_ACCOUNT_FILE
}


ask_config_aws() {

    read -p "AWS Access Key: " AWS_ACCESS_KEY
    read -p "AWS Secret Key: " AWS_SECRET_KEY

    read -p "VPC: " NETWORK_NAME
    read -p "Subnet: " SUBNETWORK_NAME

    read -p "Região AWS (us-east-1): " REGION

    read -p "Zona AWS (opcional): " ZONE

    read -p "Tipo da máquina (t3.micro): " MACHINE_TYPE
    read -p "Projeto: " PROJECT_ID
}

ask_machine_type_aws(){

    echo "Tipos disponíveis:"
    echo "1) t4g.nano  - menor custo (ARM)"
    echo "2) t3.nano   - menor custo x86"
    echo "3) t4g.micro - recomendado"
    echo "4) t3.micro  - recomendado x86"

    read -p "Escolha o tipo da máquina: " MACHINE_OPTION

    case "$MACHINE_OPTION" in
        1)
            MACHINE_TYPE="t4g.nano"
            ;;
        2)
            MACHINE_TYPE="t3.nano"
            ;;
        3)
            MACHINE_TYPE="t4g.micro"
            ;;
        4)
            MACHINE_TYPE="t3.micro"
            ;;
        *)
            echo "Opção inválida"
            exit 1
            ;;
    esac
}