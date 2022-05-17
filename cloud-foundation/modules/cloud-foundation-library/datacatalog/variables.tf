# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "datacatalog_params" {
  type = map(object({
    compartment_id       = string
    catalog_display_name = string
    defined_tags         = map(string)
  }))
}

# variable "datacatalog_data_asset_params" {
#   type = map(object({
#     datacatalog_name = string
#     data_asset_display_name = string
#     data_asset_type_key = string
#     data_asset_description = string
#     data_asset_properties = list(object({
#         name  = string
#         value = string
#     }))
#   }))
# }

# variable "datacatalog_connection_params" {
#   type = map(object({
#     datacatalog_name = string
#     connection_data_asset_key = string
#     connection_display_name = string
#     connection_properties = list(object({
#         name  = string
#         value = string
#     }))
#     connection_type_key = string
#     connection_description = string 
#     connection_enc_properties = list(object({
#         name  = string
#         value = string
#     }))
#     connection_is_default = string
#   }))
# }
