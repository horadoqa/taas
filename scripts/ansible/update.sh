if [ "$1" = "update" ]
    then
        source $CONFIG_FILE
        if [ "$CLOUD" = "gcp" ]
        then
            cd $ANSIBLE_PATH/playbooks
            ansible-playbook update-tests.yaml -u $ANSIBLE_USER -e k6_instances_cloud_provider=gcp -e k6_repo_tests=$K6_REPO_TEST -e k6_repo_branch=$K6_REPO_BRANCH -e k6_tests_path=$K6_SOURCE_DIR -i inventory/gcp.yaml 
        elif [ "$CLOUD" = "aws" ]
        then
            cd $ANSIBLE_PATH/playbooks
            ansible-playbook update-tests.yaml --key $ANSIBLE_USER -u ubuntu -e k6_instances_cloud_provider=aws -e k6_repo_tests=$K6_REPO_TEST -e k6_repo_branch=$K6_REPO_BRANCH -e k6_tests_path=$K6_SOURCE_DIR -i inventory/aws_ec2.yaml 
        fi
    fi



