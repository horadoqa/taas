name_prefix                = "k6"

region                     = "us-east-1"
zone                       = "us-east-1-a"

number_instances           = 1
machine_type               = "t2.xlarge"

create_subnetwork          = false
hub_network_name           = "VPC_CORP"
hub_subnetwork_name        = "Private_B_CORP"

service_account            = "k6-qa"

env                        = "prod"