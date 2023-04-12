# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Create ADW Database with Endpoint in private subnet or public ADW
module "adw_database_private_endpoint" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/database/adw_private_endpoint"
  adw_params = local.adw_params 
}