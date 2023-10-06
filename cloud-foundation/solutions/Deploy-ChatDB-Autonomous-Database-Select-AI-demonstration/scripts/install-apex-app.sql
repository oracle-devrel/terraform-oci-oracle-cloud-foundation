-- as moviestream
BEGIN    
    admin.workshop.write('setup for app install as moviestream', 2);
    
    -- Set the name of the workspace in which the app needs to be installed
    apex_application_install.set_workspace('MOVIESTREAM');

    -- Setting the application id to 101
    apex_application_install.set_application_id(101);
    apex_application_install.generate_offset();

    -- Setting the Schema
    apex_application_install.set_schema('MOVIESTREAM');

    -- Setting application alias
    apex_application_install.set_application_alias('CHATDB');

    -- Set Auto Install Supporting Objects
    apex_application_install.set_auto_install_sup_obj( p_auto_install_sup_obj => true );

END;
/

@./scripts/f101.sql

-- Setup Select AI
begin
    admin.workshop.write('Setup ai profile', 2);
    
    dbms_cloud_ai.drop_profile(
        profile_name => 'openai_gpt35',
        force => true
        );

    dbms_cloud_ai.create_profile(
        profile_name => 'openai_gpt35',
        attributes =>       
            '{"provider": "openai",
            "credential_name": "OPENAI_CRED",
            "comments":"true",
            "temperature":0.2,
            "object_list": [
                {"owner": "MOVIESTREAM", "name": "GENRE"},
                {"owner": "MOVIESTREAM", "name": "CUSTOMER"},
                {"owner": "MOVIESTREAM", "name": "PIZZA_SHOP"},
                {"owner": "MOVIESTREAM", "name": "STREAMS"},            
                {"owner": "MOVIESTREAM", "name": "MOVIES"},
                {"owner": "MOVIESTREAM", "name": "ACTORS"}
            ]
            }'
        );
        
        dbms_cloud_ai.set_profile(
            profile_name => 'openai_gpt35'
        );
end;
/