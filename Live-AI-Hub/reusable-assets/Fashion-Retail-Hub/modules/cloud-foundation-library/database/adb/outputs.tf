# Copyright © 2026, Oracle and/or its affiliates.
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

# output "db_connection" {
#   value = one([ for b in oci_database_autonomous_database.adw : b.connection_strings])
# }

# output "private_endpoint_ip" {
#   value = one([for b in oci_database_autonomous_database.adw : b.private_endpoint_ip])
# }

output "db_connection" {
  value = { for k, db in oci_database_autonomous_database.adw : k => db.connection_strings }
}

output "private_endpoint_ip" {
  value = { for k, db in oci_database_autonomous_database.adw : k => db.private_endpoint_ip }
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
  value = lower(trimsuffix(trimprefix(join("\n", [for b in oci_database_autonomous_database.adw : b.connection_urls.0.graph_studio_url]), "https://"), "/graphstudio/?sso=true"))
}

output "adw" {
  value = {
   for adw in oci_database_autonomous_database.adw:
    adw.display_name => adw.id
  }
}

output "autonomous_database_connection_strings_high" {
  description = "A comma-separated list of HIGH connection strings for all autonomous databases."
  value = join(", ", [for db in oci_database_autonomous_database.adw : db.connection_strings[0].high])
}

# output "high_mutual_connection_string" {
#   description = "The connection string for the HIGH consumer group with MUTUAL TLS authentication."
#   value = one([
#     for db in oci_database_autonomous_database.adw : 
#     (flatten([for p in db.connection_strings[0].profiles : [p.value] if p.consumer_group == "HIGH" && p.tls_authentication == "MUTUAL"])[0])
#     if length(flatten([for p in db.connection_strings[0].profiles : [p.value] if p.consumer_group == "HIGH" && p.tls_authentication == "MUTUAL"])) > 0
#   ])
# }


output "adw_sql_dev_web_urls" {
  value = {
    for key, adw in oci_database_autonomous_database.adw :
    key => trimsuffix(adw.connection_urls[0].sql_dev_web_url, "/sql-developer")
  }
}

output "high_mutual_connection_string" {
  value = {
    for k, db in oci_database_autonomous_database.adw :
    k => (
      flatten([
        for p in db.connection_strings[0].profiles :
        [p.value]
        if p.consumer_group == "HIGH" && p.tls_authentication == "MUTUAL"
      ])[0]
    )
    if length(flatten([
      for p in db.connection_strings[0].profiles :
      [p.value]
      if p.consumer_group == "HIGH" && p.tls_authentication == "MUTUAL"
    ])) > 0
  }
}

output "mongo_db_urls" {
  value = {
    for k, v in oci_database_autonomous_database.adw :
    k => try(v.connection_urls[0].mongo_db_url, null)
  }
}