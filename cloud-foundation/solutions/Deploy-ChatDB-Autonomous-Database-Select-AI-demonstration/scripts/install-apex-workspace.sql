-- download the app using wget:
-- wget https://martygubar.github.io/adb/shared/adb-speaks-human/apex-setup/f101.sql

-- as admin
DECLARE
    l_workspace_name VARCHAR2(100) := 'MOVIESTREAM';
    l_schema_name VARCHAR2(100) := 'MOVIESTREAM';
    l_workspace_usr_pwd VARCHAR2(100) := 'watchS0meMovies#';
begin
    admin.workshop.write('install Ask-Oracle', 1);
    admin.workshop.write('add workspace as admin', 2);
    apex_instance_admin.add_workspace(
     p_workspace_id   => null,
     p_workspace      => l_workspace_name,
     p_primary_schema => l_schema_name);

      -- We must set the APEX workspace security group ID in our session before we can call create_user
    apex_util.set_security_group_id( apex_util.find_security_group_id( p_workspace => l_workspace_name));
  apex_util.create_user( 
        p_user_name               => 'MOVIESTREAM',
        p_email_address           => 'admin@o.com',
        p_default_schema          => l_schema_name,
        p_allow_access_to_schemas => l_schema_name,
        p_web_password            => l_workspace_usr_pwd,
        p_change_password_on_first_use => 'N',
        p_developer_privs         => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL' );  -- workspace administrator
 
       
    commit;
end;
/