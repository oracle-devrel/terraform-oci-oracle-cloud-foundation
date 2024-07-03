# Copyright © 2024, Oracle and/or its affiliates.
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
    destination = "/home/opc/bastion_environment.sh"
    content = templatefile("./modules/provisioner/bastion_environment.sh.tpl", {
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

 provisioner "file" {
    destination = "/home/opc/ADW_CREATE_CREDENTIAL.sql"
    content = templatefile("./modules/provisioner/ADW_CREATE_CREDENTIAL.sql.tpl", {
        db_password = var.db_password
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
    destination = "/home/opc/CREATE_USERS.sql"
    content = templatefile("./modules/provisioner/CREATE_USERS.sql.tpl", {
        db_password = var.db_password
        llmpw       = var.llmpw
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
    destination = "/home/opc/COMMS_LAKEHOUSE_TELECOM_TOWER_dumps.sh"
    content = templatefile("./modules/provisioner/COMMS_LAKEHOUSE_TELECOM_TOWER_dumps.sh.tpl", {
        db_name     = var.db_name
        db_password = var.db_password
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
    destination = "/home/opc/LISA_JONES_dumps.sh"
    content = templatefile("./modules/provisioner/LISA_JONES_dumps.sh.tpl", {
        db_name     = var.db_name
        db_password = var.db_password
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
    source      = "./modules/provisioner/COMMS_LAKEHOUSE_TELECOM_TOWER.sql"
    destination = "/home/opc/COMMS_LAKEHOUSE_TELECOM_TOWER.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "./modules/provisioner/LISA_JONES.sql"
    destination = "/home/opc/LISA_JONES.sql"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  # provisioner "file" {
  #   source      = "./modules/provisioner/OML_USER_GRANTS.sql"
  #   destination = "/home/opc/OML_USER_GRANTS.sql"
  #   connection {
  #     agent       = false
  #     timeout     = "30m"
  #     host        = var.host
  #     user        = "opc"
  #     private_key = var.private_key
  #   }
  # }

  provisioner "file" {
    source      = "./modules/provisioner/SYNONYM_DMISHRA.sql"
    destination = "/home/opc/SYNONYM_DMISHRA.sql"
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
    source      = "./modules/provisioner/registermy_snapshot.json"
    destination = "/home/opc/registermy_snapshot.json"
    connection {
      agent       = false
      timeout     = "30m"
      host        = var.host
      user        = "opc"
      private_key = var.private_key
    }
  }

  provisioner "file" {
    source      = "./modules/provisioner/restore_mysnapshot.json"
    destination = "/home/opc/restore_mysnapshot.json"
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
        Oracle_Analytics_Instance_Name = var.Oracle_Analytics_Instance_Name
        Tenancy_Name = var.Tenancy_Name
        bucket = var.bucket
        Authorization_Token = var.Authorization_Token
        ociRegion = var.ociRegion
        ociTenancyId = var.ociTenancyId
        ociUserId = var.ociUserId
        ociKeyFingerprint = var.ociKeyFingerprint
        ociPrivateKeyWrapped = var.ociPrivateKeyWrapped
        home_region_for_oac = var.home_region_for_oac
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
    destination = "/home/opc/config"
    content = templatefile("./modules/provisioner/config.tpl", {
        ociUserId = var.ociUserId
        ociKeyFingerprint = var.ociKeyFingerprint
        ociTenancyId = var.ociTenancyId
        ociRegion = var.ociRegion
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
    source      = "./oci_api_key.pem"
    destination = "/home/opc/oci_api_key.pem"
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
      "sudo chmod 777 /home/opc/bastion_environment.sh",
      "sudo chmod 777 /home/opc/ADW_CREATE_CREDENTIAL.sql",
      "sudo chmod 777 /home/opc/CREATE_USERS.sql",
      "sudo chmod 777 /home/opc/COMMS_LAKEHOUSE_TELECOM_TOWER_dumps.sh",
      "sudo chmod 777 /home/opc/LISA_JONES_dumps.sh",
      "sudo chmod 777 /home/opc/COMMS_LAKEHOUSE_TELECOM_TOWER.sql",
      "sudo chmod 777 /home/opc/LISA_JONES.sql",
      # "sudo chmod 777 /home/opc/OML_USER_GRANTS.sql",
      "sudo chmod 777 /home/opc/SYNONYM_DMISHRA.sql",
      "sudo chmod 777 /home/opc/wallet_${var.db_name}.zip",
      "sudo mkdir /home/opc/.oci",
      "sudo chmod 777 -R /home/opc/.oci",
      "sudo chmod 777 -R /home/opc/.oci/*",
      "sudo chown -R opc:opc /home/opc/.oci",
      "sudo chown -R opc:opc -R /home/opc/.oci/*",
      "sudo mv /home/opc/config /home/opc/.oci",
      "sudo mv /home/opc/oci_api_key.pem /home/opc/.oci",
      "sudo chmod 777 /home/opc/.oci/oci_api_key.pem",
      "sudo chmod 777 /home/opc/.oci/config",
      "sudo chmod +x /home/opc/finalize.sh",
      "oci setup repair-file-permissions --file /home/opc/.oci/config",
      "oci setup repair-file-permissions --file /home/opc/.oci/oci_api_key.pem",
      "sudo systemctl disable firewalld",
      "sudo systemctl stop firewalld",
      "sh /tmp/file_envs.sh",
      "sh /home/opc/bastion_environment.sh",
      "echo 'Getting connected'",
      "echo 'Start running ADW_CREATE_CREDENTIAL.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip ADMIN/${var.db_password}@'${var.conn_db}' @/home/opc/ADW_CREATE_CREDENTIAL.sql",
      "export LC_CTYPE=en_US.UTF-8",
      "export LC_ALL=en_US.UTF-8",
      "export TNS_ADMIN=/home/opc/mywalletdir",
      "echo 'Start creating additional users'",
      "sql -cloudconfig wallet_${var.db_name}.zip ADMIN/${var.db_password}@'${var.conn_db}' @/home/opc/CREATE_USERS.sql",
      "echo 'Start importing dumps for LISA_JONES schemas'",
      "sh /home/opc/LISA_JONES_dumps.sh",
      "echo 'Start importing dumps for COMMS_LAKEHOUSE_TELECOM_TOWER schema'",
      "sh /home/opc/COMMS_LAKEHOUSE_TELECOM_TOWER_dumps.sh",
      "sql -cloudconfig wallet_${var.db_name}.zip ADMIN/${var.db_password}@'${var.conn_db}' @/home/opc/LISA_JONES.sql",
      "sql -cloudconfig wallet_${var.db_name}.zip ADMIN/${var.db_password}@'${var.conn_db}' @/home/opc/COMMS_LAKEHOUSE_TELECOM_TOWER.sql",
      # "sql -cloudconfig wallet_${var.db_name}.zip ADMIN/${var.db_password}@'${var.conn_db}' @/home/opc/OML_USER_GRANTS.sql",
      "sql -cloudconfig wallet_${var.db_name}.zip ADMIN/${var.db_password}@'${var.conn_db}' @/home/opc/SYNONYM_DMISHRA.sql",
      "echo 'Finished!'",
    ]
  }
}

