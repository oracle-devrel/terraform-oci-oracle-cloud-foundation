# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "null_resource" "remote-exec" {

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
      "echo '<h3> Adding an orange fruit via curl using REST service and query the result: <div>' >> /usr/share/nginx/html/index.html",
      "curl -X PUT -u 'ADMIN:${var.db_password}' '${var.atp_url}/admin/soda/latest/fruit'",
      "curl -X POST -u 'ADMIN:${var.db_password}' -H 'Content-Type: application/json' --data '{\"name\":\"orange\", \"count\":42}' '${var.atp_url}/admin/soda/latest/fruit'",
      "curl -X POST -u 'ADMIN:${var.db_password}' -H 'Content-Type: application/json' --data '{\"name\":\"orange\"}' '${var.atp_url}/admin/soda/latest/fruit?action=query' >> /usr/share/nginx/html/index.html",
      "echo '</div></h3></html>' >> /usr/share/nginx/html/index.html"
    ]
  }
}
