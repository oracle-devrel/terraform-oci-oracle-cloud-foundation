
resource "null_resource" "status_check" {
  count = var.existing_bastion_instance_id != "" ? var.numWLSInstances : 0
  depends_on = [null_resource.dev_mode_provisioning]

  // Connection setup for all WLS instances
  connection {
    agent       = false
    timeout     = "30m"
    host        = var.host_ips[count.index]
    user        = "opc"
    private_key = var.ssh_private_key

    bastion_user        = "opc"
    bastion_private_key = var.bastion_host_private_key
    bastion_host        = var.bastion_host
  }

  // Call check_status.sh 11 more times - if we add additional markers we must add an additional status check call here.
  // Also see - all_markers_list in check_provisioning_status.py for the list of all existing markers.
  // It is OK to call provisioning check more times than there are markers but we should at least call it as many times
  // as there are number of marker files created on VM.

  provisioner "remote-exec" {
    inline = [
      "sudo sh /opt/scripts/check_status.sh",
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }
  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su - oracle -c 'python /opt/scripts/check_provisioning_status.py'",
    ]
  }
}

resource "null_resource" "print_service_info" {

  count = var.existing_bastion_instance_id != "" ? var.numWLSInstances : 0
  depends_on = [null_resource.status_check]

  // Connection setup for all WLS instances
  connection {
    agent       = false
    timeout     = "30m"
    host        = var.host_ips[count.index]
    user        = "opc"
    private_key = var.ssh_private_key

    bastion_user        = "opc"
    bastion_private_key = var.bastion_host_private_key
    bastion_host        = var.bastion_host
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /opt/scripts/service_info.sh",
    ]
  }

}

/* resource "null_resource" "cleanup" {

  count = var.existing_bastion_instance_id != "" ? var.numWLSInstances : 0
  depends_on = [null_resource.print_service_info]


  // Connection setup for all WLS instances
  connection {
    agent       = false
    timeout     = "30m"
    host        = var.host_ips[count.index]
    user        = "opc"
    private_key = var.ssh_private_key

    bastion_user        = "opc"
    bastion_private_key = var.bastion_host_private_key
    bastion_host        = var.bastion_host
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /opt/scripts/delete_keys.sh",
    ]
  }
} */

