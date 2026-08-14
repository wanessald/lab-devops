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
