# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Calling the External Databases module

module "external_db" {
  source = "../../../cloud-foundation/modules/cloud-foundation-library/database/oci_external_databases"
  register_external_container_db  = local.register_external_container_db
  register_external_pluggable_db  = local.register_external_pluggable_db
  connector_external_container_db = local.connector_external_container_db
  connector_external_pluggable_db = local.connector_external_pluggable_db
}



