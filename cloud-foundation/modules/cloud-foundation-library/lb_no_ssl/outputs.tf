# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "BackendsetNames" {
  value = [ for b in oci_load_balancer_backend_set.these : b.name]
}

output "SSLHeadersNames" {
  value = [ for b in oci_load_balancer_rule_set.these : b.name]
}

output "CertificateNames" {
  value = [ for b in oci_load_balancer_certificate.these : b.certificate_name]
}

output "load_balancer_id" {
  value = element(coalescelist([for b in oci_load_balancer_load_balancer.these : b.id], tolist([""])), 0)
}

output "load_balancer_IP" {
  value = [for b in oci_load_balancer_load_balancer.these : b.ip_addresses]
}

output "CertificatesIds" {
  value = [ for b in oci_load_balancer_certificate.these : b.id]
}