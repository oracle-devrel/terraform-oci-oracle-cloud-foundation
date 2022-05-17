# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "log_resources" {
  type = map(string)
}

variable "log_group_params" {
  type = map(object({
    compartment_id = string
    log_group_name = string
  }))
}


variable "log_params" {
  type = map(object({
    log_name            = string
    log_group           = string
    log_type            = string
    source_log_category = string
    source_resource     = string
    source_service      = string
    source_type         = string
    compartment_id      = string
    is_enabled          = bool
    retention_duration  = number
  }))
}


