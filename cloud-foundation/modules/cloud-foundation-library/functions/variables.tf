// Copyright (c) 2022, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "app_params" {
  type = map(object({
    compartment_id = string
    subnet_ids     = list(string)
    display_name   = string
    defined_tags   = map(string)
  }))
}

variable "fn_params" {
  type = map(object({
    function_app       = string
    display_name       = string
    image              = string
    defined_tags       = map(string)
  }))
}