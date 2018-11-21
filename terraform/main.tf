provider "vault" {
  # Set token via VAULT_TOKEN=<token>
  address = "https://vault.vm:8200"
  ca_cert_file = "/etc/vault/keys/ca_cert.pem"
}

resource "vault_policy" "hiera_vault" {
  name = "hiera"

  policy = <<EOT
path "secret/*" {
  capabilities = ["read"]
}
EOT
}

resource "vault_auth_backend" "cert" {
  path = "cert"
  type = "cert"
}

resource "vault_cert_auth_backend_role" "puppetserver" {
  name          = "puppetserver"
  display_name  = "puppet"
  ttl           = 3600
  policies      = ["all_secrets"]
  certificate   = "${file("/etc/vault/keys/ca_cert.pem")}"
}
