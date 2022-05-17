# # Copyright © 2022, Oracle and/or its affiliates.
# # All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "external_containers_database" {
  description = "External Containers Database informations."
  value       = length(oci_database_external_container_database.this) > 0 ? oci_database_external_container_database.this[*] : null
}

output "external_pluggable_database" {
  description = "External Pluggable Database informations."
  value       = length(oci_database_external_pluggable_database.this) > 0 ? oci_database_external_pluggable_database.this[*] : null
}
