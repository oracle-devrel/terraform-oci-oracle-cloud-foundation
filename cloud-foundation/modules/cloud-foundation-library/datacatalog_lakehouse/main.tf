# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_datacatalog_catalog_private_endpoint" "this" {
    for_each       = var.datacatalog_params
    compartment_id = each.value.compartment_id
    dns_zones      = each.value.private_endpoint_dns_zones
    subnet_id      = each.value.subnet_id
    display_name   = each.value.catalog_display_name
    defined_tags   = each.value.defined_tags
}

resource "oci_datacatalog_catalog" "this" {
    for_each       = var.datacatalog_params
    compartment_id = each.value.compartment_id
    display_name   = each.value.catalog_display_name
    defined_tags   = each.value.defined_tags
    attached_catalog_private_endpoints = [oci_datacatalog_catalog_private_endpoint.this[each.key].id]
}

resource "oci_datacatalog_data_asset" "this" {
    for_each       = var.datacatalog_params
    catalog_id     = oci_datacatalog_catalog.this[each.key].id
    display_name   = each.value.adw_data_asset_display_name
    type_key       = data.oci_datacatalog_catalog_types.this[each.key].type_collection[0].items[0].key
     properties    = {
      "default.database"        = var.db_name
      "default.privateendpoint" = "true"
    }
}

resource "oci_datacatalog_data_asset" "that" {
    for_each       = var.datacatalog_params
    catalog_id     = oci_datacatalog_catalog.this[each.key].id
    display_name   = each.value.object_storage_data_asset_display_name
    type_key       = data.oci_datacatalog_catalog_types.objectstorage_data_asset[each.key].type_collection[0].items[0].key
    properties = {
    "default.namespace" = data.oci_objectstorage_namespace.os.namespace
    "default.url"       = "https://swiftobjectstorage.${var.region}.oraclecloud.com"
  }
}

# resource "oci_datacatalog_connection" "this" {
#     for_each       = var.datacatalog_params
#     catalog_id     = oci_datacatalog_catalog.this[each.key].id
#     data_asset_key = oci_datacatalog_data_asset.this[each.key].id
#     display_name   = each.value.catalog_display_name
#     is_default     = "false"
#     type_key       = data.oci_datacatalog_catalog_types.that[each.key].type_collection[0].items[2].key
#     properties     = {
#       "default.alias"            = "${var.db_name}_low"
#       "default.username"         = each.value.dbusername
#       "default.walletAndSecrets" = "plainWallet"
#     }
#     enc_properties = {
#       "default.password"   = each.value.dbpassword
#       "default.wallet"     = var.wallet
#     }
# } 

resource "oci_datacatalog_connection" "that" {
  for_each       = var.datacatalog_params
  catalog_id     = oci_datacatalog_catalog.this[each.key].id
  data_asset_key = oci_datacatalog_data_asset.that[each.key].id
  display_name   = each.value.object_storage_data_asset_display_name
  is_default     = "true"
  properties = {
    "default.ociCompartment" = each.value.compartment_id
    "default.ociRegion"      = var.region
  }
  type_key = data.oci_datacatalog_catalog_types.resource_principal_connection[each.key].type_collection[0].items[0].key
}

data "oci_datacatalog_catalog_types" "this" {  
    for_each       = var.datacatalog_params
    catalog_id     = oci_datacatalog_catalog.this[each.key].id
    type_category  = "dataAsset"
    name           = "Autonomous Data Warehouse"
    state          = "ACTIVE"
}


data "oci_datacatalog_catalog_types" "that" {
    for_each       = var.datacatalog_params
    catalog_id     = oci_datacatalog_catalog.this[each.key].id
    type_category  = "connection"
    name           = "Generic"
    state          = "ACTIVE"
}

data "oci_datacatalog_catalog_types" "objectstorage_data_asset" {
  for_each   = var.datacatalog_params
  catalog_id = oci_datacatalog_catalog.this[each.key].id

  filter {
    name   = "name"
    values = ["Oracle Object Storage"]
  }
  filter {
    name   = "type_category"
    values = ["dataAsset"]
  }
}

data "oci_datacatalog_catalog_types" "resource_principal_connection" {
  for_each   = var.datacatalog_params
  catalog_id = oci_datacatalog_catalog.this[each.key].id

  filter {
    name   = "name"
    values = ["Resource Principal"]
  }
  filter {
    name   = "type_category"
    values = ["connection"]
  }
}

data "oci_datacatalog_catalog_private_endpoint" "this" {
    for_each                    = var.datacatalog_params
    catalog_private_endpoint_id = oci_datacatalog_catalog_private_endpoint.this[each.key].id
}

data "oci_objectstorage_namespace" "os" {
  compartment_id = var.tenancy_ocid
}

