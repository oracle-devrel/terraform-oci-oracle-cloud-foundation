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


# Bastion Instance Outputs:

output "bastion-all_instances" {
  value = module.bastion.all_instances
}

output "bastion-all_private_ips" {
  value = module.bastion.all_private_ips
}

output "bastion-all_public_ips" {
  value = module.bastion.all_public_ips
}

## Exadata Infrastructure in First AD

output "exadata_infrastructure_informations_firstAD" {
  value = module.exadata_infrastructure_firstAD.exadata_infrastructure_informations
}

output "cloud_vm_cluster_informations_firstAD" {
  value = module.cloud_vm_cluster_firstAD.cloud_vm_cluster_informations
}

output "db_home_id_firstAD" {
  value = module.database_db_home_firstAD.db_home_id
}

output "db_system_id_firstAD" {
  value = module.database_db_home_firstAD.db_system_id
}

## Exadata Infrastructure in Second AD

output "exadata_infrastructure_informations_secondAD" {
  value = module.exadata_infrastructure_secondAD.exadata_infrastructure_informations
}

output "cloud_vm_cluster_informations_secondAD" {
  value = module.cloud_vm_cluster_secondAD.cloud_vm_cluster_informations
}
