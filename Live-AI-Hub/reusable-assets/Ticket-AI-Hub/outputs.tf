# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Autonomous Database Outputs:

output "adb_admin_password" {
  description = "ADB Admin password"
  value       = var.adw_db_password
  sensitive   = true
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

output "ATP_Mongo_DB_URL" {
  value = try(module.adb.mongo_db_urls["atp"], null)
}

# Object Storage Outputs:

output "Buckets" {
  value = module.os.buckets
}

output "apex_base_url" {
  description = "Base APEX / ORDS URL"
  value       = "https://${module.adb.database_fully_qualified_name}/ords/"
}

output "apex_app_url" {
  description = "Direct APEX application URL"
  value       = "https://${module.adb.database_fully_qualified_name}/ords/r/${lower(var.apex_workspace_name)}/${lower(var.apex_app_alias)}/home"
}

output "apex_workspace" {
  description = "APEX workspace name"
  value       = var.apex_workspace_name
}

output "apex_username" {
  description = "APEX builder / app username"
  value       = var.apex_builder_username
}

output "apex_password" {
  description = "APEX builder / app password"
  value       = nonsensitive(var.apex_builder_password)
}

output "apex_login_instructions" {
  description = "How to log in to APEX"
  value = <<EOT
APEX URL:
https://${module.adb.database_fully_qualified_name}/ords/

Direct Application URL:
https://${module.adb.database_fully_qualified_name}/ords/r/${lower(var.apex_workspace_name)}/${lower(var.apex_app_alias)}/home

Login credentials:
Workspace: ${var.apex_workspace_name}
Username: ${var.apex_builder_username}
Password: ${nonsensitive(var.apex_builder_password)}

Notes:
1. Use the APEX URL to open App Builder / workspace login.
2. Use the Direct Application URL to open the app directly.
EOT
}

output "database_actions_url" {
  description = "Database Actions URL"
  value       = "https://${module.adb.database_fully_qualified_name}/ords/sql-developer"
}