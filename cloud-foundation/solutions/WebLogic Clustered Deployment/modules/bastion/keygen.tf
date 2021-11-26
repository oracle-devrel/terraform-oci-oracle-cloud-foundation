resource "tls_private_key" "opc_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}