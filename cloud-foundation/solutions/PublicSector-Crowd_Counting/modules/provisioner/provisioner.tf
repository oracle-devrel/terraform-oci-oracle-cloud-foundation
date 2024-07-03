# Copyright © 2024, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "null_resource" "remote-exec" {

 provisioner "file" {
    destination = "/home/opc/db.yaml"
    content = templatefile("./modules/provisioner/db.yaml.tpl", {
        db_name     = var.db_name
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
      "sudo chmod 777 /home/opc/db.yaml",
      "sudo chmod 777 /home/opc/wallet_${var.db_name}.zip",
      "sudo cd /home/opc",
      "echo 'Getting connected'",
      "sudo wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/9beXHZeJ9N3O_O9SF1NDGAs6TQHe_rJ1ajuYqIX171krgSixV1pWxgQElaAVV3Xp/n/oradbclouducm/b/Crowdcount/o/yolo-crowdcount.zip",
      "sudo wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/gsfEHMYLyva7ha6gutF1lV0D8dFaIZ_i-oZFvbc63UiJPvtq6SKBfpKcEL0mD-LD/n/oradbclouducm/b/Crowdcount/o/yolo-crowdcount-footage.zip",
      "sudo unzip yolo-crowdcount.zip",
      "sudo unzip yolo-crowdcount-footage.zip",
      "sudo chmod 777 -R yolo-crowdcount",
      "sudo chmod 777 -R yolo-crowdcount-footage",


# Crowd Counting Demo with Pre-Captured Video (Shibuya Crossing)
# Standalone Application (No IP camera, ADB, Analytics instances required)


      "echo 'Collecting the datasets for the Crowd Counting Demo'",
      "sudo docker ps -a",
      "sudo docker build -t yolo-crowdcount /home/opc/yolo-crowdcount/. ",
      "sudo wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/e-UegVw-ryiOlNh7di-7opBB5poBUy65s_GJLBeXTHmAQG6ryY8yQ3FabavOJIbx/n/oradbclouducm/b/Crowdcount/o/Camera1.mp4",
      "sudo wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/5_XgriKM00UkErwAFHYj5LdHaUWvxUAcClMW380MfIm1iz-2aMj2mSOoJDslz_Bz/n/oradbclouducm/b/Crowdcount/o/Camera2.mp4",
      "sudo wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/fvfaPVAc2sGjfoOPmR2JdLgcbHN_HqR-rRzKkPxs7V8H9CMeEe3pnqoDzu4d5tNY/n/oradbclouducm/b/Crowdcount/o/Camera3.mp4",
      "sudo mkdir datasets",
      "sudo mv Camera1.mp4 Camera2.mp4 Camera3.mp4 datasets/",
      "sudo chmod 777 -R /home/opc/datasets",
      "echo 'Deploying the Crowd Counting Demo with Pre-Captured Video'",
      "sudo mkdir /home/opc/yolo-crowdcount/log",
      "sudo chmod 777 -R /home/opc/yolo-crowdcount/log",
      # "sudo docker run -d --gpus all -p 5000:5000 -v /home/opc/datasets:/usr/src/datasets -v /home/opc/yolo-crowdcount/app:/usr/src/app -v /home/opc/yolo-crowdcount/log:/usr/src/log --name=crowdmon --net=host --ipc=host -it -t yolo-crowdcount",
      "sudo docker run -d --gpus all -p 5000:5000 -v /home/opc/datasets:/usr/src/datasets -v /home/opc/yolo-crowdcount/app:/usr/src/app -v /home/opc/yolo-crowdcount/log:/usr/src/log --name=crowdmon --net=host --ipc=host -it -t localhost/yolo-crowdcount:latest",


# Yolo-crowdcount-footage
# Crowd Monitoring Demo with IP Camera
# Require an access to IP Cameras(RTSP), Autonomous DB
# Data in ADB can be utilized by OCI Analytics and Select AI demo  


      "echo 'Deploying the Crowd Monitoring Demo with IP Camera, Cameras(RTSP), Autonomous DB, Data in ADB can be utilized by OCI Analytics and Select AI demo'",
      "sudo cd /home/opc/yolo-crowdcount-footage",
      "sudo mkdir /home/opc/yolo-crowdcount-footage/app/log",
      "sudo mkdir /home/opc/yolo-crowdcount-footage/app/datasets",
      "sudo cp /home/opc/datasets/* /home/opc/yolo-crowdcount-footage/app/datasets",
      "sudo chmod 777 /home/opc/yolo-crowdcount-footage/app/log",
      "sudo chmod 777 /home/opc/yolo-crowdcount-footage/app/datasets",
      "sudo chmod 777 /home/opc/yolo-crowdcount-footage/",
      "sudo mkdir /home/opc/yolo-crowdcount-footage/app/wallet",
      "sudo cp /home/opc/wallet_${var.db_name}.zip /home/opc/yolo-crowdcount-footage/app/wallet",
      "sudo cd /home/opc/yolo-crowdcount-footage/app/wallet",
      "sudo unzip /home/opc/yolo-crowdcount-footage/app/wallet/wallet_${var.db_name}.zip -d /home/opc/yolo-crowdcount-footage/app/wallet/",
      "sudo chmod 777 /home/opc/yolo-crowdcount-footage/app/wallet",
      "sudo chmod 777 /home/opc/yolo-crowdcount-footage/app/wallet/*",
      "sudo mv /home/opc/db.yaml /home/opc/yolo-crowdcount-footage/app/",
      "sudo cd /home/opc/yolo-crowdcount-footage/schema",
      "sudo docker build -t sqlclient /home/opc/yolo-crowdcount-footage/schema/. ",
      "sudo sh -x /home/opc/yolo-crowdcount-footage/schema/create_all.sh",
      "sudo docker build -t yolo-crowdcount-footage /home/opc/yolo-crowdcount-footage/app/. ",
      # "sudo docker run -d --gpus all -p 5001:5001 -v /home/opc/yolo-crowdcount-footage/app:/workspace/app --name=crowdmon-footage --net=host --ipc=host -it -t yolo-crowdcount-footage",
      "sudo docker run -d --gpus all -p 5001:5001 -v /home/opc/yolo-crowdcount-footage/app:/workspace/app --name=crowdmon-footage --net=host --ipc=host -it -t localhost/yolo-crowdcount-footage:latest",


# OAC configuration to restore the screenshoot


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


    ]
  }
}


# ########################################################################################################
# Aditional checks for Yolo-crowdcount-footage
# Crowd Monitoring Demo with IP Camera
# Require an access to IP Cameras(RTSP), Autonomous DB
# Data in ADB can be utilized by OCI Analytics and Select AI demo 
# ########################################################################################################


# Check schema
# $ cd /home/opc/yolo-crowdcount-footage/schema/
# $ ./sqlplus.sh
# SQL> select count(*) from personcount;   -> this returns 0
# SQL> select count(*) from cam_points;    -> this returns 20
# SQL> exit


# Check logs
# $ tail home/opc/yolo-crowdcount-footage/app/log/app.log
# [2024-06-12 17:07:52,862] INFO: Starting camera thread.
# [2024-06-12 17:07:52,866] INFO: Starting camera thread.
# [2024-06-12 17:07:52,866] INFO: Starting YOLO thread.
# [2024-06-12 17:07:52,866] INFO: Starting YOLO thread.
# [2024-06-12 17:08:55,559] INFO: DB insert, RowCount = 10
# [2024-06-12 17:08:55,561] INFO: DB insert, RowCount = 10
#   :
#   :


# Check DB Please check personcount table. 20 rows should be inserted every minute.
# $ tail home/opc/yolo-crowdcount-footage/schema/sqlplus.sh
# SQL> select count(*) from personcount;

#   COUNT(*)
# ----------
#        180


# ########################################################################################################
# SELECT AI:
# ########################################################################################################
# To use the select ai - you need to connect to the ADW with sql developer and run:
# EXEC DBMS_CLOUD_AI.SET_PROFILE('DEMO');
# After that you can run the select ai, here are some examples:

# select ai how many people seen on the camera was more than 20;
# select ai how many people seen on the camera was more than 300;
# select ai what are my cameras names;
# select ai what are my cam points;
# select ai what are the coordinates for the camera Shibuya Crossing;

# select ai narrate how many people seen on the camera was more than 300;
# select ai showsql how many people seen on the camera was more than 300;

# you can use any of the followings attributes for select ai:
# showsql
# narrate
# chat
# runsql