# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "log_analytics_log_group" {
    value = {for sc in oci_log_analytics_log_analytics_log_group.this:
    sc.display_name => sc.id}
}