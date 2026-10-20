# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "db_name" { type = string }

variable "db_password" {
  type      = string
  sensitive = true
}

variable "conn_db" { type = string }
variable "wallet_zip_path" { type = string }
variable "adb_host" { type = string }
variable "fsi_db_schema" { type = string }

variable "fsi_db_password" {
  type      = string
  sensitive = true
}

variable "oci_user_ocid" { type = string }
variable "oci_tenancy_ocid" { type = string }
variable "oci_fingerprint" { type = string }

variable "oci_private_key_pem" {
  type      = string
  sensitive = true
}

variable "oci_compartment_ocid" { type = string }
variable "oci_credential_name" { type = string }
variable "oci_runtime_credential_name" { type = string }

variable "profile_apex_name" { type = string }
variable "profile_nl2sql_name" { type = string }
variable "profile_rag_name" { type = string }
variable "profile_region" { type = string }
variable "profile_apex_model" { type = string }
variable "profile_nl2sql_model" { type = string }
variable "profile_rag_model" { type = string }
variable "rag_embedding_model" { type = string }
variable "ai_max_tokens" { type = number }
variable "rag_vector_index_name" { type = string }
variable "rag_vector_dimension" { type = number }
variable "rag_vector_distance_metric" { type = string }
variable "rag_chunk_overlap" { type = number }
variable "rag_chunk_size" { type = number }
variable "rag_refresh_rate_minutes" { type = number }
variable "rag_match_limit" { type = number }
variable "rag_similarity_threshold" { type = number }
variable "rag_object_storage_location" { type = string }
variable "object_storage_prefix" { type = string }
variable "enable_rag" { type = bool }
variable "fraud_notification_threshold" { type = number }
variable "google_sheet_url" {
  type      = string
  sensitive = true
}
variable "load_sample_data" { type = bool }

variable "apex_workspace_name" { type = string }
variable "apex_workspace_id" { type = number }
variable "apex_db_schema" {
  type    = string
  default = ""
}
variable "apex_builder_username" { type = string }

variable "apex_builder_password" {
  type      = string
  sensitive = true
}

variable "apex_app_id" { type = number }
variable "apex_app_alias" { type = string }
variable "apex_app_name" { type = string }

variable "fsi_apex_ai_service_static_id" { type = string }
variable "fsi_apex_fraud_team" { type = string }
variable "fsi_apex_generic_team" { type = string }
variable "fsi_apex_rag_team" { type = string }
variable "fsi_apex_llm_instructions" { type = string }
variable "fsi_runtime_config_defaults" {
  type      = map(string)
  sensitive = true
}

variable "fsi_runtime_config" {
  type      = map(string)
  sensitive = true
}
variable "enable_fsi_ai_request_worker" { type = bool }
variable "fsi_ai_request_worker_interval" { type = string }
variable "enable_fsi_claim_generation_job" { type = bool }
variable "fsi_claim_generation_interval" { type = string }
variable "enable_fsi_new_claim_investigation_job" { type = bool }
variable "fsi_new_claim_investigation_interval" { type = string }
variable "load_dump_vector_index_snapshot" { type = bool }

variable "fsi_application_data_par_url" {
  type        = string
  sensitive   = true
  description = "Object-scoped OCI PAR URL for CrossShield relational sample data."
}

variable "fsi_vector_snapshot_par_url" {
  type        = string
  sensitive   = true
  description = "Object-scoped OCI PAR URL for the optional FSI vector snapshot."
}

variable "fsi_apex_export_par_url" {
  type        = string
  sensitive   = true
  description = "Object-scoped OCI PAR URL for current APEX Application 108."
}
