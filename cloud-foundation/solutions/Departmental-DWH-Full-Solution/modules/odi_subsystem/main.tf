# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "odi" {
  source = "../../../../../cloud-foundation/modules/cloud-foundation-library/odi"
  odi_params = { 
    odi = {
      compartment_id   = var.compartment_id,
      display_name     = var.display_name,
      description      = var.description,
      # is_private_network_enabled = var.is_private_network_enabled
      # subnet_id        = var.subnet_id
      # vcn_id           = var.vcn_id
      defined_tags     = var.defined_tags
  }
 }
}
