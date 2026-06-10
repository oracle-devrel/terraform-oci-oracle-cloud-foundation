BEGIN
    DBMS_CLOUD.CREATE_CREDENTIAL(
        credential_name => 'DMISHRA',
        username        => 'OPENAI',
        password        => '${llmpw}'
    );
END;
/

BEGIN
    DBMS_CLOUD_AI.CREATE_PROFILE(
        profile_name => 'DMISHRA',
        attributes   => '{"provider": "openai",
                          "model": "gpt-4",
                          "credential_name": "DMISHRA",
                          "comments": "true",
                          "object_list":
                              [{"owner": "DMISHRA", "name": "ESTIMATED_COST_REVENUE"},
                               {"owner": "DMISHRA", "name": "NEAREST_NEIGHBOR"},
                               {"owner": "DMISHRA", "name": "SITE_OPERATION_COST_REVENUE"}]
                         }',
        status       => 'ENABLED',
        description  => 'AI profile to use OpenAI for SQL translation'
    );
END;
/

EXEC DBMS_CLOUD_AI.SET_PROFILE('DMISHRA');

exit;
/