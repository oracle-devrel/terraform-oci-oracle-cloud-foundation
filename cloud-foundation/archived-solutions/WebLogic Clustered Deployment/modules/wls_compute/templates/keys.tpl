#!/bin/bash

echo "Creating ssh folder" >> /tmp/init.log

cp /home/opc/.ssh/authorized_keys /home/opc/.ssh/authorized_keys.bak
echo "${pubKey}" >> /home/opc/.ssh/authorized_keys
chown -R opc /home/opc/.ssh/authorized_keys

sudo su - oracle -c 'mkdir -p /home/oracle/.ssh/'
sudo su - oracle -c 'chmod 700 /home/oracle/.ssh'
sudo su - oracle -c 'echo "${oraclePriKey}" > /home/oracle/.ssh/id_rsa'
sudo su - oracle -c 'chown -R oracle:oracle /home/oracle/.ssh/id_rsa'
sudo su - oracle -c 'chmod 400 /home/oracle/.ssh/id_rsa'
sudo su - oracle -c 'echo "${oracleKey}" >> /home/oracle/.ssh/authorized_keys'
sudo su - oracle -c 'chown -R oracle:oracle /home/oracle/.ssh/authorized_keys'
sudo su - oracle -c 'chmod 600 /home/oracle/.ssh/authorized_keys'

echo "Added keys to auth keys" >> /tmp/init.log