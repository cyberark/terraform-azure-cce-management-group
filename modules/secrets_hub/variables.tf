variable "management_group_id" {
  description = "The Azure management group ID (scope for the Secrets Hub role assignments)"
  type        = string
}

variable "shared_resources" {
  description = "Secrets Hub shared resources from Commons (the Commons `secrets_hub` output). Validation happens in the root module's `secrets_hub` variable."
  type = object({
    app_id                    = optional(string)
    custom_role_id            = optional(string)
    identity_trusted_username = optional(string)
  })
}
