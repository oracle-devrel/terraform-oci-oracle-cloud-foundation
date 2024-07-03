## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.tenancy_ocid
}

resource "oci_sch_service_connector" "this" {
  for_each       = var.srv_connector_params
  compartment_id = each.value.compartment_id
  display_name   = each.value.display_name
  state          = upper(each.value.state)
  source {
    kind = lower(each.value.srv_connector_source_kind)
    cursor {
      kind = lower(each.value.srv_connector_source_kind) == "streaming" ? "streaming" : null
    }
    dynamic "log_sources" {
      iterator = ls
      for_each = each.value.log_sources_params
      content {
        compartment_id = lower(each.value.srv_connector_source_kind) == "logging" ? each.value.compartment_id : null
        log_group_id   = lower(each.value.srv_connector_source_kind) == "logging" ? ls.value.is_audit == true ? ls.value.log_group_name : var.log_group[ls.value.log_group_name] : null
        log_id         = lower(each.value.srv_connector_source_kind) == "logging" ? ls.value.is_audit == true ? ls.value.log_name : var.log_id[ls.value.log_name] : null
      }
    }
    stream_id = lower(each.value.srv_connector_source_kind) == "streaming" ? var.streaming[each.value.source_stream_name] : null
  }
  target {
    kind = each.value.srv_connector_target_kind

    batch_rollover_size_in_mbs = each.value.srv_connector_target_kind == "objectstorage" ? each.value.obj_batch_rollover_size_in_mbs : null
    batch_rollover_time_in_ms  = each.value.srv_connector_target_kind == "objectstorage" ? each.value.obj_batch_rollover_time_in_ms : null
    bucket                     = each.value.srv_connector_target_kind == "objectstorage" ? each.value.obj_target_bucket : null
    compartment_id             = each.value.compartment_id
    object_name_prefix         = each.value.srv_connector_target_kind == "objectstorage" ? each.value.object_name_prefix : null
    function_id                = each.value.srv_connector_target_kind == "functions" ? var.functions[each.value.function_name] : null
    log_group_id               = each.value.srv_connector_target_kind == "loggingAnalytics" ? each.value.target_log_group : null
    metric                     = each.value.srv_connector_target_kind == "monitoring" ? each.value.mon_target_metric : null
    metric_namespace           = each.value.srv_connector_target_kind == "monitoring" ? each.value.mon_target_metric_namespace : null
    namespace                  = each.value.srv_connector_target_kind == "objectstorage" ? data.oci_objectstorage_namespace.this.namespace : null
    stream_id                  = each.value.srv_connector_target_kind == "streaming" ? var.streaming[each.value.target_stream_name] : null
    topic_id                   = each.value.srv_connector_target_kind == "notifications" ? var.topics[each.value.target_topic_name] : null
    enable_formatted_messaging = each.value.srv_connector_target_kind == "notifications" ? var.topics[each.value.enable_formatted_messaging] : null
  }

  dynamic "tasks" {
    iterator = tsk
    for_each = each.value.tasks
    content {
      kind              = tsk.value.tasks_kind
      batch_size_in_kbs = tsk.value.task_batch_size_in_kbs
      batch_time_in_sec = tsk.value.task_batch_time_in_sec
      function_id       = var.functions[tsk.value.task_function_name]
    }
  }
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