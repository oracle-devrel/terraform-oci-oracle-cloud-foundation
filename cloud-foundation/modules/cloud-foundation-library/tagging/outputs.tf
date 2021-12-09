# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "tag_namespace" {
  value = [ for b in oci_identity_tag_namespace.this : b.name]
}

output "tag_keys" {
  value = [ for b in oci_identity_tag.this : b.name]
}