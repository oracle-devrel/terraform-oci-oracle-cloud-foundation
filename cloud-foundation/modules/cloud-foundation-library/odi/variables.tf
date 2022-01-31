# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "odi_params" {
  type = map(object({
    compartment_id   = string
    display_name     = string
    description      = string
    # is_private_network_enabled = bool
    # subnet_id        = string
    # vcn_id           = string
    defined_tags     = map(string)
  }))
}

