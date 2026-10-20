# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_id
}

locals {
  supplied_oci_private_key_pem = try(trimspace(var.oci_private_key_pem), "")

  effective_oci_private_key_pem = (
    local.supplied_oci_private_key_pem != "" ? local.supplied_oci_private_key_pem :
    trimspace(var.private_key_path) != "" ? trimspace(file(var.private_key_path)) :
    ""
  )

  object_storage_prefix       = "https://objectstorage.${var.region}.oraclecloud.com/n/${data.oci_objectstorage_namespace.this.namespace}/b/${var.files_bucket_name}/o/"
  rag_object_storage_location = "${local.object_storage_prefix}*.md"
  conn_db                     = lower(var.adw_db_name) != "" ? "${lower(var.adw_db_name)}_tp" : ""
  runtime_oci_credential_name = var.use_adb_resource_principal_for_ai ? "OCI$RESOURCE_PRINCIPAL" : var.oci_credential_name

  # The shared ADB module exposes graph_studio_url as the authoritative web endpoint.
  # Derive the hostname from it because its legacy database_fully_qualified_name
  # output can retain the Graph Studio query suffix.
  adb_graph_studio_url = one(module.adb.graph_studio_url)
  adb_base_url         = split("/graphstudio", lower(local.adb_graph_studio_url))[0]
  adb_hostname         = trimprefix(local.adb_base_url, "https://")

  adw_params = {
    adw = {
      compartment_id              = var.compartment_id
      compute_model               = var.adw_db_compute_model
      compute_count               = var.adw_db_compute_count
      size_in_tbs                 = var.adw_db_size_in_tbs
      db_name                     = var.adw_db_name
      db_workload                 = var.adw_db_workload
      db_version                  = var.adw_db_version
      enable_auto_scaling         = var.adw_db_enable_auto_scaling
      is_free_tier                = var.adw_db_is_free_tier
      license_model               = var.adw_db_license_model
      create_local_wallet         = true
      database_admin_password     = var.adw_db_password
      database_wallet_password    = var.adw_db_password
      data_safe_status            = var.adw_db_data_safe_status
      operations_insights_status  = var.adw_db_operations_insights_status
      database_management_status  = var.adw_db_database_management_status
      is_mtls_connection_required = null
      subnet_id                   = null
      nsg_ids                     = null
      defined_tags                = null
    }
  }

  bucket_params = {
    fsi_files_bucket = {
      compartment_id = var.compartment_id
      name           = var.files_bucket_name
      access_type    = "NoPublicAccess"
      storage_tier   = var.files_bucket_storage_tier
      events_enabled = var.files_bucket_events_enabled
      defined_tags   = null
    }
  }

  # Upload the three approved RAG documents from documentation/.
  knowledge_base_document_names = [
    "CrossShield_Insurance_HLD-v0.01.md",
    "CrossShield_Insurance_LLD-v0.01.md",
    "CrossShield_Insurance_HLD_LLD_Comparison_Report-v0.01.md",
  ]
  knowledge_base_uploads = var.upload_knowledge_base ? {
    for file_name in local.knowledge_base_document_names : file_name => {
      bucket  = var.files_bucket_name
      object  = file_name
      content = file("${path.root}/documentation/${file_name}")
    }
  } : {}
}
