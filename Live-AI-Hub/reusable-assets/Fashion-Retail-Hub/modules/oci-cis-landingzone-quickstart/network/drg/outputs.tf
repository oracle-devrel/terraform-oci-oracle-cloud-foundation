# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# output "drg" {
#   description = "DRG information."
#   value       = length(oci_core_drg.this) > 0 ? oci_core_drg.this[0] : null
# }

# output "drg_id" {
#   value = oci_core_drg.this.*.id
# }

output "drgs_list" {
  value = {
    for drg in oci_core_drg.this:
      drg.display_name => drg.id
  }
}

output "drgs_details" {
  description = "DRG information."
  value       = length(oci_core_drg.this) > 0 ? oci_core_drg.this[*] : null
}