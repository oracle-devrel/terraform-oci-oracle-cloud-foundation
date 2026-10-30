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
  rag_region                        = var.rag_region
  rag_embedding_model               = var.rag_embedding_model
  rag_model                         = var.rag_model
  rag_vector_dimension              = var.rag_vector_dimension
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


resource "null_resource" "empty_object_storage_bucket_before_destroy" {
  # OCI will not delete a bucket that contains objects or old object versions.
  # This provisioner runs while the bucket still exists and removes both.
  depends_on = [module.os]

  triggers = {
    bucket_name = var.files_bucket_name
    namespace   = data.oci_objectstorage_namespace.this.namespace
  }

  provisioner "local-exec" {
    when = destroy

    command = <<-EOT
      set -euo pipefail

      NAMESPACE="${self.triggers.namespace}"
      BUCKET="${self.triggers.bucket_name}"

      echo "Emptying Object Storage bucket before destroy: $BUCKET"

      while true; do
        OBJECT_VERSIONS_JSON="$(mktemp)"
        trap 'rm -f "$OBJECT_VERSIONS_JSON"' EXIT

        oci os object list-object-versions \
          --namespace-name "$NAMESPACE" \
          --bucket-name "$BUCKET" \
          --all \
          --output json > "$OBJECT_VERSIONS_JSON"

        VERSION_COUNT="$(python3 - "$OBJECT_VERSIONS_JSON" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    print(len(json.load(fh).get("data", [])))
PY
)"

        if [ "$VERSION_COUNT" -eq 0 ]; then
          rm -f "$OBJECT_VERSIONS_JSON"
          trap - EXIT
          break
        fi

        python3 - "$OBJECT_VERSIONS_JSON" "$NAMESPACE" "$BUCKET" <<'PY'
import json
import subprocess
import sys

with open(sys.argv[1], encoding="utf-8") as fh:
    objects = json.load(fh).get("data", [])

for item in objects:
    name = item.get("name")
    version_id = item.get("version-id")
    if not name:
        continue
    command = [
        "oci", "os", "object", "delete",
        "--namespace-name", sys.argv[2],
        "--bucket-name", sys.argv[3],
        "--name", name,
        "--force",
    ]
    if version_id and version_id != "null":
        command.extend(["--version-id", version_id])
    subprocess.run(command, check=True)
PY

        rm -f "$OBJECT_VERSIONS_JSON"
        trap - EXIT
      done

      echo "Object Storage bucket emptied: $BUCKET"
    EOT
  }
}


