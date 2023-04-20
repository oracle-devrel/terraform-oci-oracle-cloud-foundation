# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# Create ADW Database with Endpoint in private subnet
module "adw_database_private_endpoint" {
  source = "./modules/cloud-foundation-library/database/adw_private_endpoint_for_each"
  adw_params = local.adw_params 
}


# Calling the Object Storage module
module "os" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/object-storage"
  depends_on = [module.adw_database_private_endpoint]
  tenancy_ocid = var.tenancy_ocid
  bucket_params = {
    for k,v in local.bucket_params : k => v if v.compartment_id != "" 
  }
}


#generate public and private keys
module "keygen" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/keygen"
}


#Calling the compute module to create a bastion for VNC connectivity to informatica secure agent instance

module "bastion" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/instance_with_out_flexible"
  tenancy_ocid = var.tenancy_ocid
  instance_params = {
    for k,v in local.bastion_instance_params : k => v if v.compartment_id != ""  
  }
}


# Calling the informatica secure agent Instance module

module "informatica_secure_agent" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/instance_with_out_flexible"
  depends_on = [ module.adw_database_private_endpoint , module.os]
  tenancy_ocid = var.tenancy_ocid
  instance_params = local.informatica_secure_agent_params 
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

module "network-routing-attachment" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-routing"
  compartment_id = var.compartment_id 
  subnets_route_tables = local.network-routing-attachment
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
