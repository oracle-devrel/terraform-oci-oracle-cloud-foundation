# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "adb_admin_password" {
  description = "ADMIN password for the Autonomous Database."
  sensitive   = true
  value       = var.adw_db_password
}

output "fsi_db_password" {
  description = "Password for the FSI parsing schema."
  sensitive   = true
  value       = var.fsi_db_password
}

output "database_fully_qualified_name" {
  description = "ADB ORDS/database hostname."
  value       = local.adb_hostname
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

output "Buckets" {
  value = module.os.buckets
}

output "apex_base_url" {
  description = "Base APEX / ORDS URL."
  value       = "${local.adb_base_url}/ords/"
}

output "apex_app_url" {
  description = "Direct CrossShield Insurance application URL."
  value       = "${local.adb_base_url}/ords/r/${lower(var.apex_workspace_name)}/${lower(var.apex_app_alias)}/home"
}

output "apex_workspace" {
  value = var.apex_workspace_name
}

output "apex_username" {
  value = var.apex_builder_username
}

output "apex_password" {
  description = "APEX workspace user password."
  sensitive   = true
  value       = var.apex_builder_password
}

output "apex_login_instructions" {
  description = "APEX login details for the configured workspace user."
  sensitive   = true
  value       = <<-EOT
    APEX URL:
    ${local.adb_base_url}/ords/

    Direct application URL:
    ${local.adb_base_url}/ords/r/${lower(var.apex_workspace_name)}/${lower(var.apex_app_alias)}/home

    Workspace: ${var.apex_workspace_name}
    Username:  ${var.apex_builder_username}
    Password:  ${var.apex_builder_password}
  EOT
}

output "database_actions_url" {
  description = "Database Actions SQL Developer Web URL."
  value       = "${local.adb_base_url}/ords/sql-developer"
}

output "fsi_schema" {
  value = var.fsi_db_schema
}
