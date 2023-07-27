# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "cloud_vm_cluster_informations" {
  description = "Cloud VM Cluster informations."
  value       = length(oci_database_cloud_vm_cluster.this) > 0 ? oci_database_cloud_vm_cluster.this[*] : null
}

output "cloud_vm_cluster_id" {
  value       = [for b in oci_database_cloud_vm_cluster.this : b.id]
}

