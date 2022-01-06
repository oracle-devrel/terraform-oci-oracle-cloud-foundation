resource "null_resource" "dev_mode_provisioning" {

  count = var.mode=="DEV" ? var.numWLSInstances : 0

  provisioner "file" {
    source      = "../infra/target/wlsoci-vmscripts.zip"
    destination = "/tmp/wlsoci-vmscripts.zip"

   /* connection {
      agent       = false
      type = "ssh"
      timeout     = "30m"
      host        = var.host_ips[count.index]
      user        = "opc"
      private_key = var.ssh_private_key
      port = "22"

      bastion_user        = "opc"
      bastion_private_key = var.bastion_host_private_key
      bastion_host        = var.bastion_host
    }*/

    connection {
      type = "ssh"
      timeout     = "30m"
      host        = var.host_ips[count.index]
      user        = "opc"
      private_key = var.ssh_private_key
      port = "22"

      bastion_user        = var.bastion_user
      bastion_private_key = var.bastion_host_private_key
      bastion_host        = var.bastion_host
    }

  }

  provisioner "remote-exec" {
    /*connection {
      agent               = false
      timeout             = "30m"
      host                = var.host_ips[count.index]
      user                = "opc"
      private_key         = var.ssh_private_key
      bastion_user        = "opc"
      bastion_private_key = var.bastion_host_private_key
      bastion_host        = var.bastion_host
    }*/

    connection {
      type = "ssh"
      timeout     = "30m"
      host        = var.host_ips[count.index]
      user        = "opc"
      private_key = var.ssh_private_key
      port = "22"

      bastion_user        = var.bastion_user
      bastion_private_key = var.bastion_host_private_key
      bastion_host        = var.bastion_host
    }

    inline = [
      "sudo unzip  /tmp/wlsoci-vmscripts.zip -d /",
      "sudo chown -R oracle:oracle /opt",
      "sudo chmod +x /opt/scripts/*.sh",
      "sudo mkdir -p /u01",
      "sudo touch /u01/devModeMarker",
    ]
  }
}
