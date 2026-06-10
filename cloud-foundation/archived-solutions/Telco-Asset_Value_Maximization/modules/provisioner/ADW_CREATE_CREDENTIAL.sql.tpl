BEGIN
  DBMS_CLOUD.CREATE_CREDENTIAL(
    credential_name => 'DEF_CRED_NAME',
    username => 'admin',
    password => '${db_password}'
  );
END;
/

exit;
/