# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "cloud_vm_cluster" {
  type = map(object({
    backup_subnet_id = string
    cloud_exadata_infrastructure_id = string
    compartment_id    = string
    cpu_core_count    = number
    display_name      = string
    gi_version        = string
    hostname          = string
    ssh_public_keys   = list(string)
    subnet_id         = string
    cluster_name      = string
    data_storage_percentage = number
    defined_tags      = map(string)
    domain            = string
    freeform_tags     = map(string)
    is_local_backup_enabled     = string
    is_sparse_diskgroup_enabled = string
    license_model               = string
    nsg_ids                     = list(string)
    scan_listener_port_tcp      = number
    scan_listener_port_tcp_ssl  = number
    time_zone                   = string
  }))
}

