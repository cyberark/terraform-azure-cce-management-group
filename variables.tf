variable "entra_id" {
  description = "The Microsoft Entra tenant ID."
  type        = string
}

variable "management_group_id" {
  description = "The Azure management group ID."
  type        = string
}

variable "sca" {
  description = "SCA configuration. When **enable** is true, shared_resources (from commons output) is required. The management group only consumes it and assigns the resource app to this management group scope. Pass through add_permissions_to_manage_cluster and resource_k8s_custom_role_id from commons; when true, assigns the K8s custom role to this management group."
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
    error_message = "When SCA is enabled (sca.enable = true), sca.shared_resources must be set with the resource_app_id, resource_custom_role_id, and resource_wif_user_id (from commons output)."
  }

  validation {
    condition = (
      !var.sca.enable ||
      try(var.sca.shared_resources.add_permissions_to_manage_cluster, false) ==
      (try(var.sca.shared_resources.resource_k8s_custom_role_id, null) != null)
    )
    error_message = "add_permissions_to_manage_cluster and resource_k8s_custom_role_id must both either be set or not set. No mixed values."
  }
}

