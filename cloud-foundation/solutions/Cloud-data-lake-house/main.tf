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


# Calling the data science module

module "datascience" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/data-science"
  depends_on = [module.dynamic_groups, module.policies]
  datascience_params = {
    for k,v in local.datascience_params : k => v if v.compartment_id != "" 
  }
  notebook_params = {
    for k,v in local.notebook_params : k => v if v.compartment_id != "" 
  }
}


# Calling the golden gate module

module "golden_gate_deployment" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/golden-gate"
  deployment_params = {
    for k,v in local.deployment_params : k => v if v.compartment_id != "" 
  }
}


# Calling the oci streaming module

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


# Calling the data-flow module

module "dataflowapp" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/data-flow"
  depends_on = [module.dynamic_groups, module.policies, module.os]
  dataflow_params = {
    for k,v in local.dataflow_params : k => v if v.compartment_id != "" 
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


# Calling the Ai Anomaly Detection module

module "ai-anomaly-detection" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/ai-anomaly-detection"
  tenancy_ocid = var.tenancy_ocid
  ai_anomaly_detection_project_params = {
    for k,v in local.ai_anomaly_detection_project_params : k => v if v.compartment_id != "" 
  }
  ai_anomaly_detection_data_asset_params = {
    for k,v in local.ai_anomaly_detection_data_asset_params : k => v if v.compartment_id != "" 
  }
  ai_anomaly_detection_model_params = {
    for k,v in local.ai_anomaly_detection_model_params : k => v if v.compartment_id != "" 
  }
}


# Calling the Big Data Service module

module "big-data-service" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/big-data-service"
  depends_on = [module.dynamic_groups, module.policies]
  bds_params = {
    for k,v in local.bds_params : k => v if v.compartment_id != "" 
  }
}


##### Below, fss, keygen and compute modules are for the Streaming Processing - GOLDEN GATE STREAM ANALYTICS.
## Calling the FSS (File Storage Service) modules that are required for this solution

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


## Generate public and private keys

module "keygen" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/keygen"
  display_name = "keygen"
  subnet_domain_name = "keygen"
}


## Calling the compute/instances modules that are required for this solution

module "compute" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/instance_with_out_flexible"
  depends_on = [module.dynamic_groups, module.policies, module.keygen, module.fss]
  tenancy_ocid = var.tenancy_ocid
  instance_params = {
    for k,v in local.instance_params : k => v if v.compartment_id != ""  
  }
}


##### Calling the network modules that are required for this solution ######
## Calling the Dynamic Routing Gateways (DRGs) module
module "drg" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/network/drg"
  compartment_id = var.compartment_id 
  drg_params = local.drg_params
}


#### Calling the Fast Connect Service module

module "fastconnect" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/fastconnect"
  compartment_id = var.compartment_id 
  drgs = module.drg.drgs_list
  private_vc_with_provider_no_cross_connect_or_cross_connect_group_id = {
    for k,v in local.private_vc_with_provider_no_cross_connect_or_cross_connect_group_id : k => v if v.compartment_id != "" 
  }
  cc_group = {
    for k,v in local.cc_group : k => v if v.compartment_id != "" 
  }
  cc = {
    for k,v in local.cc : k => v if v.compartment_id != "" 
  }
  private_vc_no_provider = {
    for k,v in local.private_vc_no_provider : k => v if v.compartment_id != "" 
  }
  private_vc_with_provider = {
    for k,v in local.private_vc_with_provider : k => v if v.compartment_id != "" 
  }
  public_vc_no_provider = {
    for k,v in local.public_vc_no_provider : k => v if v.compartment_id != "" 
  }
  public_vc_with_provider = {
    for k,v in local.public_vc_with_provider : k => v if v.compartment_id != "" 
  }
}



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
  policies   = local.policies
}
