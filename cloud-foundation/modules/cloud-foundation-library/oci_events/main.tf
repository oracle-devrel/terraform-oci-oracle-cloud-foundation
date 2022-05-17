# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_events_rule" "this" {
  for_each = var.events_params
  actions {
    dynamic "actions" {
      iterator = act
      for_each = each.value.action_params
      content {
        action_type = act.value.action_type
        description = act.value.actions_description
        is_enabled  = act.value.is_enabled
        function_id = length(act.value.function_name) > 0 ? var.function_id[act.value.function_name] : ""
        topic_id    = length(act.value.topic_name) > 0 ? var.topic_id[act.value.topic_name] : ""
        stream_id   = length(act.value.stream_name) > 0 ? var.stream_id[act.value.stream_name] : ""

      }
    }
  }
  compartment_id = each.value.compartment_id
  condition     = jsonencode(each.value.condition)
  display_name  = each.value.rule_display_name
  description   = each.value.description
  is_enabled    = each.value.rule_is_enabled
  freeform_tags = each.value.freeform_tags
}



