# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "atp_db_id" {
  value = {
    for adw in oci_database_autonomous_database.adw : adw.display_name => adw.id
  }
}

output "db_connection" {
  value = one([for database in oci_database_autonomous_database.adw : database.connection_strings])
}

output "private_endpoint_ip" {
  value = one([for database in oci_database_autonomous_database.adw : database.private_endpoint_ip])
}

output "url" {
  value = [for database in oci_database_autonomous_database.adw : database.connection_urls[0].sql_dev_web_url]
}

output "graph_studio_url" {
  value = [for database in oci_database_autonomous_database.adw : database.connection_urls[0].graph_studio_url]
}

output "database_fully_qualified_name" {
  value = lower(trimsuffix(trimprefix(join("\n", [for database in oci_database_autonomous_database.adw : database.connection_urls[0].graph_studio_url]), "https://"), "/graphstudio/"))
}

output "autonomous_database_connection_strings_high" {
  description = "A comma-separated list of HIGH connection strings for all autonomous databases."
  value       = join(", ", [for database in oci_database_autonomous_database.adw : database.connection_strings[0].high])
}

output "high_mutual_connection_string" {
  description = "The connection string for the HIGH consumer group with MUTUAL TLS authentication."
  value = one([
    for database in oci_database_autonomous_database.adw :
    (flatten([for profile in database.connection_strings[0].profiles : [profile.value] if profile.consumer_group == "HIGH" && profile.tls_authentication == "MUTUAL"])[0])
    if length(flatten([for profile in database.connection_strings[0].profiles : [profile.value] if profile.consumer_group == "HIGH" && profile.tls_authentication == "MUTUAL"])) > 0
  ])
}
