# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "exadata_infrastructure_informations" {
  description = "Exadata Infrastructure informations."
  value       = length(oci_database_cloud_exadata_infrastructure.this) > 0 ? oci_database_cloud_exadata_infrastructure.this[*] : null
}

output "cloud_exadata_infrastructure_id" {
  value       = [ for b in oci_database_cloud_exadata_infrastructure.this : b.id]
}
