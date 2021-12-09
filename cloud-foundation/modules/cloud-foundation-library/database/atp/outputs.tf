# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Output details of the autonomous database

output "atp_db_id" {
  value = join ("",oci_database_autonomous_database.autonomous_database.*.id)
}

output "is_atp_db" {
  value = "true"
}

/* resource "local_file" "db_pass" {
    //content  = data.oci_kms_decrypted_data.password.plaintext
    content = base64decode(var.kms_encrypted_value)
    filename = "db_pass.txt"
} */