# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


data "oci_objectstorage_namespace" "os" {
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_object" "this" {
    for_each  = var.bucket_upload_params
    bucket    = each.value.bucket
    namespace = data.oci_objectstorage_namespace.os.namespace
    object    = each.value.object
    content   = file(each.value.object)
}