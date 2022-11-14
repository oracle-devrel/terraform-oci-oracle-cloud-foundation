# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


# Calling the Autonomous Data Warehouse module

module "adw" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/database/adw_data_safe"
  depends_on = [module.oci_data_safe]
  adw_params = {
    for k,v in local.adw_params : k => v if v.compartment_id != "" 
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

# Calling the OCI Notifications module

module "oci_notifications" {
  source       = "../../../cloud-foundation/modules/cloud-foundation-library/oci_notifications"
  topic_params = {
    for k,v in local.topic_params : k => v if v.compartment_id != "" 
  }
  subscription_params = {
    for k,v in local.subscription_params : k => v if v.compartment_id != "" 
  }
}

# Calling the OCI Monitoring Alarms module

module "oci_monitoring_alarms" {
  source       = "../../../cloud-foundation/modules/cloud-foundation-library/oci_monitoring_alarms"
  alarm_params = {
    for k,v in local.alarm_params : k => v if v.compartment_id != "" 
  }
}

# Calling the OCI Logging module

module "oci_logging" {
  source       = "../../../cloud-foundation/modules/cloud-foundation-library/oci_logging"
  log_group_params = {
    for k,v in local.log_group_params : k => v if v.compartment_id != "" 
  }
  log_params = local.log_params
  log_resources = merge(module.network-subnets.subnets_ids, module.os.bucket_id)
}

# Calling the OCI Events module

module "oci_events" {
  source          = "../../../cloud-foundation/modules/cloud-foundation-library/oci_events"
  events_params   = local.events_params
  stream_id       = {}
  topic_id        = module.oci_notifications.topic_id
  function_id     = {}
}

# Calling the Log Analytics module

module "oci_log_analytics" {
  source               = "../../../cloud-foundation/modules/cloud-foundation-library/oci_log_analytics"
  tenancy_ocid         = var.tenancy_ocid
  log_analytics_log_group_params = local.log_analytics_log_group_params
}

# Calling the OCI Logging Service Connector module

module "oci_logging_service_connector" {
  source               = "../../../cloud-foundation/modules/cloud-foundation-library/oci_logging_service_connector"
  depends_on           = [module.oci_logging, module.oci_log_analytics]
  srv_connector_params = local.srv_connector_params
  tenancy_ocid         = var.tenancy_ocid
  topics               = {}
  functions            = {}
  streaming            = {}
  log_id               = module.oci_logging.logs
  log_group            = module.oci_logging.log_groups
}

# Calling the Data Safe module

module "oci_data_safe" {
  source               = "../../../cloud-foundation/modules/cloud-foundation-library/oci_data_safe"
  oci_data_safe_private_endpoint_params = local.oci_data_safe_private_endpoint_params
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
  policies = local.policies
}
