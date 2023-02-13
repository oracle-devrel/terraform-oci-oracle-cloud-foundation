#cloud-config
  
runcmd:
  # Enable and bring up vnc  
  - echo ${odi_vnc_password} | vncpasswd -f > /home/oracle/.vnc/passwd
  - chmod 0600 /home/oracle/.vnc/passwd  

  - chmod 0766 /home/oracle/.Xauthority
  - su opc
  - sudo cp /home/opc/.ssh/authorized_keys /home/oracle/.ssh/authorized_keys
  - sudo chown oracle:oracle /home/oracle/.ssh/authorized_keys
  - sudo systemctl enable oraclevncodi.service
  - sudo systemctl start oraclevncodi.service
  - sudo chmod +rwx /usr/share/applications/odi.desktop
  - sudo sed -i "s/ODI Studio/${studio_name}/g" /usr/share/applications/odi.desktop
  - sudo cp /usr/share/applications/odi.desktop /home/opc/Desktop
  - sudo chown opc:opc /home/opc/Desktop/odi.desktop
  - chmod +rwx /home/opc/Desktop/odi.desktop
  - sudo cp /usr/share/applications/odi.desktop /home/oracle/Desktop
  - sudo chown oracle:oracle /home/oracle/Desktop/odi.desktop
  - sudo chmod +rwx /home/oracle/Desktop/odi.desktop
  - sudo cp /usr/share/applications/adpregister.desktop /home/oracle/Desktop
  - sudo chown oracle:oracle /home/oracle/Desktop/adpregister.desktop
  - sudo chmod +rwx /home/oracle/Desktop/adpregister.desktop
  
  # Create the adw properties file
  
  - echo "[config]" > /u01/oracle/odi-setup.properties   
  - echo " " >> /u01/oracle/odi-setup.properties   
  - echo "mp_stack_mode=${studio_mode}" >> /u01/oracle/odi-setup.properties   
  - echo "dbTech=${db_tech}" >> /u01/oracle/odi-setup.properties 
  - echo "adwInstanceOcId=${adw_instance}" >> /u01/oracle/odi-setup.properties
  - echo "adwInstancePassword="'${adw_password}' >> /u01/oracle/odi-setup.properties
  - echo "odiSchemaPrefix=${odi_schema_prefix}" >> /u01/oracle/odi-setup.properties
  - echo "odiSchemaPassword="'${odi_schema_password}' >> /u01/oracle/odi-setup.properties
  - echo "odiSupervisorPassword="'${odi_password}' >> /u01/oracle/odi-setup.properties
  - echo "rcuCreationMode=${adw_creation_mode}" >> /u01/oracle/odi-setup.properties
  - echo "odiSchemaUser=${odi_schema_prefix}_ODI_REPO" >> /u01/oracle/odi-setup.properties 
  - echo "webStudioUrl=http://${lb_address}:9999/oracle-data-transforms" >> /u01/oracle/odi-setup.properties 
  - echo "lb_address=${lb_address}" >> /u01/oracle/odi-setup.properties 
  - echo "register_odi_adp=${register_repository}" >> /u01/oracle/odi-setup.properties
  
  - echo export JAVA_HOME=/u01/oracle/jdk1.8.0_211 >> /home/oracle/.bashrc
  - echo export PATH=/u01/oracle/jdk1.8.0_211/bin:$PATH >> /home/oracle/.bashrc 
  - echo export APP_LOGS=/u01/oracle/mwh/app_logs >> /home/oracle/.bashrc 
  - echo export MW_HOME=/u01/oracle/mwh >> /home/oracle/.bashrc
  
  - echo masterReposDriver=oracle.jdbc.OracleDriver >> /u01/oracle/repository.properties
  - echo masterReposUser=${odi_schema_prefix}_ODI_REPO >> /u01/oracle/repository.properties
  - echo workReposName=WORKREP >> /u01/oracle/repository.properties
  
  - mv /u01/oracle/odi-setup.properties /u01/oracle/mwh/odi/common/scripts
  - mv /u01/oracle/repository.properties /u01/oracle/mwh/odi/common/scripts
  - chown oracle:oracle /u01/oracle/mwh/odi/common/scripts/repository.properties
  - chown oracle:oracle /u01/oracle/mwh/odi/common/scripts/odi-setup.properties

  - echo "export JAVA_HOME=/home/oracle/jdk1.8.0_211" > /u01/oracle/configureRepo.sh
  - echo "export PATH=/home/oracle/jdk1.8.0_211/bin:$PATH" >> /u01/oracle/configureRepo.sh
  - echo "if !(${show_adp_desktop}) " >> /u01/oracle/configureRepo.sh 
  - echo "then " >> /u01/oracle/configureRepo.sh
  - echo "rm /home/oracle/Desktop/adpregister.desktop " >> /u01/oracle/configureRepo.sh
  - echo "fi" >>  /u01/oracle/configureRepo.sh  
  - echo "if ${embedded_db}" >> /u01/oracle/configureRepo.sh 
  - echo "then " >> /u01/oracle/configureRepo.sh
  - echo "echo mp_stack_mode="${studio_mode} "> /u01/oracle/mwh/odi/common/scripts/odi-setup.properties; echo dbTech="${db_tech} ">> /u01/oracle/mwh/odi/common/scripts/odi-setup.properties;" >> /u01/oracle/configureRepo.sh
  - echo "fi" >>  /u01/oracle/configureRepo.sh
  - echo "python odiMPConfiguration.py" >> /u01/oracle/configureRepo.sh
  - echo "rm -f /u01/oracle/mysql-5.7.26-linux-glibc2.12-x86_64.tar.gz /u01/oracle/mysql-connector-python-2.1.8.zip" >> /u01/oracle/configureRepo.sh    
  - echo "echo 'Finished MP configuration' " >> /u01/oracle/configureRepo.sh
  - echo "echo 'Going to start Apps' " >> /u01/oracle/configureRepo.sh
  - echo "python manageOdiApps.py start" >> /u01/oracle/configureRepo.sh
  - mv /u01/oracle/configureRepo.sh /u01/oracle/mwh/odi/common/scripts
  - chown oracle:oracle /u01/oracle/mwh/odi/common/scripts/configureRepo.sh
  - chmod +rwx /u01/oracle/mwh/odi/common/scripts/configureRepo.sh
  - chmod +rwx /u01/oracle/mwh/odi/common/scripts/configureADBInstances.sh
  - cd /u01/oracle/mwh/odi/common/scripts 
  - sudo su
  - su oracle -c "export MW_HOME=/u01/oracle/mwh; export APP_LOGS=/u01/oracle/mwh/app_logs; export JAVA_HOME=/u01/oracle/jdk1.8.0_211; export PATH=/u01/oracle/jdk1.8.0_211/bin:$PATH; ./configureRepo.sh" > /u01/oracle/logs/odiConfigure.log      
  - sudo systemctl start mysqlodi.service
  - sudo systemctl start manageappsodi.service  
 
final_message: "The system is finally up, after $UPTIME seconds"
  
