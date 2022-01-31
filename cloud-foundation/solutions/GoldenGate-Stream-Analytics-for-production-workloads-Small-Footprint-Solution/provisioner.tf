# Copyright © 2022, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


locals {
  MountTargetIP = module.fss.mount_targets["GGSMT"]
  WebTierandBastion = module.compute.all_public_ips["Web-Tier-and-Bastion"]
  Master1 = module.compute.all_private_ips["ggsa-ha-master1"]
  Master2 = module.compute.all_private_ips["ggsa-ha-master2"]
  Worker1 = module.compute.all_private_ips["ggsa-ha-worker1"]
  Worker2 = module.compute.all_private_ips["ggsa-ha-worker2"]
  Worker3 = module.compute.all_private_ips["ggsa-ha-worker3"]
}


# Workers provisioner

resource "null_resource" "Worker1-init-kafka-zk" {
  depends_on = [module.compute, module.fss]
  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = local.Worker1
      private_key         = module.keygen.OPCPrivateKey["private_key_pem"]
      agent               = false
      timeout             = "2m"
      bastion_host        = local.WebTierandBastion
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = module.keygen.OPCPrivateKey["private_key_pem"]
    }
    inline = [
      "echo Connected on Worker1! ",
      "bash $OSA_HOME/osa-base/bin/init-kafka-zk.sh 1 ${local.MountTargetIP} ${local.Worker1} ${local.Worker2} ${local.Worker3}",
      "bash $OSA_HOME/osa-base/bin/init-spark-slave.sh ${local.MountTargetIP} ${local.Master1} ${local.Master2}",
        ]
  }  
}

resource "null_resource" "Worker2-init-kafka-zk" {
  depends_on = [module.compute, module.fss]
  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = local.Worker2
      private_key         = module.keygen.OPCPrivateKey["private_key_pem"]
      agent               = false
      timeout             = "2m"
      bastion_host        = local.WebTierandBastion
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = module.keygen.OPCPrivateKey["private_key_pem"]
    }
    inline = [
      "echo Connected on Worker2! ",
      "bash $OSA_HOME/osa-base/bin/init-kafka-zk.sh 2 ${local.MountTargetIP} ${local.Worker1} ${local.Worker2} ${local.Worker3}",
      "bash $OSA_HOME/osa-base/bin/init-spark-slave.sh ${local.MountTargetIP} ${local.Master1} ${local.Master2}",
        ]
  }  
}

resource "null_resource" "Worker3-init-kafka-zk" {
  depends_on = [module.compute, module.fss]
  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = local.Worker3
      private_key         = module.keygen.OPCPrivateKey["private_key_pem"]
      agent               = false
      timeout             = "2m"
      bastion_host        = local.WebTierandBastion
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = module.keygen.OPCPrivateKey["private_key_pem"]
    }
    inline = [
      "echo Connected on Worker3! ",
      "bash $OSA_HOME/osa-base/bin/init-kafka-zk.sh 3 ${local.MountTargetIP} ${local.Worker1} ${local.Worker2} ${local.Worker3}",
      "bash $OSA_HOME/osa-base/bin/init-spark-slave.sh ${local.MountTargetIP} ${local.Master1} ${local.Master2}",
        ]
  }  
}


# Masters provisioner

resource "null_resource" "Master1-init-spark-master" {
  depends_on = [null_resource.Worker1-init-kafka-zk, null_resource.Worker2-init-kafka-zk, null_resource.Worker3-init-kafka-zk]
  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = local.Master1
      private_key         = module.keygen.OPCPrivateKey["private_key_pem"]
      agent               = false
      timeout             = "2m"
      bastion_host        = local.WebTierandBastion
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = module.keygen.OPCPrivateKey["private_key_pem"]
    }
    inline = [
      "echo Connected on Master1! ",
      "bash /u01/app/osa/osa-base/bin/init-spark-master.sh ${local.MountTargetIP} ${local.Worker1} ${local.Worker2} ${local.Worker3}",
        ]
    on_failure = continue
  }  
}

resource "null_resource" "Master2-init-spark-master" {
  depends_on = [null_resource.Worker1-init-kafka-zk, null_resource.Worker2-init-kafka-zk, null_resource.Worker3-init-kafka-zk, null_resource.Master1-init-spark-master]
  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = local.Master2
      private_key         = module.keygen.OPCPrivateKey["private_key_pem"]
      agent               = false
      timeout             = "2m"
      bastion_host        = local.WebTierandBastion
      bastion_port        = "22"
      bastion_user        = "opc"
      bastion_private_key = module.keygen.OPCPrivateKey["private_key_pem"]
    }
    inline = [
      "echo Connected on Master2! ",
      "bash $OSA_HOME/osa-base/bin/init-spark-master.sh ${local.MountTargetIP} ${local.Worker1} ${local.Worker2} ${local.Worker3} ",
        ]
    on_failure = continue
  }  
}


# WebTierandBastion provisioner

resource "null_resource" "WebTierandBastion-init-web-tier" {
  depends_on = [null_resource.Master1-init-spark-master, null_resource.Master2-init-spark-master]
   provisioner "remote-exec" {
    connection {
      agent               = false
      timeout             = "30m"
      host                = local.WebTierandBastion
      user                = "opc"
      bastion_user        = "opc"
      private_key         = module.keygen.OPCPrivateKey["private_key_pem"]
      bastion_host        = local.WebTierandBastion
    }

    inline = [
      "echo Connected on WebTierandBastion! ",
      "sudo -s bash $OSA_HOME/osa-base/bin/init-web-tier.sh ${local.MountTargetIP} ${local.Master1} ${local.Master2} ${local.Worker1} ${local.Worker2} ${local.Worker3} ",
      "echo Deployment and configuration FINISHED! ",
      "echo Deployment and configuration FINISHED! ",
      "echo Deployment and configuration FINISHED! ",
      "echo Below are the credentials to connect to the solution!",
      "cat /home/opc/README.txt"
    ]
  }
}

