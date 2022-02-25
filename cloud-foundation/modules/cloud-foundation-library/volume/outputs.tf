# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "DataVolumeOcids" {
  value = [ for b in oci_core_volume.these : b.id]
}