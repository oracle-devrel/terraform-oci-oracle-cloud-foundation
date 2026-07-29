# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  adb_host = module.adb.database_fully_qualified_name
  conn_db = lower(var.adw_db_name) != "" ? "${lower(var.adw_db_name)}_tp" : ""
  oci_private_key_sql = replace(replace(var.oci_private_key_pem, "\r", ""), "'", "''")
  rag_object_storage_location = "https://objectstorage.${var.region}.oraclecloud.com/n/${data.oci_objectstorage_namespace.this.namespace}/b/${var.files_bucket_name}/o/*.md"
}


module "adb" {
  source     = "./modules/cloud-foundation-library/database/adb"
  adw_params = local.adw_params
}

module "os" {
  source       = "./modules/cloud-foundation-library/object-storage"
  depends_on   = [module.adb]
  tenancy_ocid = var.tenancy_ocid
  bucket_params = {
    for k, v in local.bucket_params : k => v if v.compartment_id != ""
  }
}


module "provisioner" {
  source = "./modules/provisioner"

  db_name                 = var.adw_db_name
  db_password             = var.adw_db_password
  conn_db                 = local.conn_db
  wallet_zip_path         = "wallet_${var.adw_db_name}.zip"
  adb_host                = local.adb_host
  ticket_aihub_password   = "AaBbCcDdEe123#"

  oci_user_ocid           = var.user_ocid
  oci_tenancy_ocid        = var.tenancy_ocid
  oci_fingerprint         = var.fingerprint
  oci_private_key_pem     = local.effective_oci_private_key_pem
  oci_compartment_ocid    = var.compartment_id

  adb_ords_host                     = local.adb_host
  rag_object_storage_location       = local.rag_object_storage_location
  attachment_genai_compartment_ocid = var.compartment_id

  apex_workspace_name   = "TICKET_AIHUB_WS"
  apex_workspace_id     = 101010101
  apex_db_schema        = "TICKET_AIHUB"
  apex_builder_username = "TICKET_AIHUB"
  apex_builder_password = "AaBbCcDdEe123#"
  apex_app_id           = 101
  apex_app_alias        = "TICKET-AI-HUB"
  apex_app_name         = "Ticket AI Hub"
}

data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_id
}


resource "null_resource" "upload_files_to_object_storage" {
  depends_on = [module.os]

  provisioner "local-exec" {
    command = <<-EOT
      set -euo pipefail

      SOURCE_DIR="${path.root}/healthcare"
      NAMESPACE="${data.oci_objectstorage_namespace.this.namespace}"
      BUCKET="${var.files_bucket_name}"

      if [ ! -d "$SOURCE_DIR" ]; then
        echo "ERROR: Source directory not found: $SOURCE_DIR"
        exit 1
      fi

      echo "Uploading files from $SOURCE_DIR to bucket: $BUCKET (namespace: $NAMESPACE) ..."

      cd "$SOURCE_DIR"

      find . -type f -print0 | while IFS= read -r -d '' f; do
        obj_name="$${f#./}"
        echo " -> $obj_name"
        oci os object put \
          -ns "$NAMESPACE" \
          -bn "$BUCKET" \
          --force \
          --name "$obj_name" \
          --file "$f" >/dev/null
      done

      echo "Done."
    EOT
  }
}


