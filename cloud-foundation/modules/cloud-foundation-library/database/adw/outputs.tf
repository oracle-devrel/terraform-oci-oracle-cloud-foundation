# # Copyright © 2021, Oracle and/or its affiliates.
# # All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "ADW_Service_Console_URL" {
  value = join(", ", [for x in oci_database_autonomous_database.adw : x.service_console_url])
}