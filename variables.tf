variable "data_folders" {
  description = "List of paths to folders where firewall configs are stored in yaml format. Folder may include subfolders with configuration files. Files suffix must be `.yaml`."
  type        = list(string)
  default     = null
}

variable "deployment_scope" {
  description = "Firewall policy deployment scope. Can be 'global' or 'regional'. "
  type        = string
  validation {
    condition = contains(
      ["global", "regional"],
      var.deployment_scope
    )
    error_message = "Invalid deployment scope, supported scope: 'global' or 'regional'."
  }
}

variable "policy_region" {
  description = "Firewall policy region."
  type        = string
  default     = null
}

variable "firewall_rules" {
  description = "List rule definitions, default to allow action. Actions can be 'allow', 'deny', 'goto_next'."
  type = map(object({
    action         = optional(string, "allow")
    description    = optional(string, null)
    dest_ip_ranges = optional(list(string))
    disabled       = optional(bool, false)
    direction      = optional(string, "INGRESS")
    enable_logging = optional(bool, false)
    layer4_configs = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [{ protocol = "all" }])
    priority                = optional(number, 1000)
    src_secure_tags         = optional(list(string))
    src_ip_ranges           = optional(list(string))
    target_service_accounts = optional(list(string))
    target_secure_tags      = optional(list(string))
  }))
  default  = {}
  nullable = false
}

variable "network" {
  description = "VPC SelfLink to attach the firewall policy."
  type        = string
  default     = null
}
variable "policy_name" {
  description = "Firewall policy name."
  type        = string
}

variable "project_id" {
  description = "Project id of the project that holds the network."
  type        = string
}