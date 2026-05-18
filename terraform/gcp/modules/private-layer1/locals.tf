locals {
  # Default values
  defaults = {
    machine_type = "n2-standard-2"
    boot_disk_size = 100
    compute_disk_size = null
    snapshot_id = null
    region = var.gcp_region
    zone = null
    network = var.network
    subnetwork = var.subnetwork
    spot = false
    spot_instance_termination_action = "STOP"
  }

  zone_suffixes = ["a", "b", "c"]

  default_zone = length(var.zone_list) > 0 ? var.zone_list[0] : format("%s-a", var.gcp_region)

  monitor_options = {
    machine_type   = lookup(var.monitor_options, "machine_type", local.defaults.machine_type)
    boot_disk_size = lookup(var.monitor_options, "boot_disk_size", local.defaults.boot_disk_size)
    compute_disk_size = lookup(var.monitor_options, "compute_disk_size", local.defaults.compute_disk_size)
    snapshot_id = lookup(var.monitor_options, "snapshot_id", local.defaults.snapshot_id)
    region = lookup(var.monitor_options, "region", var.gcp_region)
    zone = lookup(var.monitor_options, "zone", local.default_zone)
    network = lookup(var.monitor_options, "network", local.defaults.network)
    subnetwork = lookup(var.monitor_options, "subnetwork", local.defaults.subnetwork)
    spot = try(var.monitor_options.spot, try(var.monitor_options.spot_vm, try(var.monitor_options.preemptible, false)))
    spot_instance_termination_action = lookup(var.monitor_options, "spot_instance_termination_action", local.defaults.spot_instance_termination_action)
  }

  # Generate node options lists - can be used like get_cn_node_options[0]
  get_cn_node_options = [
    for i in range(lookup(var.cn_options, "count", 0)) : {
      machine_type = try(lookup(var.cn_options, "options", {})[tostring(i)].machine_type, lookup(var.cn_options, "machine_type", local.defaults.machine_type))
      boot_disk_size = try(lookup(var.cn_options, "options", {})[tostring(i)].boot_disk_size, lookup(var.cn_options, "boot_disk_size", local.defaults.boot_disk_size))
      compute_disk_size = try(lookup(var.cn_options, "options", {})[tostring(i)].compute_disk_size, lookup(var.cn_options, "compute_disk_size", local.defaults.compute_disk_size))
      snapshot_id = try(lookup(var.cn_options, "options", {})[tostring(i)].snapshot_id, lookup(var.cn_options, "snapshot_id", local.defaults.snapshot_id))
      service_account = try(lookup(var.cn_options, "options", {})[tostring(i)].service_account, lookup(var.cn_options, "service_account", null))
      region = try(lookup(var.cn_options, "options", {})[tostring(i)].region, lookup(var.cn_options, "region", var.gcp_region))
      zone = try(lookup(var.cn_options, "options", {})[tostring(i)].zone, lookup(var.cn_options, "zone", null))
      network = try(lookup(var.cn_options, "options", {})[tostring(i)].network, lookup(var.cn_options, "network", local.defaults.network))
      subnetwork = try(lookup(var.cn_options, "options", {})[tostring(i)].subnetwork, lookup(var.cn_options, "subnetwork", local.defaults.subnetwork))
      spot = try(lookup(var.cn_options, "options", {})[tostring(i)].spot, try(lookup(var.cn_options, "options", {})[tostring(i)].spot_vm, try(lookup(var.cn_options, "options", {})[tostring(i)].preemptible, try(var.cn_options.spot, try(var.cn_options.spot_vm, try(var.cn_options.preemptible, false))))))
      spot_instance_termination_action = try(lookup(var.cn_options, "options", {})[tostring(i)].spot_instance_termination_action, lookup(var.cn_options, "spot_instance_termination_action", local.defaults.spot_instance_termination_action))
    }
  ]

  get_pn_node_options = [
    for i in range(lookup(var.pn_options, "count", 0)) : {
      machine_type = try(lookup(var.pn_options, "options", {})[tostring(i)].machine_type, lookup(var.pn_options, "machine_type", local.defaults.machine_type))
      boot_disk_size = try(lookup(var.pn_options, "options", {})[tostring(i)].boot_disk_size, lookup(var.pn_options, "boot_disk_size", local.defaults.boot_disk_size))
      compute_disk_size = try(lookup(var.pn_options, "options", {})[tostring(i)].compute_disk_size, lookup(var.pn_options, "compute_disk_size", local.defaults.compute_disk_size))
      snapshot_id = try(lookup(var.pn_options, "options", {})[tostring(i)].snapshot_id, lookup(var.pn_options, "snapshot_id", local.defaults.snapshot_id))
      service_account = try(lookup(var.pn_options, "options", {})[tostring(i)].service_account, lookup(var.pn_options, "service_account", null))
      region = try(lookup(var.pn_options, "options", {})[tostring(i)].region, lookup(var.pn_options, "region", var.gcp_region))
      zone = try(lookup(var.pn_options, "options", {})[tostring(i)].zone, lookup(var.pn_options, "zone", null))
      network = try(lookup(var.pn_options, "options", {})[tostring(i)].network, lookup(var.pn_options, "network", local.defaults.network))
      subnetwork = try(lookup(var.pn_options, "options", {})[tostring(i)].subnetwork, lookup(var.pn_options, "subnetwork", local.defaults.subnetwork))
      spot = try(lookup(var.pn_options, "options", {})[tostring(i)].spot, try(lookup(var.pn_options, "options", {})[tostring(i)].spot_vm, try(lookup(var.pn_options, "options", {})[tostring(i)].preemptible, try(var.pn_options.spot, try(var.pn_options.spot_vm, try(var.pn_options.preemptible, false))))))
      spot_instance_termination_action = try(lookup(var.pn_options, "options", {})[tostring(i)].spot_instance_termination_action, lookup(var.pn_options, "spot_instance_termination_action", local.defaults.spot_instance_termination_action))
    }
  ]

  get_en_node_options = [
    for i in range(lookup(var.en_options, "count", 0)) : {
      machine_type = try(lookup(var.en_options, "options", {})[tostring(i)].machine_type, lookup(var.en_options, "machine_type", local.defaults.machine_type))
      boot_disk_size = try(lookup(var.en_options, "options", {})[tostring(i)].boot_disk_size, lookup(var.en_options, "boot_disk_size", local.defaults.boot_disk_size))
      compute_disk_size = try(lookup(var.en_options, "options", {})[tostring(i)].compute_disk_size, lookup(var.en_options, "compute_disk_size", local.defaults.compute_disk_size))
      snapshot_id = try(lookup(var.en_options, "options", {})[tostring(i)].snapshot_id, lookup(var.en_options, "snapshot_id", local.defaults.snapshot_id))
      service_account = try(lookup(var.en_options, "options", {})[tostring(i)].service_account, lookup(var.en_options, "service_account", null))
      region = try(lookup(var.en_options, "options", {})[tostring(i)].region, lookup(var.en_options, "region", var.gcp_region))
      zone = try(lookup(var.en_options, "options", {})[tostring(i)].zone, lookup(var.en_options, "zone", null))
      network = try(lookup(var.en_options, "options", {})[tostring(i)].network, lookup(var.en_options, "network", local.defaults.network))
      subnetwork = try(lookup(var.en_options, "options", {})[tostring(i)].subnetwork, lookup(var.en_options, "subnetwork", local.defaults.subnetwork))
      spot = try(lookup(var.en_options, "options", {})[tostring(i)].spot, try(lookup(var.en_options, "options", {})[tostring(i)].spot_vm, try(lookup(var.en_options, "options", {})[tostring(i)].preemptible, try(var.en_options.spot, try(var.en_options.spot_vm, try(var.en_options.preemptible, false))))))
      spot_instance_termination_action = try(lookup(var.en_options, "options", {})[tostring(i)].spot_instance_termination_action, lookup(var.en_options, "spot_instance_termination_action", local.defaults.spot_instance_termination_action))
    }
  ]

  cn_node_settings = [
    for i, options in local.get_cn_node_options : merge(options, {
      zone = options.zone != null ? options.zone : (
        options.region == var.gcp_region && length(var.zone_list) > 0
        ? var.zone_list[i % length(var.zone_list)]
        : format("%s-%s", options.region, local.zone_suffixes[i % length(local.zone_suffixes)])
      )
      network = options.network == "" ? "" : (
        startswith(options.network, "https://") || startswith(options.network, "projects/")
        ? options.network
        : format("projects/%s/global/networks/%s", var.project_id, options.network)
      )
      subnetwork = options.subnetwork == "" ? "" : (
        startswith(options.subnetwork, "https://") || startswith(options.subnetwork, "projects/")
        ? options.subnetwork
        : format("projects/%s/regions/%s/subnetworks/%s", var.project_id, options.region, options.subnetwork)
      )
    })
  ]

  pn_node_settings = [
    for i, options in local.get_pn_node_options : merge(options, {
      zone = options.zone != null ? options.zone : (
        options.region == var.gcp_region && length(var.zone_list) > 0
        ? var.zone_list[i % length(var.zone_list)]
        : format("%s-%s", options.region, local.zone_suffixes[i % length(local.zone_suffixes)])
      )
      network = options.network == "" ? "" : (
        startswith(options.network, "https://") || startswith(options.network, "projects/")
        ? options.network
        : format("projects/%s/global/networks/%s", var.project_id, options.network)
      )
      subnetwork = options.subnetwork == "" ? "" : (
        startswith(options.subnetwork, "https://") || startswith(options.subnetwork, "projects/")
        ? options.subnetwork
        : format("projects/%s/regions/%s/subnetworks/%s", var.project_id, options.region, options.subnetwork)
      )
    })
  ]

  en_node_settings = [
    for i, options in local.get_en_node_options : merge(options, {
      zone = options.zone != null ? options.zone : (
        options.region == var.gcp_region && length(var.zone_list) > 0
        ? var.zone_list[i % length(var.zone_list)]
        : format("%s-%s", options.region, local.zone_suffixes[i % length(local.zone_suffixes)])
      )
      network = options.network == "" ? "" : (
        startswith(options.network, "https://") || startswith(options.network, "projects/")
        ? options.network
        : format("projects/%s/global/networks/%s", var.project_id, options.network)
      )
      subnetwork = options.subnetwork == "" ? "" : (
        startswith(options.subnetwork, "https://") || startswith(options.subnetwork, "projects/")
        ? options.subnetwork
        : format("projects/%s/regions/%s/subnetworks/%s", var.project_id, options.region, options.subnetwork)
      )
    })
  ]

  monitor_settings = merge(local.monitor_options, {
    network = local.monitor_options.network == "" ? "" : (
      startswith(local.monitor_options.network, "https://") || startswith(local.monitor_options.network, "projects/")
      ? local.monitor_options.network
      : format("projects/%s/global/networks/%s", var.project_id, local.monitor_options.network)
    )
    subnetwork = local.monitor_options.subnetwork == "" ? "" : (
      startswith(local.monitor_options.subnetwork, "https://") || startswith(local.monitor_options.subnetwork, "projects/")
      ? local.monitor_options.subnetwork
      : format("projects/%s/regions/%s/subnetworks/%s", var.project_id, local.monitor_options.region, local.monitor_options.subnetwork)
    )
  })
}
