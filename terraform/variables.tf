variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "location" {
  description = "Região Azure"
  type        = string
  default     = "brazilsouth"
}

variable "ssh_public_key_path" {
  description = "Caminho para a chave pública SSH"
  type        = string
  default     = "~/.ssh/lab-devops.pub"
}

variable "vm_size" {
  description = "Tamanho das VMs"
  type        = string
  default     = "Standard_B1ms"
}
