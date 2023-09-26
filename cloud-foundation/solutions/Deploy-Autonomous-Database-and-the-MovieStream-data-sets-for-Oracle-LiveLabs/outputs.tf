# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Autonomous Database Outputs:

output "adb_admin_password" {
  value = "WlsAtpDb1234#"
}

output "adb_user_name" {
  value = "MOVIESTREAM"
}

output "adb_user_password" {
  value = "watchS0meMovies#"
}

output "ADW_Database_db_connection" {
  value = module.adb.db_connection
}

output "ADW_Database_ip" {
  value = module.adb.private_endpoint_ip
}

output "Database_Actions" {
  value = module.adb.url
}

output "graph_studio_url" {
  value = module.adb.graph_studio_url
}

output "machine_learning_user_management_url" {
  value = module.adb.machine_learning_user_management_url
}

output "database_fully_qualified_name" {
  value = module.adb.database_fully_qualified_name
}
