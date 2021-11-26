## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "datascience" {
  value = [ for b in oci_datascience_project.this : b.display_name]
}

output "notebook" {
  value = [ for b in oci_datascience_notebook_session.this : b.display_name]
}