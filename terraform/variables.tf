variable "tenancy_ocid" {
  description = "OCID do tenancy OCI"
  type        = string
}

variable "user_ocid" {
  description = "OCID do usuário OCI"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint da API key OCI"
  type        = string
}

variable "private_key_path" {
  description = "Caminho local para a chave privada da API key OCI"
  type        = string
}

variable "region" {
  description = "Região OCI"
  type        = string
  default     = "sa-saopaulo-1"
}

variable "ssh_public_key_path" {
  description = "Caminho local para a chave pública SSH das VMs"
  type        = string
  default     = "~/.ssh/lab-devops.pub"
}
