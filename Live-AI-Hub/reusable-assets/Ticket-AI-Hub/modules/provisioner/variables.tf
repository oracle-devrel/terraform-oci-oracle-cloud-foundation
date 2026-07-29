# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


variable "db_name" {
  type = string
}

variable "db_password" {
  type = string
  sensitive = false
}

variable "conn_db" {
  type = string
}

variable "wallet_zip_path" {
  type = string
}

variable "adb_host" {
  type = string
}

variable "ticket_aihub_password" {
  type      = string
  sensitive = false
  default   = "AaBbCcDdEe123#"
}

variable "oci_user_ocid" {
  type = string
}

variable "oci_tenancy_ocid" {
  type = string
}

variable "oci_fingerprint" {
  type = string
}

variable "oci_private_key_pem" {
  type      = string
  sensitive = true
}

variable "oci_compartment_ocid" {
  type = string
}

variable "ords_schema_path" {
  type    = string
  default = "ticket_aihub"
}

variable "oci_credential_name" {
  type    = string
  default = "OCI"
}

variable "profile_nl2sql_name" {
  type    = string
  default = "select_ai_hub_nl2sql"
}

variable "profile_agent_name" {
  type    = string
  default = "select_ai_hub_agent"
}

variable "profile_attachments_name" {
  type    = string
  default = "select_ai_hub_attachments"
}

variable "profile_judge_name" {
  type    = string
  default = "select_ai_hub_judge"
}

variable "profile_rag_kb_name" {
  type    = string
  default = "select_ai_rag_kb"
}

variable "profile_nl2sql_region" {
  type    = string
  default = "us-ashburn-1"
}

variable "profile_nl2sql_model" {
  type    = string
  default = "xai.grok-4-1-fast-reasoning"
}

# variable "profile_agent_region" {
#   type    = string
#   default = "eu-frankfurt-1"
# }

variable "profile_agent_region" {
  type    = string
  default = "us-ashburn-1"
}

# variable "profile_agent_model" {
#   type    = string
#   default = "meta.llama-3.3-70b-instruct"
# }

variable "profile_agent_model" {
  type    = string
  default = "xai.grok-4.20-0309-reasoning"
}

variable "profile_attachments_region" {
  type    = string
  default = "eu-frankfurt-1"
}

variable "profile_attachments_model" {
  type    = string
  default = "google.gemini-2.5-flash"
}

variable "profile_judge_region" {
  type    = string
  default = "eu-frankfurt-1"
}

variable "profile_judge_model" {
  type    = string
  default = "meta.llama-3.3-70b-instruct"
}

variable "rag_region" {
  type    = string
  default = "eu-frankfurt-1"
}

variable "rag_vector_index_name" {
  type    = string
  default = "hub_vector_index_kb"
}

variable "rag_embedding_model" {
  type    = string
  default = "cohere.embed-multilingual-v3.0"
}

variable "rag_model" {
  type    = string
  default = "meta.llama-3.3-70b-instruct"
}

variable "rag_object_storage_location" {
  type = string
}

variable "rag_object_storage_credential" {
  type    = string
  default = "OCI"
}

variable "rag_vector_dimension" {
  type    = number
  default = 1024
}

variable "rag_vector_distance_metric" {
  type    = string
  default = "cosine"
}

variable "rag_chunk_overlap" {
  type    = number
  default = 128
}

variable "rag_chunk_size" {
  type    = number
  default = 1024
}

variable "rag_refresh_rate_minutes" {
  type    = number
  default = 1440
}

variable "rag_match_limit" {
  type    = number
  default = 12
}

variable "rag_similarity_threshold" {
  type    = number
  default = 0
}

variable "attachment_object_storage_credential" {
  type    = string
  default = "OCI"
}

variable "attachment_genai_credential" {
  type    = string
  default = "OCI"
}

variable "attachment_genai_region" {
  type    = string
  default = "eu-frankfurt-1"
}

variable "attachment_genai_compartment_ocid" {
  type = string
}

variable "attachment_max_bytes" {
  type    = number
  default = 10485760
}

# variable "attachment_genai_max_tokens" {
#   type    = number
#   default = 2048
# }

variable "attachment_genai_max_tokens" {
  type    = number
  default = 4096
}

variable "adb_ords_host" {
  type = string
}

variable "ords_module_name" {
  type    = string
  default = "ticket_api"
}

variable "ords_base_path" {
  type    = string
  default = "/tickets/"
}

variable "ords_receive_escalation_path" {
  type    = string
  default = "tickets/receive_escalation"
}

variable "ords_receive_answer_path" {
  type    = string
  default = "tickets/receive_answer"
}

variable "default_notification_method" {
  type    = string
  default = "API"
}

variable "http_chunk_chars" {
  type    = number
  default = 8191
}

variable "outbound_api_max_attempts" {
  type    = number
  default = 3
}

variable "outbound_api_retry_interval_seconds" {
  type    = number
  default = 5
}

variable "teams_credential_name" {
  type    = string
  default = "TEAMS_CRED"
}

variable "smtp_credential_name" {
  type    = string
  default = "SMTPcredential"
}

variable "smtp_host" {
  type    = string
  default = "smtp.email.us-ashburn-1.oci.oraclecloud.com"
}

variable "smtp_sender" {
  type    = string
  default = "notifications@crosshealth.com"
}

variable "smtp_test_recipient" {
  type    = string
  default = "<set smoke test recipient email>"
}

variable "oauth_role_name" {
  type    = string
  default = "ticket_api.role"
}

variable "oauth_privilege_name" {
  type    = string
  default = "ticket_api.privilege"
}

variable "oauth_privilege_pattern" {
  type    = string
  default = "/tickets/*"
}

variable "oauth_client_name" {
  type    = string
  default = "ticket_api_client"
}

variable "oauth_client_owner" {
  type    = string
  default = "Ticket API Service"
}

variable "oauth_support_email" {
  type    = string
  default = "admin@example.com"
}

variable "detailed_debug" {
  type    = string
  default = "Y"
}

variable "default_ticket_priority" {
  type    = string
  default = "MEDIUM"
}

variable "default_process_attachments" {
  type    = string
  default = "Y"
}

variable "agent_completion_guard_enabled" {
  type    = string
  default = "Y"
}

variable "agent_stalled_after_minutes" {
  type    = number
  default = 30
}

variable "ai_max_tokens" {
  type    = number
  default = 4096
}

# apex

variable "apex_workspace_name" {
  type    = string
  default = "TICKET_AIHUB_WS"
}

variable "apex_workspace_id" {
  type    = number
  default = 101010101
}

variable "apex_db_schema" {
  type    = string
  default = "TICKET_AIHUB"
}

variable "apex_builder_username" {
  type    = string
  default = "TICKET_AIHUB"
}

variable "apex_builder_password" {
  type      = string
  sensitive = true
  default   = "AaBbCcDdEe123#"
}

variable "apex_app_id" {
  type    = number
  default = 101
}

variable "apex_app_alias" {
  type    = string
  default = "TICKET-AI-HUB"
}

variable "apex_app_name" {
  type    = string
  default = "Ticket AI Hub"
}