# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "cname" {
  value = { for waas in oci_waas_waas_policy.this :
    waas.display_name => waas.cname
  }
}

output "waas" {
  value = { for waas in oci_waas_waas_policy.this :
    waas.display_name => waas.id
  }
}
