set define off verify off feedback on
whenever sqlerror exit sql.sqlcode rollback

declare
  l_next_id number;
begin
  select nvl(max(claim_id), 0) + 1
    into l_next_id
    from claims;
  execute immediate 'alter sequence claims_seq restart start with ' || to_char(l_next_id, 'FM9999999999999999999999999990');

  select greatest(
           nvl((select max(incident_id) from incidents), 0),
           nvl((select max(repair_id) from vehicle_repairs), 0),
           nvl((select max(payment_id) from claim_payments), 0),
           nvl((select max(assessment_id) from medical_assessments), 0)
         ) + 1
    into l_next_id
    from dual;
  execute immediate 'alter sequence incidents_seq restart start with ' || to_char(l_next_id, 'FM9999999999999999999999999990');

  select nvl(max(indicator_id), 0) + 1
    into l_next_id
    from fraud_indicators;
  execute immediate 'alter sequence fraud_indicators_seq restart start with ' || to_char(l_next_id, 'FM9999999999999999999999999990');
end;
/
prompt Application sequences aligned with all curated business data.
EXIT;
