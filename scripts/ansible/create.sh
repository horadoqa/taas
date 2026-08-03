# Realiza a execucao os playbooks do Ansible.
ansible_func(){
    if [ "$1" = "create" ]
    then
        source $CONFIG_FILE
        if [ "$CLOUD" = "gcp" ]
        then
            echo "Executa o ansible na GCP."
            cd $ANSIBLE_PATH/playbooks 
            ansible-playbook create-enviroment.yaml -e k6_instances_cloud_provider=gcp -e k6_terraform_env_path=$PROJECT_ID -i inventory/gcp.yaml
        elif [ "$CLOUD" = "aws" ]
        then
            echo "Executa o ansible na AWS."
            cd $ANSIBLE_PATH/playbooks
            ansible-playbook create-enviroment.yaml -e k6_instances_cloud_provider=aws -e k6_terraform_env_path=$PROJECT_ID -i inventory/aws_ec2.yaml
        fi
    fi
}