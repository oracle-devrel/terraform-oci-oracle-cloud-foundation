# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_ons_notification_topic" "this" {
  for_each       = var.topic_params
  compartment_id = each.value.compartment_id
  name           = each.value.topic_name
  description    = each.value.description
}

resource "oci_ons_subscription" "this" {
  for_each       = var.subscription_params
  compartment_id = each.value.compartment_id
  endpoint       = each.value.endpoint
  protocol       = each.value.protocol
  topic_id       = oci_ons_notification_topic.this[each.value.topic_name].id
}

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.30.0"
    }
  }
  required_version = ">= 1.5.5"
}