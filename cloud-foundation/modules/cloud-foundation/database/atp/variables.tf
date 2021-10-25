#Tenancy Details

variable "tenancy_ocid" {}
variable "compartment_ocid" {}

#Database

variable "autonomous_database_cpu_core_count"{}

variable "autonomous_database_db_name" {}

variable autonomous_database_admin_password {}

variable autonomous_database_data_storage_size_in_tbs {}

/* variable "kms_encrypted_value" {
    default = "V2xzQXRwRGIxMjM0Iw=="
}

variable "kms_crypto_endpoint" {
    type = string
    default = "https://bjqmywdtaafak-crypto.kms.eu-frankfurt-1.oraclecloud.com"
}

variable "kms_key_id" {
    default = "ocid1.key.oc1.eu-frankfurt-1.bjqmywdtaafak.abtheljr4na5bc7nxsqhjlagwybhkyafvvnq63rjtot4txgqiiafmzwwsvma"
}
*/