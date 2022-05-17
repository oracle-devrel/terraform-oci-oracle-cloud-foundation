# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_datacatalog_catalog" "this" {
  for_each = {
    for k,v in var.datacatalog_params : k => v if v.compartment_id != ""
  } 
    compartment_id = each.value.compartment_id
    display_name   = each.value.catalog_display_name
    defined_tags   = each.value.defined_tags
}

# resource "oci_datacatalog_data_asset" "this" {
#     for_each       = var.datacatalog_data_asset_params
#     catalog_id     = oci_datacatalog_catalog.this[each.value.datacatalog_name].id
#     display_name   = each.value.data_asset_display_name
#     type_key       = each.value.data_asset_type_key
#     description    = each.value.data_asset_description
#     properties     = each.value.data_asset_properties
# }

# resource "oci_datacatalog_connection" "this" {
#     for_each       = var.datacatalog_connection_params
#     catalog_id     = oci_datacatalog_catalog.this[each.value.datacatalog_name].id
#     data_asset_key = oci_datacatalog_data_asset.this[each.value.connection_data_asset_key].id
#     display_name   = each.value.connection_display_name
#     properties     = each.value.connection_properties
#     type_key       = each.value.connection_type_key
#     description    = each.value.connection_description
#     enc_properties = each.value.connection_enc_properties
#     is_default     = each.value.connection_is_default
# }