## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_dataflow_application" "this" {
  for_each       = var.dataflow_params
  compartment_id = each.value.compartment_id
  display_name   = each.value.application_display_name
  driver_shape   = each.value.application_driver_shape
  executor_shape = each.value.application_executor_shape
  file_uri       = each.value.application_file_uri
  language       = each.value.application_language
  num_executors  = each.value.application_num_executors
  spark_version  = each.value.application_spark_version
  class_name     = each.value.application_class_name
  defined_tags   = each.value.defined_tags
}
