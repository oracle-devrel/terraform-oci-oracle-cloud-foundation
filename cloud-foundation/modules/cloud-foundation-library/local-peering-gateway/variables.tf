# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


variable "lpg_params" {
  type = map(object({
    vcn_id2        = string
    vcn_id1        = string
    display_name   = string
    compartment_id = string
  }))
}