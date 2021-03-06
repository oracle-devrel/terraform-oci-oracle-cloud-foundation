# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "monitoring_alarms" {
  description = "Monitoring informations."
  value       = length(oci_monitoring_alarm.this) > 0 ? oci_monitoring_alarm.this[*] : null
}
