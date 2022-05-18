# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Calling the Object Storage module

module "os" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/object-storage"
  tenancy_ocid = var.tenancy_ocid
  bucket_params = {
    for k,v in local.bucket_params : k => v if v.compartment_id != "" 
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

# Calling the functions module

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

# Calling the data-flow module

module "dataflowapp" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/data-flow"
  depends_on = [module.dynamic_groups, module.policies, module.os]
  dataflow_params = {
    for k,v in local.dataflow_params : k => v if v.compartment_id != "" 
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

module "dynamic_groups" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/iam/iam-dynamic-group"
  providers = {
    oci = oci
    oci.homeregion = oci.homeregion
  }
  dynamic_groups = local.dynamic_groups
}

module "policies" {
  source = "../../../cloud-foundation/modules/oci-cis-landingzone-quickstart/security/policies"
  depends_on = [module.dynamic_groups]
  providers = {
    oci = oci
    oci.homeregion = oci.homeregion
  }
  policies = local.policies
}

