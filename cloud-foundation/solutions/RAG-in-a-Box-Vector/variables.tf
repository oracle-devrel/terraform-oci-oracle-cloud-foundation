# Copyright © 2025, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


terraform {
  required_version = ">= 0.15.0"
}

variable "tenancy_ocid" {
  type = string
  default = ""
}

variable "region" {
    type = string
    default = ""
}

variable "compartment_id" {
  type = string
  default = ""
}

variable "user_ocid" {
    type = string
    default = ""
}

variable "fingerprint" {
    type = string
    default = ""
}

variable "private_key_path" {
    type = string
    default = ""
}


# Don't change the locals
# Override `bucket_url` with dynamic values
locals {
 bucket_url = "https://objectstorage.${var.region}.oraclecloud.com/n/${data.oci_objectstorage_namespace.this.namespace}/b/${var.bucket_name}/o/"
 # Use the bucket_url based on the condition if it's empty or not
 final_bucket_url = length(var.bucket_url) > 0 ? var.bucket_url : local.bucket_url
}



#####
# ADW Database Variables:

variable "db_name" {
  type    = string
  default = "vectorRAGinaBOX"
}

variable "db_password" {
  type = string
  default = ""
}

variable "db_compute_model" {
  type    = string
  default = "ECPU"
}

variable "db_compute_count" {
  type = number
  default = 2
}

variable "db_size_in_tbs" {
  type = number
  default = 1
}

variable "db_workload" {
  type = string
  default = "DW"
}

variable "db_version" {
  type = string
  default = "23ai"
}

variable "db_enable_auto_scaling" {
  type = bool
  default = false
}

variable "db_is_free_tier" {
  type = bool
  default = false
}

variable "db_license_model" {
  type = string
  default = "BRING_YOUR_OWN_LICENSE"
}

variable "db_data_safe_status" {
  type = string
  default = "NOT_REGISTERED"
  # default = "REGISTERED"
}

variable "db_operations_insights_status" {
  type = string
  default = "NOT_ENABLED"
  # default = "ENABLED"
}

variable "db_database_management_status" {
  type = string
  default = "NOT_ENABLED"
  # default = "ENABLED"
}


######
# Object Storage Variables:

variable "bucket_name" {
  type    = string
  default = "vectorRag_Bucket"
}

variable "bucket_access_type" {
    type    = string
    default  = "ObjectRead"
}

variable "bucket_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "bucket_events_enabled" {
    type    = bool
    default = false
}


###### 
# RAG IN A BOX SETTINGS:

# The username inside the database where you will install the apex application
variable "riab_user" {
  type = string
  default = "RIAB"
}

# The password for the user inside the database - The password must be between 12 and 30 characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol (") or the username "admin", regardless of casing. The password is mandatory if source value is "BACKUP_FROM_ID", "BACKUP_FROM_TIMESTAMP", "DATABASE" or "NONE"
variable "riab_password" {
  type = string
  default = ""
}

# The name of the apex workspace
variable "apex_workspace" {
  type = string
  default = "RIAB"
}

# The user in apex application
variable "apex_user" {
  type = string
  default = "VRIAB"
}

# The password for the apex user application - The password must be between 12 and 30 characters long, and must contain at least 1 uppercase, 1 lowercase, and 1 numeric character. It cannot contain the double quote symbol (") or the username "admin", regardless of casing. The password is mandatory if source value is "BACKUP_FROM_ID", "BACKUP_FROM_TIMESTAMP", "DATABASE" or "NONE"
variable "apex_password" {
  type = string
  default = ""
}


#  This is the URL of the source buckt where the files will be ingested.
# Example: https://objectstorage.us-chicago-1.oraclecloud.com/n/Object_storage_namespace/b/bucket_name/o/". 
# It is optional , if you don't have a bucket already, terraform will create a bucket for you and upload a sampledata file
#  as you log in the apex you can already put questions about data in industry.
variable "bucket_url" {
  type    = string
  default = ""
}

# -- If never done before, create API Key, download both PRIVATE and PUBLIC key files
# -- Convert PRIVATE KEY into the needed format for the credentials
# -- DO NOT USE rtf, just plain text files
# -- Enter as single line without breaks in the format -----BEGIN PRIVATE KEY-----.......-----END PRIVATE KEY-----
# -- Use this command to get the key correctly :    tr -d '\r\n' <mykeysep_privatepem.pem | pbcopy   - and copy the content of it in the below variable called : private_key

variable "private_key" {
  type    = string
  default = ""
}

