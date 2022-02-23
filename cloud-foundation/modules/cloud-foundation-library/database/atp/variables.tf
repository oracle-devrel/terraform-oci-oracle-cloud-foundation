variable "tenancy_ocid" {}
variable "compartment_ocid" {}

variable "autonomous_database_cpu_core_count"{}

variable "autonomous_database_db_name" {}

variable "autonomous_database_admin_password" {}

variable "autonomous_database_data_storage_size_in_tbs" {}

variable "nsg_ids" {
    default = []
}

variable "subnet_id" {
    default = null
}

variable "is_mtls_connection_required" {
    default = true
}