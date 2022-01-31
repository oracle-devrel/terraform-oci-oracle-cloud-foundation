# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# output "buckets" {
#   value = {
#     for bucket in oci_objectstorage_bucket.os:
#       bucket.name => bucket.access_type
#   }
# }


output "buckets_id"{
  value = {
    for bucket in oci_objectstorage_bucket.os:
      bucket.name => {"compartment_id": bucket.compartment_id, "id": bucket.id}
  }
}


output "buckets" {
  description = "Buckets informations."
  value       = length(oci_objectstorage_bucket.os) > 0 ? oci_objectstorage_bucket.os[*] : null
}