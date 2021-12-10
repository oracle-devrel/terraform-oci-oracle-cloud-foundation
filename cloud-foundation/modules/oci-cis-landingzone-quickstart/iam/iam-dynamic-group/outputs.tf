# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "dynamic_groups" {
  description = "The dynamic-groups indexed by group name."
  value       = { for dg in oci_identity_dynamic_group.these : dg.name => dg }
} 