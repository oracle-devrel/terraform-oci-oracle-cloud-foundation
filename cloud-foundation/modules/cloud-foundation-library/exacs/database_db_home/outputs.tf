# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "database_db_home" {
  description = "Database DB HOME informations."
  value       = length(oci_database_db_home.this) > 0 ? oci_database_db_home.this[*] : null
}

output "db_home_id" {
  value       = [ for b in oci_database_db_home.this : b.id]
}

output "db_system_id" {
  value = join(", ", [for b in oci_database_db_home.this : b.id])
}

