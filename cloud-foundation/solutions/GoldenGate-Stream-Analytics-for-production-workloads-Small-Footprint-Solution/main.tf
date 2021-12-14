# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

#Calling the FSS (File Storage Service) modules that are required for this solution

module "fss" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/fss"
  depends_on = [oci_identity_tag.ArchitectureCenterTag]
  tenancy_ocid = var.tenancy_ocid
  fss_params = {
    for k,v in local.fss_params : k => v if v.compartment_id != "" 
  }
  mt_params = {
    for k,v in local.mt_params : k => v if v.compartment_id != "" 
  }
  export_params = {
    for k,v in local.export_params : k => v if v.export_set_name != "" 
  }
}


#generate public and private keys

module "keygen" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/keygen"
  display_name = "keygen"
  subnet_domain_name = "keygen"
}


#Calling the compute/instances modules that are required for this solution

module "compute" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/instance_with_out_flexible"
  depends_on = [module.keygen, module.fss]
  tenancy_ocid = var.tenancy_ocid
  instance_params = {
    for k,v in local.instance_params : k => v if v.compartment_id != ""  
  }
}


#Calling the network modules that are required for this solution

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