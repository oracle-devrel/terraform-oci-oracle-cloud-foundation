# Copyright © 2025, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Autonomous Database Outputs:

output "adb_admin_password" {
  description = "ADB Admin password"
  value = var.db_password
  sensitive = true
}

output "adb_user_name" {
  description = "The usernaame inside the database where you will install the apex application"
  value = var.riab_user
}

output "adb_user_password" {
  description = "The password for the user inside the database"
  value = var.riab_password
  sensitive = true
}

output "ADW_Database_db_connection" {
  value = module.adb.db_connection
}

output "Database_Actions" {
  value = module.adb.url
}

output "apex_url" {
  description = "The URL to connect to the workspace of APEX"
  value = module.adb.apex_url
}

output "easyRAG_IN_A_BOX_URL" {
  description = "The URL to connect to the easyRAG_IN_A_BOX with your apex username and password"
  value = module.adb.easyRAG_IN_A_BOX_URL
}

# Object Storage Outputs:

output "Buckets" {
  value = module.os.buckets
}
