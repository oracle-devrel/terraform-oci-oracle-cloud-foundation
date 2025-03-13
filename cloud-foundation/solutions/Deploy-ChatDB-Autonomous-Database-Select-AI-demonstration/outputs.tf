# Copyright © 2025, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Autonomous Database Outputs:

output "adb_admin_password" {
  description = "ADB Admin password"
  value = var.db_password
  sensitive = true
}

output "adb_user_name" {
  description = "Workshop user name"
  value = "MOVIESTREAM"
}

output "adb_user_password" {
  description = "Workshop user initial password"
  value = "watchS0meMovies#"
}

output "ADW_Database_db_connection" {
  value = module.adb.db_connection
}

output "database_fully_qualified_name" {
  value = module.adb.database_fully_qualified_name
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

output "apex_url" {
  value = module.adb.apex_url
}

output "select_ai_demo_url" {
  value = module.adb.select_ai_demo_url
}
