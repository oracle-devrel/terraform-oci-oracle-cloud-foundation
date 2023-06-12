# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
    type = string
}

variable "region" {
    type = string
}

variable "datacatalog_params" {
  type = map(object({
    compartment_id                     = string
    catalog_display_name               = string
    adw_data_asset_display_name        = string
    object_storage_data_asset_display_name = string
    defined_tags                       = map(string)
    private_endpoint_dns_zones         = list(string)
    subnet_id                          = string
    # dbusername                         = string
    # dbpassword                         = string
  }))
}

variable "db_name" {
  type = string
}

# variable "wallet" {}
