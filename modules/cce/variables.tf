variable "management_group_id" {
  description = "The ID of the Azure Management Group"
  type        = string
}

variable "identity_issuer" {
  description = "The issuer URL for the federated identity credential"
  type        = string
}

variable "identity_user_id" {
  description = "The subject/user ID for the federated identity credential"
  type        = string
}

variable "identity_audience" {
  description = "The audience for the federated identity credential"
  type        = string
}
