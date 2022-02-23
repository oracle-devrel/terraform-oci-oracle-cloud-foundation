resource "oci_database_autonomous_database" "autonomous_database" {

    compartment_id = var.compartment_ocid
    cpu_core_count = var.autonomous_database_cpu_core_count
    db_name = var.autonomous_database_db_name
    display_name = var.autonomous_database_db_name
    admin_password = base64decode(var.autonomous_database_admin_password)
    data_storage_size_in_tbs = var.autonomous_database_data_storage_size_in_tbs
    nsg_ids                                = var.nsg_ids
    subnet_id                             = var.subnet_id
    is_mtls_connection_required = var.is_mtls_connection_required
}