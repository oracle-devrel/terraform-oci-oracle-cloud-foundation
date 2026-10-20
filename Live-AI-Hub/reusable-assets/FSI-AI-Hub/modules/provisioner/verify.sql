set pagesize 100 linesize 220
set serveroutput on size unlimited
set heading on feedback on
whenever oserror exit 9
whenever sqlerror exit failure rollback

prompt FSI schema objects
select object_name, object_type, status
from user_objects
where object_name in (
  'FSI_APEX_AI_API', 'FSI_WEATHER_ANOMALY', 'CROSSSHIELD_REPORT_STORAGE',
  'FSI_RUNTIME_CONFIG', 'FSI_APEX_LLM_CONFIG', 'CLAIMS', 'CUSTOMERS', 'POLICIES'
)
order by object_type, object_name;

prompt FSI invalid objects (zero rows expected)
select object_name, object_type, status
from user_objects
where status = 'INVALID'
  and object_type in ('FUNCTION', 'PROCEDURE', 'PACKAGE', 'PACKAGE BODY', 'TRIGGER', 'VIEW', 'TYPE', 'TYPE BODY')
order by object_type, object_name;

declare
  l_invalid_count pls_integer;
begin
  select count(*)
    into l_invalid_count
    from user_objects
   where status = 'INVALID'
     and object_type in ('FUNCTION', 'PROCEDURE', 'PACKAGE', 'PACKAGE BODY', 'TRIGGER', 'VIEW', 'TYPE', 'TYPE BODY');

  if l_invalid_count > 0 then
    raise_application_error(-20001, 'FSI schema contains ' || l_invalid_count || ' invalid PL/SQL or view object(s).');
  end if;
end;
/

prompt FSI row counts
select 'AGENTS' table_name, count(*) row_count from agents
union all select 'AUDIT_LOG', count(*) from audit_log
union all select 'BILLING_SCHEDULES', count(*) from billing_schedules
union all select 'CLAIMS', count(*) from claims
union all select 'CLAIM_PAYMENTS', count(*) from claim_payments
union all select 'COMMUNICATIONS', count(*) from communications
union all select 'CROSSSHIELD_APEX_CONFIG', count(*) from crossshield_apex_config
union all select 'CROSSSHIELD_APEX_REPORTS', count(*) from crossshield_apex_reports
union all select 'CUSTOMERS', count(*) from customers
union all select 'DOCUMENTS', count(*) from documents
union all select 'EMPLOYEES', count(*) from employees
union all select 'ENDORSEMENTS', count(*) from endorsements
union all select 'FRAUD_INDICATORS', count(*) from fraud_indicators
union all select 'FSI_APEX_AI_REQUESTS', count(*) from fsi_apex_ai_requests
union all select 'FSI_APEX_LLM_CONFIG', count(*) from fsi_apex_llm_config
union all select 'FSI_DATABRICKS_FRAUD_SCORES', count(*) from fsi_databricks_fraud_scores
union all select 'FSI_RUNTIME_CONFIG', count(*) from fsi_runtime_config
union all select 'FSI_SPREADSHEET_FRAUD_SCORES', count(*) from fsi_spreadsheet_fraud_scores
union all select 'FSI_THIRD_PARTY_FRAUD_CACHE', count(*) from fsi_third_party_fraud_cache
union all select 'FSI_WEATHER_REPORT', count(*) from fsi_weather_report
union all select 'INCIDENTS', count(*) from incidents
union all select 'MEDICAL_ASSESSMENTS', count(*) from medical_assessments
union all select 'NAMED_DRIVERS', count(*) from named_drivers
union all select 'POLICIES', count(*) from policies
union all select 'POLICY_COVERAGES', count(*) from policy_coverages
union all select 'QUOTES', count(*) from quotes
union all select 'REF_CODES', count(*) from ref_codes
union all select 'REINSURANCE_TREATIES', count(*) from reinsurance_treaties
union all select 'REINSURANCE_RECOVERIES', count(*) from reinsurance_recoveries
union all select 'REPAIRERS', count(*) from repairers
union all select 'SANCTIONS_CHECKS', count(*) from sanctions_checks
union all select 'VEHICLES', count(*) from vehicles
union all select 'CLAIM_PARTIES', count(*) from claim_parties
union all select 'EXCESS_RECOVERY', count(*) from excess_recovery
union all select 'FRAUD_INVESTIGATIONS', count(*) from fraud_investigations
union all select 'VEHICLE_REPAIRS', count(*) from vehicle_repairs
union all select 'MACHINE_LEARNING_CONFIGS', count(*) from machine_learning_configs
order by table_name;

prompt FSI runtime keys
select config_key, is_secret, case when is_secret = 'Y' then '[REDACTED]' else dbms_lob.substr(config_value, 200, 1) end value_preview
from fsi_runtime_config
order by config_key;
prompt Private Object Storage access for the configured region (one authenticated object expected)
declare
  l_credential_name varchar2(128);
  l_storage_prefix  varchar2(4000);
  l_object_found    boolean := false;
begin
  select max(case when config_key = 'OBJECT_STORAGE_CREDENTIAL_NAME' then dbms_lob.substr(config_value, 128, 1) end),
         max(case when config_key = 'OBJECT_STORAGE_PREFIX' then dbms_lob.substr(config_value, 4000, 1) end)
    into l_credential_name, l_storage_prefix
    from fsi_runtime_config;

  if l_credential_name is null or l_storage_prefix is null then
    raise_application_error(-20002, 'Private Object Storage credential or URI is missing from FSI_RUNTIME_CONFIG.');
  end if;

  for r in (
    select object_name
      from dbms_cloud.list_objects(
             credential_name => l_credential_name,
             location_uri    => l_storage_prefix
           )
     where rownum = 1
  ) loop
    l_object_found := true;
  end loop;

  if not l_object_found then
    raise_application_error(-20003, 'Authenticated private Object Storage listing returned no objects.');
  end if;

  dbms_output.put_line('Authenticated private Object Storage access verified.');
end;
/
