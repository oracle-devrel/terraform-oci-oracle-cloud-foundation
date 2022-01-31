# # Copyright © 2022, Oracle and/or its affiliates.
# # All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "ADW_Service_Console_URL" {
  value = module.adw.ADW_Service_Console_URL
}

output "Analytics_URL" {
  value = module.oac.Analytics_URL
}

output "Instructions" {
  value = "Please use the ADW URL to login by using the user admin and the password that you have provided."
}
