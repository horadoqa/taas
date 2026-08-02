#!/bin/sh

BASE_DIR="$(dirname "$0")"

# Config
source "$BASE_DIR/config/wizard.sh"
source "$BASE_DIR/config/load.sh"
source "$BASE_DIR/config/save.sh"

# Terraform
source "$BASE_DIR/terraform/configure.sh"
source "$BASE_DIR/terraform/gcp.sh"
source "$BASE_DIR/terraform/aws.sh"

# Ansible
source "$BASE_DIR/ansible/create.sh"
source "$BASE_DIR/ansible/setup.sh"
source "$BASE_DIR/ansible/run.sh"
source "$BASE_DIR/ansible/update.sh"
source "$BASE_DIR/ansible/upload.sh"
source "$BASE_DIR/ansible/destroy.sh"

# Utils
source "$BASE_DIR/utils/help.sh"
source "$BASE_DIR/utils/clean.sh"


while getopts ":hpca:" option; do
    case $option in

        h)
            help
            ;;

        c)
            clean_environment
            ;;

        p)
            configure
            ;;

        a)
            ansible_func "$OPTARG"
            ;;

        *)
            echo "Opção inválida."
            help
            exit 1
            ;;

    esac
done