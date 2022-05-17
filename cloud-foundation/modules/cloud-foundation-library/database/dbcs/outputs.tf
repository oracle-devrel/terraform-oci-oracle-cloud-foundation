# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "dbcs_info" {
  value = { for db in oci_database_db_system.this: db.display_name => db.id }
}
