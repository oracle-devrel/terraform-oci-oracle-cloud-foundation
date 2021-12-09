# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.
variable "tenancy_ocid" {
    type = string
}

variable "bucket_params" {
  type = map(object({
    compartment_id   = string
    name             = string
    access_type      = string
    storage_tier     = string
    events_enabled   = bool
    defined_tags     = map(string)
  }))
}

