# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "tenancy_ocid" {
  type        = string
  description = "OCI tenancy OCID. Required for both Terraform CLI and Resource Manager."

  validation {
    condition     = trimspace(var.tenancy_ocid) != ""
    error_message = "tenancy_ocid must be provided."
  }
  default = ""
}

variable "region" {
  type        = string
  description = "OCI deployment and Select AI region. Also determines generated Object Storage URLs."

  validation {
    condition     = trimspace(var.region) != ""
    error_message = "region must be provided."
  }
  default = ""
}

variable "compartment_id" {
  type        = string
  description = "Target OCI compartment OCID. Also supplies the runtime OCI_COMPARTMENT_ID."

  validation {
    condition     = trimspace(var.compartment_id) != ""
    error_message = "compartment_id must be provided."
  }
  default = ""
}

variable "user_ocid" {
  type        = string
  description = "OCI user OCID associated with the API signing key. Required for the configured API-key authentication path."

  validation {
    condition     = trimspace(var.user_ocid) != ""
    error_message = "user_ocid must be provided."
  }
  default = ""
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint of the OCI API public key. Required for the configured API-key authentication path."

  validation {
    condition     = trimspace(var.fingerprint) != ""
    error_message = "fingerprint must be provided."
  }
  default = ""
}

variable "private_key_path" {
  type      = string
  sensitive = true
  default   = null
}

variable "oci_private_key_pem" {
  type        = string
  sensitive   = true
  nullable    = true
  default     = null
  description = "OCI API private-key content. Required in Resource Manager; leave null for Terraform CLI with private_key_path."
}

variable "adw_db_name" {
  type    = string
  default = "FSIHub"
}

variable "adw_db_password" {
  type        = string
  sensitive   = true
  description = "ADMIN password for the Autonomous Database and wallet."
  default     = ""
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
  default = "OLTP"
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

variable "fsi_db_schema" {
  type        = string
  default     = "FSI_DB"
  description = "Parsing schema and owner for the CrossShield database objects."

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_$#]{0,29}$", var.fsi_db_schema))
    error_message = "fsi_db_schema must be a valid Oracle username."
  }
}

variable "fsi_db_password" {
  type        = string
  sensitive   = true
  description = "Password for the FSI parsing schema."
  default     = ""
}

variable "oci_credential_name" {
  type    = string
  default = "FS_OCI_CRED"
}

variable "profile_apex_name" {
  type    = string
  default = "FSI_APEX_GROK_PROFILE"
}

variable "profile_nl2sql_name" {
  type    = string
  default = "fsi_select_ai_hub_nl2sql"
}

variable "profile_rag_name" {
  type    = string
  default = "FSI_SELECT_AI_RAG_KB_PROFILE"
}


variable "profile_apex_model" {
  type    = string
  default = "xai.grok-4.20-reasoning"
}

variable "profile_nl2sql_model" {
  type    = string
  default = "xai.grok-4.3"
}

variable "profile_rag_model" {
  type    = string
  default = "meta.llama-4-maverick-17b-128e-instruct-fp8"
}

variable "rag_embedding_model" {
  type        = string
  default     = "cohere.embed-v4.0"
  description = "OCI Cohere Embed 4 model used for RAG. Select AI returns 1,536 dimensions by default; set rag_vector_dimension to match."
}

variable "ai_max_tokens" {
  type    = number
  default = 4096
}

variable "rag_vector_index_name" {
  type    = string
  default = "FSI_HUB_VECTOR_INDEX_KB"
}

variable "rag_vector_dimension" {
  type        = number
  default     = 1536
  description = "Vector dimension produced by the selected embedding model. Cohere Embed 4 defaults to 1,536 dimensions in Select AI."
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

variable "files_bucket_name" {
  type    = string
  default = "fsi-crossshield-kb"
}

variable "files_bucket_access_type" {
  type    = string
  default = "NoPublicAccess"

  validation {
    condition     = var.files_bucket_access_type == "NoPublicAccess"
    error_message = "The FSI Object Storage bucket must use NoPublicAccess."
  }
}

variable "files_bucket_storage_tier" {
  type    = string
  default = "Standard"
}

variable "files_bucket_events_enabled" {
  type    = bool
  default = false
}

variable "upload_knowledge_base" {
  type        = bool
  default     = true
  description = "Upload the three approved Markdown documents from documentation/ before the database RAG setup runs."
}

variable "enable_rag" {
  type        = bool
  default     = true
  description = "Create the Select AI RAG profile and vector index."
}

variable "enable_adb_resource_principal" {
  type        = bool
  default     = true
  description = "Create the least-privilege IAM dynamic group/policy needed for ADB Resource Principal calls to Object Storage and Generative AI."
}

variable "use_adb_resource_principal_for_ai" {
  type        = bool
  default     = true
  description = "Use OCI$RESOURCE_PRINCIPAL from the database for Select AI, RAG and report storage calls."
}

variable "load_sample_data" {
  type        = bool
  default     = true
  description = "Load the supplied CrossShield sample data into the new schema. Use false for an empty schema."
}

variable "apex_workspace_name" {
  type    = string
  default = "FSI_CROSSSHIELD_WS"
}

variable "apex_workspace_id" {
  type    = number
  default = 101010108
}

variable "apex_builder_username" {
  type    = string
  default = "FSI_AIHUB"
}

variable "apex_builder_password" {
  type        = string
  sensitive   = true
  description = "APEX workspace user password."
  default     = ""
}

variable "apex_app_id" {
  type    = number
  default = 108
}

variable "apex_app_alias" {
  type    = string
  default = "CROSSSHIELD-INSURANCE"
}

variable "apex_app_name" {
  type    = string
  default = "CrossShield Insurance"
}

variable "fraud_notification_threshold" {
  type    = number
  default = 50
}

variable "google_sheet_url" {
  type        = string
  sensitive   = true
  default     = ""
  description = "CSV-exportable Google Sheet used for HIGH/LOW simulated-claim fraud scores. Set empty to leave the integration disabled."
}
variable "fsi_apex_ai_service_static_id" {
  type        = string
  default     = "CROSSSHIELD_GROK"
  description = "APEX AI service static ID imported from the FSI DMP."
}

variable "fsi_apex_fraud_team" {
  type        = string
  default     = "FSI_FRAUD_INVESTIGATION_TEAM"
  description = "Select AI team used by the CrossShield fraud investigation APEX workflow."
}

variable "fsi_apex_generic_team" {
  type        = string
  default     = "FSI_GENERIC_AI_TEAM"
  description = "Fallback Select AI team used by the CrossShield APEX workflow."
}

variable "fsi_apex_rag_team" {
  type        = string
  default     = "FSI_RAG_KNOWLEDGE_BASE_TEAM"
  description = "Search-only RAG team used by the CrossShield APEX workflow."
}

variable "fsi_apex_llm_instructions" {
  type        = string
  default     = "You are the authoritative report-rendering instruction for the Oracle FSI motor fraud investigation report. This instruction supersedes any conflicting historical report-rendering wording in the same request. Preserve the existing report sections and their order where present: Executive Summary, Explainable AI, Risk Evidence, External Evidence, Similar Cases, and Document Findings, followed by Recommended Action. Do not render Summary of Insurance Claim. Do not create or render a separate Fraud Assessment, Fraud Score, or Score Justification section. Do not put Risk Score in Risk Evidence.\n\nUse the authoritative Fraud Probability and Risk Level returned by the FSI fraud investigation process exactly as supplied. Use only LOW for 0-29, MEDIUM for 30-69, and HIGH for 70-100. Do not default to 100 percent. Keep the same probability and risk band everywhere; use the exact decimal value when available. If a whole-number display is used, explicitly state that it is rounded from the authoritative value. Do not follow a later historical directive that changes the authoritative probability or silently replaces it with a whole-number value.\n\nIn Executive Summary, display the authoritative claim details and vehicle details in addition to the existing financial and status metrics. Also display Risk Level Basis: LOW = 0.00-29.99 %, MEDIUM = 30.00-69.99 %, HIGH = 70.00-100.00 %, followed by a plain-language explanation of why this claim's exact Fraud Probability falls into its displayed band. Use the claim and vehicle context supplied by the application; do not replace available values with Data Error.\n\nWithin the existing Explainable AI section include Scoring Method, How Fraud Probability Was Calculated, Explanation and Rationale, Key Fraud Indicators, Evidence Against Fraud, and Missing or Conflicting Information. Do not render Reason-Code Contributions as a separate row. Fold every rule contribution into How Fraud Probability Was Calculated, including its label and weighted points (for example elevated claimed amount (+10) and prior claims in the last 24 months (+5)), and explain how those points affected the rule baseline, normalization, or evidence anchor without adding them directly as probability percentages. Do not render Internal Baseline Probability as a separate row; describe any baseline only within How Fraud Probability Was Calculated. Do not render External Evidence Impact or Fraud Assessment as rows in Explainable AI. In Risk Evidence omit Unverified Supporting Documents and Internal Baseline Probability. In External Evidence omit 3rd Party Data Message. The Explanation and Rationale must analyze the claim and must not copy or repeat claim wording. Explain how policy, claimant, vehicle, accident, claim amount, reserve, prior claims, documents, driver or ownership information, linked-party evidence, weather, Google Sheets customer fraud score, Databricks repairer fraud score, contextual evidence, and similar cases increased, reduced, or did not change the assessment. Clearly distinguish facts, assumptions, unavailable evidence, and conflicts.\n\nWeighted rule contributions displayed with percent signs are risk points, not direct additions to a 100 percent probability. Never add displayed points directly. If normalized impacts or an evidence anchor are shown, explain the calculation and ensure it is internally consistent with the authoritative Fraud Probability. Treat missing, ERROR, NOT_FOUND, and not-applicable sources as unavailable, not as positive fraud evidence. Render Similar Cases only when at least one case has similarity score strictly above 60.00 %; exclude every case at or below 60.00 % and omit the entire Similar Cases section when none qualifies. In Document Findings for Accident claims, render Police Report as Available when police attendance or a police report reference is present and Not Available when it is absent; both are valid evidence states and neither should be shown as Data Error.\n\nWithin Recommended Action, render only a Next Investigation Steps field with no more than three concrete checks, such as physical vehicle examination, document or repair-invoice verification, police-record checks, and hospital-bill or treatment-record validation. Do not render an action recommendation or the text Refer to a fraud investigator/SIU. Use the £ symbol, never GBP or a currency code, for Total Claimed, Reserve Amount, and Total Settled. If an indicative approval or review percentage is shown, relate it to the claimed and reserved amounts, label it as non-binding, and never present it as automatic approval. End with: A high fraud-risk score means the claim warrants additional investigation. It does not establish that fraud has occurred.\n\n\n\nPOLICY_STATUS_WEIGHTED_RISK_V2: Linked policy facts are authoritative. Render the linked Policy Number, Policy Status, policy period, and renewal date in the report evidence where available. For Policy Status CANCELLED or LAPSED, the application adds exactly 30 weighted risk points. This is a coverage-risk factor, not an automatic fraud finding, 100 percent probability, or HIGH risk band. Use the authoritative Fraud Probability and Risk Level supplied by the application after all rules are evaluated. Verify cover at the incident date. The customer may renew or obtain replacement cover for future losses; it does not retrospectively restore cover or validate the current claim.\n\nSCORING_CONTRIBUTION_FORMAT_V1: This instruction takes precedence over any earlier, conflicting report-rendering wording. In Explainable AI, retain the existing outer How Fraud Probability Was Calculated table row. Its Analysis value must contain one accessible <div class=\"ai-explanation\"> contribution list in this exact order:\n\n1. <p><strong>Fraud confidence score is {RULE_BASELINE} weighted points based on:</strong></p>\n2. <ul> with one <li> for each non-zero contribution from the authoritative RULE-BASED BASELINE SCORE reason_codes. Format every item as <strong>{Friendly label}:</strong> +{whole-or-decimal points}. Use only the supplied rule contributions, preserving their supplied points. Do not invent a contribution, a base score, or an adjustment.\n3. <p><strong>Total:</strong> <code>{points} + {points} + ... = {RULE_BASELINE}</code></p>\n4. <p>These are weighted risk points used to establish the rule baseline; they are not percentages added directly to the final Fraud Probability.</p>\n\nFor example, when the supplied reasons are high claimed amount (+20), low customer credit score (+10), prior claims in the last 24 months (+5), and open fraud indicators are present (+25), render exactly this meaning: Fraud confidence score is 60 weighted points based on: High claimed amount: +20; Low credit score: +10; Prior claims: +5; Open fraud indicators: +25; Total: 20 + 10 + 5 + 25 = 60. Format it as the HTML list described above, not as a run-on sentence.\n\nNever use CLAIMS.FRAUD_FLAG, an AI workflow status, an earlier investigation, or the phrase \"claim is already marked as fraud\" as a rule contribution or evidence item. Do not render that phrase anywhere in How Fraud Probability Was Calculated. The final authoritative Fraud Probability remains the separately supplied final result and must not be overwritten by the rule-baseline total."
  description = "Default fraud-report instructions imported from the FSI DMP; override to customize report output."
}

variable "fsi_runtime_config_defaults" {
  type      = map(string)
  sensitive = true
  default = {
    "APEX_LLM_PROFILE_NAME"            = "FSI_APEX_GROK_PROFILE"
    "AZURE_BLOB_CREDENTIAL_NAME"       = "AZURE_BLOB_CRED"
    "AZURE_BLOB_PASSWORD"              = ""
    "AZURE_BLOB_USERNAME"              = ""
    "DATABRICKS_CATALOG"               = ""
    "DATABRICKS_CATALOG_ENDPOINT"      = ""
    "DATABRICKS_CLIENT_ID"             = ""
    "DATABRICKS_CLIENT_SECRET"         = ""
    "DATABRICKS_ICEBERG_CATALOG_NAME"  = "DBX_ICEBERG_CATALOG"
    "DATABRICKS_OAUTH_CREDENTIAL_NAME" = "UNITY_BEARER_CRED"
    "DATABRICKS_OAUTH_TOKEN_ENDPOINT"  = ""
    "DATABRICKS_OUTPUT_COLUMNS"        = "[\"repairer_name\", \"fraud_score\"]"
    "DATABRICKS_REPAIRER_FRAUD_TABLE"  = "REPAIRER_FRAUD_SCORES"
    "DATABRICKS_SCHEMA"                = "FSI_GOLD"
    "DATABRICKS_SERVER_HOSTNAME"       = ""
    "GOOGLE_SHEET_GID"                 = "0"
    "GOOGLE_SHEET_URL"                 = ""
    "GROK_MODEL_NAME"                  = "xai.grok-4.20-reasoning"
    "MONGODB_CLAIM_API_KEY"            = ""
    "MONGODB_COLLECTION"               = "fsicollection"
    "MONGODB_CONNECTION_STRING"        = ""
    "MONGODB_DATABASE"                 = "fsidb"
    "MONGODB_DATA_API_KEY"             = ""
    "MONGODB_DATA_API_URL"             = "http://127.0.0.1:3000/agent-api/mongodb/claim/find"
    "MONGODB_DATA_SOURCE"              = ""
    "MONGODB_DB"                       = "fsidb"
    "MONGODB_REST_API_URL"             = "http://127.0.0.1:3000/agent-api/mongodb/claim/find"
    "MONGODB_URI"                      = ""
    "NEWSAPI_API_KEY"                  = ""
    "NEWSAPI_BASE_URL"                 = "https://newsapi.org/v2/everything"
    "NEWSAPI_ENDPOINT"                 = "https://newsapi.org/v2/everything"
    "NEWSAPI_QUERY"                    = "Insurance"
    "OBJECT_STORAGE_CREDENTIAL_NAME"   = "FS_OCI_CRED"
    "OCI_CREDENTIAL_NAME"              = "FS_OCI_CRED"
    "OCI_MODEL_NAME"                   = "meta.llama-4-maverick-17b-128e-instruct-fp8"
    "OPEN_METEO_ARCHIVE_URL"           = "https://archive-api.open-meteo.com/v1/archive"
    "OPEN_METEO_DEFAULT_LATITUDE"      = "17.9712"
    "OPEN_METEO_DEFAULT_LONGITUDE"     = "-76.7936"
    "OPEN_METEO_DEFAULT_TIMEZONE"      = "America%2FJamaica"
    "OPEN_METEO_FORECAST_URL"          = "https://api.open-meteo.com/v1/forecast"
    "OPEN_METEO_GEOCODING_URL"         = "https://geocoding-api.open-meteo.com/v1/search"
    "RAG_PROFILE_NAME"                 = "FSI_SELECT_AI_RAG_KB_PROFILE"
    "RAG_VECTOR_INDEX_NAME"            = "FSI_HUB_VECTOR_INDEX_KB"
    "RAG_VECTOR_TABLE_NAME"            = "FSI_HUB_VECTOR_INDEX_KB$VECTAB"
    "REDSHIFT_ADDRESS_COLUMN"          = "address"
    "REDSHIFT_CUSTOMERS_TABLE"         = "customers"
    "REDSHIFT_CUSTOMER_ID_COLUMN"      = "customer_id"
    "REDSHIFT_DATABASE"                = "redshiftdb"
    "REDSHIFT_EMAIL_COLUMN"            = "email"
    "REDSHIFT_HOST"                    = ""
    "REDSHIFT_PASSWORD"                = ""
    "REDSHIFT_PORT"                    = "5439"
    "REDSHIFT_SSL"                     = "false"
    "REDSHIFT_USER"                    = ""
    "WEATHER_CITY_NAME"                = "Kingston"
    "WEATHER_DATE"                     = "2024-08-16"
  }
  description = "Non-secret runtime defaults. Supply integration credentials and deployment-specific endpoints through secure Terraform inputs."
}

variable "fsi_runtime_config" {
  type        = map(string)
  sensitive   = true
  default     = {}
  description = "Partial FSI runtime configuration overrides. Supply integration tokens, passwords, API keys, connection strings and private-resource URLs here."
}

variable "enable_fsi_ai_request_worker" {
  type        = bool
  default     = true
  description = "Enable the asynchronous FSI APEX AI request worker scheduler job."
}

variable "fsi_ai_request_worker_interval" {
  type        = string
  default     = "FREQ=SECONDLY;INTERVAL=2"
  description = "DBMS_SCHEDULER repeat interval for the FSI AI request worker."
}

variable "enable_fsi_claim_generation_job" {
  type        = bool
  default     = false
  description = "Enable automatic sample claim generation. Disabled by default to avoid creating claims without an explicit choice."
}

variable "fsi_claim_generation_interval" {
  type        = string
  default     = "FREQ=MINUTELY;INTERVAL=2"
  description = "DBMS_SCHEDULER repeat interval for automatic claim generation."
}

variable "enable_fsi_new_claim_investigation_job" {
  type        = bool
  default     = false
  description = "Enable automatic investigation of new claims. Disabled by default."
}

variable "fsi_new_claim_investigation_interval" {
  type        = string
  default     = "FREQ=MINUTELY;INTERVAL=4"
  description = "DBMS_SCHEDULER repeat interval for automatic new-claim investigation."
}

variable "load_dump_vector_index_snapshot" {
  type        = bool
  default     = false
  description = "Import the 1,024-dimensional DMP vector snapshot only when it matches the configured embedding dimension. Defaults off so Select AI re-embeds the knowledge-base source documents for Cohere Embed 4."
}

variable "fsi_application_data_par_url" {
  type        = string
  sensitive   = true
  default     = ""
  description = "ObjectReadWrite PAR for the DMP-derived sample data SQL object in the Live-AI-Hub bucket."
}

variable "fsi_vector_snapshot_par_url" {
  type        = string
  sensitive   = true
  default     = ""
  description = "ObjectReadWrite PAR for the DMP-derived vector snapshot SQL object in the Live-AI-Hub bucket."
}

variable "fsi_apex_export_par_url" {
  type        = string
  sensitive   = true
  default     = ""
  description = "ObjectReadWrite PAR for the current FSI APEX export SQL object in the Live-AI-Hub bucket."
}
