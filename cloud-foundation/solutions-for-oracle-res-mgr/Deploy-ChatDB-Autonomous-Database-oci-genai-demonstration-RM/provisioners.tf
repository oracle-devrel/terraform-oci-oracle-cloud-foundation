# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "null_resource" "sqlcl-create-usr" {

        provisioner "local-exec" {
             command = <<-EOT

                echo 'Download the apex applications'
                chmod 777 ./scripts/
                # wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/6Oy9O8JVmddTzPQ8PsavtpzByQhjo4jGP1mRC3MK3o7QE7vGXKb8573-6etTdGUy/n/c4u04/b/building_blocks_utilities/o/select-ai-apex-demo/f101.sql -P ./scripts/
                wget https://github.com/oracle-devrel/oracle-autonomous-database-samples/blob/main/apex/select-ai-chat/f101.sql?raw=true -P ./scripts/
                wget https://objectstorage.us-ashburn-1.oraclecloud.com/p/6Oy9O8JVmddTzPQ8PsavtpzByQhjo4jGP1mRC3MK3o7QE7vGXKb8573-6etTdGUy/n/c4u04/b/building_blocks_utilities/o/select-ai-apex-demo/f100-genai-project.sql -P ./scripts/

                # install the data
      
                sql -cloudconfig wallet_${var.db_name}.zip admin/${var.db_password}@'${local.conn_db}' @./scripts/init.sql
                
                echo 'Start running install-apex-workspace.sql script'
                sql -cloudconfig wallet_${var.db_name}.zip admin/${var.db_password}@'${local.conn_db}' @./scripts/install-apex-workspace.sql

                echo 'Start running tables.sql script to install data sets'
                sql -cloudconfig wallet_${var.db_name}.zip moviestream/watchS0meMovies#@'${local.conn_db}' @./tables.sql

                echo 'Start running install-apex-app.sql script to install the apex app'
                sql -cloudconfig wallet_${var.db_name}.zip moviestream/watchS0meMovies#@'${local.conn_db}' @./scripts/install-apex-app.sql

                rm -rf tables.sql
                rm -rf ./scripts/f100-genai-project.sql
                rm -rf ./scripts/f101.sql?raw=true
                rm -rf ./scripts/install-apex-app.sql
            EOT
        }
depends_on = [module.adb]
}

resource "local_file" "this" {
  content  = templatefile("./scripts/tables.sql.tmpl", { tag = var.tag, run_post_load_procedures = var.run_post_load_procedures })
  filename = "./tables.sql"
}

resource "local_file" "this2" {
  content  = templatefile("./scripts/install-apex-app.sql.tmpl", { llm_region = var.llm_region })
  filename = "./scripts/install-apex-app.sql"
}