# Copyright © 2023, Oracle and/or its affiliates.
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


# Object Storage Bucket

variable "data_bucket_name" {
  type    = string
  default = "data_bucket"
}

variable "data_bucket_access_type" {
  type    = string
  default = "NoPublicAccess"
}

variable "data_bucket_storage_tier" {
  type    = string
  default = "Standard"
}

variable "data_bucket_events_enabled" {
  type    = bool
  default = false
}

variable "dataflow_logs_bucket_name" {
  type    = string
  default = "dataflow-logs"
}

variable "dataflow_logs_bucket_access_type" {
  type    = string
  default = "NoPublicAccess"
}

variable "dataflow_logs_bucket_storage_tier" {
  type    = string
  default = "Standard"
}

variable "dataflow_logs_bucket_events_enabled" {
  type    = bool
  default = false
}

# Streaming

variable "stream_name" {
  type    = string
  default = "Test_Stream"
}

variable "stream_partitions" {
  type    = string
  default = "1"
}

variable "stream_retention_in_hours" {
  type    = string
  default = "24"
}

variable "stream_pool_name" {
  type    = string
  default = "Test_Stream_Pool"
}

variable "service_connector_display_name" {
  default = "Test_Service_Connector"
}

variable "service_connector_source_kind" {
  default = "streaming"
}

variable "service_connector_source_cursor_kind" {
  default = "TRIM_HORIZON"
}

variable "service_connector_target_kind" {
  default = "objectStorage"
}

variable "service_connector_target_bucket" {
  default = "data_bucket"
}

variable "service_connector_target_object_name_prefix" {
  default = "data"
}

variable "service_connector_target_batch_rollover_size_in_mbs" {
  default = 10
}

variable "service_connector_target_batch_rollover_time_in_ms" {
  default = 60000
}

variable "service_connector_description" {
  default = "Used to connect streaming to object storage"
}

variable "service_connector_tasks_kind" {
  default = "function"
}

variable "service_connector_tasks_batch_size_in_kbs" {
  default = 5120
}

variable "service_connector_tasks_batch_time_in_sec" {
  default = 60
}

# Functions

variable "app_display_name" {
  default = "DecoderApp"
}

variable "application_shape" {
  default = "GENERIC_ARM"
  # default = "GENERIC_X86"
  # default = "GENERIC_X86_ARM"
}

# Example: decoder 

variable "ocir_repo_name" {
  default = "decoder_repo"
}

# Example: oracleidentitycloudservice/username

variable "ocir_user_name" {
  default = "oracleidentitycloudservice/username"
}

# Example: Q0fn}4DpL8B[WwGbuSYt

variable "ocir_user_password" {
  default = ""
}

# Data Flow Application
# Variables for Data Flow Application
# The default values below are specific to the data flow tutorial for a Java application
# URL for the data flow tutorial https://docs.cloud.oracle.com/en-us/iaas/data-flow/tutorial/dfs_tut_etl_java_create.htm
# Modify the values below based on your specific application

variable "application_display_name" {
  default = "dataflowapp"
}

variable "application_driver_shape" {
  default = "VM.Standard2.1"
}

variable "application_executor_shape" {
  default = "VM.Standard2.1"
}

variable "application_file_uri" {
  default = "oci://oow_2019_dataflow_lab@bigdatadatasciencelarge/usercontent/oow-lab-2019-java-etl-1.0-SNAPSHOT.jar"
}

variable "application_language" {
  default = "Java"
}

variable "application_num_executors" {
  default = 1
}

variable "application_spark_version" {
  default = "2.4.4"
}

variable "application_class_name" {
  default = "convert.Convert"
}

variable "application_description" {
  default = "Test Java Application"
}

# Data Science with notebook 

variable "project_description" {
  default = "Test_Project"
}

variable "project_display_name" {
  default = "data_science_project"
}

variable "notebook_session_display_name" {
  default = "notebook_session"
}

variable "notebook_session_notebook_session_configuration_details_shape" {
  default = "VM.Standard2.1"
}

variable "notebook_session_notebook_session_configuration_details_block_storage_size_in_gbs" {
  default = 50
}


# Network variables

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}
variable "private_subnet_cidr" {
  default = "10.0.1.0/24"
}

# don't modify any other variables (below) - it may cause that the solution will not work propertly.

variable "service_name" {
  type        = string
  default     = "servicename"
  description = "prefix for stack resources"
}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.0.0"
}

# End
