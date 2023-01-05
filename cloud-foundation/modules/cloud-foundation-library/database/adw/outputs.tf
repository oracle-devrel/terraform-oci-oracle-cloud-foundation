# # Copyright © 2022, Oracle and/or its affiliates.
# # All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "ADW_Service_Console_URL" {
  value = [for x in oci_database_autonomous_database.adw : x.service_console_url]
}

output "adw" {
  value = {
   for adw in oci_database_autonomous_database.adw:
    adw.display_name => adw.id
  }
}