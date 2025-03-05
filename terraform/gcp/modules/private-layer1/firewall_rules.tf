locals {
  firewall_rules = [
    {
      name        = "klayspray-ssh"
      direction   = "INGRESS"
      ranges      = var.ssh_client_ips
      target_tags = ["klayspray"]
      allow = {
        protocol = "tcp"
        ports    = ["22"]
      }
    },
    {
      name        = "klayspray-rpc-tcp"
      direction   = "INGRESS"
      ranges      = ["0.0.0.0/0"]
      source_tags = ["cn", "pn", "en"]
      target_tags = ["cn", "pn", "en"]
      allow = {
        protocol = "tcp"
        ports    = ["8551", "32323-32324"]
      }
    },
    {
      name        = "klayspray-rpc-udp"
      direction   = "INGRESS"
      ranges      = ["0.0.0.0/0"]
      source_tags = ["cn", "pn", "en"]
      target_tags = ["cn", "pn", "en"]
      allow = {
        protocol = "udp"
        ports    = ["32323"]
      }
    },
    {
      name        = "klayspray-monitor-internal"
      direction   = "INGRESS"
      source_tags = ["monitor"]
      target_tags = ["cn", "pn", "en"]
      allow = {
        protocol = "tcp"
        ports    = ["61001"]
      }
    },
    {
      name        = "klayspray-monitor-external"
      direction   = "INGRESS"
      ranges      = ["0.0.0.0/0"]
      target_tags = ["monitor"]
      allow = {
        protocol = "tcp"
        ports    = ["3000", "9090"]
      }
    },
    {
      name        = "klayspray-egress-tcp"
      direction   = "EGRESS"
      ranges      = ["0.0.0.0/0"]
      target_tags = ["klayspray"]
      allow = {
        protocol = "tcp"
        ports    = ["0-65535"]
      }
    },
    {
      name        = "klayspray-egress-udp"
      direction   = "EGRESS"
      ranges      = ["0.0.0.0/0"]
      target_tags = ["klayspray"]
      allow = {
        protocol = "udp"
        ports    = ["0-65535"]
      }
    },
  ]
}

module "firewall_rules" {
  count = length(var.network_tags) > 0 ? 0 : length(local.firewall_rules)

  source       = "terraform-google-modules/network/google//modules/firewall-rules"
  project_id   = var.project_id
  network_name = var.network

  rules = [{
    name                    = try(local.firewall_rules[count.index].name, "rule")
    description             = try(local.firewall_rules[count.index].description, null)
    direction               = try(local.firewall_rules[count.index].direction, "INGRESS") # INGRESS OR EGRESS
    priority                = try(local.firewall_rules[count.index].priority, null)
    ranges                  = try(local.firewall_rules[count.index].ranges, null) # []
    source_tags             = try(local.firewall_rules[count.index].source_tags, null)
    source_service_accounts = try(local.firewall_rules[count.index].source_service_accounts, null)
    target_tags             = try(local.firewall_rules[count.index].target_tags, null)
    target_service_accounts = try(local.firewall_rules[count.index].target_service_accounts, null)

    allow = [{
      protocol = try(local.firewall_rules[count.index].allow.protocol, "tcp")
      ports    = try(local.firewall_rules[count.index].allow.ports, null) # []
    }]

    deny = []

    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
    }
  }]
}
