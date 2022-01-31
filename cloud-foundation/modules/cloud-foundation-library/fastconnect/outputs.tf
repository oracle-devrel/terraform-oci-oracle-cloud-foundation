# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


output "private_vc_with_provider_no_cross_connect_or_cross_connect_group_id" {
  value = {
    for fc in oci_core_virtual_circuit.private_vc_with_provider_no_cross_connect_or_cross_connect_group_id :
    fc.display_name => { "compartment_id" : fc.compartment_id, "id" : fc.id, "type" : fc.type, "bandwidth_shape_name" : fc.bandwidth_shape_name }
  }
}

