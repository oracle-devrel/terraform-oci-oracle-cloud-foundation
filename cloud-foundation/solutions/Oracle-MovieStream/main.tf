# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Create ADW Database with Endpoint in private subnet
module "adw_database_private_endpoint" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/database/adw_private_endpoint"
  adw_params = local.adw_params 
}

# # Calling the Data Catalog module
# module "datacatalog" {
#   source = "../../../cloud-foundation/modules/cloud-foundation-library/database/datacatalog_private_endpoint"
#   datacatalog_params = local.datacatalog_params
#   depends_on = [module.adw_database_private_endpoint]
#   db_name = var.db_name
#   wallet = module.adw_database_private_endpoint.adb_wallet_content
#   count = var.bastion_instance_shape == "VM.Standard.E2.1.Micro" ? 0 : 1
# }

# Generate instance public/private key pair
module "keygen" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/keygen"
  display_name = "keygen"
  subnet_domain_name = lookup(module.network-subnets.subnets,"deploy-lb-subnet").subnet_domain_name
}

# Create Compute instance
module "web-instance" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/instance_with_out_flexible"
  tenancy_ocid = var.tenancy_ocid
  instance_params = local.instance_params
}

# Connect to instance and execute provision of server
module "provisioner" {
  source = "./modules/provisioner"
  depends_on = [module.adw_database_private_endpoint, module.web-instance]
  host = module.web-instance.InstancePublicIPs[0]
  private_key = module.keygen.OPCPrivateKey["private_key_pem"]
  atp_url = module.adw_database_private_endpoint.url
  db_password = var.db_password
  db_name = var.db_name
  conn_db = module.adw_database_private_endpoint.db_connection[0].profiles[1].value
  dbhostname = module.adw_database_private_endpoint.database_fully_qualified_name
  # tag = var.tag
  # run_post_load_procedures = var.run_post_load_procedures
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