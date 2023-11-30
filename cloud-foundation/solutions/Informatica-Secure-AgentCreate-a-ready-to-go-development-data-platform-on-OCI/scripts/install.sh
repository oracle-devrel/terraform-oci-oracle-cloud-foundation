#!/usr/bin/env bash


if [ -f /opt/DO_NOT_DELETE_INFA_IICS_SA.txt ]
then
  echo "Previous installation check file present. Installation not required. Agent will be connected to the IICS server shortly..." >> /opt/agent_setup.log
  echo "Starting IICS Agent" >> /opt/agent_setup.log
  sudo su - infa -c "cd /opt/infaagent/apps/agentcore; ./infaagent startup"
else
  echo "Starting IICS secure agent installation..." >> /opt/agent_setup.log
  cd /opt/infaagent/
  if [[ ${iics_provider} == "AWS" ]]
  then
    sed -i s/dm-us/dm-us/g /opt/infaagent/apps/agentcore/conf/infaagent.ini
  elif [[ ${iics_provider} == "Azure" ]]
  then
    sed -i s/dm-us/dm1-us/g /opt/infaagent/apps/agentcore/conf/infaagent.ini
  elif [[ ${iics_provider} == "GCP" ]]
  then
    sed -i s/dm-us/dm2-us/g /opt/infaagent/apps/agentcore/conf/infaagent.ini
  else
    sed -i s/dm-us/dm3-us/g /opt/infaagent/apps/agentcore/conf/infaagent.ini
  fi
  echo "Starting agent registration..." >> /opt/agent_setup.log
  sed -i s/^InfaAgent.UseToken=.*/InfaAgent.UseToken=true/ /opt/infaagent/apps/agentcore/conf/infaagent.ini
  echo "Setting Data Center location..." >> /opt/agent_setup.log
  if [[ $${$#iics_gn} -ge 1 ]]
  then
    echo "Adding secure agent to group ${iics_gn}" >> /opt/agent_setup.log
    echo -e "\nInfaAgent.GroupName=${iics_gn}" >> /opt/infaagent/apps/agentcore/conf/infaagent.ini
  fi
  chown -R infa:infa /opt/infaagent
  echo "Starting IICS Agent" >> /opt/agent_setup.log
  sudo su - infa -c "cd /opt/infaagent/apps/agentcore; ./infaagent startup"
  sleep 2m
  echo "Registering IICS Agent" >> /opt/agent_setup.log
  cd /opt/infaagent/apps/agentcore
  ./consoleAgentManager.sh configureToken "${iics_un}" "${iics_tk}"
  echo "Execution complete" >> /opt/agent_setup.log
  echo "Secure agent installation script completed." >> /opt/DO_NOT_DELETE_INFA_IICS_SA.txt

  sudo yum install java -y
  sudo yum install sqlcl -y
  cd /home/infa
  wget https://objectstorage.${region}.oraclecloud.com/n/${tenancy}/b/${bucket_name}/o/wallet_${db_name}.zip
  wget https://download.oracle.com/otn_software/linux/instantclient/1914000/instantclient-basic-linux.x64-19.14.0.0.0dbru.zip
  sudo chmod 777 /home/infa/wallet_${db_name}.zip
  sudo chmod 777 /home/infa/instantclient-basic-linux.x64-19.14.0.0.0dbru.zip
  sudo unzip instantclient-basic-linux.x64-19.14.0.0.0dbru.zip
  sudo export LD_LIBRARY_PATH=/home/infa/instantclient_19_4:$LD_LIBRARY_PATH
  mkdir -p mywalletdir
  unzip wallet_${db_name}.zip -d /home/infa/mywalletdir
  sudo chown infa:infa -R /home/infa/*
  cd /home/infa/mywalletdir/
  export LC_CTYPE=en_US.UTF-8
  export LC_ALL=en_US.UTF-8
  perl -pi.back -e 's#\?\/network\/admin#'$//home/infa/mywalletdir'#g' /home/infa/mywalletdir/sqlnet.ora
  export TNS_ADMIN=/home/infa/mywalletdir
  echo "export LD_LIBRARY_PATH=/home/infa/instantclient_19_4:$LD_LIBRARY_PATH" >> /home/infa/.bashrc
  echo "export TNS_ADMIN=/home/infa/mywalletdir" >> /home/infa/.bashrc
fi

