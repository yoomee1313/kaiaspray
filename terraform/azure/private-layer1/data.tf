data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

data "azurerm_platform_image" "rocky" {
  location  = data.azurerm_resource_group.this.location
  publisher = "resf"
  offer     = "rockylinux-x86_64"
  sku       = "9-base"
}
