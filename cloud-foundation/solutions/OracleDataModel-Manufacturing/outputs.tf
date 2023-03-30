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
  value = "Please use the ADW URL to login by using the user admin and the password that you have provided."
}


# Autonomous Database Outputs:


output "ADW_Database_db_connection" {
  value = module.adw_database_private_endpoint.db_connection
}

output "ADW_Database_private_endpoint_ip" {
  value = module.adw_database_private_endpoint.private_endpoint_ip
}


# Analytics Outputs:

output "Analytics_URL" {
  value = module.oac.Analytics_URL
}


# Object Storage Outputs:

output "Buckets" {
  value = module.os.buckets
}


# # Data Catalog Outputs:

# output "DataCatalog_Name" {
#   value = module.datacatalog.datacatalog
# }

# output "datacatalog_data_asset" {
#   value = module.datacatalog.datacatalog_data_asset
# }

# output "datacatalog_connection" {
#   value = module.datacatalog.datacatalog_connection
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

output tenancy_name {
  value = lower(data.oci_identity_tenancy.tenancy.name)
}

output home_region_for_oac {
  value = lower(substr(local.home_region_for_oac, 0, 2))
}
