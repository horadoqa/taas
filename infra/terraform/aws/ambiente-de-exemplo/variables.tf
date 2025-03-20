variable "project_id" {
  type        = string
  description = "Variável responsável pelo ID do projeto da GCP."
  default     = ""
}

variable "env" {
  type        = string
  description = "Ambiente que será executado"
}

variable "zone" {
  type        = string
  description = "Variável da zona de disponibilidade."
}

variable "region" {
  type        = string
  description = "Variável da região de disponibilidade."
}

variable "machine_type" {
  type        = string
  description = "Variável responsável pelo tipo da instância."
}

variable "source_image" {
  type        = string
  description = "Imagem para ser utilizacada na criação da instância."
  default     = ""
}

variable "disk_size" {
  type        = number
  description = "Valor para o tamanho do disco."
  default     = 60
}

variable "name_prefix" {
  type        = string
  description = "Prefixo do nome padrão Globo com padrão para template."
}

variable "number_instances" {
  type        = number
  description = "Numero de instancias"
}

variable "hub_network_project_id" {
  type = string
  description = "Project ID da rede na GCP"
  default     = ""
}

variable "hub_network_name" {
  type = string
  description = "Nome da rede"
}

variable "service_account" {
  type = string
  description = "Conta de serviço para a instância"
}

variable "hub_subnetwork_name" {
  type = string
  description = "Nome da sub-rede"
}

variable "create_subnetwork" {
  type        = bool
  description = "Flag para criar uma sub-rede"
  default     = false
}