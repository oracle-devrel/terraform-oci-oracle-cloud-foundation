# # Copyright © 2023, Oracle and/or its affiliates.
# # All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_waf_web_app_firewall" "this" {
    for_each       = var.waf_params      
    backend_type   = each.value.backend_type
    compartment_id = each.value.compartment_id
    load_balancer_id = each.value.load_balancer_id
    web_app_firewall_policy_id = oci_waf_web_app_firewall_policy.this[each.key].id
    defined_tags   = each.value.defined_tags
    display_name   = each.value.display_name
    freeform_tags  = each.value.freeform_tags
}

resource "oci_waf_web_app_firewall_policy" "this" {
    for_each       = var.waf_params  
    compartment_id = each.value.compartment_id
    defined_tags   = each.value.defined_tags
    display_name   = each.value.display_name
    freeform_tags  = each.value.freeform_tags
}
