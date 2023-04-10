# Google Cloud Network Firewall Policy

Since Firewall Policies is now Google's recommended and preferred firewall construct over VPC Firewall rules. This module allows creation and management of regional and global network firewall policies and rules.

Yaml abstraction for Firewall rules can simplify users onboarding and also makes rules definition simpler and clearer comparing to HCL.

Nested folder structure for yaml configurations is optionally supported, which allows better and structured code management for multiple teams and environments.

## Example

### Terraform code

```hcl
module "global_policy" { # global firewall policy using YAML by defining rules file location
  source           = "./fabric/modules/net-vpc-network-firewall"
  project_id       = "my-project"
  policy_name      = "global-policy"
  deployment_scope = "global"
  network          = "my-network"
  data_folders     = ["./firewall-rules"]
}

module "regional_policy" {
  source           = "./net_vpc_network_firewall"
  project_id       = "my-project"
  policy_name      = "regional-policy"
  deployment_scope = "regional"
  policy_region    = "australia-southeast1"
  firewall_rules = {
    "rule-1" = {
      action         = "allow"
      description    = "rule 30"
      direction      = "INGRESS"
      disabled       = false
      enable_logging = true
      layer4_configs = [{
        ports    = ["8080", "443", "80"]
        protocol = "tcp"
        },
        {
          ports    = ["53", "123-130"]
          protocol = "udp"
        }
      ]
      priority           = 1113
      source_ranges      = ["0.0.0.0/0"]
      target_tags = ["516738215535", "839187618417"]
    }

    "ssh" = {
      action         = "allow"
      description    = "allow ssh from onprem network"
      direction      = "INGRESS"
      disabled       = false
      enable_logging = true
      layer4_configs = [{
        ports    = ["22"]
        protocol = "tcp"
        }
      ]
      priority           = 2222
      source_ranges      = ["192.168.0.0/24"]
    }
  }
}
```

### Example Configuration Structure using yaml files to create rules

```bash
├── common
│   ├── global-rules.yaml
│   └── regional-rules.yaml
├── dev
│   ├── team-a
│   │   ├── databases.yaml
│   │   └── regional-rules.yaml
│   └── team-b
│       ├── backend.yaml
│       └── frontend.yaml
└── prod
    ├── team-a
    │   ├── regional-rules.yaml
    │   └── webb-app-a.yaml
    └── team-b
        ├── backend.yaml
        └── frontend.yaml
```

### Rule definition format and structure

```yaml
rule-name: # rule descriptive name
  disabled: false #`false` or `true`, FW rule is disabled when `true`, default value is `false`
  description: global rule-2 # rules description
  action: allow # allow or deny
  direction: INGRESS # INGRESS or EGRESS
  priority: 1000 # rule priority value, default value is 1000
  enable_logging: true # Enable rule logging. Default is false
  source_tags: ["12345678912", ["98765432198"]] # list of source secure tag
  layer4_configs:
    - protocol: tcp # protocol, put `all` for any protocol
      port: ['443', '80', "140-150"] # ports for a specific protocol, keep empty list `[]` for all ports
  target_service_accounts: # list of target service accounts
  destination_ranges: # list of destination ranges, should be specified only for `EGRESS` rule
  source_ranges: # list of source ranges, should be specified only for `INGRESS` rule
  target_tags: # list of taget secure tag
  ```

Firewall rules example yaml configuration

```yaml
rule-1:
  description: global rule 1
  action: allow
  direction: ingress
  priority: 1000
  enable_logging: true
  layer4_configs:
    - protocol: tcp
      ports:
        - 80
        - 443
    - protocol: udp
      ports:
        - 555
        - 666
  source_ranges:
   - 192.168.1.100/32
   - 10.10.10.0/24
  target_tags:
    - 446253268572
  source_tags:
    - 516738215535
    - 839187618417

rule-2:
  description: global rule 2
  action: allow
  direction: EGRESS
  priority: 2000
  enable_logging: true
  layer4_configs:
    - protocol: tcp
      ports:
        - 80
        - 443
    - protocol: udp
      ports:
        - 555
        - 666
  destination_ranges:
    - 192.168.0.0/24
    - 172.16.10.0/24
  target_tags:
    - 446253268572
  
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.40.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 4.40.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.40.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_network_firewall_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy) | resource |
| [google_compute_network_firewall_policy_association.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_association) | resource |
| [google_compute_network_firewall_policy_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_firewall_policy_rule) | resource |
| [google_compute_region_network_firewall_policy.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_firewall_policy) | resource |
| [google_compute_region_network_firewall_policy_association.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_firewall_policy_association) | resource |
| [google_compute_region_network_firewall_policy_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_firewall_policy_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_folders"></a> [data\_folders](#input\_data\_folders) | List of paths to folders where firewall configs are stored in yaml format. Folder may include subfolders with configuration files. Files suffix must be `.yaml`. | `list(string)` | `null` | no |
| <a name="input_deployment_scope"></a> [deployment\_scope](#input\_deployment\_scope) | Firewall policy deployment scope. Can be either 'global' or 'regional'. | `string` | n/a | yes |
| <a name="input_firewall_rules"></a> [firewall\_rules](#input\_firewall\_rules) | List rule definitions, default to allow action. | <pre>map(object({<br>    action         = optional(string, "allow")<br>    description    = optional(string, null)<br>    destination_ranges = optional(list(string))<br>    disabled       = optional(bool, false)<br>    direction      = optional(string, "INGRESS")<br>    enable_logging = optional(bool, false)<br>    layer4_configs = optional(list(object({<br>      protocol = string<br>      ports    = optional(list(string))<br>    })), [{ protocol = "all" }])<br>    priority                = optional(number, 1000)<br>    source_tags         = optional(list(string))<br>    source_ranges           = optional(list(string))<br>    target_service_accounts = optional(list(string))<br>    target_tags      = optional(list(string))<br>  }))</pre> | `{}` | no |
| <a name="input_network"></a> [network](#input\_network) | VPC SelfLink to attach the firewall policy. | `string` | `null` | no |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | Network firewall policy name. | `string` | n/a | yes |
| <a name="input_policy_region"></a> [policy\_region](#input\_policy\_region) | Network firewall policy region. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project id of the project that holds the network. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_global_network_association"></a> [global\_network\_association](#output\_global\_network\_association) | Global association name |
| <a name="output_global_policy_name"></a> [global\_policy\_name](#output\_global\_policy\_name) | Global network firewall policy name |
| <a name="output_global_rules"></a> [global\_rules](#output\_global\_rules) | Global rules. |
| <a name="output_regional_network_association"></a> [regional\_network\_association](#output\_regional\_network\_association) | Global association name |
| <a name="output_regional_policy_name"></a> [regional\_policy\_name](#output\_regional\_policy\_name) | Regional network firewall policy name |
| <a name="output_regional_rules"></a> [regional\_rules](#output\_regional\_rules) | Regional rules. |
<!-- END_TF_DOCS -->