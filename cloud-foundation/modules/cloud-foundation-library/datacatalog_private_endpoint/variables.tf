# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "datacatalog_params" {
  type = map(object({
    compartment_id                     = string
    catalog_display_name               = string
    defined_tags                       = map(string)
    dbusername                         = string
    dbpassword                         = string
  }))
}

variable "db_name" {
  type = string
}

variable "wallet" {}
