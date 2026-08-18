variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "location" {
  description = "Região Azure onde os recursos serão criados"
  type        = string
  default     = "brazilsouth"
}

variable "prefix" {
  description = "Prefixo usado no nome de todos os recursos"
  type        = string
  default     = "cloudlab"
}

variable "ssh_source_address_prefix" {
  description = "CIDR autorizado a acessar a porta SSH. Use seu IP público no formato x.x.x.x/32 ou * para qualquer origem."
  type        = string
  default     = "*"
}
