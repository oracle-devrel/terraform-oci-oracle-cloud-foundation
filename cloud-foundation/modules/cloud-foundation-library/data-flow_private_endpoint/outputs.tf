## Copyright © 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


output "dataflow_application" {
  description = "Data Flow informations."
  value       = length(oci_dataflow_application.this) > 0 ? oci_dataflow_application.this[*] : null
}

output "dataflow_private_endpoint" {
  description = "Data Flow informations."
  value       = length(oci_dataflow_private_endpoint.this) > 0 ? oci_dataflow_private_endpoint.this[*] : null
}