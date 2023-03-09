# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Autonomous Database Outputs:

output "adb_admin_password" {
  value = "WlsAtpDb1234#"
}

output "graph_username" {
  value = "MOVIESTREAM"
}

output "graph_password" {
  value = "watchS0meMovies#"
}

output "ADW_Database_db_connection" {
  value = module.adw_database_private_endpoint.db_connection
}

output "ADW_Database_private_endpoint_ip" {
  value = module.adw_database_private_endpoint.private_endpoint_ip
}

output "Database_Actions" {
  value = module.adw_database_private_endpoint.url
}

output "graph_studio_url" {
  value = module.adw_database_private_endpoint.graph_studio_url
}

output "machine_learning_user_management_url" {
  value = module.adw_database_private_endpoint.machine_learning_user_management_url
}

output "database_fully_qualified_name" {
  value = module.adw_database_private_endpoint.database_fully_qualified_name
}
