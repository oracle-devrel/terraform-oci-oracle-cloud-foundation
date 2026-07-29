# Copyright © 2026, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "generated_sql_file" {
  value = local_file.ticket_aihub_admin_sql.filename
}

output "ticket_agent_data_model_script" {
  value = "${path.module}/ticket_agent_data_model.sql"
}