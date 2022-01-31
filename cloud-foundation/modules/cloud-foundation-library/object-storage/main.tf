# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_objectstorage_namespace" "os" {
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "os" {
  for_each = {
    for k,v in var.bucket_params : k => v if v.compartment_id != ""
  } 
  compartment_id        = each.value.compartment_id
  name                  = each.value.name
  namespace             = data.oci_objectstorage_namespace.os.namespace
  access_type           = each.value.access_type
  storage_tier          = each.value.storage_tier
  object_events_enabled = each.value.events_enabled
  defined_tags          = each.value.defined_tags
}
