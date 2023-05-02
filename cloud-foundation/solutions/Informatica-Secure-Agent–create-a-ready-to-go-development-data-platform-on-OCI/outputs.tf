# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Autonomous Database Outputs:

output "ADW_Database_db_connection" {
  value = module.adw_database.db_connection
}

output "ADW_Database_endpoint_ip" {
  value = module.adw_database.private_endpoint_ip
}

output "Database_Actions" {
  value = module.adw_database.url
}

output "graph_studio_url" {
  value = module.adw_database.graph_studio_url
}

output "machine_learning_user_management_url" {
  value = module.adw_database.machine_learning_user_management_url
}

output "database_fully_qualified_name" {
  value = module.adw_database.database_fully_qualified_name
}

output "ADW_LOGIN" {
  value = "Please use the ADW URL to login by using the user admin and the password that you have provided."
}

# Object Storage Outputs:

output "Buckets" {
  value = module.os.buckets
}

# Instances Outputs:

output "informatica_secure_agent_compute_linux_instances" {
  value = module.informatica_secure_agent.linux_instances
}

output "informatica_secure_agent_all_private_ips" {
  value = module.informatica_secure_agent.all_private_ips
}

output "generated_ssh_private_key_for_instances" {
  value = nonsensitive(module.keygen.OPCPrivateKey["private_key_pem"])
}

resource "local_file" "private_key" {
    content  = module.keygen.OPCPrivateKey["private_key_pem"]
    filename = "private_key.pem"
    file_permission = 0600
}