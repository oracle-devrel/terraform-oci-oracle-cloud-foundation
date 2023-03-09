# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "null_resource" "sqlcl-create-usr" {

        provisioner "local-exec" {
             command = <<-EOT
                wget https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-21.4.1.17.1458.zip
                unzip sqlcl-21.4.1.17.1458.zip
                echo 'Start running init.sql script'
                ./sqlcl/bin/sql -cloudconfig wallet_${var.db_name}.zip admin/${var.db_password}@'${local.conn_db}' @./scripts/init.sql
                echo 'Start running tables.sql script'
                ./sqlcl/bin/sql -cloudconfig wallet_${var.db_name}.zip moviestream/watchS0meMovies#@'${local.conn_db}' @./tables.sql
                rm -rf sqlcl-21.4.1.17.1458.zip
                rm -rf sqlcl
                rm -rf tables.sql
            EOT
        }

depends_on = [module.adw_database_private_endpoint]

}

resource "local_file" "this" {
  content  = templatefile("./scripts/tables.sql.tmpl", { tag = var.tag, run_post_load_procedures = var.run_post_load_procedures  })
  filename = "./tables.sql"
}