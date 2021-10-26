# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_analytics_analytics_instance" "oac" {
  for_each = {
    for k,v in var.oac_params : k => v if v.compartment_id != ""
  } 
      compartment_id    = each.value.compartment_id
      feature_set       = each.value.analytics_instance_feature_set
      license_type      = each.value.analytics_instance_license_type
      name              = each.value.analytics_instance_hostname
      description       = "Oracle Analytics Cloud"
      idcs_access_token = each.value.analytics_instance_idcs_access_token
      #Optional
      defined_tags = each.value.defined_tags
      network_endpoint_details {
        #Required
        network_endpoint_type = each.value.analytics_instance_network_endpoint_details_network_endpoint_type

        #Optional
        subnet_id = each.value.subnet_id
        vcn_id = each.value.vcn_id
        whitelisted_ips = each.value.analytics_instance_network_endpoint_details_whitelisted_ips

        whitelisted_vcns {
            #Optional
            id = each.value.analytics_instance_network_endpoint_details_whitelisted_vcns_id
            whitelisted_ips = each.value.whitelisted_ips
        }
    }
  capacity {
    capacity_type  = each.value.analytics_instance_capacity_capacity_type
    capacity_value = each.value.analytics_instance_capacity_value
  }
}


