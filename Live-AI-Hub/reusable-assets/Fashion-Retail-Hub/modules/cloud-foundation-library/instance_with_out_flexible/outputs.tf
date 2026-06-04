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

locals {
  linux_instances = {
    for instance in oci_core_instance.instance :
    instance.display_name => { "id" : instance.id, "ip" : instance.public_ip != "" ? instance.public_ip : instance.private_ip }
  }

   linux_ids = {
    for instance in oci_core_instance.instance :
    instance.display_name => instance.id
  }

   linux_private_ips = {
    for instance in oci_core_instance.instance :
    instance.display_name => instance.private_ip
  }

  linux_public_ips = {
    for instance in oci_core_instance.instance :
    instance.display_name => instance.public_ip
  }

  all_instances   = local.linux_ids
  all_private_ips = local.linux_private_ips
  all_public_ips  = local.linux_public_ips
}

output "linux_instances" {
  value = local.linux_instances
}

output "all_instances" {
  value = local.all_instances
}

output "all_private_ips" {
  value = local.all_private_ips
}

output "all_public_ips" {
  value = local.all_public_ips
}