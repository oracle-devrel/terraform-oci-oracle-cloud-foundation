# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "alarm_params" {
  type = map(object({
    compartment_id                         = string
    destinations                           = list(string)
    alarm_display_name                     = string
    alarm_is_enabled                       = bool
    alarm_metric_comp_name                 = string
    alarm_namespace                        = string
    alarm_query                            = string
    alarm_severity                         = string
    alarm_body                             = string
    message_format                         = string
    alarm_metric_compartment_id_in_subtree = bool
    alarm_pending_duration                 = string
    alarm_repeat_notification_duration     = string
    alarm_resolution                       = string
    alarm_resource_group                   = string
    suppression_params = list(object({
      alarm_suppression_description         = string
      alarm_suppression_time_suppress_from  = string
      alarm_suppression_time_suppress_until = string
    }))
  }))
}

