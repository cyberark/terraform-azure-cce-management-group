variable "entra_id" {
  description = "The Azure Entra (Tenant) ID"
  type        = string
}

variable "management_group_id" {
  description = "The Azure Management Group ID"
  type        = string
}

variable "sca" {
  description = "SCA config. When enable is true, shared_resources (from commons output) is required; MG only consumes it and assigns resource app to this MG scope. Pass through add_permissions_to_manage_cluster and resource_k8s_custom_role_id from commons; when true, assigns the K8s custom role at this management group."
  type = object({
    enable = optional(bool, false)
    shared_resources = optional(object({
      entra_app_id                      = optional(string)
      entra_custom_role_id              = optional(string)
      entra_wif_user_id                 = optional(string)
      resource_app_id                   = optional(string)
      resource_custom_role_id           = optional(string)
      resource_wif_user_id              = optional(string)
      add_permissions_to_manage_cluster = optional(bool, false)
      resource_k8s_custom_role_id       = optional(string)
    }), null)
  })
  default = { enable = false, shared_resources = null }

  validation {
    condition = (
      !var.sca.enable ||
      (var.sca.shared_resources != null &&
        try(var.sca.shared_resources.resource_app_id, null) != null &&
        try(length(var.sca.shared_resources.resource_app_id), 0) > 0 &&
        try(var.sca.shared_resources.resource_custom_role_id, null) != null &&
        try(length(var.sca.shared_resources.resource_custom_role_id), 0) > 0 &&
        try(var.sca.shared_resources.resource_wif_user_id, null) != null &&
      try(length(var.sca.shared_resources.resource_wif_user_id), 0) > 0)
    )
    error_message = "When SCA is enabled (sca.enable = true), sca.shared_resources must be set with non-empty resource_app_id, resource_custom_role_id, and resource_wif_user_id (from commons output)."
  }

  validation {
    condition = (
      !var.sca.enable ||
      try(var.sca.shared_resources.add_permissions_to_manage_cluster, false) ==
      (try(var.sca.shared_resources.resource_k8s_custom_role_id, null) != null)
    )
    error_message = "add_permissions_to_manage_cluster and resource_k8s_custom_role_id must both be set or both be unset — they must agree."
  }
}

