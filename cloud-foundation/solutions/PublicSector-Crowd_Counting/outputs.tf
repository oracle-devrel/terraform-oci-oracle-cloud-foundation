# Copyright © 2024, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Autonomous Database Outputs:

output "ADW_Database_db_connection" {
  value = module.adb.db_connection
}

output "Adb_ip" {
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

output "ADW_LOGIN" {
  value = "Please use the ADW URL to login by using the user admin and the password that you have provided."
}

# Analytics Outputs:

output "Analytics_URL" {
  value = module.oac.Analytics_URL
}

# Object Storage Outputs:

output "Buckets" {
  value = module.os.buckets
}

# Instances Outputs:


output "ui_data_server_compute_linux_instances" {
  value = module.ui_data_server.linux_instances
}

output "ui_data_server_all_private_ips" {
  value = module.ui_data_server.all_private_ips
}

output "ui_data_server_public_ip" {
  value = module.ui_data_server.all_public_ips
}

output "Connect-to-Crowdcount-AI-Server-Crowd_Counting_Demo_with_Pre-Captured_Video" {
  value = "* Open a browser and connect to : `http://<ui_data_server_public_ip>:5000"
}

output "Connect-to-Crowdcount-AI-Server-Crowd_Monitoring_Demo_with_IP_Camera_and_Autonomous-DB" {
  value = "* Open a browser and connect to : `http://<ui_data_server_public_ip>:5001 ; and wait for a couple of minutes so the AI will count the people from the cameras and will inject the data inside the database. For more information what to do next and how to use select AI please refer to the readme.md file."
}

output "generated_ssh_private_key_for_bastion" {
  value = nonsensitive(module.keygen.OPCPrivateKey["private_key_pem"])
}

resource "local_file" "private_key" {
    content  = module.keygen.OPCPrivateKey["private_key_pem"]
    filename = "private_key.pem"
    file_permission = 0600
}

