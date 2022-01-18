# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "mysql_params" {
  description = "The paramaters for the database"
  type        = map(object({
    compartment_id          = string
    admin_password          = string
    admin_username          = string
    availability_domain     = string
    configuration_id        = string
    shape_name              = string
    subnet_id               = string
    data_storage_size_in_gb = number
    description             = string
    display_name            = string
    db_system_port          = number
    db_system_port_x        = number
    db_system_hostname      = string
    fault_domain            = string
    backup_is_enabled       = bool
    backup_retention_in_days = number
    backup_window_start_time = string
    is_highly_available      = bool
    defined_tags             = map(string)
    heat_wave_cluster_cluster_size = number
    head_wave_cluster_shape_name   = string
  }))
}

variable "mysql_conf" {
  type = map(string)
}

