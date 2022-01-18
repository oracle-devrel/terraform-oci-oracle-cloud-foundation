# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "bds_params" {
  type = map(object({
    compartment_id = string
    cluster_admin_password      = string
    cluster_public_key   = string
    cluster_version  = string
    display_name = string
    is_high_availability = bool
    is_secure = bool
    master_node = list(object({
      shape                    = string
      subnet_id                = string
      block_volume_size_in_gbs = number
      number_of_nodes          = number
    }))
    util_node = list(object({
      shape                    = string
      subnet_id                = string
      block_volume_size_in_gbs = number
      number_of_nodes          = number
    }))
    worker_node = list(object({
      shape                    = string
      subnet_id                = string
      block_volume_size_in_gbs = number
      number_of_nodes          = number
    }))
    defined_tags   = map(string)
    ## This variables below will be uncommented when the autoscalling feature will work on the new "ODH1" new version with Ambari Server
    # is_enabled = bool # from this line below, it's about the autoscalling that's only available on the old version CDH6
    # node_type        = string
    # policy_type      = string
    # rules            = list(object({
    #   action  = string
    #   metric_type     = string
    #   metric_operator = string # GT, GTE, LT, LTE
    #   threshold_value = number
    #   threshold_duration_in_minutes = number
    # }))
  }))
}

