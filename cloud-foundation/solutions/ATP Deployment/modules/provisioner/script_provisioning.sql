CREATE USER PROVISION IDENTIFIED BY AaBbCcDdEe123# QUOTA UNLIMITED ON users;

grant execute on apex_instance_admin to PROVISION;

grant create user, drop user, alter user to PROVISION;

grant select on sys.dba_sys_privs to PROVISION;

begin
    for c1 in (select privilege
             from sys.dba_sys_privs
            where grantee = 'APEX_GRANTS_FOR_NEW_USERS_ROLE' ) loop
        execute immediate 'grant '||c1.privilege||' to PROVISION with admin option';
    end loop;
end;
/

declare
    l_workspace_base constant varchar2(30) := 'WORKSHOP';
    l_db_user_base   constant varchar2(30) := 'USER_WORKSHOP';
    l_password_base  constant varchar2(30) := 'AaBbCcDdEe123!';
begin
    
    execute immediate 'create user '||l_db_user_base||' identified by "'||l_password_base||'" default tablespace DATA quota unlimited on DATA';

    --grant all the privileges that a db user would get if provisioned by APEX
    for c1 in (select privilege
        from sys.dba_sys_privs
            where grantee = 'APEX_GRANTS_FOR_NEW_USERS_ROLE' ) loop
        execute immediate 'grant '||c1.privilege||' to '||l_db_user_base;
    end loop;

    apex_instance_admin.add_workspace(
        p_workspace      => l_workspace_base,
        p_primary_schema => l_db_user_base);

    --Add the parsing db user of this application to allow apex_util.set_workspace to succeed
    apex_instance_admin.add_schema(
        p_workspace      => l_workspace_base,
        p_schema         => 'PROVISION');

    apex_util.set_workspace(
        p_workspace      => l_workspace_base);

    apex_util.create_user(
        p_user_name                    => l_db_user_base,
        p_web_password                 => l_password_base,
        p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL',
        p_email_address                => l_db_user_base||'@example.com',
        p_default_schema               => l_db_user_base,
        p_change_password_on_first_use => 'N' );

    apex_instance_admin.remove_schema(
        p_workspace        => l_workspace_base,
        p_schema           => 'PROVISION');

    apex_util.set_workspace(
        p_workspace      => 'PROVISION');
end;
/

exit;
/