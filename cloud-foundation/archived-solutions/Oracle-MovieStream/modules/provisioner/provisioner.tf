# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "null_resource" "remote-exec" {

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
    source      = "./modules/provisioner/init.sql"
    destination = "/home/opc/init.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

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
    source      = "./modules/provisioner/tables.sql"
    destination = "/home/opc/tables.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }
  
  provisioner "file" {
    destination = "/home/opc/oml_sample.py"
    content = templatefile("./modules/provisioner/oml_sample.py.tpl", {
        db_name    = var.db_name
    })
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    destination = "/home/opc/finalize.sh"
    content = templatefile("./modules/provisioner/finalize.sh.tpl", {
        dbhostname = var.dbhostname
        db_name    = var.db_name
    })
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
      "sudo chmod 777 /tmp/file_envs.sh",
      "sudo chmod 777 /home/opc/init.sql",
      "sudo chmod 777 /home/opc/wallet_${var.db_name}.zip",
      "sudo chmod 777 /home/opc/tables.sql",
      "sudo chmod 777 /home/opc/finalize.sh",
      "sudo chmod 777 /home/opc/oml_sample.py",
      "sudo wget https://objectstorage.us-ashburn-1.oraclecloud.com/n/oradbclouducm/b/data/o/movieapp.zip -P /home/opc/",
      "sudo chmod 777 /home/opc/movieapp.zip",
      "sudo wget https://objectstorage.us-ashburn-1.oraclecloud.com/n/oradbclouducm/b/data/o/oml4py-client-linux-x86_64-1.0.zip -P /home/opc/",
      "sudo chmod 777 /home/opc/oml4py-client-linux-x86_64-1.0.zip",
      "sudo systemctl disable firewalld",
      "sudo systemctl stop firewalld",
      "sudo /bin/yum install -y sqlcl",
      "sudo unzip /home/opc/movieapp.zip",
      "sudo cat /home/opc/src/config.json",
      "sudo chmod +x /home/opc/finalize.sh",
      "sudo export LC_CTYPE=en_US.UTF-8",
      "sudo export LC_ALL=en_US.UTF-8",
      "sudo perl -pi.back -e 's/qggemtywectzfj9-movieapp.adb.sa-saopaulo-1.oraclecloudapps.com/'${var.dbhostname}'/g'  /home/opc/src/config.json",
      "sudo cat /home/opc/src/config.json",
      "sh /tmp/file_envs.sh",
      "echo 'Getting connected'",
      "echo 'Start running init.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip ADMIN/${var.db_password}@'${var.conn_db}' @/home/opc/init.sql",
      "echo 'Start running tables.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip moviestream/watchS0meMovies#@'${var.conn_db}' @/home/opc/tables.sql",
      "echo 'Start running finalize.sql script'",
      "sudo sh /home/opc/finalize.sh",
      "echo 'Start building the docker image and run the container'",
      "sudo docker build -t moviestream/moviestream:1.0 /home/opc/.",
      "sudo docker run -it -p 80:8080 -d --name moviestream moviestream/moviestream:1.0",
      "sudo docker ps",
      "echo 'Finished!'",
    ]
  }
}

