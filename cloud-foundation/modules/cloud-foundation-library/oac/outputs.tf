# Copyright © 2021, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "Analytics_URL" {
  value = join(", ", [for x in oci_analytics_analytics_instance.oac : x.service_url])
}

