locals {
  name = var.name != null ? var.name : format("%s-%s", random_pet.this.id, random_string.this.id)

  key_name = module.keypair.key_name

  source_image_reference = {
    publisher = data.azurerm_platform_image.rocky.publisher
    offer     = data.azurerm_platform_image.rocky.offer
    sku       = data.azurerm_platform_image.rocky.sku
    version   = data.azurerm_platform_image.rocky.version
  }

  default_tags = merge(
    var.tags,
    {
      Name      = local.name
      ManagedBy = "terraform"
    }
  )
}

resource "random_string" "this" {
  length  = 4
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "random_pet" "this" {}
