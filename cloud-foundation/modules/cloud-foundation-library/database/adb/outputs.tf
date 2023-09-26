# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "atp_db_id" {
  value = {
   for adw in oci_database_autonomous_database.adw:
    adw.display_name => adw.id
  }
}

output "ad" {
  value = {
    for idx, ad in oci_database_autonomous_database.adw:
      ad.db_name => { "connection_strings" : ad.connection_strings.0.all_connection_strings}
  }
}

output "db_connection" {
  value = one([ for b in oci_database_autonomous_database.adw : b.connection_strings])
}

output "private_endpoint_ip" {
  value = one([for b in oci_database_autonomous_database.adw : b.private_endpoint_ip])
}

output "private_endpoint" {
  value = ([for b in oci_database_autonomous_database.adw : b.private_endpoint])
}

output "url" {
  value = [for b in oci_database_autonomous_database.adw : b.connection_urls.0.sql_dev_web_url]
}

output "graph_studio_url" {
  value = [for b in oci_database_autonomous_database.adw : b.connection_urls.0.graph_studio_url]
}

output "machine_learning_user_management_url" {
  value = [for b in oci_database_autonomous_database.adw : b.connection_urls.0.machine_learning_user_management_url]
}

output "adb_wallet_content" {
value = oci_database_autonomous_database_wallet.autonomous_database_wallet["adw"].content
}

output "database_fully_qualified_name" {
  value = lower(trimsuffix(trimprefix(join("\n", [for b in oci_database_autonomous_database.adw : b.connection_urls.0.graph_studio_url]), "https://"), "/graphstudio/"))
}

output "adw" {
  value = {
   for adw in oci_database_autonomous_database.adw:
    adw.display_name => adw.id
  }
}
