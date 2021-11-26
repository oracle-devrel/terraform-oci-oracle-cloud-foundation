resource "null_resource" "status_check" {

  count = var.numWLSInstances
  depends_on = [null_resource.dev_mode_provisioning]

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

  count = var.numWLSInstances
  depends_on = [null_resource.status_check]

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

