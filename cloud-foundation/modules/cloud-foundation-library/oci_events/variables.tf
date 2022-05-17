# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "function_id" {
  type = map(string)
}

variable "topic_id" {
  type = map(string)
}

variable "stream_id" {
  type = map(string)
}

variable "events_params" {
  type = map(object({
    rule_display_name = string
    description       = string
    compartment_id    = string
    rule_is_enabled   = bool
    condition         = any
    freeform_tags     = map(any)
    action_params = list(object({
      action_type         = string
      is_enabled          = bool
      actions_description = string
      function_name       = string
      topic_name          = string
      stream_name         = string

    }))
  }))
}



