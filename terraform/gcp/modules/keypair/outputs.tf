output "ssh_private_key" {
  value = var.create_gcp_key_pair ? try(tls_private_key.this[0].private_key_openssh, null) : null
}

output "ssh_public_key" {
  value = var.create_gcp_key_pair ? try(data.tls_public_key.this[0].public_key_openssh, null) : null
}

output "ssh_private_key_path" {
  value = var.create_gcp_key_pair ? try(local_sensitive_file.this[0].filename, null) : null
}
