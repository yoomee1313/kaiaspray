locals {
  ansible_inventory = templatefile(
    "${path.module}/templates/inventory.tftpl",
    {
      ansible_ssh_private_key_file = var.create_gcp_key_pair ? module.keypair.ssh_private_key_path : "<change-me>"
      cn                           = try(module.layer1.cn, [])
      pn                           = try(module.layer1.pn, [])
      en                           = try(module.layer1.en, [])
      monitor                      = try(module.layer1.monitor, {})
    }
  )
}
resource "local_file" "this" {
  content  = local.ansible_inventory
  filename = format("%s/../../../inventory/%s/inventory.ini", path.module, basename(abspath(path.module)))
}
