output "id" {
  value = "${module.bastion_instance.InstanceOcids[0]}"
}

output "display_name" {
  value = "${module.bastion_instance.display_names[0]}"
}

output "publicIp" {
  value = "${module.bastion_instance.InstancePublicIPs[0]}"
}

output "privateIp" {
  value = "${module.bastion_instance.InstancePrivateIPs[0]}"
}

output "privateKey" {
  value = local.bastion_private_ssh_key
}

resource "local_file" "private_key" {
    content  = local.bastion_private_ssh_key
    filename = "private_key.pem"
}

