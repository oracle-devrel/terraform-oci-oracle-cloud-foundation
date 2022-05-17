# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


output "log_groups" {
    value = {for lg in oci_logging_log_group.this :
    lg.display_name => lg.id}
}


output "logs" {
    value = {for l in oci_logging_log.this:
    l.display_name => l.id}
}