# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_database_db_system" "this" {
  
  for_each            = var.dbcs_params

    availability_domain = each.value.availability_domain
    compartment_id      = each.value.compartment_id
    subnet_id           = each.value.subnet_id
    cpu_core_count      = each.value.cpu_core_count
    database_edition    = each.value.db_edition

  lifecycle {
    ignore_changes = [cpu_core_count, ssh_public_keys]
  }

  db_home {
    database {
      admin_password = each.value.db_admin_password
      db_name        = each.value.db_name
      db_workload    = each.value.db_workload
      pdb_name       = each.value.pdb_name

      db_backup_config {
        auto_backup_enabled = each.value.enable_auto_backup
      }
    }

    db_version   = each.value.db_version
    display_name = each.value.display_name
  }

  disk_redundancy         = each.value.disk_redundancy
  shape                   = each.value.shape
  ssh_public_keys         = [file(each.value.ssh_public_key)]
  display_name            = each.value.display_name
  hostname                = each.value.hostname
  data_storage_size_in_gb = each.value.data_storage_size_in_gb
  license_model           = each.value.license_model
  node_count              = each.value.node_count
}
