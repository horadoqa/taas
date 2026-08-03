variable "project_id" {
  type        = string
  description = "Variável responsável pelo ID do Projeto da GCP."
}

variable "environment" {
  type        = string
  description = "Ambiente que será executado o Terraform"
}

variable "zone" {
  type        = string
  default     = "southamerica-east1-b"
  description = "Variável da zona de Disponibilidade RHSSO Template."
}

variable "machine_type" {
  type        = string
  description = "Variável responsável pelo tipo da instância."
}

variable "source_image" {
  type        = string
  description = "Imagem para ser utilizacada na criação da instância."
}

variable "network" {
  type        = string
  description = "Valor da rede a ser configurada na instância."
}

variable "region" {
  type        = string
  description = "Valor da regiao do projeto."
}

variable "subnetwork" {
  type        = string
  description = "Valor a subrede a ser configurada na instância."
}

variable "disk_size" {
  type        = number
  default     = 60
  description = "Valor para o tamanho do disco."
}

variable "service_account" {
  type        = string
  description = "Valor da conta padrão de serviço utilizada."
}

variable "name_prefix" {
  type        = string
  description = "Prefixo do nome padrão Globo com padrão para template."
  default     = "sa-e1"
}

variable "system_label" {
  type        = string
  description = "Objetivo da maquina virtual"
  default     = "k6"
}

variable "number_instances" {
  type        = number
  description = "Numero de instancias K6"
  default     = 1
}

variable "managed_zone" {
  type        = string
  description = "Variável responsável pela Zona de DNS na GCP."
}

variable "provisioning_model" {
  type        = string
  description = "Variável responsável por identificar o tipo de maquina"
}

variable "preemptible" {
  type        = bool
  description = "Variável responsável por identitificar o formato do schedule"
}

variable "automatic_restart" {
  type        = bool
  description = "Variável responsável por identitificar se a maquina irá ou não ser reiniciada."
}