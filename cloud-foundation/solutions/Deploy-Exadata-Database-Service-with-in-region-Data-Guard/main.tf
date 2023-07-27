# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

############################################################

# Generate instance public/private key pair
module "keygen" {
  source             = "../../../cloud-foundation/modules/cloud-foundation-library/keygen"
  display_name       = "keygen"
  subnet_domain_name = "keygen"
}

############################################################

# Networking
module "network-vcn" {
  source               = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"
  compartment_id       = var.compartment_id
  service_label        = ""
  service_gateway_cidr = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block")
  vcns = {
    for k, v in local.vcns-lists : k => v if v.compartment_id != ""
  }
}

module "network-subnets" {
  source               = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"
  compartment_id       = var.compartment_id
  service_label        = ""
  service_gateway_cidr = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block")
  vcns = {
    for k, v in local.subnet-lists : k => v if v.compartment_id != ""
  }
}

module "network-routing" {
  source         = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-routing"
  compartment_id = var.compartment_id
  subnets_route_tables = {
    for k, v in local.subnets_route_tables : k => v if v.compartment_id != ""
  }
}

module "network-routing-attachment" {
  source               = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-routing"
  compartment_id       = var.compartment_id
  subnets_route_tables = local.network-routing-attachment
}

module "network-security-lists" {
  source                               = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/security"
  compartment_id                       = var.compartment_id
  ports_not_allowed_from_anywhere_cidr = []
  security_lists = {
    for k, v in local.security_lists : k => v if v.compartment_id != ""
  }
}

############################################################

# Create Bastion
module "bastion" {
  source          = "../../../cloud-foundation/modules/cloud-foundation-library/instance_with_out_flexible"
  tenancy_ocid    = var.tenancy_ocid
  instance_params = local.instance_params
}

############################################################
# Exadata Infrastructure in AD 1:

module "exadata_infrastructure_firstAD" {
  source                 = "../../../cloud-foundation/modules/cloud-foundation-library/exacs/exadata_infrastructure"
  tenancy_ocid           = var.tenancy_ocid
  exadata_infrastructure = local.exadata_infrastructure_firstAD
}

module "cloud_vm_cluster_firstAD" {
  source           = "../../../cloud-foundation/modules/cloud-foundation-library/exacs/cloud_vm_cluster"
  cloud_vm_cluster = local.cloud_vm_cluster_firstAD
}

module "database_db_home_firstAD" {
  source           = "../../../cloud-foundation/modules/cloud-foundation-library/exacs/database_db_home"
  database_db_home = local.database_db_home_firstAD
}

############################################################
# Exadata Infrastructure in AD 2:

module "exadata_infrastructure_secondAD" {
  source                 = "../../../cloud-foundation/modules/cloud-foundation-library/exacs/exadata_infrastructure"
  tenancy_ocid           = var.tenancy_ocid
  exadata_infrastructure = local.exadata_infrastructure_secondAD
}

module "cloud_vm_cluster_secondAD" {
  source           = "../../../cloud-foundation/modules/cloud-foundation-library/exacs/cloud_vm_cluster"
  cloud_vm_cluster = local.cloud_vm_cluster_secondAD
}

############################################################
# Data Guard Association:

module "database_data_guard_association" {
  source                          = "../../../cloud-foundation/modules/cloud-foundation-library/exacs/database_data_guard_association"
  depends_on                      = [module.cloud_vm_cluster_firstAD, module.cloud_vm_cluster_secondAD]
  compartment_id                  = var.compartment_id
  db_home_id                      = module.database_db_home_firstAD.db_system_id
  database_data_guard_association = local.database_data_guard_association
}

############################################################