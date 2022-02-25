# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource  "oci_identity_policy" "these" {
    for_each = var.policies
      name           = each.key
      compartment_id = each.value.compartment_id
      description    = each.value.description
      statements     = each.value.statements 
}