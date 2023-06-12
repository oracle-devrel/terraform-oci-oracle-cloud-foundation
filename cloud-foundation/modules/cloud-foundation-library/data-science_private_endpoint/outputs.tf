## Copyright © 2023, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "datascience" {
  value       = length(oci_datascience_project.this) > 0 ? oci_datascience_project.this[*] : null
}

output "notebook" {
  value       = length(oci_datascience_notebook_session.this) > 0 ? oci_datascience_notebook_session.this[*] : null
}