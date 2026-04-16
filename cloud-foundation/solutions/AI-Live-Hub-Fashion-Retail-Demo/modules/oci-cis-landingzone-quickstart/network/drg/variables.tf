# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


variable "compartment_id" {
  description = "Compartment's OCID where VCN will be created."
}

# variable "service_label" {
#   description = "A service label to be used as part of resource names."
# }

# variable "is_create_drg" {
#   description = "Whether a DRG is to be created."
#   default     = false
#   type        = bool
# }


variable "drg_params" {
  type = map(object({
    name         = string
    cidr_rt      = string
    defined_tags = map(string)
  }))
}