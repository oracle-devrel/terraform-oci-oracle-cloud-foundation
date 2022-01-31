## Copyright © 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# output "dataflow" {
#   value = [ for b in oci_dataflow_application.this : b.display_name]
# }


output "dataflow" {
  description = "Data Flow informations."
  value       = length(oci_dataflow_application.this) > 0 ? oci_dataflow_application.this[*] : null
}