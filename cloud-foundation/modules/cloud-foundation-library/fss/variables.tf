// Copyright (c) 2020, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartments_ids" {
  type = map(string)
}

variable "vcn_cidr" {
  type = string
}

variable "subnet_ids" {
  type = map(string)
}

variable "fss_params" {
  type = map(object({
    ad               = number
    compartment_name = string
    name             = string
    kms_key_name     = string
  }))
}

variable "mt_params" {
  type = map(object({
    ad               = number
    compartment_name = string
    name             = string
    subnet_name      = string
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

variable "kms_key_ids" {
  type = map(string)
}
