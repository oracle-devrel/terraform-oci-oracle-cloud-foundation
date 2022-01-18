# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_mysql_mysql_db_system" "this" {
    for_each                    = var.mysql_params
    availability_domain         = each.value.availability_domain
    admin_password              = each.value.admin_password
    admin_username              = each.value.admin_username    
    compartment_id              = each.value.compartment_id
    configuration_id            = var.mysql_conf[each.value.configuration_id]
    shape_name                  = each.value.shape_name
    subnet_id                   = each.value.subnet_id
    data_storage_size_in_gb     = each.value.data_storage_size_in_gb
    description                 = each.value.description
    display_name                = each.value.display_name
    port                        = each.value.db_system_port
    port_x                      = each.value.db_system_port_x
    hostname_label              = each.value.db_system_hostname
    fault_domain                = each.value.fault_domain
    is_highly_available         = each.value.is_highly_available
    defined_tags                = each.value.defined_tags

    backup_policy {
        is_enabled          = each.value.backup_is_enabled
        retention_in_days   = each.value.backup_retention_in_days
        window_start_time   = each.value.backup_window_start_time
    }
}

resource "oci_mysql_heat_wave_cluster" "this" {
    for_each     = var.mysql_params
    db_system_id = oci_mysql_mysql_db_system.this[each.key].id
    cluster_size = each.value.heat_wave_cluster_cluster_size
    shape_name   = each.value.head_wave_cluster_shape_name
}
