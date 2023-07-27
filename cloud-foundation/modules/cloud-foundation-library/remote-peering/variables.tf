# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type = string
}

variable "vcns" {
  description = "The list of vnc's"
  type        = map(map(string))
}

variable "vcns2" {
  description = "The list of vnc's"
  type        = map(map(string))
}

variable "rpg_params" {
  description = "The parameters for the DRG"
  type = list(object({
    vcn_name_requestor = string
    vcn_name_acceptor  = string
  }))
}

variable "requestor_region" {}
variable "acceptor_region" {}
