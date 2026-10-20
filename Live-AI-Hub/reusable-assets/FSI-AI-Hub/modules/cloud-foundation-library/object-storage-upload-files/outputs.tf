# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "buckets_upload" {
  value = {
    for key, upload in oci_objectstorage_object.this :
    key => { bucket = upload.bucket, object = upload.object, id = upload.id }
  }
}
