# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "datacatalog" {
  value = {
    for datacatalog in oci_datacatalog_catalog.this:
      datacatalog.display_name => datacatalog.display_name
  }
}

