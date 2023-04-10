locals {
  _files = try(flatten(
    [
      for config_path in var.data_folders :
      concat(
        [
          for config_file in fileset("${path.root}/${config_path}", "**/*.yaml") :
          "${path.root}/${config_path}/${config_file}"
        ]
      )
    ]
  ), null)

  _files_rules = try(merge(
    [
      for config_file in local._files :
      try(yamldecode(file(config_file)), {})
    ]...
  ), null)

  _firewall_rules = try({ for k, v in local._files_rules : k => {
    disabled                = try(v.disabled, false)
    description             = try(v.description, null)
    action                  = try(v.action, "allow")
    direction               = try(upper(v.direction), "INGRESS")
    priority                = try(v.priority, 1000)
    enable_logging          = try(v.enable_logging, false)
    layer4_configs          = try(v.layer4_configs, [{ protocol = "all" }])
    target_service_accounts = try(v.target_service_accounts, null)
    destination_ranges      = try(v.destination_ranges, null)
    source_ranges           = try(v.source_ranges, null)
    source_tags             = try(v.source_tags, null)
    target_tags             = try(v.target_tags, null)
    }
  }, null)

  rules = merge(local._firewall_rules, var.firewall_rules)
}

###############################################################################
#                                global policy                                #
###############################################################################

resource "google_compute_network_firewall_policy" "default" {
  count       = var.deployment_scope == "global" ? 1 : 0
  name        = var.policy_name
  project     = var.project_id
  description = var.description
}

resource "google_compute_network_firewall_policy_rule" "default" {
  for_each        = { for k, v in local.rules : k => v if var.deployment_scope == "global" }
  project         = var.project_id
  firewall_policy = google_compute_network_firewall_policy.default[0].name
  rule_name       = each.key
  disabled        = each.value["disabled"]
  action          = each.value["action"]
  direction       = each.value["direction"]
  priority        = each.value["priority"]
  description     = each.value["description"]
  enable_logging  = each.value["enable_logging"]
  match {
    dynamic "src_secure_tags" {
      for_each = each.value["source_tags"] == null ? [] : each.value["source_tags"]
      content {
        name = "tagValues/${src_secure_tags.value}"
      }
    }

    dynamic "layer4_configs" {
      for_each = each.value["layer4_configs"]
      content {
        ip_protocol = layer4_configs.value.protocol
        ports       = try(layer4_configs.value.ports, [])
      }
    }

    dest_ip_ranges = each.value["destination_ranges"]
    src_ip_ranges  = each.value["source_ranges"]
  }

  target_service_accounts = each.value["target_service_accounts"]
  dynamic "target_secure_tags" {
    for_each = each.value["target_tags"] == null ? [] : each.value["target_tags"]
    content {
      name = "tagValues/${target_secure_tags.value}"
    }
  }
}

resource "google_compute_network_firewall_policy_association" "default" {
  count             = var.deployment_scope == "global" ? 1 : 0
  name              = "global-association"
  attachment_target = var.network
  firewall_policy   = google_compute_network_firewall_policy.default[0].name
  project           = var.project_id
}

###############################################################################
#                               regional policy                               #
###############################################################################

resource "google_compute_region_network_firewall_policy" "default" {
  count       = var.deployment_scope == "regional" ? 1 : 0
  name        = var.policy_name
  project     = var.project_id
  description = var.description
  region      = var.policy_region
}

resource "google_compute_region_network_firewall_policy_rule" "default" {
  for_each        = { for k, v in local.rules : k => v if var.deployment_scope == "regional" }
  project         = var.project_id
  firewall_policy = google_compute_region_network_firewall_policy.default[0].name
  region          = var.policy_region
  rule_name       = each.key
  disabled        = each.value["disabled"]
  action          = each.value["action"]
  direction       = each.value["direction"]
  priority        = each.value["priority"]
  description     = each.value["description"]
  enable_logging  = each.value["enable_logging"]

  match {
    dynamic "src_secure_tags" {
      for_each = each.value["source_tags"] == null ? [] : each.value["source_tags"]
      content {
        name = "tagValues/${src_secure_tags.value}"
      }
    }

    dynamic "layer4_configs" {
      for_each = each.value["layer4_configs"]
      content {
        ip_protocol = layer4_configs.value.protocol
        ports       = try(layer4_configs.value.ports, [])
      }
    }

    dest_ip_ranges = each.value["destination_ranges"]
    src_ip_ranges  = each.value["source_ranges"]
  }

  target_service_accounts = each.value["target_service_accounts"]
  dynamic "target_secure_tags" {
    for_each = each.value["target_tags"] == null ? [] : each.value["target_tags"]
    content {
      name = "tagValues/${target_secure_tags.value}"
    }
  }
}

resource "google_compute_region_network_firewall_policy_association" "default" {
  count             = var.deployment_scope == "regional" ? 1 : 0
  name              = "regional-association"
  attachment_target = var.network
  firewall_policy   = google_compute_region_network_firewall_policy.default[0].name
  project           = var.project_id
  region            = var.policy_region
}