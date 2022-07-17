## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "data_safe_private_endpoint" {
    value = {for b in oci_data_safe_data_safe_private_endpoint.this:
    b.display_name => b.id}
}

