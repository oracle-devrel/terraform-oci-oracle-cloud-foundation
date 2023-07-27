# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_database_cloud_vm_cluster" "this" {
    for_each                        = var.cloud_vm_cluster
    backup_subnet_id                = each.value.backup_subnet_id
    cloud_exadata_infrastructure_id = each.value.cloud_exadata_infrastructure_id
    compartment_id                  = each.value.compartment_id
    cpu_core_count                  = each.value.cpu_core_count
    display_name                    = each.value.display_name
    gi_version                      = each.value.gi_version
    hostname                        = each.value.hostname
    ssh_public_keys                 = each.value.ssh_public_keys
    subnet_id                       = each.value.subnet_id
    cluster_name                    = each.value.cluster_name
    data_storage_percentage         = each.value.data_storage_percentage
    defined_tags                    = each.value.defined_tags
    domain                          = each.value.domain
    freeform_tags                   = each.value.freeform_tags
    is_local_backup_enabled         = each.value.is_local_backup_enabled
    is_sparse_diskgroup_enabled     = each.value.is_sparse_diskgroup_enabled
    license_model                   = each.value.license_model
    nsg_ids                         = each.value.nsg_ids
    scan_listener_port_tcp          = each.value.scan_listener_port_tcp
    scan_listener_port_tcp_ssl      = each.value.scan_listener_port_tcp_ssl
    time_zone                       = each.value.time_zone
    lifecycle {
      ignore_changes = all
    }
}