# Copyright © 2025, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# Create ADW Database with Endpoint in private subnet
module "adb" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/database/adb"
  adw_params = local.adw_params 
}


# Networking
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
  nsgs = local.nsgs-lists
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


# Generate public and private keys
module "keygen" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/keygen"
}


# Create Web Server - compute instance
module "web-instance" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/instance_with_out_flexible"
  tenancy_ocid = var.tenancy_ocid
  instance_params = local.instance_params
}


#Connect to instance and execute provision of web server
module "provisioner" {
  source = "./modules/provisioner"
  depends_on = [module.adb, module.keygen, module.web-instance]
  host = module.web-instance.InstancePublicIPs[0]
  private_key = module.keygen.OPCPrivateKey["private_key_pem"]
  atp_url = module.adb.adw_sql_dev_web_urls
  db_password = var.db_password
  db_name = var.db_name
  conn_db = module.adb.db_connection[0].profiles[1].value
} 


