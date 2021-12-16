## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_streaming_stream_pool" "this" {
  for_each       = var.streaming_pool_params
  compartment_id = each.value.compartment_id
  name           = each.value.name
  defined_tags   = each.value.defined_tags
  dynamic "kafka_settings" {
    iterator = kafka_settings
    for_each = each.value.kafka_settings
    content {
      auto_create_topics_enable = kafka_settings.value.auto_create_topics_enable
      log_retention_hours       = kafka_settings.value.log_retention_hours
      num_partitions            = kafka_settings.value.num_partitions
    }
  }
}

resource "oci_streaming_stream" "this" {
  for_each           = var.streaming_params
  name               = each.value.name
  partitions         = each.value.partitions
  retention_in_hours = each.value.retention_in_hours
  stream_pool_id     = oci_streaming_stream_pool.this[each.value.stream_pool_name].id
  defined_tags       = each.value.defined_tags
}

data "oci_objectstorage_namespace" "user_namespace" {
  compartment_id = var.tenancy_ocid
}

resource "oci_sch_service_connector" "service_connector" {
  for_each       = var.service_connector
  compartment_id = each.value.compartment_id
  display_name   = each.value.service_connector_display_name
  source {
    kind =  each.value.service_connector_source_kind

    cursor {
      kind =  each.value.service_connector_source_cursor_kind
    }
    stream_id = oci_streaming_stream.this[each.key].id
  }

  target {
    kind =  each.value.service_connector_target_kind

    batch_rollover_size_in_mbs =  each.value.service_connector_target_batch_rollover_size_in_mbs
    batch_rollover_time_in_ms  =  each.value.service_connector_target_batch_rollover_time_in_ms
    bucket                     =  each.value.service_connector_target_bucket
    compartment_id             =  each.value.compartment_id
    namespace          = data.oci_objectstorage_namespace.user_namespace.namespace
    object_name_prefix = each.value.service_connector_target_object_name_prefix
  }

  description = each.value.service_connector_description
  defined_tags = each.value.defined_tags
  tasks {
    kind = each.value.service_connector_tasks_kind

    batch_size_in_kbs = each.value.service_connector_tasks_batch_size_in_kbs
    batch_time_in_sec = each.value.service_connector_tasks_batch_time_in_sec
    function_id = each.value.function_id
  }
}



