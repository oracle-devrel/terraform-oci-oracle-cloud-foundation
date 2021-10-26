# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
    type = string
}

variable "compartment_id" {
  type    = string
}

variable "bucket_name" {
    type    = string
}

variable "bucket_access_type" {
    type    = string
}

variable "bucket_storage_tier" {
    type    = string
}
  
variable "bucket_events_enabled" {
    type    = bool
}

variable "defined_tags" {
  type    = map
  default = {}
}




