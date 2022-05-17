# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "topic_params" {
  type = map(object({
    compartment_id = string
    topic_name  = string
    description = string
  }))
}

variable "subscription_params" {
  type = map(object({
    compartment_id = string
    endpoint   = string
    protocol   = string
    topic_name = string
  }))
}
