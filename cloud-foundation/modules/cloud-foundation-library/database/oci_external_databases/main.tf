# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_database_external_container_database" "this" {
  for_each       = var.register_external_container_db
  compartment_id = each.value.compartment_id
  display_name   = each.value.external_container_display_name
}

resource "oci_database_external_pluggable_database" "this" {
    for_each       = var.register_external_pluggable_db
    compartment_id = each.value.compartment_id
    display_name   = each.value.external_pluggable_database_display_name
    external_container_database_id = oci_database_external_container_database.this[each.value.external_container_name].id
}

resource "oci_database_external_database_connector" "this" {
    for_each = var.connector_external_container_db
    connection_credentials {
        credential_name = each.value.external_database_connector_connection_credentials_credential_name
        credential_type = each.value.external_database_connector_connection_credentials_credential_type
        password = each.value.external_database_connector_connection_credentials_password
        role = each.value.external_database_connector_connection_credentials_role
        username = each.value.external_database_connector_connection_credentials_username
    }
    connection_string {
        hostname = each.value.external_database_connector_connection_string_hostname
        port = each.value.external_database_connector_connection_string_port
        protocol = each.value.external_database_connector_connection_string_protocol
        service = each.value.external_database_connector_connection_string_service
    }
    connector_agent_id = each.value.oci_database_connector_agent_id
    display_name = each.value.external_database_connector_display_name
    external_database_id = oci_database_external_container_database.this[each.value.external_container_name].id
    connector_type = each.value.external_database_connector_connector_type
}

resource "oci_database_external_database_connector" "that" {
    for_each = var.connector_external_pluggable_db
    connection_credentials {
        credential_name = each.value.external_database_connector_connection_credentials_credential_name
        credential_type = each.value.external_database_connector_connection_credentials_credential_type
        password = each.value.external_database_connector_connection_credentials_password
        role = each.value.external_database_connector_connection_credentials_role
        username = each.value.external_database_connector_connection_credentials_username
    }
    connection_string {
        hostname = each.value.external_database_connector_connection_string_hostname
        port = each.value.external_database_connector_connection_string_port
        protocol = each.value.external_database_connector_connection_string_protocol
        service = each.value.external_database_connector_connection_string_service
    }
    connector_agent_id = each.value.oci_database_connector_agent_id
    display_name = each.value.external_database_connector_display_name
    external_database_id = oci_database_external_pluggable_database.this[each.value.external_pluggable_name].id
    connector_type = each.value.external_database_connector_connector_type
    depends_on = [
    oci_database_external_database_connector.this,
    ]
}

# Monitoring 
# Enabling Database Management External Container Database and for External Pluggable Database Details
# Enabling Operation Insights for External Pluggable Database

resource "oci_database_external_container_database_management" "this" {
    for_each = var.connector_external_container_db
    enable_management = each.value.enable_database_management_for_external_containers_database
    external_container_database_id = oci_database_external_container_database.this[each.value.external_container_name].id
    external_database_connector_id = oci_database_external_database_connector.this[each.value.external_container_name].id
    license_model = each.value.license_model 
    depends_on = [
    oci_database_external_container_database.this, oci_database_external_pluggable_database.this, oci_database_external_database_connector.this, oci_database_external_database_connector.that
    ]
}  

resource "oci_database_external_pluggable_database_management" "this" {
    for_each = var.connector_external_pluggable_db
    enable_management = each.value.enable_database_management_for_external_pluggable_database
    external_database_connector_id = oci_database_external_database_connector.this[each.value.external_container_name].id
    external_pluggable_database_id = oci_database_external_pluggable_database.this[each.value.external_pluggable_name].id
    depends_on = [
    oci_database_external_container_database.this, oci_database_external_pluggable_database.this, oci_database_external_database_connector.this, oci_database_external_database_connector.that, oci_database_external_container_database_management.this,
    ]
}

resource "oci_database_external_pluggable_database_operations_insights_management" "this" {
    for_each = var.connector_external_pluggable_db
    external_database_connector_id = oci_database_external_database_connector.this[each.value.external_container_name].id
    external_pluggable_database_id = oci_database_external_pluggable_database.this[each.value.external_pluggable_name].id
    enable_operations_insights = each.value.enable_operations_insights_management_for_external_pluggable_database
    depends_on = [
    oci_database_external_container_database.this, oci_database_external_pluggable_database.this, oci_database_external_database_connector.this, oci_database_external_database_connector.that, oci_database_external_container_database_management.this, oci_database_external_pluggable_database_management.this,
    ]
}