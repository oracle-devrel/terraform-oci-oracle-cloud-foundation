# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "Analytics_URL" {
  value = [ for x in oci_analytics_analytics_instance.this : x.service_url]
}

output "oci_analytics_analytics_instance_private_access_channel" {
value = oci_analytics_analytics_instance_private_access_channel.this
}

output "private_endpoint_ip" {
  value = one([for b in oci_analytics_analytics_instance_private_access_channel.this : b.ip_address])
}


