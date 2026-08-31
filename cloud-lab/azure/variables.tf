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

variable "ssh_public_key" {
  description = "Conteúdo da chave pública SSH para as VMs. Use: $(cat ~/.ssh/lab-devops.pub)"
  type        = string
  default     = ""
}

variable "vm_size" {
  description = "Tamanho da VM Azure (SKU)"
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "availability_zone" {
  description = "Zona de disponibilidade Azure (1, 2 ou 3)"
  type        = string
  default     = "1"
}
