# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

############################################################

# Generate instance public/private key pair - Common for both regions
module "keygen" {
  source             = "../../../cloud-foundation/modules/cloud-foundation-library/keygen"
  display_name       = "keygen"
  subnet_domain_name = "keygen"
}

############################################################

# Networking for Region 1
module "network-vcn_region1" {
  source               = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"
  providers            = { oci = oci.first }
  compartment_id       = var.compartment_id
  service_label        = ""
  service_gateway_cidr = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block")
  vcns = {
    for k, v in local.vcns-lists : k => v if v.compartment_id != ""
  }
}

module "network-subnets_region1" {
  source               = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"
  providers            = { oci = oci.first }
  compartment_id       = var.compartment_id
  service_label        = ""
  service_gateway_cidr = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block")
  vcns = {
    for k, v in local.subnet-lists : k => v if v.compartment_id != ""
  }
}

module "network-routing_region1" {
  source         = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-routing"
  providers      = { oci = oci.first }
  compartment_id = var.compartment_id
  subnets_route_tables = {
    for k, v in local.subnets_route_tables : k => v if v.compartment_id != ""
  }
}

module "network-routing-attachment_region1" {
  source               = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-routing"
  providers            = { oci = oci.first }
  compartment_id       = var.compartment_id
  subnets_route_tables = local.network-routing-attachment
}

module "network-security-lists_region1" {
  source                               = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/security"
  providers                            = { oci = oci.first }
  compartment_id                       = var.compartment_id
  ports_not_allowed_from_anywhere_cidr = []
  security_lists = {
    for k, v in local.security_lists : k => v if v.compartment_id != ""
  }
}

# Create Bastion Region 1
module "bastion_region1" {
  source          = "../../../cloud-foundation/modules/cloud-foundation-library/instance_with_out_flexible"
  providers       = { oci = oci.first }
  tenancy_ocid    = var.tenancy_ocid
  instance_params = local.instance_params_region1
}

############################################################

# Networking for Region 2 
module "network-vcn_region2" {
  source               = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"
  providers            = { oci = oci.second }
  compartment_id       = var.compartment_id
  service_label        = ""
  service_gateway_cidr = local.valid_service_gateway_cidrs[0]
  vcns = {
    for k, v in local.vcns-lists_region2 : k => v if v.compartment_id != ""
  }
}

module "network-subnets_region2" {
  source               = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"
  providers            = { oci = oci.second }
  compartment_id       = var.compartment_id
  service_label        = ""
  service_gateway_cidr = local.valid_service_gateway_cidrs[0]
  vcns = {
    for k, v in local.subnet-lists_region2 : k => v if v.compartment_id != ""
  }
}

module "network-routing_region2" {
  source         = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-routing"
  providers      = { oci = oci.second }
  compartment_id = var.compartment_id
  subnets_route_tables = {
    for k, v in local.subnets_route_tables_region2 : k => v if v.compartment_id != ""
  }
}

module "network-routing-attachment_region2" {
  source               = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-routing"
  providers            = { oci = oci.second }
  compartment_id       = var.compartment_id
  subnets_route_tables = local.network-routing-attachment_region2
}

module "network-security-lists_region2" {
  source                               = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/security"
  providers                            = { oci = oci.second }
  compartment_id                       = var.compartment_id
  ports_not_allowed_from_anywhere_cidr = []
  security_lists = {
    for k, v in local.security_lists_region2 : k => v if v.compartment_id != ""
  }
}

# Create Bastion Region 2
module "bastion_region2" {
  source          = "../../../cloud-foundation/modules/cloud-foundation-library/instance_with_out_flexible"
  providers       = { oci = oci.second }
  tenancy_ocid    = var.tenancy_ocid
  instance_params = local.instance_params_region2
}


############################################################
# VCN remote peering between Regions

module "remote_peering" {
  source     = "../../../cloud-foundation/modules/cloud-foundation-library/remote-peering"
  depends_on = [module.network-vcn_region1, module.network-vcn_region2]
  providers = {
    oci.requestor = oci.first
    oci.acceptor  = oci.second
  }
  compartment_id   = var.compartment_id
  vcns             = module.network-vcn_region1.vcnss
  vcns2            = module.network-vcn_region2.vcnss
  rpg_params       = local.rpg_params
  requestor_region = var.region
  acceptor_region  = var.region2
}

############################################################
# Exadata Infrastructure in Region 1

module "exadata_infrastructure_region1" {
  source                 = "../../../cloud-foundation/modules/cloud-foundation-library/exacs/exadata_infrastructure"
  providers              = { oci = oci.first }
  tenancy_ocid           = var.tenancy_ocid
  exadata_infrastructure = local.exadata_infrastructure_region1
}

module "cloud_vm_cluster_region1" {
  source           = "../../../cloud-foundation/modules/cloud-foundation-library/exacs/cloud_vm_cluster"
  providers        = { oci = oci.first }
  cloud_vm_cluster = local.cloud_vm_cluster_region1
}

module "database_db_home_region1" {
  source           = "../../../cloud-foundation/modules/cloud-foundation-library/exacs/database_db_home"
  providers        = { oci = oci.first }
  database_db_home = local.database_db_home_region1
}

############################################################
# Exadata Infrastructure in Region 2:

module "exadata_infrastructure_region2" {
  source                 = "../../../cloud-foundation/modules/cloud-foundation-library/exacs/exadata_infrastructure"
  providers              = { oci = oci.second }
  tenancy_ocid           = var.tenancy_ocid
  exadata_infrastructure = local.exadata_infrastructure_region2
}

module "cloud_vm_cluster_region2" {
  source           = "../../../cloud-foundation/modules/cloud-foundation-library/exacs/cloud_vm_cluster"
  providers        = { oci = oci.second }
  cloud_vm_cluster = local.cloud_vm_cluster_region2
}

############################################################
# Data Guard Association:

module "database_data_guard_association" {
  source                          = "../../../cloud-foundation/modules/cloud-foundation-library/exacs/database_data_guard_association"
  depends_on                      = [module.cloud_vm_cluster_region1, module.cloud_vm_cluster_region2]
  providers                       = { oci = oci.first }
  compartment_id                  = var.compartment_id
  db_home_id                      = module.database_db_home_region1.db_system_id
  database_data_guard_association = local.database_data_guard_association
}

############################################################