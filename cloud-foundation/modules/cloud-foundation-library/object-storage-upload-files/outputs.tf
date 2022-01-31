# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


output "buckets_upload" {
  value = {
    for upload in oci_objectstorage_object.this:
      upload.bucket => { "object" : upload.object, "content" : upload.content, "id": upload.id }
  }
}