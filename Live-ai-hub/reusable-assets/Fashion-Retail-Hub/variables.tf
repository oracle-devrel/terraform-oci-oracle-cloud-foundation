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
  default = "AgenticAiADW"
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
  default = "23ai"
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

# ATP Autonomous Database Configuration Variables

variable "atp_db_name" {
  type    = string
  default = "AgenticAiATP"
}

variable "atp_db_password" {
  type    = string
  default = "V2xzQXRwRGIxMjM0Iw=="
}

variable "atp_db_compute_model" {
  type    = string
  default = "ECPU"
}

variable "atp_db_compute_count" {
  type    = number
  default = 4
}

variable "atp_db_size_in_tbs" {
  type    = number
  default = 1
}

variable "atp_db_workload" {
  type    = string
  default = "OLTP"
}

variable "atp_db_version" {
  type    = string
  default = "23ai"
}

variable "atp_db_enable_auto_scaling" {
  type    = bool
  default = true
}

variable "atp_db_is_free_tier" {
  type    = bool
  default = false
}

variable "atp_db_license_model" {
  type    = string
  default = "BRING_YOUR_OWN_LICENSE"
}

variable "atp_db_data_safe_status" {
  type    = string
  default = "NOT_REGISTERED"
}

variable "atp_db_operations_insights_status" {
  type    = string
  default = "NOT_ENABLED"
}

variable "atp_db_database_management_status" {
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

# MongoDB Atlas Creds

variable "mongodb_atlas_public_key" {
  type    = string
  default = ""
}

variable "mongodb_atlas_private_key" {
  type    = string
  default = ""
}

variable "mongodb_atlas_org_id" {
  type    = string
  default = ""
}

variable "mongodb_atlas_project_name" {
  type    = string
  default = "agentic-ai-project"
}

variable "mongodb_atlas_cluster_name" {
  type    = string
  default = "agentic-ai-free"
}

variable "mongodb_atlas_region" {
  type    = string
  default = "EU_WEST_1"
}

variable "mongodb_db_username" {
  type    = string
  default = ""
}

variable "mongodb_db_password" {
  type    = string
  default = ""
}

variable "mongodb_database_name" {
  type    = string
  default = "co"
}

# Project Settings

variable "mongo_mode" {
  type    = string
  default = "oracle_api"
}

variable "atp_private_endpoint_subnet_id" {
  type    = string
  default = null
}

variable "atp_private_endpoint_nsg_ids" {
  type    = list(string)
  default = []
}

variable "oracle_mongo_username" {
  type    = string
  default = "CO"
}

variable "oracle_mongo_password" {
  type    = string
  default = "AaBbCcDdEe123#"
}

variable "oracle_mongo_schema" {
  type    = string
  default = "CO"
}

# Object Storage Variables

variable "files_bucket_name" {
  type    = string
  default = "AgenticAiFiles"
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

# ATP bucket

variable "atp_creds_bucket_name" {
  type    = string
  default = "AgenticATPCreds"
}

variable "atp_creds_bucket_access_type" {
  type    = string
  default = "ObjectRead"
}

variable "atp_creds_bucket_storage_tier" {
  type    = string
  default = "Standard"
}

variable "atp_creds_bucket_events_enabled" {
  type    = bool
  default = false
}

# Bastion Instance Variables

variable "bastion_instance_image_ocid" {
  type = map(string)
  default = {
    eu-amsterdam-1    = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaabcomraotpw6apg7xvmc3xxu2avkkqpx4yj7cbdx7ebcm4d52halq"
    eu-stockholm-1    = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaa52kiqhwcoprmwfiuwureucv7nehqjfofoicwptpixdphzvon2mua"
    me-abudhabi-1     = "ocid1.image.oc1.me-abudhabi-1.aaaaaaaa7nqsxvp4vp25gvzcrvld6xaiyxaxmzepkb5gz6us5sfkgeeez2zq"
    ap-mumbai-1       = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaham2gnbrst3s46jrwchlnl3uqo7yxij7f3pqdzwx7zybu657347q"
    eu-paris-1        = "ocid1.image.oc1.eu-paris-1.aaaaaaaaab5yi4bbnabymexkvwcdjlcjiue26kf3vz6dvzm6dvpttqcpaj5q"
    uk-cardiff-1      = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaagvgnze6oq5il7b26onoq4daeaqrghp5hx4yp3q3rvtfpnbzq4zhq"
    me-dubai-1        = "ocid1.image.oc1.me-dubai-1.aaaaaaaaid5v36623wk7lyoivnqwygyaxppqfbzyo35wifxs7hkqo5caxhqa"
    eu-frankfurt-1    = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa3mdtxzi5rx2ids2tb74wmm77zvsqdaxbjlgvjpr4ytzc5njtksjq"
    sa-saopaulo-1     = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaa22wjczcl7udl7w7e347zkwig7mh5p3zfbcemzs46jiaeom5lznyq"
    ap-hyderabad-1    = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaaaq6ggb4u6p4fgsdcj7o2p4akt5t7gmyjnvootiytrqc5joe5pmfq"
    us-ashburn-1      = "ocid1.image.oc1.iad.aaaaaaaas4cu36z32iraul5otar4gl3uy4s5jkupcc4m5shfqlatjiwaoftq"
    ap-seoul-1        = "ocid1.image.oc1.ap-seoul-1.aaaaaaaakrtvc67c6thtmhrwphecd66omeytl7jmv3zd2bci74j56r4xodwq"
    me-jeddah-1       = "ocid1.image.oc1.me-jeddah-1.aaaaaaaaghsie5mvgzb6fbfzujidzrg7jnrraqkh6qkyh2vw7rl6cdnbpe6a"
    af-johannesburg-1 = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaa2sj43nffpmyqlubrj4cikfgoij7qyqhymlnhw3bj7t26lh46euia"
    ap-osaka-1        = "ocid1.image.oc1.ap-osaka-1.aaaaaaaao3swjyengmcc5rz3ynp2euqskvcscqwgouzs3smaarxofxbwstcq"
    uk-london-1       = "ocid1.image.oc1.uk-london-1.aaaaaaaaetscnayepwj2lto7mpgiwtom4jwkqafr3axumt3pt32cgwczkexq"
    eu-milan-1        = "ocid1.image.oc1.eu-milan-1.aaaaaaaavht3nwv7qsue7ljexbqqgofogwvrlgybvtrxylm52eg6b6xrgniq"
    ap-melbourne-1    = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaafavk2azn6cizxnugwi7izvxsumhiuzthw6g7k2o4vuhg4l3phi3a"
    eu-marseille-1    = "ocid1.image.oc1.eu-marseille-1.aaaaaaaakpex24z6rmmyvdeop72nomfui5t54lztix7t5mblqii4l7v4iecq"
    il-jerusalem-1    = "ocid1.image.oc1.il-jerusalem-1.aaaaaaaafgok5gj36cnrsqo6a3p72wqpg45s3q32oxkt45fq573obioliiga"
    ap-tokyo-1        = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaappsxkscys22g5tha37tksf6rlec3tm776dnq7dcquaofeqqb6rna"
    us-phoenix-1      = "ocid1.image.oc1.phx.aaaaaaaawmvmgfvthguywgry23pugqqv2plprni37sdr2jrtzq6i6tmwdjwa"
    sa-santiago-1     = "ocid1.image.oc1.sa-santiago-1.aaaaaaaatqcxvjriek3gdndhk43fdss6hmmd47fw2vmuq7ldedr5f555vx5q"
    ap-singapore-1    = "ocid1.image.oc1.ap-singapore-1.aaaaaaaaouprplh2bubqudrghr46tofi3bukvtrdgiuvckylpk4kvmxyhzda"
    us-sanjose-1      = "ocid1.image.oc1.us-sanjose-1.aaaaaaaaqudryedi3l4danxy5kxbwqkz3nonewp3jwb5l3tdcikhftthmtga"
    ap-sydney-1       = "ocid1.image.oc1.ap-sydney-1.aaaaaaaaogu4pvw4zw2p7kjabyynczopoqipecr2gozdaolh5kem2mkdrloa"
    sa-vinhedo-1      = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaa57khlnd4ziajy6wwmud2d6k3wsqkm4yce3mlzbgxeggpbu3yqbpa"
    ap-chuncheon-1    = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaanod2kc3bw5l3myyd5okw4c46kapdpsu2fqgyswf4lka2hrordlla"
    ca-montreal-1     = "ocid1.image.oc1.ca-montreal-1.aaaaaaaaevwlof26wfzcoajtlmykpaev7q5ekqyvkpqo2sjo3gdwzygu7xta"
    ca-toronto-1      = "ocid1.image.oc1.ca-toronto-1.aaaaaaaanajb7uklrra5eq2ewx35xfi2aulyohweb2ugik7kc6bdfz6swyha"
    eu-zurich-1       = "ocid1.image.oc1.eu-zurich-1.aaaaaaaameaqzqjwp45epgv2zywkaw2cxutz6gdc6jxnrrbb4ciqpyrnkczq"
  }
}

variable "bastion_instance_display_name" {
  type    = string
  default = "AgenticAI"
}

variable "bastion_instance_shape" {
  type    = string
  default = "VM.Standard2.1"
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