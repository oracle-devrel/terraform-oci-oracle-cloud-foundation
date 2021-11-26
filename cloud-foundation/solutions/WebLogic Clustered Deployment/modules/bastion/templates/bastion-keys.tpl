#!/bin/bash

echo "Adding keys" >> /tmp/init.log

cp /home/opc/.ssh/authorized_keys /home/opc/.ssh/authorized_keys.bak
echo "${pubKey}" >> /home/opc/.ssh/authorized_keys
chown -R opc /home/opc/.ssh/authorized_keys

echo "Added keys to auth keys" >> /tmp/init.log