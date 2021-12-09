# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.
variable "bv_params" {
  type = map(object({
    ad                   = string
    compartment_id       = string
    display_name         = string
    bv_size              = number
    defined_tags         = map(string)
    freeform_tags        = map(string)
  }))
}

variable "bv_attach_params" {
  type = map(object({
    display_name         = string
    attachment_type      = string
    instance_id          = string
    volume_id            = string
  }))
}

