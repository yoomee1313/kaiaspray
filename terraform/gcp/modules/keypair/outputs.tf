output "key_pair_name" {
  value = var.name
}

output "ssh_public_key" {
  value = local.public_key
}

output "ssh_private_key_path" {
  value = var.create_gcp_key_pair ? var.ssh_private_key_path : var.ssh_existing_private_key_path
}

output "ssh_key_file_created" {
  value = var.create_gcp_key_pair ? local_sensitive_file.this[0].id : "existing_key"
}
