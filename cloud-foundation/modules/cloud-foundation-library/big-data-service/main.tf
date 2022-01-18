# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_bds_bds_instance" "this" {
    for_each = var.bds_params
    compartment_id = each.value.compartment_id
    cluster_admin_password = each.value.cluster_admin_password
    cluster_public_key = file(each.value.cluster_public_key)
    cluster_version = each.value.cluster_version
    display_name = each.value.display_name
    is_high_availability = each.value.is_high_availability
    is_secure = each.value.is_secure
    dynamic "master_node" {
      iterator = master_node
      for_each = each.value.master_node
    content {
        shape = master_node.value.shape
        subnet_id = master_node.value.subnet_id
        block_volume_size_in_gbs = master_node.value.block_volume_size_in_gbs
        number_of_nodes = master_node.value.number_of_nodes
     }
    }
    dynamic "util_node" {
      iterator = util_node
      for_each = each.value.util_node
    content {
        shape = util_node.value.shape
        subnet_id = util_node.value.subnet_id
        block_volume_size_in_gbs = util_node.value.block_volume_size_in_gbs
        number_of_nodes = util_node.value.number_of_nodes
     }
    }
    dynamic "worker_node" {
      iterator = worker_node
      for_each = each.value.worker_node
    content {
        shape = worker_node.value.shape
        subnet_id = worker_node.value.subnet_id
        block_volume_size_in_gbs = worker_node.value.block_volume_size_in_gbs
        number_of_nodes = worker_node.value.number_of_nodes
     }
    }
    defined_tags   = each.value.defined_tags
}

## This resource will be uncommented when the autoscalling feature will work on the new "ODH1" new version with Ambari Server

# resource "oci_bds_auto_scaling_configuration" "this" {
#     for_each = var.bds_params
#     bds_instance_id = oci_bds_bds_instance.this[each.key].id
#     cluster_admin_password = each.value.cluster_admin_password
#     is_enabled = each.value.is_enabled
#     node_type = each.value.node_type
#     policy {
#         policy_type = each.value.policy_type
#         dynamic "rules" {
#             iterator = rules
#             for_each = each.value.rules
#           content {
#             action = rules.value.action
#             metric {
#                 metric_type = rules.value.metric_type
#             threshold {
#                 duration_in_minutes = rules.value.threshold_duration_in_minutes
#                 operator = rules.value.metric_operator
#                 value = rules.value.threshold_value
#                 }
#               }
#           }
#         }
#     }
# }