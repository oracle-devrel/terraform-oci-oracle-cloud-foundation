# Copyright © 2023, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

#!/bin/bash
db_name=${db_name}

echo "-- Getting Started"
echo "-- Download Python 3.9.5 and install it with all the dependences"
cd /home/opc
wget https://www.python.org/ftp/python/3.9.5/Python-3.9.5.tar.xz
tar xvf Python-3.9.5.tar.xz

yum install -y perl-Env libffi-devel openssl openssl-devel tk-devel xz-devel zlib-devel bzip2-devel readline-devel libuuid-devel ncurses-devel

export PREFIX=`pwd`/Python-3.9.5
cd $PREFIX
./configure --prefix=$PREFIX --enable-shared

make clean; make
make altinstall

export PYTHONHOME=$PREFIX
export PATH=$PYTHONHOME/bin:$PATH
export LD_LIBRARY_PATH=$PYTHONHOME/lib:$LD_LIBRARY_PATH

cd $PYTHONHOME/bin 
ln -s python3.9 python3
python3 --version

echo "-- Install pip"
python3 -m pip install --upgrade pip

echo "-- Install Instance client"
cd /home/opc
wget https://download.oracle.com/otn_software/linux/instantclient/1914000/instantclient-basic-linux.x64-19.14.0.0.0dbru.zip
unzip instantclient-basic-linux.x64-19.14.0.0.0dbru.zip
export LD_LIBRARY_PATH=/home/opc/instantclient_19_4:$LD_LIBRARY_PATH

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

echo "-- Install from pip the neccesary packages"
pip3.9 install pandas==1.3.4
pip3.9 install scipy==1.7.3
pip3.9 install matplotlib==3.3.3
pip3.9 install cx_Oracle==8.1.0
pip3.9 install threadpoolctl==2.1.0
pip3.9 install joblib==0.14.0
pip3.9 install scikit-learn==1.0.1 --no-deps
pip3.9 uninstall -y numpy
pip3.9 install numpy==1.21.5
pip3.9 install scikit-learn==1.0.1

echo "-- Install oml4py for ML"
cd /home/opc
unzip /home/opc/oml4py-client-linux-x86_64-1.0.zip
perl -Iclient client/client.pl -y

echo "-- Run a python script inside Autonomous ML"
cat oml_sample.py
python3 oml_sample.py






