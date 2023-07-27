# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_database_db_home" "this" {
    for_each = var.database_db_home
    database {
        admin_password = each.value.admin_password
        defined_tags   = each.value.defined_tags
        freeform_tags  = each.value.freeform_tags
        db_name        = each.value.db_name
    }
    db_version         = each.value.db_version
    display_name       = each.value.display_name
    source             = each.value.source
    vm_cluster_id      = each.value.vm_cluster_id
    lifecycle {
      ignore_changes = all
    }
}