// Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_datacatalog_catalog" "this" {
  for_each = {
    for k,v in var.datacatalog_params : k => v if v.compartment_id != ""
  } 
    compartment_id = each.value.compartment_id
    display_name   = each.value.catalog_display_name
    defined_tags   = each.value.defined_tags
}

