# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


terraform {
  required_version = ">= 0.14.0"
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


# ADW Database Variables:

variable "db_name" {
  type    = string
  default = "ADWDataLake"
}

variable "db_password" {
  type = string
  default = "<enter-password-here>"
}

variable "db_cpu_core_count" {
  type = number
  default = 1
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
  default = "19c"
}

variable "db_enable_auto_scaling" {
  type = bool
  default = true
}

variable "db_is_free_tier" {
  type = bool
  default = false
}

variable "db_license_model" {
  type = string
  default = "BRING_YOUR_OWN_LICENSE"
}


# Object Storage Variables:

variable "bronze_bucket_name" {
  type    = string
  default = "bronze_bucket"
}

variable "bronze_bucket_access_type" {
    type    = string
    default  = "NoPublicAccess"
}

variable "bronze_bucket_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "bronze_bucket_events_enabled" {
    type    = bool
    default = false
}

variable "silver_bucket_name" {
  type    = string
  default = "silver_bucket"
}

variable "silver_bucket_access_type" {
    type    = string
    default  = "NoPublicAccess"
}

variable "silver_bucket_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "silver_bucket_events_enabled" {
    type    = bool
    default = false
}

variable "gold_bucket_name" {
  type    = string
  default = "gold_bucket"
}

variable "gold_bucket_access_type" {
    type    = string
    default  = "NoPublicAccess"
}

variable "gold_bucket_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "gold_bucket_events_enabled" {
    type    = bool
    default = false
}

variable "dataflow_logs_bucket_name" {
    type    = string
    default = "dataflow-logs"
}

variable "dataflow_logs_bucket_access_type" {
    type    = string
    default  = "NoPublicAccess"
}

variable "dataflow_logs_bucket_storage_tier" {
    type    = string
    default = "Standard"
}
  
variable "dataflow_logs_bucket_events_enabled" {
    type    = bool
    default = false
}


# Api gateway Variables:

variable "apigw_display_name" {
  default = "Lakehouse_ApiGW"
}

variable "apigwdeploy_display_name" {
  default = "Lakehouse_deployment"
}


# Streaming Variables:

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
  default = "bronze_bucket"
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


# Functions Variables:

variable "app_display_name" {
  default = "DecoderApp"
}

# Example: decoder 
variable "ocir_repo_name" {
  default = "decoder_repo"
}

# Example: oracleidentitycloudservice/username
variable "ocir_user_name" {
  default = "oracleidentitycloudservice/username"
}

# Example: rDCKamI}}Y.:5p2fVgX5
variable "ocir_user_password" {
  default = "<your-token>"
}


# Data Catalog Variables:

variable "catalog_display_name" {
    type    = string
    default = "DataLakeHouse"
}


# Bastion Service Variables:

variable "private_bastion_service_name" {
  default = "private-bastion-service"
}


# Analytics Cloud Instance Variables:

variable "Oracle_Analytics_Instance_Name" {
  default = "DataLakeHousev"
}

variable "analytics_instance_feature_set" {
  type = string
  default = "ENTERPRISE_ANALYTICS"
}

variable "analytics_instance_license_type" {
  type = string
  default = "LICENSE_INCLUDED"
}

variable "analytics_instance_idcs_access_token" {
  type = string
  default = "copy-paste your token instead"
}

variable "analytics_instance_capacity_capacity_type" {
  type = string
  default = "OLPU_COUNT"
}

variable "analytics_instance_capacity_value" {
  type = number
  default = 1
}


# ODI - Oracle Cloud Infrastructure Data Integration Service Variables:

variable "ocidi_display_name" {
    type    = string
    default = "ocidi_workspace"
}

variable "ocidi_description" {
    type    = string
    default  = "ocidi_workspace"
}



# Data Science with notebook Variables:

variable "project_description" {
  default = "Machine_learning_platform"
}

variable "project_display_name" {
  default = "Machine_learning_platform"
}

variable "notebook_session_display_name" {
  default = "Machine_learning_notebook_session"
}

variable "notebook_session_notebook_session_configuration_details_shape" {
  default = "VM.Standard2.1"
}

variable "notebook_session_notebook_session_configuration_details_block_storage_size_in_gbs" {
  default = 50
}


# Data Flow Application Variables:
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

variable "dataflow_display_name" {
  default = "dataflowapp"
}

variable "dataflow_max_host_count" {
  type = number
  default = 512
}


# Waf Service Variables:

variable "waf_display_name" {
  default = "waflb"
}


# Networking Variables: 
# DRG Variables


variable "drg_cidr_rt" {
  default = "192.0.0.0/16"
}


# VCN and subnet Variables

# VNC0
variable "vcn_0_hub_cidr" {
  default = "192.0.0.0/16"
}

variable "public_subnet_cidr_vcn0" {
  default = "192.0.2.0/28"
}

# VNC 1
variable "vcn_1_workload_cidr" {
  default = "10.0.0.0/16"
}

variable "private_subnet_cidr_application_vnc1" {
  default = "10.0.10.0/28"
}

variable "private_subnet_cidr_midtier_vnc1" {
  default = "10.0.20.0/28"
}

variable "private_subnet_cidr_data_vnc1" {
  default = "10.0.30.0/28"
}


# Load Balancer Variables:

variable "load_balancer_shape" {
  default = "flexible"
}

variable "load_balancer_maximum_bandwidth_in_mbps" {
  type    = number 
  default = 400
}

variable "load_balancer_minimum_bandwidth_in_mbps" {
  type    = number 
  default = 10
}

variable "load_balancer_display_name" {
  default = "lboac"
}

# # don't modify any other variables (below) - it may cause that the solution will not work propertly.

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.0.0"
}

