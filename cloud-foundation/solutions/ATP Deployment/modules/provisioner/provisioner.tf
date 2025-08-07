# Copyright © 2025, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


resource "null_resource" "remote-exec" {


  provisioner "file" {
    source      = "wallet_${var.db_name}.zip"
    destination = "/home/opc/wallet_${var.db_name}.zip"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "./modules/provisioner/file_envs.sh"
    destination = "/tmp/file_envs.sh"

    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }

  }

  provisioner "file" {
    source      = "./modules/provisioner/script_provisioning.sql"
    destination = "/home/opc/script_provisioning.sql"

    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }

  }

  provisioner "file" {
    source      = "./modules/provisioner/f101.sql"
    destination = "/home/opc/f101.sql"

    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }

  }
  
  provisioner "remote-exec" {

    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  
    inline = [
      "sudo /bin/yum install -y nginx",
      "sudo /bin/systemctl start nginx",
      "sudo /bin/firewall-offline-cmd --add-port=80/tcp",
      "sudo /bin/systemctl restart firewalld",
      "sudo cp /usr/share/nginx/html/index.html /usr/share/nginx/html/index.original.html",
      "sudo chmod 777 /usr/share/nginx/html/index.html",
      "echo '<html><h1> Hello, Web Server! </h1>' > /usr/share/nginx/html/index.html",
      "echo '<h2> Accessing from Web Server pre-deployed REST services on the ATP database. </h2>' >> /usr/share/nginx/html/index.html",
      "sudo /bin/yum install -y java-1.8.0-openjdk sqlcl",
      "sudo chmod 777 /tmp/file_envs.sh",
      "sudo chmod 777 /home/opc/wallet_${var.db_name}.zip",
      "sudo chmod 777 /home/opc/script_provisioning.sql",
      "sudo chmod 777 /home/opc/f101.sql",
      "sh /tmp/file_envs.sh",
      "echo 'Getting connected'",
      "sql -cloudconfig wallet_${var.db_name}.zip ADMIN/${var.db_password}@'${var.conn_db}' @/home/opc/script_provisioning.sql",
      "sql -cloudconfig wallet_${var.db_name}.zip USER_WORKSHOP/AaBbCcDdEe123!@'${var.conn_db}' @/home/opc/f101.sql",
      "echo 'Connected'",
      "echo ${var.atp_url.adw}",
      "curl -X GET -u 'USER_WORKSHOP:AaBbCcDdEe123!' -H 'Content-Type: application/json' '${var.atp_url.adw}/r/workshop/hellouser' >> /usr/share/nginx/html/index.html",
    ]
  }
}
