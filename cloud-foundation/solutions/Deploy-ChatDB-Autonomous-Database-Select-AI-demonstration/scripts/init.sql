-- **Copyright © 2023, Oracle and/or its affiliates.
-- **All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.


-- **To install the database objects required for the demo. Connect to ADB as ADMIN:**

declare 
    l_uri varchar2(500) := 'https://objectstorage.us-ashburn-1.oraclecloud.com/n/c4u04/b/building_blocks_utilities/o/setup/workshop-setup.sql';
begin
    dbms_cloud_repo.install_sql(
        content => to_clob(dbms_cloud.get_object(object_uri => l_uri))
    );
end;
/

-- Add the MOVIESTREAM  user
begin
    workshop.write('Begin demo install');
    workshop.write('add user MOVIESTREAM', 1);
    workshop.add_adb_user('MOVIESTREAM','watchS0meMovies#');
    
    ords_admin.enable_schema (
        p_enabled               => TRUE,
        p_schema                => 'MOVIESTREAM',
        p_url_mapping_type      => 'BASE_PATH',
        p_auto_rest_auth        => TRUE   
    ); 
    
    -- Allow MOVIESTREAM to use the resource principal
    dbms_cloud_admin.enable_resource_principal(username  => 'MOVIESTREAM');

end;
/

-- Open up access to openai for moviestream user
BEGIN
 DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE (
  host         => 'api.openai.com',
  lower_port   => 443,
  upper_port   => 443,
  ace          => xs$ace_type(
      privilege_list => xs$name_list('http'),
      principal_name => 'MOVIESTREAM',
      principal_type => xs_acl.ptype_db));
END;
/

