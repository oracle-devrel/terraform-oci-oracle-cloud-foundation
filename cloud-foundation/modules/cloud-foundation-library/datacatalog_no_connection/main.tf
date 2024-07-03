# Copyright © 2024, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_datacatalog_catalog" "this" {
    for_each       = var.datacatalog_params
    compartment_id = each.value.compartment_id
    display_name   = each.value.catalog_display_name
    defined_tags   = each.value.defined_tags
}

resource "oci_datacatalog_data_asset" "this" {
    for_each       = var.datacatalog_params
    catalog_id     = oci_datacatalog_catalog.this[each.key].id
    display_name   = each.value.catalog_display_name
    type_key       = data.oci_datacatalog_catalog_types.this[each.key].type_collection[0].items[0].key
     properties    = {
      "default.database"        = var.db_name
      "default.privateendpoint" = "false"
    }
}

data "oci_datacatalog_catalog_types" "this" {  
    for_each       = var.datacatalog_params
    catalog_id     = oci_datacatalog_catalog.this[each.key].id
    type_category  = "dataAsset"
    name           = "Autonomous Data Warehouse"
    state          = "ACTIVE"
}
