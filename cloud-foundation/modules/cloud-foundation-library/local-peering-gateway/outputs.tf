# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


output "lpg_requestor" {
  value       = join("\n", [ for b in oci_core_local_peering_gateway.acceptor_lpgs : b.id])
}

output "lpg_acceptor" {
  value       = join("\n", [ for b in oci_core_local_peering_gateway.requestor_lpgs : b.id])
}


