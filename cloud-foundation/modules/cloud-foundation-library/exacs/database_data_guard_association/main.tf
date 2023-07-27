# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_database_databases" "this" {
    compartment_id = var.compartment_id
    db_home_id     = var.db_home_id
}

resource "oci_database_data_guard_association" "this" {
    for_each                 = var.database_data_guard_association
    creation_type            = each.value.creation_type
    database_admin_password  = each.value.database_admin_password
    database_id              = data.oci_database_databases.this.databases[0].id
    delete_standby_db_home_on_delete = each.value.delete_standby_db_home_on_delete
    peer_vm_cluster_id       = each.value.peer_vm_cluster_id
    protection_mode          = each.value.protection_mode
    transport_type           = each.value.transport_type
}
