# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "atp_db_id" {
  value = join ("",oci_database_autonomous_database.this.*.id)
}

output "is_atp_db" {
  value = "true"
}

output "url" {
  value = trimsuffix(oci_database_autonomous_database.this.connection_urls.*.sql_dev_web_url[0], "/sql-developer")
}

output "db_connection" {
   value = oci_database_autonomous_database.this.connection_strings
}

output "private_endpoint_ip" {
   value = oci_database_autonomous_database.this.private_endpoint_ip
}
