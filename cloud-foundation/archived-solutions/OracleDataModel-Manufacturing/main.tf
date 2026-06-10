# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Create ADW Database
module "adb" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/database/adb"
  adw_params = local.adw_params 
}

# Calling the Oracle Analytics Cloud module
module "oac" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/oac"
  oac_params = local.oac_params 
}

# Calling the Object Storage module
module "os" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/object-storage"
  tenancy_ocid = var.tenancy_ocid
  bucket_params = {
    for k,v in local.bucket_params : k => v if v.compartment_id != "" 
  }
}

# # Calling the Data Catalog module
# module "datacatalog" {
#   source = "../../../cloud-foundation/modules/cloud-foundation-library/datacatalog_private_endpoint"
#   datacatalog_params = local.datacatalog_params
#   depends_on = [module.adb, module.provisioner]
#   db_name = var.db_name
#   wallet = module.adb.adb_wallet_content
# }

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

# Connect to instance and execute provision of server
module "provisioner" {
  source = "./modules/provisioner"
  depends_on = [module.adb, module.web-instance]
  host = module.web-instance.InstancePublicIPs[0]
  private_key = module.keygen.OPCPrivateKey["private_key_pem"]
  atp_url = module.adb.url
  db_password = var.db_password
  db_name = var.db_name
  conn_db = module.adb.db_connection[0].profiles[1].value
  Oracle_Analytics_Instance_Name = var.Oracle_Analytics_Instance_Name
  home_region_for_oac = lower(substr(local.home_region_for_oac, 0, 2))
  Tenancy_Name = lower(data.oci_identity_tenancy.tenancy.name)
  bucket = var.bucket_name 
  Authorization_Token = var.Authorization_Token
  ociRegion = var.region
  ociTenancyId = var.tenancy_ocid
  ociUserId = var.user_ocid
  ociKeyFingerprint = var.fingerprint
  ociPrivateKeyWrapped = var.ociPrivateKeyWrapped
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