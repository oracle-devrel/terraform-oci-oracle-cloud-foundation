# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "oac_params" {
  type = map(object({
    compartment_id                             = string
    analytics_instance_feature_set             = string
    analytics_instance_license_type            = string
    analytics_instance_hostname                = string
    analytics_instance_idcs_access_token       = string
    analytics_instance_capacity_capacity_type  = string
    analytics_instance_capacity_value          = number
    defined_tags                               = map(string)
    analytics_instance_network_endpoint_details_network_endpoint_type = string
    subnet_id                                  = string
    vcn_id                                     = string
    analytics_instance_network_endpoint_details_whitelisted_ips = list(string)
    analytics_instance_network_endpoint_details_whitelisted_vcns_id   = string
    whitelisted_ips                            = list(string)
  }))
}

