resource "oci_bastion_bastion" "these" {
  for_each = var.bastions  
    bastion_type     = "STANDARD"
    compartment_id   = each.value.compartment_id
    target_subnet_id = each.value.target_subnet_id
    name             = each.value.name
    client_cidr_block_allow_list = each.value.client_cidr_block_allow_list
    max_session_ttl_in_seconds   = each.value.max_session_ttl_in_seconds
}

resource "oci_bastion_session" "session" {

   for_each = var.sessions 

    bastion_id = each.value.bastion_id
  
    key_details {   
        public_key_content = each.value.ssh_public_key
    }

  target_resource_details {

    session_type       = each.value.session_type
    target_resource_id = each.value.private_instance_id

    target_resource_operating_system_user_name = each.value.user_name
    target_resource_port                       = each.value.port
    target_resource_private_ip_address = each.value.private_ip_address
  }

  session_ttl_in_seconds = 3600

  display_name = each.value.display_name
}