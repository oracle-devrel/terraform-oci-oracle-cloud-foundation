# Copyright © 2024, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

#!/bin/bash
db_name=${db_name}

echo "-- Getting Started"
echo "-- SQLnet.ora inject the wallet location" 
mkdir -p mywalletdir
unzip wallet_${db_name}.zip -d mywalletdir
cd /home/opc/mywalletdir/
ls
cat /home/opc/mywalletdir/sqlnet.ora
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
perl -pi.back -e 's#\?\/network\/admin#'$//home/opc/mywalletdir'#g' /home/opc/mywalletdir/sqlnet.ora
export TNS_ADMIN=/home/opc/mywalletdir
cat /home/opc/mywalletdir/sqlnet.ora
echo "export TNS_ADMIN=/home/opc/mywalletdir" >> /home/opc/.bashrc
echo "-bastion_environment.sh.tpl DONE!" 



