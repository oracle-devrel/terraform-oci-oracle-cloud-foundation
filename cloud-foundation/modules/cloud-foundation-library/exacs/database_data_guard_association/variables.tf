# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "compartment_id" {
    type = string
}

variable "db_home_id" {
    type = string
}

variable "database_data_guard_association" {
  type = map(object({
    creation_type           = string
    database_admin_password = string
    delete_standby_db_home_on_delete = bool
    peer_vm_cluster_id      = string
    protection_mode         = string
    transport_type          = string
  }))
}