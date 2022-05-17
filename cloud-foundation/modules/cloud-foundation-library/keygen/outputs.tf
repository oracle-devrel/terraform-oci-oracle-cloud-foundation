# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "OPCPrivateKey" {
  value = tomap({"public_key_openssh" = tls_private_key.opc_key.public_key_openssh, "private_key_pem"=tls_private_key.opc_key.private_key_pem})
}

output "OraclePrivateKey" {
  value = tomap({"public_key_openssh"=tls_private_key.oracle_key.public_key_openssh, "private_key_pem"=tls_private_key.oracle_key.private_key_pem})
}

output "SSPrivateKey" {
  value = tomap({"private_key_pem"=tls_private_key.ss_private_key.private_key_pem})
}

output "CertPem" {
  value = tomap({"cert_pem"=tls_self_signed_cert.demo_cert.cert_pem})
}

resource local_file "cert_demo" {
  content              = tls_self_signed_cert.demo_cert.cert_pem
  filename             = "cert_demo.pem"
  file_permission      = 0777
  directory_permission = 0777
}

resource local_file "cert_private_key" {
  content              = tls_private_key.ss_private_key.private_key_pem
  filename             = "cert_private_key.pem"
  file_permission      = 0777
  directory_permission = 0777
}

resource "local_file" "private_key" {
    content  = tls_private_key.opc_key.private_key_pem
    filename = "private_key.pem"
    file_permission = "0600"
}

resource "local_file" "public_key" {
    content  = tls_private_key.opc_key.public_key_openssh
    filename = "public_key.pem"
    file_permission = "0600"
}

