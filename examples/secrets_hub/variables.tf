variable "entra_id" {
  description = "The Microsoft Entra tenant ID."
  type        = string
}

variable "management_group_id" {
  description = "The Azure management group ID."
  type        = string
}

variable "subscription_id" {
  description = "The Azure subscription ID the azurerm provider authenticates against."
  type        = string
}
