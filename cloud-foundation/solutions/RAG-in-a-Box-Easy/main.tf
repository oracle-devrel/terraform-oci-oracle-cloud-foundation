# Copyright © 2025, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Create ADW Database with Endpoint in private subnet or public ADW
module "adb" {
  source = "./modules/cloud-foundation-library/database/adb"
  adw_params = local.adw_params
}

# Calling the Object Storage module
module "os" {
  source = "./modules/cloud-foundation-library/object-storage"
  depends_on = [module.adb]
  tenancy_ocid = var.tenancy_ocid
  bucket_params = {
    for k,v in local.bucket_params : k => v if v.compartment_id != "" 
  }
}

# Ensure the bucket deletion happens after objects are removed
resource "null_resource" "ensure_bucket_deletion_order" {
  depends_on = [null_resource.delete_files_from_object_storage]
}