# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "odi" {
  value = {
    for odi in oci_dataintegration_workspace.this:
      odi.display_name => odi.display_name
  }
}