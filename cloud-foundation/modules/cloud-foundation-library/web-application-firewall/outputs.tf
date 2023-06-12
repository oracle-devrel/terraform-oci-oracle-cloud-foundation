# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "waf" {
  value       = length(oci_waf_web_app_firewall.this) > 0 ? oci_waf_web_app_firewall.this[*] : null
}



