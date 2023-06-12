# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_artifacts_container_repository" "this" {
    for_each       = var.containers_artifacts_params
    compartment_id = each.value.compartment_id
    display_name   = each.value.display_name
    is_immutable   = each.value.is_immutable
    is_public      = each.value.is_public
}