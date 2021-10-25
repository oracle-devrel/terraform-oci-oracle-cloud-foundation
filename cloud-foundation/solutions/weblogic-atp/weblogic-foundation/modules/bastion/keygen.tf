# Creating OPC key bastion host
# Either key1 or key2 is used based on the number of node count.
# This is work around to trigger creation of new bastion for scale out.

resource "tls_private_key" "opc_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}