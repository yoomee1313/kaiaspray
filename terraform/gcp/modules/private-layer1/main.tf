module "cn" {
  count = length(local.cn_node_settings)

  source = "../kaia-node"

  name         = format("%s-cn-%d", var.name, count.index + 1)
  
  # Get node settings with index-based overrides
  machine_type = local.cn_node_settings[count.index].machine_type

  network       = local.cn_node_settings[count.index].network
  subnetwork    = local.cn_node_settings[count.index].subnetwork
  zone          = local.cn_node_settings[count.index].zone
  use_public_ip = true
  region        = local.cn_node_settings[count.index].region
  network_tier  = var.network_tier
  spot          = local.cn_node_settings[count.index].spot
  spot_instance_termination_action = local.cn_node_settings[count.index].spot_instance_termination_action

  boot_disk = {
    image_id       = var.boot_image_id
    boot_disk_size = local.cn_node_settings[count.index].boot_disk_size
  }

  compute_disk = local.cn_node_settings[count.index].compute_disk_size != null ? {
    name        = format("%s-cn-%d-disk", var.name, count.index + 1)
    type        = "pd-ssd"
    zone        = local.cn_node_settings[count.index].zone
    size        = local.cn_node_settings[count.index].compute_disk_size
    snapshot    = local.cn_node_settings[count.index].snapshot_id
  } : null

  tags = length(var.network_tags) > 0 ? concat(var.network_tags) : ["kaiaspray", "cn"]

  metadata = merge(var.metadata, {
    Name = format("%s-cn-%d", var.name, count.index + 1)
  })

  service_account = local.cn_node_settings[count.index].service_account
}

module "pn" {
  count = length(local.pn_node_settings)

  source = "../kaia-node"

  name         = format("%s-pn-%d", var.name, count.index + 1)
  
  # Get node settings with index-based overrides
  machine_type = local.pn_node_settings[count.index].machine_type

  network       = local.pn_node_settings[count.index].network
  subnetwork    = local.pn_node_settings[count.index].subnetwork
  zone          = local.pn_node_settings[count.index].zone
  use_public_ip = true
  region        = local.pn_node_settings[count.index].region
  network_tier  = var.network_tier
  spot          = local.pn_node_settings[count.index].spot
  spot_instance_termination_action = local.pn_node_settings[count.index].spot_instance_termination_action

  boot_disk = {
    image_id       = var.boot_image_id
    boot_disk_size = local.pn_node_settings[count.index].boot_disk_size
  }

  compute_disk = local.pn_node_settings[count.index].compute_disk_size != null ? {
    name = format("%s-pn-%d-disk", var.name, count.index + 1)
    type = "pd-ssd"
    zone = local.pn_node_settings[count.index].zone
    size = local.pn_node_settings[count.index].compute_disk_size
    snapshot = local.pn_node_settings[count.index].snapshot_id
  } : null

  tags = length(var.network_tags) > 0 ? concat(var.network_tags) : ["kaiaspray", "pn"]

  metadata = merge(var.metadata, {
    Name = format("%s-pn-%d", var.name, count.index + 1)
  })

  service_account = local.pn_node_settings[count.index].service_account
}

module "en" {
  count = length(local.en_node_settings)

  source = "../kaia-node"

  name         = format("%s-en-%d", var.name, count.index + 1)
  
  # Get node settings with index-based overrides
  machine_type = local.en_node_settings[count.index].machine_type

  network       = local.en_node_settings[count.index].network
  subnetwork    = local.en_node_settings[count.index].subnetwork
  zone          = local.en_node_settings[count.index].zone
  use_public_ip = true
  region        = local.en_node_settings[count.index].region
  network_tier  = var.network_tier
  spot          = local.en_node_settings[count.index].spot
  spot_instance_termination_action = local.en_node_settings[count.index].spot_instance_termination_action

  boot_disk = {
    image_id       = var.boot_image_id
    boot_disk_size = local.en_node_settings[count.index].boot_disk_size
  }

  compute_disk = local.en_node_settings[count.index].compute_disk_size != null ? {
    name = format("%s-en-%d-disk", var.name, count.index + 1)
    type = "pd-ssd"
    zone = local.en_node_settings[count.index].zone
    size = local.en_node_settings[count.index].compute_disk_size
    snapshot = local.en_node_settings[count.index].snapshot_id
  } : null

  tags = length(var.network_tags) > 0 ? concat(var.network_tags) : ["kaiaspray", "en"]

  metadata = merge(var.metadata, {
    Name = format("%s-en-%d", var.name, count.index + 1)
  })

  service_account = local.en_node_settings[count.index].service_account
}

module "monitor" {
  source = "../kaia-node"

  name         = format("%s-monitor", var.name)
  machine_type = local.monitor_settings.machine_type

  network       = local.monitor_settings.network
  subnetwork    = local.monitor_settings.subnetwork
  zone          = local.monitor_settings.zone
  use_public_ip = true
  region        = local.monitor_settings.region
  network_tier  = var.network_tier
  spot          = local.monitor_settings.spot
  spot_instance_termination_action = local.monitor_settings.spot_instance_termination_action

  boot_disk = {
    image_id       = var.boot_image_id
    boot_disk_size = local.monitor_settings.boot_disk_size
  }

  compute_disk = try(local.monitor_settings.compute_disk_size, null) != null ? {
    name = format("%s-monitor-disk", var.name)
    type = "pd-ssd"
    zone = local.monitor_settings.zone
    size = local.monitor_settings.compute_disk_size
    snapshot = try(local.monitor_settings.snapshot_id, null)
  } : null

  tags = length(var.network_tags) > 0 ? var.network_tags : ["kaiaspray", "monitor"]

  metadata = merge(var.metadata, {
    Name = format("%s-monitor", var.name)
  })

  service_account = null
}

# Provisioner for CN nodes with compute disk
resource "null_resource" "cn_disk_mount" {
  for_each = {
    for idx, options in local.get_cn_node_options : idx => options
    if options.compute_disk_size != null
  }

  depends_on = [var.ssh_key_file_created]

  triggers = {
    instance_id = module.cn[each.key].instance_link
    ssh_key_file = var.ssh_key_file_created
  }

  provisioner "file" {
    source   = "${path.module}/mount_disk.sh"
    destination = "/tmp/mount_disk.sh"

    connection {
      type        = "ssh"
      user        = var.user_name
      private_key = file(var.ssh_private_key_path)
      host        = module.cn[each.key].public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/mount_disk.sh",
      "sudo /tmp/mount_disk.sh ${format("%s-cn-%d-disk", var.name, each.key + 1)} kcnd"
    ]

    connection {
      type        = "ssh"
      user        = var.user_name
      private_key = file(var.ssh_private_key_path)
      host        = module.cn[each.key].public_ip
    }
  }
}

# Provisioner for PN nodes with compute disk
resource "null_resource" "pn_disk_mount" {
  for_each = {
    for idx, options in local.get_pn_node_options : idx => options
    if options.compute_disk_size != null
  }

  depends_on = [var.ssh_key_file_created]

  triggers = {
    instance_id = module.pn[each.key].instance_link
    ssh_key_file = var.ssh_key_file_created
  }

  provisioner "file" {
    source   = "${path.module}/mount_disk.sh"
    destination = "/tmp/mount_disk.sh"

    connection {
      type        = "ssh"
      user        = var.user_name
      private_key = file(var.ssh_private_key_path)
      host        = module.pn[each.key].public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/mount_disk.sh",
      "sudo /tmp/mount_disk.sh ${format("%s-pn-%d-disk", var.name, each.key + 1)} kpnd"
    ]

    connection {
      type        = "ssh"
      user        = var.user_name
      private_key = file(var.ssh_private_key_path)
      host        = module.pn[each.key].public_ip
    }
  }
}

# Provisioner for EN nodes with compute disk
resource "null_resource" "en_disk_mount" {
  for_each = {
    for idx, options in local.get_en_node_options : idx => options
    if options.compute_disk_size != null
  }

  depends_on = [var.ssh_key_file_created]

  triggers = {
    instance_id = module.en[each.key].instance_link
    ssh_key_file = var.ssh_key_file_created
  }

  provisioner "file" {
    source   = "${path.module}/mount_disk.sh"
    destination = "/tmp/mount_disk.sh"

    connection {
      type        = "ssh"
      user        = var.user_name
      private_key = file(var.ssh_private_key_path)
      host        = module.en[each.key].public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/mount_disk.sh",
      "sudo /tmp/mount_disk.sh ${format("%s-en-%d-disk", var.name, each.key + 1)} kend"
    ]

    connection {
      type        = "ssh"
      user        = var.user_name
      private_key = file(var.ssh_private_key_path)
      host        = module.en[each.key].public_ip
    }
  }
}

# Provisioner for Monitor node with compute disk
resource "null_resource" "monitor_disk_mount" {
  count = try(local.monitor_options.compute_disk_size, null) != null ? 1 : 0

  depends_on = [var.ssh_key_file_created]

  triggers = {
    instance_id = module.monitor.instance_link
    ssh_key_file = var.ssh_key_file_created
  }

  provisioner "file" {
    source   = "${path.module}/mount_disk.sh"
    destination = "/tmp/mount_disk.sh"

    connection {
      type        = "ssh"
      user        = var.user_name
      private_key = file(var.ssh_private_key_path)
      host        = module.monitor.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/mount_disk.sh",
      "sudo /tmp/mount_disk.sh ${format("%s-monitor-disk", var.name)} monitor"
    ]

    connection {
      type        = "ssh"
      user        = var.user_name
      private_key = file(var.ssh_private_key_path)
      host        = module.monitor.public_ip
    }
  }
}
