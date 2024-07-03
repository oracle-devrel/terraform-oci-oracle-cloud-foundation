# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_logging_log_group" "this" {
  for_each       = var.log_group_params
  compartment_id = each.value.compartment_id
  display_name   = each.value.log_group_name
}


resource "oci_logging_log" "this" {
  for_each     = var.log_params
  display_name = each.value.log_name
  log_group_id = oci_logging_log_group.this[each.value.log_group].id
  log_type     = each.value.log_type
  configuration {
    source {
      category    = each.value.source_log_category
      resource    = each.value.source_service == "objectstorage" ? each.value.source_resource : var.log_resources[each.value.source_resource]
      service     = each.value.source_service
      source_type = each.value.source_type
    }
      compartment_id = each.value.compartment_id
  }
  is_enabled         = each.value.is_enabled
  retention_duration = each.value.retention_duration
}

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.30.0"
    }
  }
  required_version = ">= 1.5.5"
}