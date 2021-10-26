output "OPCPrivateKey" {
  value = "${tomap({"public_key_openssh" = tls_private_key.opc_key.public_key_openssh, "private_key_pem"=tls_private_key.opc_key.private_key_pem})}"
}

output "OraclePrivateKey" {
  value = "${tomap({"public_key_openssh"=tls_private_key.oracle_key.public_key_openssh, "private_key_pem"=tls_private_key.oracle_key.private_key_pem})}"
}

output "SSPrivateKey" {
  value = "${tomap({"private_key_pem"=tls_private_key.ss_private_key.private_key_pem})}"
}

output "CertPem" {
  value = "${tomap({"cert_pem"=tls_self_signed_cert.demo_cert.cert_pem})}"
}