# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "generated_admin_user_sql" {
  value = local_sensitive_file.adw_admin_user_sql.filename
}

output "api_gateway_hostname_used_for_acl" {
  value = var.api_gateway_hostname
}