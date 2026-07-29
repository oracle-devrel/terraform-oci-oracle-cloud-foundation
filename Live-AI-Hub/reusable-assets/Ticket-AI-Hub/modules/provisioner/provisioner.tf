# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  oci_private_key_sql = replace(
    replace(var.oci_private_key_pem, "\r", ""),
    "'",
    "''"
  )

  apex_export_url = "https://objectstorage.us-ashburn-1.oraclecloud.com/p/a9SODSOjMvoDNJlzX6CeJ88VFp_yzxQdkNmaJkEd5DI4iDNBOKFC-0iUGtuOSv9Y/n/idukzrqavn8q/b/Live-AI-Hub/o/f101-ticket-ai-hub-2026-07-09-15-49.sql"

  apex_export_path = abspath(
    "${path.module}/f101-ticket-ai-hub-2026-07-09-15-49.sql"
  )
}


resource "local_file" "ticket_aihub_admin_sql" {
  content = templatefile("${path.module}/atp-ticket-aihub-v0.02-admin.sql.tftpl", {
    adb_host              = var.adb_host
    ticket_aihub_password = var.ticket_aihub_password
  })

  filename = "${path.module}/generated-atp-ticket-aihub-v0.02-admin.sql"
}


resource "local_file" "ticket_agent_runtime_sql" {
  content = templatefile("${path.module}/ticket_agent_runtime.sql.tftpl", {
    ords_schema_path                    = var.ords_schema_path
    oci_credential_name                 = var.oci_credential_name
    oci_user_ocid                       = var.oci_user_ocid
    oci_tenancy_ocid                    = var.oci_tenancy_ocid
    oci_fingerprint                     = var.oci_fingerprint
    oci_private_key_sql                 = local.oci_private_key_sql
    oci_compartment_ocid                = var.oci_compartment_ocid

    profile_nl2sql_name                 = var.profile_nl2sql_name
    profile_agent_name                  = var.profile_agent_name
    profile_attachments_name            = var.profile_attachments_name
    profile_judge_name                  = var.profile_judge_name
    profile_rag_kb_name                 = var.profile_rag_kb_name
    ai_max_tokens                       = var.ai_max_tokens

    profile_nl2sql_region               = var.profile_nl2sql_region
    profile_nl2sql_model                = var.profile_nl2sql_model
    profile_agent_region                = var.profile_agent_region
    profile_agent_model                 = var.profile_agent_model
    profile_attachments_region          = var.profile_attachments_region
    profile_attachments_model           = var.profile_attachments_model
    profile_judge_region                = var.profile_judge_region
    profile_judge_model                 = var.profile_judge_model

    rag_region                          = var.rag_region
    rag_vector_index_name               = var.rag_vector_index_name
    rag_embedding_model                 = var.rag_embedding_model
    rag_model                           = var.rag_model
    rag_object_storage_location         = var.rag_object_storage_location
    rag_object_storage_credential       = var.rag_object_storage_credential
    rag_vector_dimension                = var.rag_vector_dimension
    rag_vector_distance_metric          = var.rag_vector_distance_metric
    rag_chunk_overlap                   = var.rag_chunk_overlap
    rag_chunk_size                      = var.rag_chunk_size
    rag_refresh_rate_minutes            = var.rag_refresh_rate_minutes
    rag_match_limit                     = var.rag_match_limit
    rag_similarity_threshold            = var.rag_similarity_threshold

    attachment_object_storage_credential = var.attachment_object_storage_credential
    attachment_genai_credential          = var.attachment_genai_credential
    attachment_genai_region              = var.attachment_genai_region
    attachment_genai_compartment_ocid    = var.attachment_genai_compartment_ocid
    attachment_max_bytes                 = var.attachment_max_bytes
    attachment_genai_max_tokens          = var.attachment_genai_max_tokens

    adb_ords_host                       = var.adb_ords_host
    ords_module_name                    = var.ords_module_name
    ords_base_path                      = var.ords_base_path
    ords_receive_escalation_path        = var.ords_receive_escalation_path
    ords_receive_answer_path            = var.ords_receive_answer_path

    default_notification_method         = var.default_notification_method
    http_chunk_chars                    = var.http_chunk_chars
    outbound_api_max_attempts           = var.outbound_api_max_attempts
    outbound_api_retry_interval_seconds = var.outbound_api_retry_interval_seconds

    teams_credential_name               = var.teams_credential_name
    smtp_credential_name                = var.smtp_credential_name
    smtp_host                           = var.smtp_host
    smtp_sender                         = var.smtp_sender
    smtp_test_recipient                 = var.smtp_test_recipient

    oauth_role_name                     = var.oauth_role_name
    oauth_privilege_name                = var.oauth_privilege_name
    oauth_privilege_pattern             = var.oauth_privilege_pattern
    oauth_client_name                   = var.oauth_client_name
    oauth_client_owner                  = var.oauth_client_owner
    oauth_support_email                 = var.oauth_support_email

    detailed_debug                      = var.detailed_debug
    default_ticket_priority             = var.default_ticket_priority
    default_process_attachments         = var.default_process_attachments
    agent_completion_guard_enabled      = var.agent_completion_guard_enabled
    agent_stalled_after_minutes         = var.agent_stalled_after_minutes
  })

  filename = "${path.module}/generated-ticket_agent_runtime.sql"
}


resource "local_file" "apex_workspace_setup_sql" {
  content = templatefile("${path.module}/apex_workspace_setup.sql.tftpl", {
    apex_workspace_name   = var.apex_workspace_name
    apex_workspace_id     = var.apex_workspace_id
    apex_db_schema        = var.apex_db_schema
    apex_builder_username = var.apex_builder_username
    apex_builder_password = var.apex_builder_password
  })

  filename = "${path.module}/generated-apex_workspace_setup.sql"
}

resource "local_file" "apex_import_wrapper_sql" {
  content = templatefile("${path.module}/apex_import_wrapper.sql.tftpl", {
    apex_workspace_name = var.apex_workspace_name
    apex_db_schema      = var.apex_db_schema
    apex_app_id         = var.apex_app_id
    apex_app_alias      = var.apex_app_alias
    apex_app_name       = var.apex_app_name
    apex_export_file    = local.apex_export_path
  })

  filename = "${path.module}/generated-apex_import_wrapper.sql"
}


resource "null_resource" "sqlcl_ticket_aihub_admin" {
  depends_on = [local_file.ticket_aihub_admin_sql]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      echo "Running ticket_aihub admin bootstrap..."

      sql -cloudconfig wallet_${var.db_name}.zip "admin/${var.db_password}@${var.conn_db}" @"${local_file.ticket_aihub_admin_sql.filename}"

      echo "ticket_aihub admin bootstrap completed."
    EOT
  }
}


resource "null_resource" "sqlcl_ticket_agent_data_model" {
  depends_on = [
    local_file.ticket_aihub_admin_sql,
    null_resource.sqlcl_ticket_aihub_admin
  ]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      echo "Running ticket_agent_data_model.sql..."

      sql -cloudconfig wallet_${var.db_name}.zip "ticket_aihub/${var.ticket_aihub_password}@${var.conn_db}" @"${path.module}/ticket_agent_data_model.sql"

      echo "ticket_agent_data_model.sql completed."
    EOT
  }
}

resource "null_resource" "sqlcl_ticket_reference_data_seed" {
  depends_on = [
    null_resource.sqlcl_ticket_agent_data_model
  ]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      echo "Running ticket reference data seed..."

      sql \
        -cloudconfig wallet_${var.db_name}.zip \
        "ticket_aihub/${var.ticket_aihub_password}@${var.conn_db}" \
        @"${path.module}/ticket_response_agent_seed_english.sql"

      echo "Ticket reference data seed completed."
    EOT
  }
}

resource "null_resource" "sqlcl_tickets_seed" {
  depends_on = [
    null_resource.sqlcl_ticket_reference_data_seed
  ]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      echo "Running ticket data seed..."

      sql \
        -cloudconfig wallet_${var.db_name}.zip \
        "ticket_aihub/${var.ticket_aihub_password}@${var.conn_db}" \
        @"${path.module}/tickets_seed_and_translate_english.sql"

      echo "Ticket data seed completed."
    EOT
  }
}

resource "null_resource" "sqlcl_ticket_agent_runtime" {
  depends_on = [
    null_resource.sqlcl_tickets_seed,
    local_file.ticket_agent_runtime_sql
  ]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      echo "Running ticket_agent_runtime.sql..."
      sql -cloudconfig wallet_${var.db_name}.zip "ticket_aihub/${var.ticket_aihub_password}@${var.conn_db}" @"${local_file.ticket_agent_runtime_sql.filename}"
      echo "ticket_agent_runtime.sql completed."
    EOT
  }
}


resource "null_resource" "sqlcl_apex_workspace_setup" {
  depends_on = [
    null_resource.sqlcl_ticket_agent_runtime,
    local_file.apex_workspace_setup_sql
  ]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      echo "Running APEX workspace setup..."
      sql -cloudconfig "${var.wallet_zip_path}" "admin/${var.db_password}@${var.conn_db}" @"${local_file.apex_workspace_setup_sql.filename}"
      echo "APEX workspace setup completed."
    EOT
  }
}

resource "null_resource" "sqlcl_ticket_aihub_apex_app" {
  depends_on = [
    null_resource.sqlcl_apex_workspace_setup,
    local_file.apex_import_wrapper_sql
  ]

  triggers = {
    apex_export_url  = local.apex_export_url
    apex_export_path = local.apex_export_path
    apex_app_id      = tostring(var.apex_app_id)
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      APEX_EXPORT="${local.apex_export_path}"
      APEX_EXPORT_TMP="$APEX_EXPORT.part"

      echo "Downloading APEX application export..."
      echo "Source: ${local.apex_export_url}"
      echo "Target: $APEX_EXPORT"

      mkdir -p "$(dirname "$APEX_EXPORT")"

      rm -f "$APEX_EXPORT_TMP"

      curl \
        --fail \
        --location \
        --silent \
        --show-error \
        --retry 5 \
        --retry-delay 5 \
        --connect-timeout 30 \
        --max-time 1800 \
        --output "$APEX_EXPORT_TMP" \
        "${local.apex_export_url}"

      if [ ! -s "$APEX_EXPORT_TMP" ]; then
        echo "ERROR: Downloaded APEX export is empty."
        rm -f "$APEX_EXPORT_TMP"
        exit 1
      fi

      FILE_SIZE=$(wc -c < "$APEX_EXPORT_TMP" | tr -d '[:space:]')

      echo "Downloaded APEX export size: $FILE_SIZE bytes"

      if [ "$FILE_SIZE" -lt 100000000 ]; then
        echo "ERROR: Downloaded file is unexpectedly small."
        echo "Expected an APEX export of approximately 134 MB."
        echo "The PAR URL may be expired or may have returned an error document."
        rm -f "$APEX_EXPORT_TMP"
        exit 1
      fi

      mv "$APEX_EXPORT_TMP" "$APEX_EXPORT"

      echo "APEX export downloaded successfully."
      echo "Running APEX application import..."

      sql \
        -cloudconfig "${var.wallet_zip_path}" \
        "ticket_aihub/${var.ticket_aihub_password}@${var.conn_db}" \
        @"${local_file.apex_import_wrapper_sql.filename}"

      echo "APEX application import completed."
    EOT
  }
}

resource "local_file" "apex_app_acl_setup_sql" {
  content = templatefile("${path.module}/apex_app_acl_setup.sql.tftpl", {
    apex_workspace_name   = var.apex_workspace_name
    apex_app_id           = var.apex_app_id
    apex_builder_username = var.apex_builder_username
  })

  filename = "${path.module}/generated-apex_app_acl_setup.sql"
}

resource "null_resource" "sqlcl_apex_app_acl_setup" {
  depends_on = [
    null_resource.sqlcl_ticket_aihub_apex_app,
    local_file.apex_app_acl_setup_sql
  ]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      echo "Running APEX application ACL setup..."
      sql -cloudconfig "${var.wallet_zip_path}" "ticket_aihub/${var.ticket_aihub_password}@${var.conn_db}" @"${local_file.apex_app_acl_setup_sql.filename}"
      echo "APEX application ACL setup completed."
    EOT
  }
}