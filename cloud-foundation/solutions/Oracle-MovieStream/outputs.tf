# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "local_file" "private_key" {
    content  = module.keygen.OPCPrivateKey["private_key_pem"]
    filename = "private_key.pem"
    file_permission = 0600
}

output "generated_ssh_private_key_for_bastion" {
  value = nonsensitive(module.keygen.OPCPrivateKey["private_key_pem"])
}

output "Instructions" {
  value = "Please use the public IP address listed below to connect to the moviestream application via a web-browser."
}


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

output "Connect-to-Autonomous-Database-MovieStream-User" {
  value = "* User: `MOVIESTREAM`, Password: `watchS0meMovies#`"
}

output "Connect-to-Autonomous-Database-Admin-User" {
  value = "* User: `ADMIN`, Password: `WlsAtpDb1234#`"
}

# # Data Catalog Outputs:

# output "DataCatalog_Name" {
#   value = toset(module.datacatalog[*].datacatalog)
# }

# output "datacatalog_data_asset" {
#   value = toset(module.datacatalog[*].datacatalog_data_asset)
# }

# output "datacatalog_connection" {
#   value = toset(module.datacatalog[*].datacatalog_connection)
# }


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




