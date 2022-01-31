# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Output the private and public IPs of the instance
output "InstancePrivateIPs" {
  value = [ for b in oci_core_instance.instance : b.private_ip]
}

output "InstancePublicIPs" {
  value = [ for b in oci_core_instance.instance : b.public_ip]
}

output "InstanceOcids" {
  value = [ for b in oci_core_instance.instance : b.id]
}

output "display_names" {
  value = [ for b in oci_core_instance.instance : b.display_name]
}

output "InstanceShapes" {
  value = [ for b in oci_core_instance.instance : b.shape]
}

output "AvailabilityDomains" {
  value = [ for b in oci_core_instance.instance : b.availability_domain]
}