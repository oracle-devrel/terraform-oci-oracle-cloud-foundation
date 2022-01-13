output "dbcs_info" {
  value = { for db in oci_database_db_system.this: db.display_name => db.id }
}
