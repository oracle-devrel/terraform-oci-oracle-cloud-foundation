# Copyright © 2022, Oracle and/or its affiliates.
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

# Autonomous Database Configuration Variables

variable "adw_cpu_core_count" {
    type = number
    default = 1
}

variable "adw_size_in_tbs" {
    type = number
    default = 1
}

variable "adw_db_name" {
    type = string
    default = "ADWipanLH"
}

variable "adw_db_workload" {
    type = string
    default = "DW"
}

variable "adw_db_version" {
    type = string
    default = "19c"
}

variable "adw_enable_auto_scaling" {
    type = bool
    default = true
}

variable "adw_is_free_tier" {
    type = bool
    default = false
}

variable "adw_license_model" {
    type = string
    default = "LICENSE_INCLUDED"
}

variable "database_admin_password" {
  type = string
  default = ""
}

variable "database_wallet_password" {
  type = string
  default = ""
}


# Oracle Analytics Cloud Configuration

variable "analytics_instance_feature_set" {
    type    = string
    default = "ENTERPRISE_ANALYTICS"
}

variable "analytics_instance_license_type" {
    type    = string
    default = "LICENSE_INCLUDED"
}

variable "analytics_instance_hostname" {
    type    = string
    default = "AnalyicSDLH"
}

variable "analytics_instance_idcs_access_token" {
    type    = string
    default = "copy-paste your token instead"
}

variable "analytics_instance_capacity_capacity_type" {
    type    = string
    default = "OLPU_COUNT"
}

variable "analytics_instance_capacity_value" {
    type    = number
    default = 1
}

variable "analytics_instance_network_endpoint_details_network_endpoint_type" {
    type    = string
    default = "public"
}

variable "whitelisted_ips" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "analytics_instance_network_endpoint_details_whitelisted_ips" {
  type = list(string)
  default = ["0.0.0.0/0"]
}


# Object Storage Bucket

variable "data_bucket_name" {
    type    = string
    default = "Lakehouse_data_bucket"
}

variable "data_bucket_access_type" {
    type    = string
    default  = "NoPublicAccess"
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


# Data Catalog

variable "datacatalog_display_name" {
    type    = string
    default = "DataCatalogIP"
}


# ODI - Oracle Cloud Infrastructure Data Integration service

variable "odi_display_name" {
    type    = string
    default = "odi_workspace"
}

variable "odi_description" {
    type    = string
    default  = "odi_workspace"
}


# Data Science with notebook 

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


# OCI Golden Gate

variable "goden_gate_cpu_core_count" {
  default = 2
}

variable "goden_gate_deployment_type" {
  default = "OGG"
}

variable "golden_gate_license_model" {
  default = "LICENSE_INCLUDED"
}

variable "goden_gate_display_name" {
  default = "ogg_deployment"
}

variable "goden_gate_is_auto_scaling_enabled" {
  default = false
}

variable "goden_gate_admin_password" {
  default = "Oracle-1234567"
}

variable "goden_gate_admin_username" {
  default = "ogg"
}

variable "goden_gate_deployment_name" {
  default = "ogg_deployment"
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


# Api gateway

variable "apigw_display_name" {
  default = "Lakehouse_ApiGW"
}

variable "apigwdeploy_display_name" {
  default = "Lakehouse_deployment"
}


# Ai Anomaly Detection Variables

variable "ai_anomaly_detection_project_display_name" {
  default = "Lakehouse_anomaly_detection_project"
}

variable "ai_anomaly_detection_project_description" {
  default = "Lakehouse_anomaly_detection_project"
}

variable "ai_anomaly_detection_data_asset_project_name" {
  default = "Lakehouse_project"
}

variable "ai_anomaly_detection_data_asset_data_source_type" {
  default = "ORACLE_OBJECT_STORAGE"
}

variable "ai_anomaly_detection_data_asset_bucket" {
  default = "Lakehouse_data_bucket"
}

variable "ai_anomaly_detection_data_asset_measurement_name" {
  default = "influx_lakehouse"
}

variable "ai_anomaly_detection_data_asset_object" {
  default = "demo-testing-data.json"
}

variable "ai_anomaly_detection_data_asset_influx_version" {
  default = "V_2_0"
}

variable "ai_anomaly_detection_data_asset_description" {
  default = "Lakehouse_anomaly_detection_data_asset"
}

variable "ai_anomaly_detection_data_asset_display_name" {
  default = "Lakehouse_anomaly_detection_data_asset"
}


# Big Data Service Variables

variable "big_data_cluster_admin_password" {
  default = "SW5pdDAxQA=="     # Password has to be Base64 encoded, e.g.: echo Init01$$ | base64
}

variable "big_data_cluster_public_key" {
  default = "" # example : "/root/.ssh/id_rsa.pub"
}

variable "big_data_cluster_version" {
  default = "ODH1" // new version with Ambari Server - no autoscalling working at the moment
    # cluster_version = "CDH6" // old version - Cloudera Manager version with autoscalling working 
}

variable "big_data_display_name" {
  default = "Lakehouse Cluster"
}

variable "big_data_is_high_availability" {
  default = false
}

variable "big_data_is_secure" {
  default = false
}

variable "big_data_master_node_spape" {
  default = "VM.Standard2.4"
}

variable "big_data_master_node_block_volume_size_in_gbs" {
  default = 150 // minimum size is 150
}

variable "big_data_master_node_number_of_nodes" {
  default = 1
}

variable "big_data_util_node_shape" {
  default = "VM.Standard2.4"
}

variable "big_data_util_node_block_volume_size_in_gbs" {
  default = 150 // minimum size is 150
}

variable "big_data_util_node_number_of_nodes" {
  default = 1
}

variable "big_data_worker_node_shape" {
  default = "VM.Standard2.4"
}

variable "big_data_worker_node_block_volume_size_in_gbs" {
  default = 150 // minimum size is 150
}

variable "big_data_worker_node_number_of_nodes" {
  default = 3 // worker_node.0.number_of_nodes to be at least (3)
}


# Compute Configuration
# More information regarding shapes can be found here:
# https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm
# "Web-Tier-and-Bastion" variables

variable "bastion_shape" {
  default = "VM.Standard2.4"
}

# "Workers" variables

variable "worker1_shape" {
  default = "VM.Standard2.4"
}

variable "worker2_shape" {
  default = "VM.Standard2.4"
}

variable "worker3_shape" {
  default = "VM.Standard2.4"
}


# "Masters" variables

variable "master1_shape" {
  default = "VM.Standard2.4"
}

variable "master2_shape" {
  default = "VM.Standard2.4"
}


# Networking variables

# FastConnect Variables

variable "private_fastconnect_name" {
  default = "private_vc_with_provider_no_cross_connect_or_cross_connect_group_id"
}

variable "private_fastconnect_type" {
  default = "PRIVATE"
}

variable "private_fastconnect_bw_shape" {
  default = "10 Gbps"
}

variable "private_fastconnect_cust_bgp_peering_ip" {
  default = "10.0.0.22/30"
}

variable "private_fastconnect_oracle_bgp_peering_ip" {
  default = "10.0.0.21/30"
}

variable "private_fastconnect_drg" {
  default = "mgmt_drg"
}


# DRG Variables

variable "drg_name" {
  default = "mgmt_drg"
}

variable "drg_cidr_rt" {
  default = "192.0.0.0/16"
}


# VCN and subnet Variables

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "service_name" {
  type        = string
  default     = "IonelP"
  description = "A prefix for policies and dynamic groups names - scope: to be unique names not duplicates"
}

# # don't modify any other variables (below) - it may cause that the solution will not work propertly.

variable "use_regional_subnet" {
  type = bool
  default = true
  description = "Indicates use of regional subnets (preferred) instead of AD specific subnets"
}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.0.0"
}

# # End