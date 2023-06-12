# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_analytics_analytics_instance" "this" {
      for_each = var.oac_params
      compartment_id    = each.value.compartment_id
      feature_set       = each.value.analytics_instance_feature_set
      license_type      = each.value.analytics_instance_license_type
      name              = each.value.name
      description       = "analytics"
      idcs_access_token = each.value.analytics_instance_idcs_access_token
      defined_tags      = each.value.defined_tags
      network_endpoint_details {
        network_endpoint_type = each.value.analytics_instance_network_endpoint_details_network_endpoint_type
        subnet_id = each.value.subnet_id
        vcn_id    = each.value.vcn_id
        whitelisted_ips = each.value.analytics_instance_network_endpoint_details_whitelisted_ips
        whitelisted_vcns {
            id = each.value.analytics_instance_network_endpoint_details_whitelisted_vcns_id
            whitelisted_ips = each.value.whitelisted_ips
        }
    }
  capacity {
    capacity_type  = each.value.analytics_instance_capacity_capacity_type
    capacity_value = each.value.analytics_instance_capacity_value
  }
   lifecycle {
    ignore_changes = all
  }
}

resource "oci_analytics_analytics_instance_private_access_channel" "this" {
    for_each = var.oac_params
    analytics_instance_id = oci_analytics_analytics_instance.this[each.key].id
    display_name = each.value.analytics_instance_private_access_channel_display_name
    subnet_id = each.value.subnet_id
    vcn_id = each.value.vcn_id
    private_source_dns_zones {
        dns_zone = element(each.value.analytics_instance_private_access_channel_private_source_dns_zones_dns_zone,0)
    }
    private_source_dns_zones {
        dns_zone = element(each.value.analytics_instance_private_access_channel_private_source_dns_zones_dns_zone,1)
    }
}

  
