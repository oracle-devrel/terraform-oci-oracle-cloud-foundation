# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

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


# Don't modify this variable
variable "oci_private_key_pem" {
  type        = string
  default     = ""
  description = "OCI API private key content, used mainly by Resource Manager. Leave empty when using private_key_path with Terraform CLI."
}

# ADW Autonomous Database Configuration Variables

variable "adw_db_name" {
  type    = string
  default = "TicketAIHub"
}

variable "adw_db_password" {
  type    = string
  default = "V2xzQXRwRGIxMjM0Iw=="
}

variable "adw_db_compute_model" {
  type    = string
  default = "ECPU"
}

variable "adw_db_compute_count" {
  type    = number
  default = 4
}

variable "adw_db_size_in_tbs" {
  type    = number
  default = 1
}

variable "adw_db_workload" {
  type    = string
  default = "DW"
}

variable "adw_db_version" {
  type    = string
  default = "26ai"
}

variable "adw_db_enable_auto_scaling" {
  type    = bool
  default = true
}

variable "adw_db_is_free_tier" {
  type    = bool
  default = false
}

variable "adw_db_license_model" {
  type    = string
  default = "BRING_YOUR_OWN_LICENSE"
}

variable "adw_db_data_safe_status" {
  type    = string
  default = "NOT_REGISTERED"
}

variable "adw_db_operations_insights_status" {
  type    = string
  default = "NOT_ENABLED"
}

variable "adw_db_database_management_status" {
  type    = string
  default = "ENABLED"
}

# LLM settings

variable "rag_region" {
  type    = string
  default = "us-ashburn-1"
}

variable "select_ai_model_nl2sql" {
  type        = string
  default     = "xai.grok-4-1-fast-reasoning"
  description = "Model used by the Select AI NL2SQL profile (select_ai_hub_nl2sql). This profile converts user questions into SQL over the business views and metadata. Change this when you want to improve SQL generation quality, reasoning depth, or latency for database querying."
}

variable "select_ai_model_agent" {
  type        = string
  default     = "xai.grok-4-fast-non-reasoning"
  description = "Model used by the main Select AI agent profile (select_ai_hub). This profile is consumed by the operational agents and tasks such as customer360, fashion advisor, weather assistant, backoffice assistant, and shopping cart assistant. Change this when you want to tune general agent behavior, tool usage, speed, or cost."
}

variable "genai_embedding_region" {
  type        = string
  default     = "us-chicago-1"
  description = "OCI Generative AI inference region used for embedding and RAG operations executed through DBMS_CLOUD_AI. Example: us-chicago-1."
}

variable "select_ai_model_rag" {
  type        = string
  default     = "meta.llama-4-maverick-17b-128e-instruct-fp8"
  description = "Model used by the RAG response profiles (select_ai_rag and select_ai_rag_faqs). These profiles generate answers from the indexed fashion articles and FAQ knowledge bases. Change this when you want to tune knowledge-base answer quality, response style, cost, or latency."
}

variable "select_ai_embedding_model" {
  type        = string
  default     = "cohere.embed-english-v3.0"
  description = "Embedding model used to build and query the vector indexes for RAG content. This affects how documents are vectorized for similarity search. Change this only when you intentionally want a different embedding strategy and are prepared to recreate or refresh the vector indexes."
}

# Object Storage Variables

variable "files_bucket_name" {
  type    = string
  default = "TicketAIFiles"
}

variable "files_bucket_access_type" {
  type    = string
  default = "ObjectRead"
}

variable "files_bucket_storage_tier" {
  type    = string
  default = "Standard"
}

variable "files_bucket_events_enabled" {
  type    = bool
  default = false
}

# Apex Settings:

variable "apex_workspace_name" {
  type    = string
  default = "TICKET_AIHUB_WS"
}

variable "apex_app_alias" {
  type    = string
  default = "TICKET-AI-HUB"
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