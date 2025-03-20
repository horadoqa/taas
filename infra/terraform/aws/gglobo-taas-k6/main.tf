module "ec2_instance" {

  source = "git::https://gitlab.globoi.com/devops/terraform/terraform-aws-modules/terraform-aws-ec2.git//modules/ec2_simple_instance"

  env              = var.env
  
  number_instances = var.number_instances
  name_prefix      = var.name_prefix

  hub_network_name           = var.hub_network_name
  hub_subnetwork_name        = var.hub_subnetwork_name
  create_subnetwork          = var.create_subnetwork

  region       = var.region
  zone         = var.zone

  service_account = var.service_account
  
  machine_type = var.machine_type
}