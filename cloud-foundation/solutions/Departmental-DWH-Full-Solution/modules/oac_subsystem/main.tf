# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "oac" {
  source = "../../../../../cloud-foundation/modules/cloud-foundation-library/oac"
  oac_params = { 
    oac = {
      compartment_id                             = var.compartment_id,
      analytics_instance_feature_set             = var.analytics_instance_feature_set,
      analytics_instance_license_type            = var.analytics_instance_license_type,
      analytics_instance_hostname                = var.analytics_instance_hostname,
      analytics_instance_idcs_access_token       = var.analytics_instance_idcs_access_token,
      analytics_instance_capacity_capacity_type  = var.analytics_instance_capacity_capacity_type,
      analytics_instance_capacity_value          = var.analytics_instance_capacity_value,
      defined_tags                               = var.defined_tags
      analytics_instance_network_endpoint_details_network_endpoint_type = var.analytics_instance_network_endpoint_details_network_endpoint_type
      subnet_id                                  = var.subnet_id
      vcn_id                                     = var.vcn_id
      analytics_instance_network_endpoint_details_whitelisted_ips = var.analytics_instance_network_endpoint_details_whitelisted_ips
      analytics_instance_network_endpoint_details_whitelisted_vcns_id = var.analytics_instance_network_endpoint_details_whitelisted_vcns_id
      whitelisted_ips                            = var.whitelisted_ips
  }
 }
}
