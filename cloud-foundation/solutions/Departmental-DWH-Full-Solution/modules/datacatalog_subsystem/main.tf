# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "datacatalog" {
  source = "../../../../../cloud-foundation/modules/cloud-foundation-library/datacatalog"
  
  datacatalog_params = { 
    datacatalog = {
      compartment_id        = var.compartment_id,
      catalog_display_name  = var.datacatalog_display_name,
      defined_tags          = var.defined_tags
  }
 }
}
