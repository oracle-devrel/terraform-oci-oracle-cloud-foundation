----------------------------------------------------------------
--
-- easyRAG-IN-A-BOX_APEX_ADMIN.sql
--
-- this script will setup up a new workspace in APEX and add
-- the admin user.
--
-- MUST run as ADMIN
--
-- Parameters:
-- 1 workspace name
-- 2 base oracle schema
-- 3 apex admin username
-- 4 apex admin password for db
-- 5 apex admin password for apex
--
-- v2.0 initial release
--
----------------------------------------------------------------

declare
    l_workspace varchar2(50) := '&1';
    l_db_schema varchar2(50) := '&2';
    l_apex_user varchar2(50) := '&3';
    l_apex_pwdd varchar2(50) := '&4';
    l_apex_pwda varchar2(50) := '&5';
begin

    execute immediate 'create user '||l_apex_user||' identified by "'||l_apex_pwdd||'"';

    --grant all the privileges that a db user would get if provisioned by APEX
    for c1 in (select privilege
                 from sys.dba_sys_privs
                where grantee = 'APEX_GRANTS_FOR_NEW_USERS_ROLE' ) loop
        execute immediate 'grant '||c1.privilege||' to '||l_apex_user;
    end loop;

    apex_instance_admin.add_workspace(
        p_workspace      => l_workspace,
        p_primary_schema => l_db_schema);

    apex_util.set_workspace(
        p_workspace      => l_workspace);

    apex_util.create_user(
        p_user_name                    => l_apex_user,
        p_web_password                 => l_apex_pwda,
        p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
        p_email_address                => l_apex_user ||'@example.com',
        p_default_schema               => l_db_schema,
        p_change_password_on_first_use => 'N' );

end;
/

--
-- end of script
--