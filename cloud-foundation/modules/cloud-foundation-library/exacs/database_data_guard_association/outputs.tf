# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "exadata_infrastructure_informations" {
  description = "Exadata Infrastructure informations."
  value       = length(oci_database_data_guard_association.this) > 0 ? oci_database_data_guard_association.this[*] : null
}

output "database_data_guard_association" {
  value = {for s in oci_database_data_guard_association.this : s.display_name => s}
}


