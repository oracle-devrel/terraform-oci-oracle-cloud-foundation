# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_tenancy" "this" {
    tenancy_id = var.tenancy_ocid
}

resource "oci_log_analytics_log_analytics_log_group" "this" {
    for_each       = var.log_analytics_log_group_params
    compartment_id = each.value.compartment_id
    display_name   = each.value.display_name
    namespace      = data.oci_identity_tenancy.this.name
}

