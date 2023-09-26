# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# Create ADW Database with Endpoint in private subnet

module "adb" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/database/adb"
  adw_params = local.adw_params 
}


# Calling the Object Storage module

module "os" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/object-storage"
  tenancy_ocid = var.tenancy_ocid
  bucket_params = {
    for k,v in local.bucket_params : k => v if v.compartment_id != "" 
  }
}


# Calling the API Gateway module

module "api-gateway" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/api-gateway"
  depends_on = [module.dynamic_groups, module.policies]
  apigw_params = {
    for k,v in local.apigw_params : k => v if v.compartment_id != "" 
  }
  gwdeploy_params = {
    for k,v in local.gwdeploy_params : k => v if v.compartment_id != "" 
  }
}


# Calling the OCI Streaming module

module "streaming" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/streaming"
  tenancy_ocid = var.tenancy_ocid
  depends_on = [module.dynamic_groups, module.policies]
  streaming_params = {
    for k,v in local.streaming_params : k => v if v.compartment_id != "" 
  }
  streaming_pool_params = {
    for k,v in local.streaming_pool_params : k => v if v.compartment_id != "" 
  }
  service_connector = {
    for k,v in local.service_connector : k => v if v.compartment_id != "" 
  }
}


# Calling the Functions module

module "functions" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/functions"
  depends_on = [module.dynamic_groups, module.policies, null_resource.DecoderPush2OCIR]
  app_params = {
    for k,v in local.app_params : k => v if v.compartment_id != "" 
  }
  fn_params = {
    for k,v in local.fn_params : k => v if v.function_app != "" 
  }
}


# Calling the Data Catalog module

module "datacatalog" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/datacatalog_lakehouse"
  depends_on = [module.os]
  datacatalog_params = local.datacatalog_params
  tenancy_ocid = var.tenancy_ocid
  region     = var.region
  db_name    = var.db_name
  # wallet     = module.adb.adb_wallet_content
}


#generate public and private keys
module "keygen" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/keygen"
}


# Calling the Bastion Service module

module "bastions" {

  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/security/bastion"
  bastions = local.bastions_params
  sessions = local.sessions_params
}


# Calling the Oracle Analytics Cloud module

module "oac" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/oac_private_endpoint"
  oac_params = local.oac_params 
}


# Calling the Oracle Cloud Infrastructure Data Integration service module with private endpoint

module "ocidi" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/odi_private_endpoint"
  depends_on = [module.network-subnets, module.dynamic_groups, module.policies]
  odi_params = {
    for k,v in local.ocidi_params : k => v if v.compartment_id != "" 
  }
}



# Calling the Data Science module

module "datascience" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/data-science_private_endpoint"
  depends_on = [module.dynamic_groups, module.policies]
  datascience_params = {
    for k,v in local.datascience_params : k => v if v.compartment_id != "" 
  }
  notebook_params = {
    for k,v in local.notebook_params : k => v if v.compartment_id != "" 
  }
}


# Calling the Data Flow module

module "dataflowapp" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/data-flow_private_endpoint"
  depends_on = [module.dynamic_groups, module.policies, module.os]
  dataflow_params = {
    for k,v in local.dataflow_params : k => v if v.compartment_id != "" 
  }
}


# Calling the WAF module

module "waf" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/web-application-firewall"
  waf_params = local.waf_params 
}


# Calling the Containers & Artifacts module

module "containers_artifacts" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/oci_artifacts_container_repository"
  containers_artifacts_params = local.containers_artifacts_params 
}


# Calling the Dynamic Routing Gateways (DRGs) module
module "drg" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/drg"
  compartment_id = var.compartment_id 
  drg_params = local.drg_params
}


# Calling the Newtwork modules and create also the local peering between vcns

module "network-vcn" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/vcn-basic"
  compartment_id = var.compartment_id 
  service_label = ""
  drg_id = module.drg.drgs_list["mgmt_drg"]
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
  vcns = local.subnet-lists
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

module "local_peering_gateway" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/local-peering-gateway"
  lpg_params = local.lpg_params 
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


# Calling the Load Balancer module

module "lb" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb_no_ssl"
   lb-params = local.lb-params  
}

module "lb-backendset" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb_no_ssl"
  lb-backendset-params = local.lb-backendset-params
}

module "lb-listener-https" {

  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb_no_ssl"
  lb-listener-https-params = local.lb-listener-https-params
}

module "lb-backend" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb_no_ssl"
  lb-backend-params = local.lb-backend-params 
}

module "SSL_headers" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb_no_ssl"
  SSL_headers-params = local.SSL_headers-params 
}

module "lb-demo_certificate" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/lb_no_ssl"
  demo_certificate-params = local.demo_certificate-params 
}
