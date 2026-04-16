# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "dynamic_groups" {
  type = map(object({
    description    = string
    compartment_id = string
    matching_rule  = string
  }))
}  