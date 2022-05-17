# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
 	description = "The OCID of the tenancy."
}
variable "compartment_ocid" {
	description = "The OCID of autonomous database compartment."
}
variable "autonomous_database_cpu_core_count"{
	description = "Number of CPU cores count for ATP."
}
variable "autonomous_database_db_name" {
	description = "Name of ATP database."
}
variable "autonomous_database_admin_password" {
	description = "Admin Password - One Time."
}
variable "autonomous_database_data_storage_size_in_tbs" {
	description = "Storage Size in Tbs."
}

variable "nsg_ids" {
    description = "NSG IDs for autonomus database."
    default = []
}

variable "subnet_id" {
    description = "Subnet ID of database."
    default = null
}

variable "is_mtls_connection_required" {
    description = "MTLS connection required."
    default = true
}