# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Autonomous Database Outputs:

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

output "ADW_LOGIN" {
  value = "Please use the ADW URL to login by using the user admin and the password that you have provided."
}

# Instances Outputs:

output "Bastion_compute_linux_instances" {
  value = module.bastion.linux_instances
}

output "Bastion_all_private_ips" {
  value = module.bastion.all_private_ips
}

output "ui_data_server_compute_linux_instances" {
  value = module.ui_data_server.linux_instances
}

output "ui_data_server_all_private_ips" {
  value = module.ui_data_server.all_private_ips
}

output "generated_ssh_private_key_for_bastion" {
  value = nonsensitive(module.keygen.OPCPrivateKey["private_key_pem"])
}

resource "local_file" "private_key" {
    content  = module.keygen.OPCPrivateKey["private_key_pem"]
    filename = "private_key.pem"
    file_permission = 0600
}

# Streaming Outputs:

output "streaming_poolID" {
  value = module.streaming.streaming_poolID
}

output "streaming_ID" {
  value = module.streaming.streaming_ID
}

# Load Balancer Outputs:

output "load_balancer_IP" {
  value = module.lb.load_balancer_IP
}

output "Connect-to-listener-ui-backend" {
  value = "* Open a browser and connect to : `https://load_balancer_public_ip:443"
}

output "Connect-to-listener-data-backend" {
  value = "* Open a browser and connect to : `https://load_balancer_public_ip:1443"
}
