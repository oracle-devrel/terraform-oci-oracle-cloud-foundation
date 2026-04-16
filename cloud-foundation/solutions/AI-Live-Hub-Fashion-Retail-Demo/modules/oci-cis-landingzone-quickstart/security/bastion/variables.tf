# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "bastions" {
    description = "Details of the Bastion resources to be created."
    type = map(object({
      name = string,
      compartment_id = string,
      target_subnet_id = string,
      client_cidr_block_allow_list = list(string),
      max_session_ttl_in_seconds = number
    }))
}

variable "sessions" {
    description = "Details of sessions to be created."
    type = map(object({
      session_type = string,
      bastion_id = string,
      ssh_public_key = string,
      private_instance_id = string,
      private_ip_address = string,
      user_name = string,
      port = string,
      display_name = string
    }))
}