resource "tls_private_key" "this" {
  count     = var.create_gcp_key_pair ? 1 : 0  # Create only if true
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_sensitive_file" "this" {
  count = var.create_gcp_key_pair ? 1 : 0  # Create only if true

  content         = tls_private_key.this[0].private_key_openssh
  filename        = var.ssh_private_key_path
  file_permission = "0400"
}

data "tls_public_key" "this" {
  count = var.create_gcp_key_pair ? 1 : 0  # Create only if the private key exists

  private_key_pem = length(tls_private_key.this) > 0 ? tls_private_key.this[0].private_key_pem : null
}
