# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


output "big_data_service" {
  value = {
    for instance in oci_bds_bds_instance.this:
      instance.display_name => { "display_name" : instance.display_name, "id" : instance.id, "compartment_id": instance.compartment_id, "cluster_version" : instance.cluster_version, "is_high_availability" : instance.is_high_availability, "master_node" : instance.master_node, "util_node" : instance.util_node, "worker_node" : instance.worker_node }
  }
}

