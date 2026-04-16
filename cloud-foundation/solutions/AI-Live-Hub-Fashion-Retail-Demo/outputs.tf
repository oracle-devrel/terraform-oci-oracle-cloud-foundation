# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "local_file" "private_key" {
  content  = module.keygen.OPCPrivateKey["private_key_pem"]
  filename = "private_key.pem"
  file_permission = 0600
}

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

output "cart_api_gateway_id" {
  value = module.cart_api_gateway.gateway_id
}

output "cart_api_gateway_hostname" {
  value = module.cart_api_gateway.gateway_hostname
}

output "cart_api_deployment_id" {
  value = module.cart_api_gateway.deployment_id
}

output "cart_api_deployment_endpoint" {
  value = module.cart_api_gateway.deployment_endpoint
}

output "cart_api_routes" {
  value = module.cart_api_gateway.routes
}

# Bastion Instance Outputs:

output "web-instance-all_instances" {
  value = module.web-instance.all_instances
}

output "web-instance-all_private_ips" {
  value = module.web-instance.all_private_ips
}

output "web-instance-all_public_ips" {
  value = module.web-instance.all_public_ips
}

output "application_url" {
  description = "Fashion Retail application URL"
  value       = "http://${values(module.web-instance.all_public_ips)[0]}:5000"
}

output "application_access_instructions" {
  description = "How to access the deployed AI Live Hub Fashion Retail demo"
  value       = <<EOT
Open a browser and navigate to the application URL above.

Then sign in with one of the demo users populated from the database.

Example credentials:
- Username: tammy.bryant@internalmail
- Password: user
EOT
}

output "generated_ssh_private_key_for_bastion" {
  description = "Generated SSH private key for the bastion / web instance"
  value       = nonsensitive(module.keygen.OPCPrivateKey["private_key_pem"])
}