# # Copyright © 2023, Oracle and/or its affiliates.
# # All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "local_file" "private_key" {
  content         = module.keygen.OPCPrivateKey["private_key_pem"]
  filename        = "private_key.pem"
  file_permission = 0600
}

output "generated_ssh_private_key_for_bastion" {
  value = nonsensitive(module.keygen.OPCPrivateKey["private_key_pem"])
}

# Remote Peeting Details

output "Remote_Peeting_Region1" {
  value = module.remote_peering.Remote_Peeting_Region1
}

output "Remote_Peeting_Region2" {
  value = module.remote_peering.Remote_Peeting_Region2
}

# Bastion Instance Outputs Region 1

output "bastion_region1-all_instances" {
  value = module.bastion_region1.all_instances
}

output "bastion_region1-all_private_ips" {
  value = module.bastion_region1.all_private_ips
}

output "bastion_region1-all_public_ips" {
  value = module.bastion_region1.all_public_ips
}

# Bastion Instance Outputs Region 2

output "bastion_region2-all_instances" {
  value = module.bastion_region2.all_instances
}

output "bastion_region2-all_private_ips" {
  value = module.bastion_region2.all_private_ips
}

output "bastion_region2-all_public_ips" {
  value = module.bastion_region2.all_public_ips
}

## Exadata Infrastructure in Region 1

output "exadata_infrastructure_informations_region1" {
  value = module.exadata_infrastructure_region1.exadata_infrastructure_informations
}

output "cloud_vm_cluster_informations_region1" {
  value = module.cloud_vm_cluster_region1.cloud_vm_cluster_informations
}

output "db_home_id_region1" {
  value = module.database_db_home_region1.db_home_id
}

output "db_system_id_region1" {
  value = module.database_db_home_region1.db_system_id
}

## Exadata Infrastructure in Region 2

output "exadata_infrastructure_informations_region2" {
  value = module.exadata_infrastructure_region2.exadata_infrastructure_informations
}

output "cloud_vm_cluster_informations_region2" {
  value = module.cloud_vm_cluster_region2.cloud_vm_cluster_informations
}
