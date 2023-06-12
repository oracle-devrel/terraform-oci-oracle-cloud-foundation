# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "datacatalog" {
  value = {
    for datacatalog in oci_datacatalog_catalog.this:
      datacatalog.display_name => datacatalog.display_name
  }
}

output "datacatalog_data_asset_adw" {
  value = {
    for datacatalog_data_asset in oci_datacatalog_data_asset.this:
      datacatalog_data_asset.display_name => datacatalog_data_asset.display_name
  }
}

output "datacatalog_data_asset_object_storage" {
  value = {
    for datacatalog_data_asset in oci_datacatalog_data_asset.that:
      datacatalog_data_asset.display_name => datacatalog_data_asset.display_name
  }
}
