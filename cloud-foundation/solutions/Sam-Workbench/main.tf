# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# Create ADW Database with Endpoint in private subnet

module "adw_database_private_endpoint" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/database/adw_private_endpoint"
  adw_params = local.adw_params 
}


# Generate public and private keys

module "keygen" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/keygen"
}


# Calling the compute module to create a bastion

module "bastion" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/instance_with_out_flexible"
  tenancy_ocid = var.tenancy_ocid
  instance_params = {
    for k,v in local.bastion_instance_params : k => v if v.compartment_id != ""  
  }
}


# Calling the UI Data Server Instance module

module "ui_data_server" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/instance_flexible"
  tenancy_ocid = var.tenancy_ocid
  instance_params = local.ui_data_server_params 
}


# Calling the oci streaming module

module "streaming" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/streaming"
  tenancy_ocid = var.tenancy_ocid
  streaming_params = local.streaming_params
  streaming_pool_params = local.streaming_pool_params
  service_connector = local.service_connector
}


# Calling the Network modules 

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


# Calling the Load Balancer module

module "lb" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb"
   lb-params = local.lb-params  
}

module "lb-backendset" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb"
  lb-backendset-params = local.lb-backendset-params
}

module "lb-listener-https" {

  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb"
  lb-listener-https-params = local.lb-listener-https-params
}

module "lb-backend" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb"
  lb-backend-params = local.lb-backend-params 
}

module "SSL_headers" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb"
  SSL_headers-params = local.SSL_headers-params 
}

module "lb-demo_certificate" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb"
  demo_certificate-params = local.demo_certificate-params 
}