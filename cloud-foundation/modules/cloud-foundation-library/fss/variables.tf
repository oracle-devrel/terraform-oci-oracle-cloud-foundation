# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
    type = string
}

variable "fss_params" {
  type = map(object({
    availability_domain = string
    compartment_id      = string
    name                = string
    defined_tags        = map(string)
    freeform_tags       = map(string)
  }))
}

variable "mt_params" {
  type = map(object({
    availability_domain = string
    compartment_id   = string
    name             = string
    subnet_id        = string
    defined_tags     = map(string)
    freeform_tags    = map(string)
  }))
}

variable "export_params" {
  type = map(object({
    export_set_name = string
    filesystem_name = string
    path            = string
    export_options = list(object({
      source   = string
      access   = string
      identity = string
      use_port = bool
    }))
  }))
}








