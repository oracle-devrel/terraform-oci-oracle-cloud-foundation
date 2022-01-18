# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "mysql_instances" {
  value = {
    for instance in oci_mysql_mysql_db_system.this:
      instance.display_name => { "display_name" : instance.display_name, "id" : instance.id, "ip": instance.ip_address, "compartment_id": instance.compartment_id }
  }
}

output "mysql_credentials" {
  value = {
    for credentials in var.mysql_params:
      credentials.display_name => { "username" : credentials.admin_username, "password" : credentials.admin_password }
  }
}

output "mysql_heat_wave_cluster" {
  value = {
    for instance in oci_mysql_heat_wave_cluster.this:
       instance.cluster_size => { "cluster_size" : instance.cluster_size, "id" : instance.id }
  }
}