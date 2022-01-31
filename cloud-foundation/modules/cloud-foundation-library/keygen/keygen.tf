# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# TEMP WAY OF CREATING ORACLE SSH KEY FOR DEVELOPMENT
resource "tls_private_key" "oracle_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Creating OPC key for script copy
resource "tls_private_key" "opc_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

//For Load Balancer 
resource "tls_private_key" "ss_private_key" {

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "demo_cert" {

  key_algorithm     = "RSA"
  private_key_pem   = tls_private_key.ss_private_key.private_key_pem

  subject {
    common_name         = format("%s-%s", var.display_name,var.subnet_domain_name)
    organization        = "Demo"
    organizational_unit = "FOR TESTING ONLY"
  }

  #1 year validity
  validity_period_hours = 24 * 365

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}
