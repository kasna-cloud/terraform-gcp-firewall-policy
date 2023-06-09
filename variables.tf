variable "data_folders" {
  description = "List of paths to folders where firewall configs are stored in yaml format. Folder may include subfolders with configuration files. Files suffix must be `.yaml`."
  type        = list(string)
  default     = null
}

variable "description" {
  description = "Policy description."
  type        = string
  default     = null
}

variable "policy_region" {
  description = "Firewall policy region. Leave null to enable global policy"
  type        = string
  default     = null
}

variable "firewall_rules" {
  description = "List rule definitions, default to allow action. Actions can be 'allow', 'deny', 'goto_next'."
  type = map(object({
    action             = optional(string, "allow")
    description        = optional(string, null)
    destination_ranges = optional(list(string))
    disabled           = optional(bool, false)
    direction          = optional(string, "INGRESS")
    enable_logging     = optional(bool, false)
    layer4_configs = optional(list(object({
      protocol = string
      ports    = optional(list(string))
    })), [{ protocol = "all" }])
    priority                = optional(number, 1000)
    source_tags             = optional(list(string))
    source_ranges           = optional(list(string))
    target_service_accounts = optional(list(string))
    target_tags             = optional(list(string))
  }))
  default  = {}
  nullable = false
}

variable "network" {
  description = "VPC SelfLink to attach the firewall policy."
  type        = string
  nullable    = false
}
variable "policy_name" {
  description = "Firewall policy name."
  type        = string
  nullable    = false
}

variable "project_id" {
  description = "Project id of the project that holds the network."
  type        = string
  nullable    = false
}