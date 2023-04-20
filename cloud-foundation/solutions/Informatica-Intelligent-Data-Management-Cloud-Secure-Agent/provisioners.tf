# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "null_resource" "upload_files_to_object_storage" {

        provisioner "local-exec" {
             command = <<-EOT
              oci os object put -ns ${data.oci_identity_tenancy.tenancy.name} -bn ${var.bucket_name} --force --file wallet_${var.db_name}.zip
            EOT
        }
depends_on = [module.adw_database_private_endpoint]
}

resource "null_resource" "delete_files_from_object_storage" {
triggers = {
      bucket_name = var.bucket_name
      db_name = var.db_name
  }
provisioner "local-exec" {
    when = destroy
    command = "oci os object delete --bucket-name ${self.triggers.bucket_name} --force --object-name wallet_${self.triggers.db_name}.zip"
    environment = {
      bucket_name = self.triggers.bucket_name
      db_name = self.triggers.db_name
    }
  }
}
