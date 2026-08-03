#!/usr/bin/env bash

# BASE_DIR="$(dirname "$0")"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Libraries
source "$BASE_DIR/lib/constants.sh"
source "$BASE_DIR/lib/utils.sh"

# Config
source "$BASE_DIR/config/wizard.sh"
source "$BASE_DIR/config/load.sh"
source "$BASE_DIR/config/save.sh"

# Providers
source "$BASE_DIR/providers/gcp.sh"
source "$BASE_DIR/providers/aws.sh"

# Terraform
source "$BASE_DIR/terraform/prepare.sh"
source "$BASE_DIR/terraform/create.sh"
source "$BASE_DIR/terraform/destroy.sh"
source "$BASE_DIR/terraform/configure.sh"

# Ansible
source "$BASE_DIR/ansible/setup.sh"
source "$BASE_DIR/ansible/update.sh"

# Utils
source "$BASE_DIR/utils/help.sh"
source "$BASE_DIR/utils/clean.sh"
source "$BASE_DIR/utils/infracost.sh"


while getopts ":hpca:" option; do
    case $option in

        h)
            help
            ;;

        c)
            clean_environment
            ;;

        p)
            prepare
            ;;

        a)
    case "$OPTARG" in

        create|destroy)
            terraform_func "$OPTARG"
            ;;

        setup|update|cmd)
            ansible_func "$OPTARG"
            ;;

        infracost)
            terraform_cost
            ;;

        *)
            echo "Opção inválida: $OPTARG"
            help
            ;;
    esac
            ;;

        *)
            echo "Opção inválida: $option"
            help
            ;;
    esac
done