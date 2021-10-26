# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "os" {
  source = "../../../../../cloud-foundation/modules/cloud-foundation-library/object-storage"
  tenancy_ocid = var.tenancy_ocid
  
  bucket_params = { 
    bucket = {
      compartment_id   = var.compartment_id,
      name             = var.bucket_name,
      access_type      = var.bucket_access_type,
      storage_tier     = var.bucket_storage_tier,
      events_enabled   = var.bucket_events_enabled,
      defined_tags     = var.defined_tags
  }
 }
}
