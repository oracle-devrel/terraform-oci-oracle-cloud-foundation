## Copyright © 2021, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "dataflow" {
  value = [ for b in oci_dataflow_application.this : b.display_name]
}