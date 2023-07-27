# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "requestor" {
  value = oci_core_drg.requestor_drg[0].id
}


output "acceptor" {
  value = oci_core_drg.acceptor_drg[0].id
}

output "Remote_Peeting_Region1" {
  value       = length(oci_core_remote_peering_connection.requestor) > 0 ? oci_core_remote_peering_connection.requestor[*] : null
}

output "Remote_Peeting_Region2" {
  value       = length(oci_core_remote_peering_connection.acceptor) > 0 ? oci_core_remote_peering_connection.acceptor[*] : null
}