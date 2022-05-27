# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "register_external_container_db" {
  type = map(object({
    compartment_id                  = string
    external_container_display_name = string
  }))
}

variable "register_external_pluggable_db" {
  type = map(object({
    compartment_id                           = string
    external_pluggable_database_display_name = string
    external_container_name                  = string
  }))
}

variable "connector_external_container_db" {
  type = map(object({
    oci_database_connector_agent_id = string
    external_database_connector_display_name = string
    external_database_connector_connection_credentials_credential_name = string
    external_database_connector_connection_credentials_credential_type = string
    external_database_connector_connection_credentials_password = string
    external_database_connector_connection_credentials_role = string
    external_database_connector_connection_credentials_username = string
    external_database_connector_connection_string_hostname = string
    external_database_connector_connection_string_port = string
    external_database_connector_connection_string_protocol = string
    external_database_connector_connection_string_service = string
    external_database_connector_connector_type = string
    external_container_name = string
    enable_database_management_for_external_containers_database = bool
    license_model = string
  }))
}

variable "connector_external_pluggable_db" {
  type = map(object({
    external_pluggable_name = string
    external_container_name = string
    oci_database_connector_agent_id = string
    external_database_connector_display_name = string
    external_database_connector_connection_credentials_credential_name = string
    external_database_connector_connection_credentials_credential_type = string
    external_database_connector_connection_credentials_password = string
    external_database_connector_connection_credentials_role = string
    external_database_connector_connection_credentials_username = string
    external_database_connector_connection_string_hostname = string
    external_database_connector_connection_string_port = string
    external_database_connector_connection_string_protocol = string
    external_database_connector_connection_string_service = string
    external_database_connector_connector_type = string
    enable_database_management_for_external_pluggable_database = bool
    enable_operations_insights_management_for_external_pluggable_database = bool
  }))
}

