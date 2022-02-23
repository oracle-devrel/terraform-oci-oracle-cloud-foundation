resource "tls_private_key" "oracle_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "opc_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
 
resource "tls_private_key" "ss_private_key" {

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "demo_cert" {

  key_algorithm     = "RSA"
  private_key_pem   = tls_private_key.ss_private_key.private_key_pem

  subject {
    common_name         = format("%s-%s", var.display_name,var.subnet_domain_name)
    organization        = var.organization
    organizational_unit = var.organizational_unit
  }

  validity_period_hours = 24 * 365

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
    "server_auth",
    "key_encipherment",
  ]
}
