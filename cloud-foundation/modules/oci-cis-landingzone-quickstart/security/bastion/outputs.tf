output "bastions_details" {
  value = {for g in oci_bastion_bastion.these : g.name => g}
}

output "sessions_details" {
  value = {for g in oci_bastion_session.session : g.display_name => g}
}

