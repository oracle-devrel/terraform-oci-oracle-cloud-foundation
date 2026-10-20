# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "adb" {
  source     = "./modules/cloud-foundation-library/database/adb"
  adw_params = local.adw_params
}

module "os" {
  source       = "./modules/cloud-foundation-library/object-storage"
  tenancy_ocid = var.tenancy_ocid

  bucket_params = {
    for key, value in local.bucket_params : key => value if value.compartment_id != ""
  }
}

resource "null_resource" "empty_fsi_bucket_before_destroy" {
  # On destroy, knowledge_base_files is removed first, then this cleanup runs
  # while module.os still exists; only after that can OCI delete the bucket.
  depends_on = [module.os]

  triggers = {
    bucket_name = var.files_bucket_name
    namespace   = data.oci_objectstorage_namespace.this.namespace
    region      = var.region
  }

  provisioner "local-exec" {
    when = destroy

    command = <<-EOT
      set -euo pipefail
      command -v oci >/dev/null 2>&1 || { echo "OCI CLI is required to empty the FSI bucket before destroy." >&2; exit 127; }
      oci os object bulk-delete-versions \
        --region "$OCI_REGION" --namespace-name "$OCI_NAMESPACE" \
        --bucket-name "$OCI_BUCKET_NAME" --force >/dev/null
      oci os object bulk-delete \
        --region "$OCI_REGION" --namespace-name "$OCI_NAMESPACE" \
        --bucket-name "$OCI_BUCKET_NAME" --force >/dev/null
      echo "Emptied Object Storage bucket $OCI_BUCKET_NAME before Terraform destroy."
    EOT

    environment = {
      OCI_BUCKET_NAME = self.triggers.bucket_name
      OCI_NAMESPACE   = self.triggers.namespace
      OCI_REGION      = self.triggers.region
    }
  }
}

module "knowledge_base_files" {
  source = "./modules/cloud-foundation-library/object-storage-upload-files"
  depends_on = [
    module.os,
    null_resource.empty_fsi_bucket_before_destroy,
  ]
  tenancy_ocid         = var.tenancy_ocid
  bucket_upload_params = local.knowledge_base_uploads
}

resource "oci_identity_dynamic_group" "fsi_adb" {
  count    = var.enable_adb_resource_principal ? 1 : 0
  provider = oci.homeregion

  compartment_id = var.tenancy_ocid
  name           = "FSIHub_ADB_RESOURCE_PRINCIPAL"
  description    = "Resource principal for the FSIHub Autonomous AI Database."
  matching_rule  = "ALL {resource.type = 'autonomousdatabase', resource.id = '${module.adb.atp_db_id[var.adw_db_name]}'}"
}

resource "oci_identity_policy" "fsi_adb" {
  count    = var.enable_adb_resource_principal ? 1 : 0
  provider = oci.homeregion

  compartment_id = var.compartment_id
  name           = "FSIHub_ADB_RESOURCE_PRINCIPAL_POLICY"
  description    = "Least-privilege Object Storage and Generative AI access for the FSIHub ADB resource principal."
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.fsi_adb[0].name} to read buckets in compartment id ${var.compartment_id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.fsi_adb[0].name} to manage objects in compartment id ${var.compartment_id} where target.bucket.name = '${var.files_bucket_name}'",
    "Allow dynamic-group ${oci_identity_dynamic_group.fsi_adb[0].name} to use generative-ai-family in compartment id ${var.compartment_id}"
  ]
}

module "provisioner" {
  source = "./modules/provisioner"

  depends_on = [
    module.adb,
    module.os,
    module.knowledge_base_files,
    oci_identity_policy.fsi_adb
  ]

  db_name         = var.adw_db_name
  db_password     = var.adw_db_password
  conn_db         = local.conn_db
  wallet_zip_path = "${path.root}/wallet_${var.adw_db_name}.zip"
  adb_host        = local.adb_hostname
  fsi_db_schema   = var.fsi_db_schema
  fsi_db_password = var.fsi_db_password

  oci_user_ocid        = var.user_ocid
  oci_tenancy_ocid     = var.tenancy_ocid
  oci_fingerprint      = var.fingerprint
  oci_private_key_pem  = local.effective_oci_private_key_pem
  oci_compartment_ocid = var.compartment_id

  oci_credential_name           = var.oci_credential_name
  oci_runtime_credential_name   = local.runtime_oci_credential_name
  profile_apex_name             = var.profile_apex_name
  profile_nl2sql_name           = var.profile_nl2sql_name
  profile_rag_name              = var.profile_rag_name
  profile_region                = var.region
  profile_apex_model            = var.profile_apex_model
  profile_nl2sql_model          = var.profile_nl2sql_model
  profile_rag_model             = var.profile_rag_model
  rag_embedding_model           = var.rag_embedding_model
  ai_max_tokens                 = var.ai_max_tokens
  rag_vector_index_name         = var.rag_vector_index_name
  rag_vector_dimension          = var.rag_vector_dimension
  rag_vector_distance_metric    = var.rag_vector_distance_metric
  rag_chunk_overlap             = var.rag_chunk_overlap
  rag_chunk_size                = var.rag_chunk_size
  rag_refresh_rate_minutes      = var.rag_refresh_rate_minutes
  rag_match_limit               = var.rag_match_limit
  rag_similarity_threshold      = var.rag_similarity_threshold
  rag_object_storage_location   = local.rag_object_storage_location
  object_storage_prefix         = local.object_storage_prefix
  enable_rag                    = var.enable_rag
  fraud_notification_threshold  = var.fraud_notification_threshold
  google_sheet_url              = var.google_sheet_url
  fsi_apex_ai_service_static_id = var.fsi_apex_ai_service_static_id
  fsi_apex_fraud_team           = var.fsi_apex_fraud_team
  fsi_apex_generic_team         = var.fsi_apex_generic_team
  fsi_apex_rag_team             = var.fsi_apex_rag_team
  fsi_apex_llm_instructions     = var.fsi_apex_llm_instructions
  fsi_runtime_config_defaults   = var.fsi_runtime_config_defaults
  fsi_runtime_config            = var.fsi_runtime_config

  enable_fsi_ai_request_worker           = var.enable_fsi_ai_request_worker
  fsi_ai_request_worker_interval         = var.fsi_ai_request_worker_interval
  enable_fsi_claim_generation_job        = var.enable_fsi_claim_generation_job
  fsi_claim_generation_interval          = var.fsi_claim_generation_interval
  enable_fsi_new_claim_investigation_job = var.enable_fsi_new_claim_investigation_job
  fsi_new_claim_investigation_interval   = var.fsi_new_claim_investigation_interval
  load_dump_vector_index_snapshot        = var.load_dump_vector_index_snapshot
  load_sample_data                       = var.load_sample_data
  fsi_application_data_par_url           = var.fsi_application_data_par_url
  fsi_vector_snapshot_par_url            = var.fsi_vector_snapshot_par_url
  fsi_apex_export_par_url                = var.fsi_apex_export_par_url

  apex_workspace_name   = var.apex_workspace_name
  apex_workspace_id     = var.apex_workspace_id
  apex_db_schema        = var.fsi_db_schema
  apex_builder_username = var.apex_builder_username
  apex_builder_password = var.apex_builder_password
  apex_app_id           = var.apex_app_id
  apex_app_alias        = var.apex_app_alias
  apex_app_name         = var.apex_app_name
}
