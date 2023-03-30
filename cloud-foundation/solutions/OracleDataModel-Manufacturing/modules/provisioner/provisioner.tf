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
    source      = "./modules/provisioner/CREATE_DISCRT_OBJECTS.sql"
    destination = "/home/opc/CREATE_DISCRT_OBJECTS.sql"
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
      "sudo chmod 777 /home/opc/CREATE_DISCRT_OBJECTS.sql",
      "sudo chmod 777 /home/opc/wallet_${var.db_name}.zip",
      "sudo wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/AN3VOdCf83YYUJMZBN-4RZ4kzd0z50ywnDN_RhRvOV5RbWhFLV1_LDvK5nelIuHa/n/oradbclouducm/b/bucket-20200907-1650/o/DISCRT_Manufacturing.zip -P /home/opc/",
      "sudo chmod 777 /home/opc/DISCRT_Manufacturing.zip",
      "sudo unzip /home/opc/DISCRT_Manufacturing.zip",
      "sudo wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/lWyck0UK09gGppE6hMgHQ0C1Utj12xRkkF1F0RaOYJDcCfXE8_DiGDUqls1IO8WJ/n/oradbclouducm/b/bucket-20200907-1650/o/PROCESS_Manufacturing.zip -P /home/opc/",
      "sudo chmod 777 /home/opc/PROCESS_Manufacturing.zip",
      "sudo unzip /home/opc/PROCESS_Manufacturing.zip",
      "sudo chmod 777 /home/opc/DISCRT_DOWNTIME_REASON_CATEGORY2.sql",
      "sudo chmod 777 /home/opc/DISCRT_DOWNTIME.sql",
      "sudo chmod 777 /home/opc/DISCRT_DS_BARIER_OUTLIER.sql",
      "sudo chmod 777 /home/opc/DISCRT_DS_BARIER_RESULT_TOPTEN_PARAMETER.sql",
      "sudo chmod 777 /home/opc/DISCRT_DS_MPARAMETER_OUTLIER.sql",
      "sudo chmod 777 /home/opc/DISCRT_DS_MPARAMETER_TOP_TEN.sql",
      "sudo chmod 777 /home/opc/DISCRT_FACTORY_LOC.sql",
      "sudo chmod 777 /home/opc/DISCRT_G2_REJECTION.sql",
      "sudo chmod 777 /home/opc/DISCRT_MACHINE_LOG.sql",
      "sudo chmod 777 /home/opc/DISCRT_MLOG_UOM.sql",
      "sudo chmod 777 /home/opc/DISCRT_OPM_DETAILS.sql",
      "sudo chmod 777 /home/opc/DISCRT_OPM_MASTER.sql",
      "sudo chmod 777 /home/opc/DISCRT_POWER_GAS_CONSUMPTION.sql",
      "sudo chmod 777 /home/opc/DISCRT_QUALITY_CONTROL.sql",
      "sudo chmod 777 /home/opc/DISCRT_QUALITY_PIVOT.sql",
      "sudo chmod 777 /home/opc/DISCRT_TORQUE_CURRENT.sql",
      "sudo chmod 777 /home/opc/PROCESS_DDL.sql",
      "sudo chmod 777 /home/opc/PROCESS_INSERT_SCRIPTS.sql",
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
      "sudo /bin/yum install -y sqlcl",
      "sh /tmp/file_envs.sh",
      "echo 'Getting connected'",
      "echo 'Start running CREATE_DISCRT_OBJECTS.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip ADMIN/${var.db_password}@'${var.conn_db}' @/home/opc/CREATE_DISCRT_OBJECTS.sql",
      "echo 'Start running DISCRT_DOWNTIME_REASON_CATEGORY2.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_DOWNTIME_REASON_CATEGORY2.sql",
      "echo 'Start running DISCRT_DOWNTIME.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_DOWNTIME.sql",
      "echo 'Start running DISCRT_DS_BARIER_OUTLIER.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_DS_BARIER_OUTLIER.sql",
      "echo 'Start running DISCRT_DS_BARIER_RESULT_TOPTEN_PARAMETER.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_DS_BARIER_RESULT_TOPTEN_PARAMETER.sql",
      "echo 'Start running DISCRT_DS_MPARAMETER_OUTLIER.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_DS_MPARAMETER_OUTLIER.sql",
      "echo 'Start running DISCRT_DS_MPARAMETER_TOP_TEN.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_DS_MPARAMETER_TOP_TEN.sql",
      "echo 'Start running DISCRT_FACTORY_LOC.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_FACTORY_LOC.sql",
      "echo 'Start running DISCRT_G2_REJECTION.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_G2_REJECTION.sql",
      "echo 'Start running DISCRT_MACHINE_LOG.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_MACHINE_LOG.sql",
      "echo 'Start running DISCRT_MLOG_UOM.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_MLOG_UOM.sql",
      "echo 'Start running DISCRT_OPM_DETAILS.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_OPM_DETAILS.sql",
      "echo 'Start running DISCRT_OPM_MASTER.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_OPM_MASTER.sql",
      "echo 'Start running DISCRT_POWER_GAS_CONSUMPTION.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_POWER_GAS_CONSUMPTION.sql",
      "echo 'Start running DISCRT_QUALITY_CONTROL.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_QUALITY_CONTROL.sql",
      "echo 'Start running DISCRT_QUALITY_PIVOT.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_QUALITY_PIVOT.sql",
      "echo 'Start running DISCRT_TORQUE_CURRENT.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip DISCRT/Welcome#1234@'${var.conn_db}' @/home/opc/DISCRT_TORQUE_CURRENT.sql",
      "echo 'Start running PROCESS_DDL.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip PROCESS/Welcome#1234@'${var.conn_db}' @/home/opc/PROCESS_DDL.sql",
      "echo 'Start running PROCESS_INSERT_SCRIPTS.sql script'",
      "sql -cloudconfig wallet_${var.db_name}.zip PROCESS/Welcome#1234@'${var.conn_db}' @/home/opc/PROCESS_INSERT_SCRIPTS.sql",
      "echo 'Finished!'",
    ]
  }
}