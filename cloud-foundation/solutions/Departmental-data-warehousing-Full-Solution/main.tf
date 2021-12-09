# Copyright © 2021, Oracle and/or its affiliates.
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


# Calling the Object Storage module

module "os" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/object-storage"
  tenancy_ocid = var.tenancy_ocid
  bucket_params = {
    for k,v in local.bucket_params : k => v if v.compartment_id != "" 
  }
}


# Calling the Data Catalog module

module "datacatalog" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/datacatalog"
  datacatalog_params = {
    for k,v in local.datacatalog_params : k => v if v.compartment_id != "" 
  }
}


# Calling the Oracle Cloud Infrastructure Data Integration service module

module "odi" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/odi"
  odi_params = {
    for k,v in local.odi_params : k => v if v.compartment_id != "" 
  }
}

#Calling the network modules that are required for this solution

module "network-vcn" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"
  compartment_id = var.compartment_id 
  service_label  = var.service_name
  service_gateway_cidr = lookup(data.oci_core_services.sgw_services.services[0], "cidr_block")
  vcns = {
    for k,v in local.vcns-lists : k => v if v.compartment_id != "" 
  }
}

module "network-subnets" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"
  compartment_id = var.compartment_id 
  service_label  = var.service_name
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


#Calling the tagging module

module "tags" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/tagging"
  compartment_id = var.compartment_id 
  tags = var.tags
}