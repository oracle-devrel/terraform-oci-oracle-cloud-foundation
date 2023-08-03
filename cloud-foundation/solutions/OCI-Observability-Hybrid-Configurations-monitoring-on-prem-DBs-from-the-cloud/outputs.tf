# # Copyright © 2023, Oracle and/or its affiliates.
# # All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "external_containers_database" {
  value = module.external_db.external_containers_database
}

output "external_pluggable_database" {
  value = module.external_db.external_pluggable_database
}
