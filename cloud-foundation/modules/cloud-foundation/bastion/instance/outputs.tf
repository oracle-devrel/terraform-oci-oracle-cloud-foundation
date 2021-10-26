
# Output the private and public IPs of the instance
output "InstancePrivateIPs" {
  value = [ for b in oci_core_instance.instance : b.private_ip]
}

output "InstancePublicIPs" {
  value = [ for b in oci_core_instance.instance : b.public_ip]
}

output "InstanceOcids" {
  value = [ for b in oci_core_instance.instance : b.id]
}

output "display_names" {
  value = [ for b in oci_core_instance.instance : b.display_name]
}

output "InstanceShapes" {
  value = [ for b in oci_core_instance.instance : b.shape]
}

output "AvailabilityDomains" {
  value = [ for b in oci_core_instance.instance : b.availability_domain]
}