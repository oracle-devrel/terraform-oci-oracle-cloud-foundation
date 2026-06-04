# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "project_id" {
  value = mongodbatlas_project.this.id
}

output "cluster_name" {
  value = mongodbatlas_cluster.this.name
}

output "mongodb_srv_address" {
  value = mongodbatlas_cluster.this.connection_strings[0].standard_srv
}

output "mongodb_uri" {
  value     = "mongodb+srv://${var.db_username}:${urlencode(var.db_password)}@${replace(mongodbatlas_cluster.this.connection_strings[0].standard_srv, "mongodb+srv://", "")}/${var.database_name}?retryWrites=true&w=majority"
  sensitive = false
}

output "database_name" {
  value = var.database_name
}

output "mongodb_hostname" {
  value = replace(mongodbatlas_cluster.this.connection_strings[0].standard_srv, "mongodb+srv://", "")
}