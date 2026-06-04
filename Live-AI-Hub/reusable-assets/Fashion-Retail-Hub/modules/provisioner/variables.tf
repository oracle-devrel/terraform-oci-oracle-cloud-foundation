# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "host" {
  type = string
}

variable "private_key" {
  type      = string
  sensitive = false
}

variable "atp_url" {
  type    = any
  default = null
}

variable "db_password" {
  type      = string
  default   = ""
  sensitive = false
}

variable "conn_db" {
  type    = string
  default = ""
}

variable "db_name" {
  type    = string
  default = ""
}

variable "atp_creds_bucket_name" {
  type    = string
  default = ""
}

variable "atp_db_name" {
  type    = string
  default = ""
}

variable "atp_db_password" {
  type      = string
  default   = ""
  sensitive = false
}

variable "conn_db_atp" {
  type    = string
  default = ""
}

variable "compartment_id" {
  type = string
}

variable "atp_wallet_zip_path" {
  type = string
}

variable "service_selector" {
  type    = string
  default = "_tp"
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
}

variable "objectstorage_region" {
  type = string
}

variable "api_gateway_hostname" {
  type = string
}

variable "rag_region" {
  type = string
}

variable "rag_compartment_id" {
  type = string
}

variable "files_bucket_name" {
  type = string
}

variable "cart_items_api_url" {
  type = string
}

variable "cart_summary_api_url" {
  type = string
}

# MongoDB

variable "mongo_uri" {
  type      = string
  default   = ""
  sensitive = false
}

variable "mongo_db_name" {
  type    = string
  default = ""
}

variable "mongodb_hostname" {
  type    = string
  default = ""
}

variable "mongodb_db_name" {
  type    = string
  default = ""
}

variable "mongodb_username" {
  type    = string
  default = ""
}

variable "mongodb_password" {
  type      = string
  default   = ""
  sensitive = false
}

variable "mongo_mode" {
  type    = string
  default = ""
}

variable "oracle_mongo_url" {
  type    = string
  default = ""
}

# Models

variable "genai_embedding_region" {
  type = string
}

variable "select_ai_model_nl2sql" {
  type        = string
  description = "Model used by the Select AI NL2SQL profile. Change this when you want to control how natural-language questions are translated into SQL over the database metadata and views."
}

variable "select_ai_model_agent" {
  type        = string
  description = "Model used by the main Select AI agent profile for general agent execution, orchestration, tool calling, and conversational tasks. Change this when you want to tune the behavior of operational agents such as fashion advisor, backoffice, weather, or shopping cart assistants."
}

variable "select_ai_model_rag" {
  type        = string
  description = "Model used by the RAG profiles to generate answers from the indexed knowledge base content such as fashion articles and FAQs. Change this when you want different answer quality, latency, or cost for retrieval-augmented generation responses."
}

variable "select_ai_embedding_model" {
  type        = string
  description = "Embedding model used to create vectors for the RAG knowledge base indexes. Change this only when you intentionally want to rebuild or align the vector search setup with a different embedding model."
}