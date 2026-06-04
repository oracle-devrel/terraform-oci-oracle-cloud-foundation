# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "bastions_details" {
  value = {for g in oci_bastion_bastion.these : g.name => g}
}

output "sessions_details" {
  value = {for g in oci_bastion_session.these : g.display_name => g}
}

