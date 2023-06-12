## Copyright © 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_dataflow_application" "this" {
    for_each       = var.dataflow_params
    compartment_id = each.value.compartment_id
    display_name   = each.value.application_display_name
    driver_shape   = each.value.application_driver_shape
    executor_shape = each.value.application_executor_shape
    language = each.value.application_language
    num_executors  = each.value.application_num_executors
    spark_version  = each.value.application_spark_version 
    class_name     = each.value.application_class_name
    defined_tags   = each.value.defined_tags
    file_uri       = each.value.application_file_uri
    freeform_tags  = each.value.freeform_tags
    logs_bucket_uri = each.value.logs_bucket_uri
    private_endpoint_id = oci_dataflow_private_endpoint.this[each.key].id
    lifecycle {
    ignore_changes = all
  }
}

resource "oci_dataflow_private_endpoint" "this" {
    for_each       = var.dataflow_params
    compartment_id = each.value.compartment_id
    dns_zones      = each.value.dns_zones
    subnet_id      = each.value.subnet_id
    defined_tags   = each.value.defined_tags
    description    = each.value.description
    display_name   = each.value.display_name
    freeform_tags  = each.value.freeform_tags
    max_host_count = each.value.max_host_count
    nsg_ids        = each.value.nsg_ids
       lifecycle {
    ignore_changes = all
  }
}

