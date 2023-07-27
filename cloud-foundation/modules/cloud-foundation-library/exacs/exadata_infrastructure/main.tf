# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

resource "oci_database_cloud_exadata_infrastructure" "this" {
    for_each = var.exadata_infrastructure
    availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[each.value.availability_domain - 1].name
    compartment_id      = each.value.compartment_id
    display_name        = each.value.display_name
    shape               = each.value.shape
    customer_contacts {
        email = each.value.email
    }
    defined_tags  = each.value.defined_tags
    freeform_tags = each.value.freeform_tags
    maintenance_window {
        hours_of_day   = each.value.hours_of_day
        preference     = each.value.preference
        weeks_of_month = each.value.weeks_of_month
    }
      lifecycle {
      ignore_changes = all
    }
}