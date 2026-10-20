# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  schema_functions = replace(
    file("${path.module}/03FunctionsProcs.sql"),
    "/(?i)MADHU_RAO\\./",
    "${lower(var.fsi_db_schema)}."
  )
  fsi_runtime_config = merge(
    var.fsi_runtime_config_defaults,
    var.fsi_runtime_config,
    {
      OCI_REGION                     = var.profile_region
      OCI_COMPARTMENT_ID             = var.oci_compartment_ocid
      OCI_CREDENTIAL_NAME            = var.oci_credential_name
      OCI_MODEL_NAME                 = var.profile_rag_model
      OBJECT_STORAGE_CREDENTIAL_NAME = var.oci_credential_name
      OBJECT_STORAGE_PREFIX          = var.object_storage_prefix
      OBJECT_STORAGE_PATTERN         = var.rag_object_storage_location
      APEX_LLM_PROFILE_NAME          = var.profile_apex_name
      RAG_PROFILE_NAME               = var.profile_rag_name
      RAG_VECTOR_INDEX_NAME          = var.rag_vector_index_name
      RAG_VECTOR_TABLE_NAME          = "${var.rag_vector_index_name}$VECTAB"
      FRAUD_NOTIFICATION_THRESHOLD   = tostring(var.fraud_notification_threshold)
      GOOGLE_SHEET_URL               = var.google_sheet_url != "" ? var.google_sheet_url : lookup(var.fsi_runtime_config, "GOOGLE_SHEET_URL", "")
      GROK_MODEL_NAME                = var.profile_apex_model
    }
  )
}

resource "local_file" "fsi_admin_template" {
  content = templatefile("${path.module}/fsi-admin.sql.tftpl", {
    fsi_db_schema                   = var.fsi_db_schema
    adb_host                        = var.adb_host
    databricks_server_hostname      = replace(lookup(local.fsi_runtime_config, "DATABRICKS_SERVER_HOSTNAME", ""), "'", "''")
    databricks_oauth_token_endpoint = replace(lookup(local.fsi_runtime_config, "DATABRICKS_OAUTH_TOKEN_ENDPOINT", ""), "'", "''")
    databricks_catalog_endpoint     = replace(lookup(local.fsi_runtime_config, "DATABRICKS_CATALOG_ENDPOINT", ""), "'", "''")
    azure_blob_storage_hostname     = lookup(local.fsi_runtime_config, "AZURE_BLOB_USERNAME", "") != "" ? "${lookup(local.fsi_runtime_config, "AZURE_BLOB_USERNAME", "")}.blob.core.windows.net" : ""
  })
  filename = "${path.module}/generated-fsi-admin.sql.in"
}

resource "local_file" "fsi_runtime_template" {
  content = templatefile("${path.module}/fsi-runtime.sql.tftpl", {
    fsi_db_schema                          = var.fsi_db_schema
    oci_credential_name                    = var.oci_credential_name
    oci_user_ocid                          = var.oci_user_ocid
    oci_tenancy_ocid                       = var.oci_tenancy_ocid
    oci_fingerprint                        = var.oci_fingerprint
    oci_compartment_ocid                   = var.oci_compartment_ocid
    oci_runtime_credential_name            = var.oci_runtime_credential_name
    profile_apex_name                      = var.profile_apex_name
    profile_nl2sql_name                    = var.profile_nl2sql_name
    profile_rag_name                       = var.profile_rag_name
    profile_region                         = var.profile_region
    profile_apex_model                     = var.profile_apex_model
    profile_nl2sql_model                   = var.profile_nl2sql_model
    profile_rag_model                      = var.profile_rag_model
    rag_embedding_model                    = var.rag_embedding_model
    ai_max_tokens                          = var.ai_max_tokens
    rag_vector_index_name                  = var.rag_vector_index_name
    rag_vector_dimension                   = var.rag_vector_dimension
    rag_vector_distance_metric             = var.rag_vector_distance_metric
    rag_chunk_overlap                      = var.rag_chunk_overlap
    rag_chunk_size                         = var.rag_chunk_size
    rag_refresh_rate_minutes               = var.rag_refresh_rate_minutes
    rag_match_limit                        = var.rag_match_limit
    rag_similarity_threshold               = var.rag_similarity_threshold
    rag_object_storage_location            = var.rag_object_storage_location
    object_storage_prefix                  = var.object_storage_prefix
    enable_rag                             = var.enable_rag
    fraud_notification_threshold           = var.fraud_notification_threshold
    google_sheet_url                       = var.google_sheet_url
    enable_fsi_ai_request_worker           = var.enable_fsi_ai_request_worker
    fsi_ai_request_worker_interval         = var.fsi_ai_request_worker_interval
    enable_fsi_claim_generation_job        = var.enable_fsi_claim_generation_job
    fsi_claim_generation_interval          = var.fsi_claim_generation_interval
    enable_fsi_new_claim_investigation_job = var.enable_fsi_new_claim_investigation_job
    fsi_new_claim_investigation_interval   = var.fsi_new_claim_investigation_interval
    load_dump_vector_index_snapshot        = var.load_dump_vector_index_snapshot
  })
  filename = "${path.module}/generated-fsi-runtime.sql.in"
}

resource "local_file" "schema_functions_sql" {
  content  = local.schema_functions
  filename = "${path.module}/generated-03FunctionsProcs.sql"
}

resource "local_file" "apex_workspace_template" {
  content = templatefile("${path.module}/apex_workspace_setup.sql.tftpl", {
    apex_workspace_name   = var.apex_workspace_name
    apex_workspace_id     = var.apex_workspace_id
    apex_db_schema        = var.apex_db_schema
    apex_builder_username = var.apex_builder_username
  })
  filename = "${path.module}/generated-apex-workspace.sql.in"
}

resource "local_file" "apex_import_sql" {
  content = templatefile("${path.module}/apex_import_wrapper.sql.tftpl", {
    apex_workspace_name = var.apex_workspace_name
    apex_db_schema      = var.apex_db_schema
    apex_app_id         = var.apex_app_id
    apex_app_alias      = var.apex_app_alias
    apex_app_name       = var.apex_app_name
    apex_export_file    = "${path.module}/.fsi-apex-export.sql"
  })
  filename = "${path.module}/generated-apex-import.sql"
}

resource "local_file" "apex_acl_sql" {
  content = templatefile("${path.module}/apex_app_acl_setup.sql.tftpl", {
    apex_workspace_name   = var.apex_workspace_name
    apex_app_id           = var.apex_app_id
    apex_builder_username = var.apex_builder_username
  })
  filename = "${path.module}/generated-apex-acl.sql"
}

resource "null_resource" "sqlcl_fsi_admin" {
  depends_on = [local_file.fsi_admin_template]

  triggers = {
    admin_template_sha256 = local_file.fsi_admin_template.content_sha256
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      TMP_SQL="$(mktemp "${path.module}/.fsi-admin.sql.XXXXXX")"
      trap 'rm -f "$TMP_SQL"' EXIT
      echo "[FSI] Admin setup source SQL: ${local_file.fsi_admin_template.filename}"
      echo "[FSI] Rendered SQL file: $TMP_SQL"
      envsubst '$FSI_DB_PASSWORD' < "${local_file.fsi_admin_template.filename}" > "$TMP_SQL"
      sql -cloudconfig "${var.wallet_zip_path}" "admin/$DB_ADMIN_PASSWORD@${var.conn_db}" @"$TMP_SQL"
    EOT

    environment = {
      DB_ADMIN_PASSWORD = var.db_password
      FSI_DB_PASSWORD   = var.fsi_db_password
    }
  }
}

resource "null_resource" "sqlcl_fsi_schema_sequences" {
  depends_on = [null_resource.sqlcl_fsi_admin]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      echo "[FSI] Loading SQL file: ${path.module}/01Seqs.sql"
      sql -cloudconfig "${var.wallet_zip_path}" "${var.fsi_db_schema}/$FSI_DB_PASSWORD@${var.conn_db}" @"${path.module}/01Seqs.sql"
    EOT

    environment = {
      FSI_DB_PASSWORD = var.fsi_db_password
    }
  }
}

resource "null_resource" "sqlcl_fsi_schema_tables" {
  depends_on = [null_resource.sqlcl_fsi_schema_sequences]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      echo "[FSI] Loading SQL file: ${path.module}/02TablesViews.sql"
      sql -cloudconfig "${var.wallet_zip_path}" "${var.fsi_db_schema}/$FSI_DB_PASSWORD@${var.conn_db}" @"${path.module}/02TablesViews.sql"
    EOT

    environment = {
      FSI_DB_PASSWORD = var.fsi_db_password
    }
  }
}

resource "null_resource" "sqlcl_fsi_schema_functions" {
  depends_on = [
    null_resource.sqlcl_fsi_schema_tables,
    local_file.schema_functions_sql
  ]

  triggers = {
    schema_sha256 = filesha256("${path.module}/03FunctionsProcs.sql")
    schema_owner  = lower(var.fsi_db_schema)
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      echo "[FSI] Applying generated SQL file: ${local_file.schema_functions_sql.filename}"
      sql -cloudconfig "${var.wallet_zip_path}" "${var.fsi_db_schema}/$FSI_DB_PASSWORD@${var.conn_db}" @"${local_file.schema_functions_sql.filename}"
    EOT

    environment = {
      FSI_DB_PASSWORD = var.fsi_db_password
    }
  }
}

resource "null_resource" "sqlcl_fsi_sample_data" {
  depends_on = [null_resource.sqlcl_fsi_schema_functions]

  triggers = {
    enabled              = tostring(var.load_sample_data)
    source_data_sha256   = sha256(var.fsi_application_data_par_url)
    loader_sha256        = filesha256("${path.module}/load_business_data.sh")
    sequence_sync_sha256 = filesha256("${path.module}/sync_application_sequences.sql")
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      if [ "${var.load_sample_data}" = "true" ]; then
        echo "[FSI] Sample-data loader: ${path.module}/load_business_data.sh"
        "${path.module}/load_business_data.sh" \
          "${var.wallet_zip_path}" \
          "${var.conn_db}" \
          "${var.fsi_db_schema}" \
      else
        echo "CrossShield sample data loading disabled."
      fi
    EOT

    environment = {
      FSI_DB_PASSWORD              = var.fsi_db_password
      FSI_APPLICATION_DATA_PAR_URL = var.fsi_application_data_par_url
    }
  }
}

resource "null_resource" "sqlcl_fsi_runtime" {
  depends_on = [
    null_resource.sqlcl_fsi_admin,
    null_resource.sqlcl_fsi_sample_data,
    local_file.fsi_runtime_template
  ]

  triggers = {
    runtime_config_sha256 = sha256(join("|", [
      var.fsi_db_schema,
      var.oci_credential_name,
      var.oci_compartment_ocid,
      var.profile_apex_name,
      var.profile_nl2sql_name,
      var.profile_rag_name,
      var.profile_region,
      var.profile_apex_model,
      var.profile_nl2sql_model,
      var.profile_rag_model,
      var.rag_embedding_model,
      tostring(var.ai_max_tokens),
      var.rag_vector_index_name,
      tostring(var.rag_vector_dimension),
      var.rag_vector_distance_metric,
      tostring(var.rag_chunk_overlap),
      tostring(var.rag_chunk_size),
      tostring(var.rag_refresh_rate_minutes),
      tostring(var.rag_match_limit),
      tostring(var.rag_similarity_threshold),
      var.rag_object_storage_location,
      var.object_storage_prefix,
      tostring(var.enable_rag),
      tostring(var.fraud_notification_threshold),
      var.google_sheet_url,
      tostring(var.enable_fsi_ai_request_worker),
      var.fsi_ai_request_worker_interval,
      tostring(var.enable_fsi_claim_generation_job),
      var.fsi_claim_generation_interval,
      tostring(var.enable_fsi_new_claim_investigation_job),
      var.fsi_new_claim_investigation_interval,
      tostring(var.load_dump_vector_index_snapshot)
    ]))
    runtime_template_sha256 = local_file.fsi_runtime_template.content_sha256
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      TMP_SQL="$(mktemp "${path.module}/.fsi-runtime.sql.XXXXXX")"
      trap 'rm -f "$TMP_SQL"' EXIT
      echo "[FSI] Runtime SQL template: ${local_file.fsi_runtime_template.filename}"
      echo "[FSI] Rendered runtime SQL file: $TMP_SQL"
      envsubst '$OCI_PRIVATE_KEY_PEM' < "${local_file.fsi_runtime_template.filename}" > "$TMP_SQL"
      sql -cloudconfig "${var.wallet_zip_path}" "${var.fsi_db_schema}/$FSI_DB_PASSWORD@${var.conn_db}" @"$TMP_SQL"
    EOT

    environment = {
      FSI_DB_PASSWORD     = var.fsi_db_password
      OCI_PRIVATE_KEY_PEM = var.oci_private_key_pem
    }
  }
}

resource "null_resource" "sqlcl_fsi_runtime_config" {
  depends_on = [
    null_resource.sqlcl_fsi_runtime,
    null_resource.sqlcl_fsi_admin
  ]

  triggers = {
    schema_owner    = lower(var.fsi_db_schema)
    renderer_sha256 = filesha256("${path.module}/render_fsi_runtime_config.py")
    config_sha256 = nonsensitive(sha256(jsonencode({
      runtime = local.fsi_runtime_config
      apex = {
        ai_service_static_id = var.fsi_apex_ai_service_static_id
        fraud_team           = var.fsi_apex_fraud_team
        generic_team         = var.fsi_apex_generic_team
        rag_team             = var.fsi_apex_rag_team
        llm_model_id         = var.profile_apex_model
      }
      llm_instructions = var.fsi_apex_llm_instructions
      investigate_new  = var.enable_fsi_new_claim_investigation_job
    })))
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      TMP_SQL="$(mktemp "${path.module}/.fsi-runtime-config.sql.XXXXXX")"
      chmod 600 "$TMP_SQL"
      trap 'rm -f "$TMP_SQL"' EXIT
      echo "[FSI] Runtime config SQL output: $TMP_SQL"
      printf '[FSI] FSI_APEX_LLM_INSTRUCTIONS=%s\n' "$FSI_APEX_LLM_INSTRUCTIONS"
      python3 "${path.module}/render_fsi_runtime_config.py" "$TMP_SQL"
      sql -cloudconfig "${var.wallet_zip_path}" "${var.fsi_db_schema}/$FSI_DB_PASSWORD@${var.conn_db}" @"$TMP_SQL"
    EOT

    environment = {
      FSI_DB_PASSWORD         = var.fsi_db_password
      FSI_RUNTIME_CONFIG_JSON = jsonencode(local.fsi_runtime_config)
      FSI_APEX_CONFIG_JSON = jsonencode({
        AI_SERVICE_STATIC_ID = var.fsi_apex_ai_service_static_id
        FRAUD_TEAM           = var.fsi_apex_fraud_team
        GENERIC_TEAM         = var.fsi_apex_generic_team
        LLM_MODEL_ID         = var.profile_apex_model
        RAG_TEAM             = var.fsi_apex_rag_team
      })
      FSI_APEX_LLM_INSTRUCTIONS          = var.fsi_apex_llm_instructions
      FSI_ENABLE_NEW_CLAIM_INVESTIGATION = tostring(var.enable_fsi_new_claim_investigation_job)
    }
  }
}

resource "null_resource" "sqlcl_fsi_vector_snapshot" {
  count      = var.enable_rag && var.load_dump_vector_index_snapshot ? 1 : 0
  depends_on = [null_resource.sqlcl_fsi_runtime, null_resource.sqlcl_fsi_runtime_config]

  triggers = {
    vector_snapshot_sha256 = sha256(var.fsi_vector_snapshot_par_url)
    vector_index_name      = var.rag_vector_index_name
    vector_dimension       = tostring(var.rag_vector_dimension)
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      TMP_SQL="$(mktemp -t fsi-vector-snapshot.XXXXXX)"
      chmod 600 "$TMP_SQL"
      trap 'rm -f "$TMP_SQL"' EXIT
      echo "[FSI] Vector snapshot rendered SQL output: $TMP_SQL"
      python3 "${path.module}/render_vector_snapshot_sql.py" "$TMP_SQL" "${var.rag_vector_index_name}"
      sql -cloudconfig "${var.wallet_zip_path}" "${var.fsi_db_schema}/$FSI_DB_PASSWORD@${var.conn_db}" @"$TMP_SQL"
    EOT

    environment = {
      FSI_DB_PASSWORD             = var.fsi_db_password
      FSI_VECTOR_SNAPSHOT_PAR_URL = var.fsi_vector_snapshot_par_url
    }
  }
}

resource "null_resource" "sqlcl_apex_workspace" {
  triggers = {
    workspace_setup_sha256 = nonsensitive(sha256(jsonencode({
      workspace_name  = var.apex_workspace_name
      workspace_id    = var.apex_workspace_id
      schema_name     = var.apex_db_schema
      username        = var.apex_builder_username
      password_sha256 = sha256(var.apex_builder_password)
      template_sha256 = filesha256("${path.module}/apex_workspace_setup.sql.tftpl")
    })))
  }

  depends_on = [
    null_resource.sqlcl_fsi_runtime,
    null_resource.sqlcl_fsi_runtime_config,
    null_resource.sqlcl_fsi_vector_snapshot,
    local_file.apex_workspace_template
  ]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      TMP_SQL="$(mktemp "${path.module}/.apex-workspace.sql.XXXXXX")"
      trap 'rm -f "$TMP_SQL"' EXIT
      echo "[FSI] APEX workspace SQL template: ${local_file.apex_workspace_template.filename}"
      echo "[FSI] Rendered workspace SQL file: $TMP_SQL"
      envsubst '$APEX_BUILDER_PASSWORD' < "${local_file.apex_workspace_template.filename}" > "$TMP_SQL"
      sql -cloudconfig "${var.wallet_zip_path}" "admin/$DB_ADMIN_PASSWORD@${var.conn_db}" @"$TMP_SQL"
    EOT

    environment = {
      DB_ADMIN_PASSWORD     = var.db_password
      APEX_BUILDER_PASSWORD = var.apex_builder_password
    }
  }
}

resource "null_resource" "sqlcl_apex_import" {
  depends_on = [
    null_resource.sqlcl_apex_workspace,
    local_file.apex_import_sql
  ]

  triggers = {
    app_sha256       = sha256(var.fsi_apex_export_par_url)
    app_schema       = upper(var.fsi_db_schema)
    app_renderer_sha = filesha256("${path.module}/render_apex_export.py")
    app_id           = tostring(var.apex_app_id)
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      TMP_APEX_EXPORT="${path.module}/.fsi-apex-export.sql"
      trap 'rm -f "$TMP_APEX_EXPORT"' EXIT
      echo "[FSI] APEX export output file: $TMP_APEX_EXPORT"
      echo "[FSI] APEX import SQL file: ${local_file.apex_import_sql.filename}"
      python3 "${path.module}/render_apex_export.py" "$TMP_APEX_EXPORT" "${var.fsi_db_schema}"
      sql -cloudconfig "${var.wallet_zip_path}" "${var.fsi_db_schema}/$FSI_DB_PASSWORD@${var.conn_db}" @"${local_file.apex_import_sql.filename}"
    EOT

    environment = {
      FSI_DB_PASSWORD         = var.fsi_db_password
      FSI_APEX_EXPORT_PAR_URL = var.fsi_apex_export_par_url
    }
  }
}

resource "null_resource" "sqlcl_fsi_schema_functions_after_apex" {
  depends_on = [
    null_resource.sqlcl_fsi_schema_functions,
    null_resource.sqlcl_apex_import,
    local_file.schema_functions_sql
  ]

  triggers = {
    schema_sha256 = filesha256("${path.module}/03FunctionsProcs.sql")
    schema_owner  = lower(var.fsi_db_schema)
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      echo "[FSI] Applying generated SQL file: ${local_file.schema_functions_sql.filename}"
      sql -cloudconfig "${var.wallet_zip_path}" "${var.fsi_db_schema}/$FSI_DB_PASSWORD@${var.conn_db}" @"${local_file.schema_functions_sql.filename}"
    EOT

    environment = {
      FSI_DB_PASSWORD = var.fsi_db_password
    }
  }
}

resource "null_resource" "sqlcl_apex_acl" {
  depends_on = [
    null_resource.sqlcl_fsi_schema_functions_after_apex,
    local_file.apex_acl_sql
  ]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      echo "[FSI] Applying APEX ACL SQL file: ${local_file.apex_acl_sql.filename}"
      sql -cloudconfig "${var.wallet_zip_path}" "${var.fsi_db_schema}/$FSI_DB_PASSWORD@${var.conn_db}" @"${local_file.apex_acl_sql.filename}"
    EOT

    environment = {
      FSI_DB_PASSWORD = var.fsi_db_password
    }
  }
}

resource "null_resource" "sqlcl_fsi_verify" {
  depends_on = [null_resource.sqlcl_apex_acl]

  triggers = {
    verification_sha256   = filesha256("${path.module}/verify.sql")
    sequences_sha256      = filesha256("${path.module}/01Seqs.sql")
    tables_sha256         = filesha256("${path.module}/02TablesViews.sql")
    functions_sha256      = filesha256("${path.module}/03FunctionsProcs.sql")
    source_data_sha256    = sha256(var.fsi_application_data_par_url)
    vector_data_sha256    = sha256(var.fsi_vector_snapshot_par_url)
    loader_sha256         = filesha256("${path.module}/load_business_data.sh")
    runtime_config_sha256 = local_file.fsi_runtime_template.content_sha256
    apex_config_sha256    = null_resource.sqlcl_fsi_runtime_config.triggers.config_sha256
    apex_import_id        = null_resource.sqlcl_apex_import.id
    apex_sha256           = sha256(var.fsi_apex_export_par_url)
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail
      echo "[FSI] Running verification SQL file: ${path.module}/verify.sql"
      sql -cloudconfig "${var.wallet_zip_path}" "${var.fsi_db_schema}/$FSI_DB_PASSWORD@${var.conn_db}" @"${path.module}/verify.sql"
    EOT

    environment = {
      FSI_DB_PASSWORD = var.fsi_db_password
    }
  }
}
