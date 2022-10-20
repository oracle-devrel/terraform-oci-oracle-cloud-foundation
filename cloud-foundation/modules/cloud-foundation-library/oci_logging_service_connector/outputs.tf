## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "service_connectors" {
    value = {for sc in oci_sch_service_connector.this:
    sc.display_name => sc.id}
}