output "atp_db_id" {
  value = join ("",oci_database_autonomous_database.autonomous_database.*.id)
}

output "is_atp_db" {
  value = "true"
}

output "url" {
  value = trimsuffix(oci_database_autonomous_database.autonomous_database.connection_urls.*.sql_dev_web_url[0], "/sql-developer")
}

output "db_connection" {
   value = oci_database_autonomous_database.autonomous_database.connection_strings
}

output "private_endpoint_ip" {
   value = oci_database_autonomous_database.autonomous_database.private_endpoint_ip
}
