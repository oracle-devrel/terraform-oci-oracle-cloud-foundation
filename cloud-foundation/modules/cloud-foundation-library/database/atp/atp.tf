# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

#Resource for ATP database

/*data "oci_kms_decrypted_data" "password" {
  ciphertext = "${var.kms_encrypted_value}"
  crypto_endpoint = "${var.kms_crypto_endpoint}"
  key_id = "${var.kms_key_id}"
}*/

resource "oci_database_autonomous_database" "autonomous_database" {

    #Required

    compartment_id = var.compartment_ocid
    cpu_core_count = var.autonomous_database_cpu_core_count
    db_name = var.autonomous_database_db_name
    display_name = var.autonomous_database_db_name
   //admin_password = "${data.oci_kms_decrypted_data.password.plaintext}"
    admin_password = base64decode(var.autonomous_database_admin_password)
    data_storage_size_in_tbs = var.autonomous_database_data_storage_size_in_tbs

    #Optional
    #admin_password = var.autonomous_database_admin_password
    #are_primary_whitelisted_ips_used = var.autonomous_database_are_primary_whitelisted_ips_used
    #autonomous_container_database_id = oci_database_autonomous_container_database.test_autonomous_container_database.id
    #autonomous_database_backup_id = oci_database_autonomous_database_backup.test_autonomous_database_backup.id
    #autonomous_database_id = oci_database_autonomous_database.test_autonomous_database.id
    #clone_type = var.autonomous_database_clone_type
    #customer_contacts {

        #Optional
        #email = var.autonomous_database_customer_contacts_email
    #}
    #data_safe_status = var.autonomous_database_data_safe_status
    #db_version = var.autonomous_database_db_version
    #db_workload = var.autonomous_database_db_workload
    #defined_tags = var.autonomous_database_defined_tags
    #display_name = var.autonomous_database_display_name
    #freeform_tags = {"Department"= "Finance"}
    #is_access_control_enabled = var.autonomous_database_is_access_control_enabled
    #is_auto_scaling_enabled = var.autonomous_database_is_auto_scaling_enabled
    #is_data_guard_enabled = var.autonomous_database_is_data_guard_enabled
    #is_dedicated = var.autonomous_database_is_dedicated
    #is_free_tier = var.autonomous_database_is_free_tier
    #is_preview_version_with_service_terms_accepted = var.autonomous_database_is_preview_version_with_service_terms_accepted
    #kms_key_id = oci_kms_key.test_key.id
    #license_model = var.autonomous_database_license_model
    #nsg_ids = var.autonomous_database_nsg_ids
    #private_endpoint_label = var.autonomous_database_private_endpoint_label
    #refreshable_mode = var.autonomous_database_refreshable_mode
    #source = var.autonomous_database_source
    #source_id = oci_database_source.test_source.id
    #standby_whitelisted_ips = var.autonomous_database_standby_whitelisted_ips
    #subnet_id = oci_core_subnet.test_subnet.id
    #timestamp = var.autonomous_database_timestamp
    #vault_id = oci_kms_vault.test_vault.id
    #whitelisted_ips = var.autonomous_database_whitelisted_ips
}