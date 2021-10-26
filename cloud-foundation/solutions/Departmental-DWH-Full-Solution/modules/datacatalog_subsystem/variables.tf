# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
  type    = string
}

variable "datacatalog_display_name" {
    type    = string
}

variable "defined_tags" {
  type    = map
  default = {}
}



