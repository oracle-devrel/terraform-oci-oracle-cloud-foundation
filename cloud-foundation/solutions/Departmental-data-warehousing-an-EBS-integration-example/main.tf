# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# Calling the Autonomous Data Warehouse module

module "adw" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/database/adw"
  adw_params = {
    for k,v in local.adw_params : k => v if v.compartment_id != "" 
  }
}


# Calling the Oracle Analytics Cloud module

module "oac" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/oac"
  oac_params = {
    for k,v in local.oac_params : k => v if v.compartment_id != "" 
  }
}


# Calling the Data Catalog module

module "datacatalog" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/datacatalog"
  datacatalog_params = {
    for k,v in local.datacatalog_params : k => v if v.compartment_id != "" 
  }
}


#generate public and private keys

module "keygen" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/keygen"
  display_name = "keygen"
  subnet_domain_name = "keygen"
}


#Calling the compute module to create a bastion for VNC connectivity to odi instance

module "bastion" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/instance_with_out_flexible"
  depends_on = [module.keygen, module.adw]
  tenancy_ocid = var.tenancy_ocid
  instance_params = {
    for k,v in local.bastion_instance_params : k => v if v.compartment_id != ""  
  }
}


# Calling the ODI Instance module

module "odi" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/instance_with_out_flexible"
  depends_on = [module.keygen, module.bastion, module.adw]
  tenancy_ocid = var.tenancy_ocid
  instance_params = local.odi_instance_params 
}


# Calling the Newtwork modules 

module "network-vcn" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"
  compartment_id = var.compartment_id 
  service_label = ""
  service_gateway_cidr = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block")
  vcns = {
    for k,v in local.vcns-lists : k => v if v.compartment_id != "" 
  }
}

module "network-subnets" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"
  compartment_id = var.compartment_id 
  service_label = ""
  service_gateway_cidr = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block")
  vcns = {
    for k,v in local.subnet-lists : k => v if v.compartment_id != "" 
  }
}

module "network-routing" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-routing"
  compartment_id = var.compartment_id 
  subnets_route_tables = {
    for k,v in local.subnets_route_tables : k => v if v.compartment_id != "" 
  }
}

module "network-security-lists" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/security"
  compartment_id = var.compartment_id 
  ports_not_allowed_from_anywhere_cidr = []
  security_lists = {
    for k,v in local.security_lists : k => v if v.compartment_id != "" 
  }
}

module "network-security-groups" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/security"
  compartment_id = var.compartment_id
  nsgs = {
    for k,v in local.nsgs-lists : k => v if v.compartment_id != "" 
  }
}

module "dynamic_groups" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/iam/iam-dynamic-group"
  providers = {
    oci = oci.homeregion
  }
  dynamic_groups = local.dynamic_groups
}

module "policies" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/security/policies"
  depends_on = [module.dynamic_groups]
  providers = {
    oci = oci.homeregion
  }
  policies = local.policies
}
