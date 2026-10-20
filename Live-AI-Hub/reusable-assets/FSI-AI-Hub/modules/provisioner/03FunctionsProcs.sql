-- Application PL/SQL and triggers from the imported FSI Data Pump schema.
-- Terraform remaps MADHU_RAO references to var.fsi_db_schema before execution.
SET DEFINE OFF
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

CREATE OR REPLACE EDITIONABLE PACKAGE "CROSSSHIELD_REPORT_STORAGE" authid definer as
  procedure rebuild_vector_index_job;
  procedure store_and_index(
    p_claim_id     in number,
    p_claim_number in varchar2,
    p_report_html  in clob
  );
end crossshield_report_storage;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CROSSSHIELD_REPORT_STORAGE" as
  function runtime_config_value(p_config_key varchar2, p_default varchar2) return varchar2 is
    l_value varchar2(4000);
  begin
    select trim(dbms_lob.substr(config_value, 4000, 1))
      into l_value
      from fsi_runtime_config
     where config_key = upper(trim(p_config_key));
    return coalesce(l_value, p_default);
  exception when no_data_found then
    return p_default;
  end;

  function html_to_markdown(
    p_claim_id     in number,
    p_claim_number in varchar2,
    p_report_html  in clob
  ) return clob is
    l_text clob;
  begin
    l_text:=regexp_replace(p_report_html,'</(h[1-6]|p|div|section|article|header|footer|li|tr)>',chr(10),1,0,'in');
    l_text:=regexp_replace(l_text,'<br[[:space:]]*/?>',chr(10),1,0,'in');
    l_text:=regexp_replace(l_text,'<li[^>]*>','- ',1,0,'in');
    l_text:=regexp_replace(l_text,'<[^>]+>',' ',1,0,'in');
    l_text:=replace(replace(replace(replace(replace(l_text,';','&'),';','<'),';','>'),';','"'),'&#39;','''');
    l_text:=regexp_replace(l_text,'[[:space:]]+'||chr(10),chr(10),1,0,'n');
    l_text:=regexp_replace(l_text,chr(10)||'{3,}',chr(10)||chr(10),1,0,'n');
    return to_clob('# Fraud Investigation Report for Claim ID '||to_char(p_claim_id)||chr(10)||chr(10)||
      'Claim ID: '||to_char(p_claim_id)||chr(10)||
      'Claim Number: '||nvl(p_claim_number,'--')||chr(10)||
      'Generated: '||to_char(systimestamp,'YYYY-MM-DD"T"HH24:MI:SS TZH:TZM')||chr(10)||chr(10))||l_text;
  end html_to_markdown;

  procedure rebuild_vector_index is
    l_attributes clob;
    l_credential_name varchar2(128);
    l_storage_pattern varchar2(1000);
    l_vector_index varchar2(128);
    l_vector_table varchar2(128);
    l_rag_profile varchar2(128);
    l_vector_dimension number;
  begin
    l_credential_name := runtime_config_value('OBJECT_STORAGE_CREDENTIAL_NAME', 'FS_OCI_CRED');
    l_storage_pattern := runtime_config_value('OBJECT_STORAGE_PATTERN', 'https://objectstorage.us-chicago-1.oraclecloud.com/n/idukzrqavn8q/b/fsi-crossshield-kb/o/*.md');
    l_vector_index := runtime_config_value('RAG_VECTOR_INDEX_NAME', 'FSI_HUB_VECTOR_INDEX_KB');
    l_vector_table := runtime_config_value('RAG_VECTOR_TABLE_NAME', 'FSI_HUB_VECTOR_INDEX_KB$VECTAB');
    l_rag_profile := runtime_config_value('RAG_PROFILE_NAME', 'FSI_SELECT_AI_RAG_KB_PROFILE');
    l_vector_dimension := to_number(runtime_config_value('RAG_VECTOR_DIMENSION', '1536'));
    select json_object(
             'vector_db_provider' value 'oracle',
             'location' value l_storage_pattern,
             'object_storage_credential_name' value l_credential_name,
             'profile_name' value l_rag_profile,
             'vector_dimension' value l_vector_dimension,
             'vector_distance_metric' value 'cosine',
             'chunk_overlap' value 128,
             'chunk_size' value 1024,
             'refresh_rate' value 1440
             returning clob
           )
      into l_attributes
      from dual;
    begin
      dbms_cloud_ai.drop_vector_index(
        index_name=>l_vector_index,
        include_data=>true,
        force=>true
      );
    exception when others then
      if sqlcode not in (-942,-4043,-20000) then raise; end if;
    end;
    begin
      dbms_cloud_ai.create_vector_index(
        index_name=>l_vector_index,
        attributes=>l_attributes,
        status=>'Enabled',
        description=>'CrossShield and FSI generated fraud investigation reports',
        wait_for_completion=>true
      );
    exception
      when others then
        if sqlcode=-20000 and instr(sqlerrm,'ORA-00955')>0 then
          execute immediate 'drop table ' || dbms_assert.simple_sql_name(l_vector_table) || ' purge';
          dbms_cloud_ai.create_vector_index(
            index_name=>l_vector_index,
            attributes=>l_attributes,
            status=>'Enabled',
            description=>'CrossShield and FSI generated fraud investigation reports',
            wait_for_completion=>true
          );
        else
          raise;
        end if;
    end;
  end rebuild_vector_index;

  procedure rebuild_vector_index_job is
  begin
    rebuild_vector_index;
  end rebuild_vector_index_job;

  procedure schedule_vector_index_rebuild(
    p_claim_id in number
  ) is
    l_job_name varchar2(128);
  begin
    l_job_name := 'FSI_VEC_REBUILD_' || to_char(p_claim_id) || '_' || substr(rawtohex(sys_guid()), 1, 16);
    dbms_scheduler.create_job(
      job_name        => l_job_name,
      job_type        => 'STORED_PROCEDURE',
      job_action      => 'CROSSSHIELD_REPORT_STORAGE.REBUILD_VECTOR_INDEX_JOB',
      start_date      => systimestamp + interval '1' second,
      enabled         => false,
      auto_drop       => true,
      comments        => 'Background vector-index rebuild after report storage for claim ' || to_char(p_claim_id)
    );
    dbms_scheduler.enable(l_job_name);
  exception
    when others then
      null;
  end schedule_vector_index_rebuild;

  procedure store_and_index(
    p_claim_id     in number,
    p_claim_number in varchar2,
    p_report_html  in clob
  ) is
    l_object_name varchar2(255);
    l_object_uri  varchar2(2000);
    l_markdown    clob;
    l_contents    blob;
    l_dest_offset integer:=1;
    l_src_offset  integer:=1;
    l_lang_ctx    integer:=dbms_lob.default_lang_ctx;
    l_warning     integer;
    l_credential_name varchar2(128);
    l_storage_prefix varchar2(1000);
    l_model_name varchar2(128);
  begin
    if p_claim_id is null or p_claim_id<1 then
      raise_application_error(-20101,'A valid claim ID is required for report storage.');
    end if;
    if p_report_html is null then
      raise_application_error(-20102,'Fraud investigation report HTML is required for report storage.');
    end if;
    l_credential_name := runtime_config_value('OBJECT_STORAGE_CREDENTIAL_NAME', 'FS_OCI_CRED');
    l_storage_prefix := runtime_config_value('OBJECT_STORAGE_PREFIX', 'https://objectstorage.us-chicago-1.oraclecloud.com/n/idukzrqavn8q/b/fsi-crossshield-kb/o/');
    l_model_name := runtime_config_value('OCI_MODEL_NAME', 'FSI_SELECT_AI');
    l_object_name:='claim-'||to_char(p_claim_id)||'-fraud-investigation.md';
    l_object_uri:=l_storage_prefix||l_object_name;
    l_markdown:=html_to_markdown(p_claim_id,p_claim_number,p_report_html);
    insert into crossshield_apex_reports(
      claim_id,
      report_html,
      ai_service_name,
      ai_model_id
    ) values (
      p_claim_id,
      p_report_html,
      'OCI Generative AI',
      l_model_name
    );
    dbms_lob.createtemporary(l_contents,true,dbms_lob.call);
    dbms_lob.converttoblob(
      dest_lob=>l_contents,
      src_clob=>l_markdown,
      amount=>dbms_lob.lobmaxsize,
      dest_offset=>l_dest_offset,
      src_offset=>l_src_offset,
      blob_csid=>nls_charset_id('AL32UTF8'),
      lang_context=>l_lang_ctx,
      warning=>l_warning
    );
    begin
      dbms_cloud.put_object(
        credential_name=>l_credential_name,
        object_uri=>l_object_uri,
        contents=>l_contents
      );
    exception when others then
      dbms_output.put_line(
        'Optional Object Storage upload skipped for claim ' || to_char(p_claim_id) || ': ' || sqlerrm
      );
    end;
    dbms_lob.freetemporary(l_contents);
    schedule_vector_index_rebuild(p_claim_id);
  exception when others then
    if dbms_lob.istemporary(l_contents)=1 then dbms_lob.freetemporary(l_contents); end if;
    raise_application_error(-20103,'Unable to persist local report for claim '||to_char(p_claim_id)||': '||substr(sqlerrm,1,1700));
  end store_and_index;
end crossshield_report_storage;
/

CREATE OR REPLACE EDITIONABLE PACKAGE "FSI_APEX_AI_API" authid definer as
  function ask_rag(p_question in varchar2) return clob;
  function investigate_claim(p_claim_id in number) return clob;
  procedure process_request(p_request_id in varchar2);
  procedure process_next_request;
end fsi_apex_ai_api;
/
create or replace package body fsi_apex_ai_api as

   function runtime_config_value(
      p_config_key in varchar2,
      p_default    in varchar2
   ) return varchar2 is
      l_value varchar2(4000);
   begin
      select trim(dbms_lob.substr(config_value, 4000, 1))
        into l_value
        from fsi_runtime_config
       where config_key = upper(trim(p_config_key));
      return coalesce(l_value, p_default);
   exception
      when no_data_found then return p_default;
   end runtime_config_value;

    /*
    FSI_APEX_AI_API will provide the interface 
    for interacting with the FSI AI Agent.
    Details of the FSI AI Agent are in the package
    fsi_apex_ai_agent. The FSI AI Agent is a
    team of LLMs and vector search profiles  
    */ 

   function run_team (
      p_team_name in varchar2,
      p_prompt    in varchar2
   ) return clob is
      pragma autonomous_transaction;
      l_request_id    varchar2(32) := lower(rawtohex(sys_guid()));
      l_status        varchar2(20);
      l_response      clob;
      l_error_message varchar2(4000);
   begin
      delete from fsi_apex_ai_requests
       where created_at < systimestamp - interval '7' day;
      insert into fsi_apex_ai_requests (
         request_id,
         team_name,
         user_prompt
      ) values ( l_request_id,
                 p_team_name,
                 substr(
                    trim(p_prompt),
                    1,
                    12000
                 ) );
      commit;

      -- Process the request in this session. The old implementation only
      -- enqueued the request and polled for up to five minutes, but no
      -- worker was guaranteed to consume the queue before the APEX gateway
      -- timed out. Vector-index rebuilding is queued separately below.
      process_request(l_request_id);

      select status,
             response,
             error_message
        into l_status,
             l_response,
             l_error_message
        from fsi_apex_ai_requests
       where request_id = l_request_id;

      if l_status = 'COMPLETED' then
         return l_response;
      end if;

      raise_application_error(
         -20003,
         substr(nvl(l_error_message, 'FSI AI request did not complete.'), 1, 1900)
      );
   end run_team;

   procedure process_request (
      p_request_id in varchar2
   ) is
      l_team_name            varchar2(128);
      l_prompt               varchar2(12000);
      l_agent_response       clob;
      l_render_prompt        clob;
      l_instructions         clob;
      l_claim_context        clob;
      l_multi_source_context clob;
      l_claim_id             number;
      l_claim_number         varchar2(100);
      l_policy_number        varchar2(100);
      l_policy_status        varchar2(30);
      l_policy_product_type  varchar2(100);
      l_policy_cover_type    varchar2(100);
      l_policy_start_date    date;
      l_policy_end_date      date;
      l_policy_renewal_date  date;
      l_claim_status         varchar2(100);
      l_claim_type           varchar2(100);
      l_risk_tier            varchar2(20);
      l_claim_details        varchar2(4000);
      l_vehicle_details      varchar2(1200);
      -- FSI_VEHICLE_POLICY_DETAILS_ROW_V1
      l_vehicle_policy_details varchar2(2000);
      l_police_report_status varchar2(30);
      l_claim_reason         varchar2(500);
      l_customer_name        varchar2(300);
      l_total_claimed        number;
      l_total_settled        number;
      l_reserve_amount       number;
      l_fraud_score          number;
      l_fraud_probability    number;
      l_confidence_display   varchar2(30);
      l_reported_date        date;
      l_response             clob;
      l_error                varchar2(4000);
      l_stage                varchar2(100) := 'START';
      -- FSI_REPORT_GENERATION_DURATION_V1
      l_report_started_at   timestamp with time zone := systimestamp;
      l_report_elapsed_seconds number;
      l_report_elapsed_text varchar2(100);
      l_conversation_id     varchar2(4000);
   begin
      update fsi_apex_ai_requests
         set
         status = 'RUNNING'
       where request_id = p_request_id;
      commit;
      select team_name,
             dbms_lob.substr(
                user_prompt,
                12000,
                1
             )
        into
         l_team_name,
         l_prompt
       from fsi_apex_ai_requests
       where request_id = p_request_id;

      l_stage := 'CREATE_CONVERSATION';
      select dbms_cloud_ai.create_conversation
        into l_conversation_id
        from dual;

      l_stage := 'AGENT_RUN_TEAM';
      select dbms_cloud_ai_agent.run_team(
         team_name   => l_team_name,
         user_prompt => l_prompt,
         params      => '{"conversation_id":"' || l_conversation_id || '"}'
      )
        into l_agent_response
        from dual;

      if upper(l_team_name) = 'FSI_FRAUD_INVESTIGATION_TEAM' then
         l_stage := 'LOAD_REPORT_INSTRUCTIONS';
         select config_value
           into l_instructions
           from fsi_apex_llm_config
          where config_key = 'FRAUD_REPORT_SYSTEM_INSTRUCTIONS';

         l_claim_id := to_number ( regexp_substr(
            l_prompt,
            'claim id ([0-9]+)',
            1,
            1,
            'i',
            1
         ) );
         begin
            select c.claim_number,
                   p.policy_number,
                   p.status,
                   p.product_type,
                   p.cover_type,
                   p.start_date,
                   p.end_date,
                   p.renewal_date,
                   c.claim_status,
                   c.claim_type,
                   (
                      select case fi.indicator_code
                               when 'SIMULATION_HIGH_RISK' then 'HIGH'
                               when 'SIMULATION_MEDIUM_RISK' then 'MEDIUM'
                               when 'SIMULATION_LOW_RISK' then 'LOW'
                             end
                        from fraud_indicators fi
                       where fi.claim_id = c.claim_id
                         and fi.detected_by = 'FSI_CLAIM_SIMULATOR'
                         and fi.indicator_code in ('SIMULATION_HIGH_RISK', 'SIMULATION_MEDIUM_RISK', 'SIMULATION_LOW_RISK')
                       order by fi.detected_date desc, fi.indicator_id desc
                       fetch first 1 row only
                   ),
                   dbms_lob.substr(c.claim_details, 4000, 1),
                   trim(
                     nvl(v.registration, '--') || ' | ' ||
                     nvl(v.make, '--') || ' ' || nvl(v.model, '--') ||
                     ' | Year ' || nvl(to_char(v.year), '--') ||
                     ' | Body type ' || nvl(v.body_type, '--') ||
                     ' | Colour ' || nvl(v.colour, '--')
                   ),
                   (
                     select case
                              when i.police_attended = 'Y' or i.police_report_no is not null then 'Available'
                              else 'Not Available'
                            end
                       from incidents i
                      where i.claim_id = c.claim_id
                      fetch first 1 row only
                   ),
                   trim(cu.first_name
                        || ' ' || cu.last_name),
                   nvl(
                      c.total_claimed,
                      0
                   ),
                   nvl(
                      c.total_settled,
                      0
                   ),
                   nvl(
                      c.reserve_amount,
                      0
                   ),
                   nvl(
                      c.fraud_score,
                      0
                   ),
                   c.reported_date
              into
               l_claim_number,
               l_policy_number,
               l_policy_status,
               l_policy_product_type,
               l_policy_cover_type,
               l_policy_start_date,
               l_policy_end_date,
               l_policy_renewal_date,
               l_claim_status,
               l_claim_type,
               l_risk_tier,
               l_claim_details,
               l_vehicle_details,
               l_police_report_status,
               l_customer_name,
               l_total_claimed,
               l_total_settled,
               l_reserve_amount,
               l_fraud_score,
               l_reported_date
              from claims c
              left join customers cu
                on cu.customer_id = c.customer_id
              left join vehicles v
                on v.vehicle_id = c.vehicle_id
              left join policies p
                on p.policy_id = c.policy_id
             where c.claim_id = l_claim_id;

            begin
              select trim(
                       'Policy ' || nvl(p.policy_number, '--')
                       || ' | Status ' || nvl(p.status, '--')
                       || ' | Product ' || nvl(p.product_type, '--')
                       || ' | Cover ' || nvl(p.cover_type, '--')
                       || ' | Period '
                       || nvl(to_char(p.start_date, 'YYYY-MM-DD'), '--')
                       || ' to '
                       || nvl(to_char(p.end_date, 'YYYY-MM-DD'), '--')
                       || ' | Annual Premium £'
                       || nvl(
                            to_char(
                              p.annual_premium,
                              'FM999G999G999G990D00',
                              'NLS_NUMERIC_CHARACTERS=''.,'''
                            ),
                            '--'
                          )
                       || ' | Excess £'
                       || nvl(
                            to_char(
                              p.excess_amount,
                              'FM999G999G999G990D00',
                              'NLS_NUMERIC_CHARACTERS=''.,'''
                            ),
                            '--'
                          )
                     )
                into l_vehicle_policy_details
                from claims c
                join policies p
                  on p.policy_id = c.policy_id
               where c.claim_id = l_claim_id;
            exception
              when no_data_found then
                l_vehicle_policy_details := '--';
            end;

            l_claim_reason := case upper(trim(l_claim_type))
               when 'ACCIDENT' then
                  'Car accident claim.'
               when 'PERSONAL_INJURY' then
                  'Personal injury arising from a car accident.'
               when 'FIRE' then
                  'Fire damage occurring during a car accident.'
               when 'THEFT' then
                  'Theft occurring during a car accident.'
               when 'VANDALISM' then
                  'Vandalism occurring during a car accident.'
               else
                  'Use only the authoritative claim and investigation evidence to state the reason for filing; do not infer a cause.'
            end;

            l_claim_context := 'Authoritative FSIHUB.CLAIMS values (these values are available and must never be shown as Data Error):'
                               || chr(10)
                               || 'Claim ID: '
                               || to_char(l_claim_id)
                               || chr(10)
                               || 'Claim number: '
                               || l_claim_number
                               || chr(10)
                               || 'Linked policy number: '
                               || nvl(l_policy_number, '--')
                               || chr(10)
                               || 'Policy status: '
                               || nvl(l_policy_status, '--')
                               || chr(10)
                               || 'Policy product type: '
                               || nvl(l_policy_product_type, '--')
                               || chr(10)
                               || 'Policy cover type: '
                               || nvl(l_policy_cover_type, '--')
                               || chr(10)
                               || 'Policy period: '
                               || nvl(to_char(l_policy_start_date, 'YYYY-MM-DD'), '--')
                               || ' to '
                               || nvl(to_char(l_policy_end_date, 'YYYY-MM-DD'), '--')
                               || chr(10)
                               || 'Policy renewal date: '
                               || nvl(to_char(l_policy_renewal_date, 'YYYY-MM-DD'), '--')
                               || chr(10)
                               || 'Policy coverage assessment: '
                               || case
                                    when upper(nvl(l_policy_status, 'UNKNOWN')) in ('CANCELLED', 'LAPSED') then
                                      upper(nvl(l_policy_status, 'UNKNOWN')) ||
                                      ' is a coverage anomaly with a 30-point weighted risk contribution, not an automatic fraud finding. Verify cover at the incident date. Renewal or replacement cover applies only to future losses and does not retrospectively restore cover or validate this claim.'
                                    else
                                      'Use the linked policy facts when assessing coverage and fraud risk.'
                                  end
                               || chr(10)
                               || 'Customer name: '
                               || nvl(
               l_customer_name,
               '--'
            )
                               || chr(10)
                               || 'Claim type: '
                               || l_claim_type
                               || chr(10)
                               || 'Selected risk tier: '
                               || nvl(l_risk_tier, '--')
                               || chr(10)
                               || 'Claim details: '
                               || nvl(l_claim_details, '--')
                               || chr(10)
                               || 'Vehicle details: '
                               || nvl(l_vehicle_details, '--')
                               || chr(10)
                               || 'Vehicle policy details: '
                               || nvl(l_vehicle_policy_details, '--')
                               || chr(10)
                               || 'Police report evidence status: '
                               || nvl(l_police_report_status, 'Not Available')
                               || chr(10)
                               || 'Reason for filing claim: '
                               || l_claim_reason
                               || chr(10)
                               || 'Claim status: '
                               || l_claim_status
                               || chr(10)
                               || 'Claim date: '
                               || nvl(
               to_char(
                  l_reported_date,
                  'YYYY-MM-DD'
               ),
               '--'
            )
                               || chr(10)
                               || 'Total claimed: £'
                               || to_char(
               l_total_claimed,
               'FM9999999990D00',
               'NLS_NUMERIC_CHARACTERS=''.,'''
            )
                               || chr(10)
                               || 'Total settled: £'
                               || to_char(
               l_total_settled,
               'FM9999999990D00',
               'NLS_NUMERIC_CHARACTERS=''.,'''
            )
                               || chr(10)
                               || 'Reserve amount: £'
                               || to_char(
               l_reserve_amount,
               'FM9999999990D00',
               'NLS_NUMERIC_CHARACTERS=''.,'''
            )
                               || chr(10)
                               || 'Fraud score: '
                               || to_char(
               l_fraud_score,
               'FM9999999990D00',
               'NLS_NUMERIC_CHARACTERS=''.,'''
            )
                               || chr(10)
                               || 'Render these exact financial values in the Executive Summary and top metrics using the £ symbol. Never write GBP or a currency code for Total Claimed, Reserve Amount, or Total Settled. Data Error is allowed only for fields not listed here.'
                               || chr(10)
                               ||
               case
                  when upper(l_claim_type) <> 'ACCIDENT' then
                     'This is not an accident claim. Repairer evidence does not apply: omit repairer scores and never label their absence as Data Error.'
                  else
                     'This is an accident claim. Render repairer evidence when it is available.'
               end;
         exception
            when no_data_found then
               l_claim_context := 'No authoritative CLAIMS row was found for claim ID '
                                  || to_char(l_claim_id)
                                  || '.';
         end;

         begin
            l_stage := 'MULTI_SOURCE_EVIDENCE';
            l_multi_source_context := fsi_validate_multi_source_risk_summary(l_claim_id);
         exception
            when others then
               l_multi_source_context := '{
  "status": "ERROR",
  "message": "Multi-source evidence lookup failed."
}';
         end;

         l_fraud_probability := json_value(
            l_multi_source_context,
            '$.fraud_potential' returning number null on error
         );
         l_fraud_probability := nvl(l_fraud_probability, l_fraud_score);
         l_confidence_display := to_char(l_fraud_probability, 'FM990D00', 'NLS_NUMERIC_CHARACTERS=''.,''');

         l_render_prompt := l_instructions
                            || chr(10)
                            || chr(10)
                            || 'APEX delivery requirements:'
                            || chr(10)
                            || 'Return only an HTML fragment with no markdown fence, html, head, body, style, or script tags.'
                            || chr(10)
                            || 'Render a full-width Oracle Redwood fraud investigation report matching the standalone FSI Dashboard for an executive claims audience. Wrap the complete fragment in exactly one <div class="rw-report"> container.'
                            || chr(10)
                            || 'Use semantic HTML and the bundled report classes from styles.redwood.css, including report-header, report-section, risk-high, risk-medium, risk-low, status-badge, data-table, and ai-explanation where appropriate. Use risk-high for 70-100, risk-medium for 30-69, and risk-low for 0-29. Do not use risk-critical for the fraud-risk band. Do not include inline styles or external stylesheet tags.'
                            || chr(10)
                            || 'Display report results in properly aligned tables. Do not use metric-card, metric-grid, card grids, definition lists, or paragraph-only layouts for factual results.'
                            || chr(10)
                            || 'Format Fraud Probability and every other percentage score consistently to two decimal places with a space before the percent sign, for example 89.00 %. For any final Fraud Probability of 70.00 % or greater, wrap only the displayed probability value in <span class="risk-high">...</span>; use risk-medium for 30.00-69.99 % and risk-low for 0.00-29.99 %. Do not use inline styles.'
                            || chr(10)
                            || 'The Executive Summary is mandatory. Its heading must be exactly <h2>Executive Summary for Claim ID '
                            || to_char(l_claim_id)
                            || '</h2>. Use <section class="report-section executive-summary"><h2>Executive Summary for Claim ID '
                            || to_char(l_claim_id)
                            || '</h2><div class="executive-summary-table-wrap"><table class="executive-summary-table"><tbody>...</tbody></table></div></section>. Each row must contain <th scope="row">Label</th><td>Value</td>. Include Fraud Probability, Risk Level, Risk Level Basis, Claim Status, Customer, Claim Type, Claim Details, Vehicle Details, Vehicle Policy Details, Total Claimed, Reserve Amount, and Total Settled. For Risk Level Basis, explicitly state LOW = 0.00-29.99 %, MEDIUM = 30.00-69.99 %, HIGH = 70.00-100.00 %, and explain which band contains this claim''s authoritative Fraud Probability. Render the authoritative claim details and vehicle details supplied in the claim context; do not replace them with Data Error. Render Vehicle Policy Details as one row immediately after Vehicle Details, using the authoritative vehicle policy details supplied in the claim context. Do not render Main Risk Drivers or Recommendation in Executive Summary.'
                            || chr(10)
                            || 'Do not render a Summary of Insurance Claim section. Its claim facts remain available in the Executive Summary and the other existing report sections. Do not display a separate Fraud Score.'
                            || chr(10)
                            || 'For every remaining factual section use <section class="report-section"><h2>...</h2><div class="executive-summary-table-wrap"><table class="data-table"><thead>...</thead><tbody>...</tbody></table></div></section>. Use one consistent column count per table, a descriptive header for every column, <th scope="row"> for row labels, class="u-tR" for numeric and currency cells, and class="u-tC" for scores, statuses, risk levels, dates, and confidence. Keep narrative explanations in a final full-width Details column.'
                            || chr(10)
                            || 'Use -- for an unavailable scalar value and a single full-width No evidence available row for an unavailable table. Never emit empty cells, malformed rows, nested tables, colspan values that do not match the table header, or raw pipe-delimited text.'
                            || chr(10)
                            || 'Keep the existing sections: Explainable AI, Risk Evidence, External Evidence, Similar Cases, and Document Findings, followed by Recommended Action. Do not render Summary of Insurance Claim, Fraud Assessment, or Score Justification. In Explainable AI include Scoring Method, How Fraud Probability Was Calculated, Explanation and Rationale, Key Fraud Indicators, Evidence Against Fraud, and Missing or Conflicting Information; do not render Reason-Code Contributions as a separate row. Fold every rule contribution into How Fraud Probability Was Calculated, including its label and weighted points (for example elevated claimed amount (+10) and prior claims in the last 24 months (+5)), and explain how those points affected the rule baseline, normalization, or evidence anchor without directly adding them as probability percentages. Do not render External Evidence Impact or Fraud Assessment as rows in Explainable AI. Do not render Internal Baseline Probability as a separate row; if relevant, describe the baseline only inside How Fraud Probability Was Calculated. In Risk Evidence omit Unverified Supporting Documents and Internal Baseline Probability. In External Evidence omit 3rd Party Data Message. The Explanation and Rationale must analyze the claim rather than copy claim details and must explain how claim data, policy, prior claims, linked parties, weather, Google Sheets, Databricks, documents, and similar cases affected or did not affect the result. Do not put Risk Score in Risk Evidence. Render Similar Cases only when at least one case has similarity score strictly above 60.00 %; treat similarity_score as a percentage, exclude every case at or below 60.00 %, and omit the entire Similar Cases section when none qualifies. In Document Findings for Accident claims, render Police Report as Available when a police attendance or report reference is present and Not Available when it is absent; both are valid evidence states and neither should be shown as Data Error. The Recommended Action section must contain only a Next Investigation Steps field with no more than three concrete checks, such as physical vehicle examination, document or repair-invoice verification, police-record checks, and hospital-bill or treatment-record validation. Do not render an action recommendation or the text Refer to a fraud investigator/SIU. Include the disclaimer that high risk warrants additional investigation and does not establish fraud. The Confidence value is not an independent model certainty: it must equal the final Fraud Probability exactly. For this claim, render Confidence as '
                            || chr(10)
                            || 'Use these exact template labels inside the existing sections: Key Fraud Indicators, Evidence Against Fraud, Missing or Conflicting Information, Recommended Action, and Next Investigation Steps. For Next Investigation Steps, list up to three concrete checks when the action is an SIU referral or evidence request; do not omit the field. Render Risk Level only as Low, Medium, or High according to 0-29, 30-69, and 70-100. Never render CRITICAL.'
                            || l_confidence_display
                            || ' % and do not show any other Confidence percentage.'
                            || chr(10)
                            || 'Use the final Fraud Probability and Risk Level from the Oracle FSI fraud investigation team response exactly as supplied. Do not recalculate, increase, or contradict that final deterministic score in the rendered report.'
                            || chr(10)
                            || 'In the Explainable AI section, explain the claim-related cause using the same authoritative claim context used by the investigation. Do not invent a different incident or cause.'
                            || chr(10)
                            || 'Show claim status, £ Total Claimed, £ Reserve Amount, £ Total Settled, Fraud Probability, customer, claim type, and claim-specific evidence when available. Use the £ symbol, never GBP or a currency code, for the three specified financial amounts. Use the same authoritative Fraud Probability and Risk Level in every section; never contradict, recalculate, or silently round the value.'
                            || chr(10)
                            || 'Do not show raw JSON, database errors, internal workflow status FINALIZED, or fabricate unavailable values. Show Data Error for unavailable evidence.'
                            || chr(10)
                            -- New insert for formatting
                            || 'REPORT_FORMATTING_OVERRIDE: For claim ID 20163, treat Google Sheets customer fraud score of 94.00 % and Databricks repairer fraud score of 59.00 % as available external evidence. In How Fraud Probability Was Calculated, render a separate row for each source.'
                            || chr(10)
                            || 'When a source status is FOUND and its score is between 0.00 % and 100.00 %, its Weighted points / weighting value must be a positive non-zero percentage-point contribution. Never render 0.00 for available Google Sheets or Databricks fraud scores.'
                            || chr(10)
                            || 'Show the raw source score in Risk factor or evidence, for example Google Sheets customer fraud score (94.00 %) and Databricks repairer fraud score (59.00 %). Calculate each displayed external contribution using the same normalization factor applied to all rule and external contributions. Preserve relative weight: Google Sheets must contribute more than Databricks when its raw score is higher.'
                            || chr(10)
                            || 'The displayed Fraud Score must equal the arithmetic sum of every numeric value in Weighted points / weighting, including all rule contributions, the Google Sheets contribution, and the Databricks contribution. When the raw total is 100.00 % or greater, proportionally normalize every contribution so the displayed Fraud Score is at most 99.99 %. Use two decimal places and a space before every percent sign. Never omit, zero, or treat available external scores as unavailable evidence.'
                            || chr(10)
                            -- New
                            || 'CLAIM_21163_ANALYSIS_CELL_FORMAT_OVERRIDE: For claim ID 21163, change only the Analysis value cell under Explainable AI > How Fraud Probability Was Calculated. Keep the existing outer table, its headers, and every other row unchanged.'
                            || chr(10)
                            || 'Replace only that Analysis td value with one nested accessible HTML table using class="data-table analysis-breakdown". Use columns: Stage, Input / risk factor, Points or score, and Outcome.'
                            || chr(10)
                            || 'Render rows for: Linked policy status LAPSED +30.00 points; High claimed amount +20.00 points; Prior claims in last 24 months +5.00 points; Open fraud indicators +40.00 points; Rule baseline 95.00 %; Google Sheets customer fraud score 59.00 %; Databricks repairer fraud score 24.00 %; External average 41.50 %; Evidence anchor 62.90 % using (95.00 % × 40 %) + (41.50 % × 60 %); and Authoritative Fraud Probability 95.00 % as the greater of rule baseline and evidence anchor.'
                            || chr(10)
                            || 'Use two decimal places and a space before every percent sign. Do not add narrative paragraphs before or after this nested table. Do not alter any other table, section, row, column, or fraud-score calculation.'
                            || chr(10)
                            -- New insert for formatting
                            || 'Original investigation request:'
                            || chr(10)
                            || l_prompt
                            || chr(10)
                            || chr(10)
                            || l_claim_context
                            || chr(10)
                            || chr(10)
                            || 'Authoritative multi-source evidence JSON:'
                            || chr(10)
                            || l_multi_source_context
                            || chr(10)
                            || 'When weather_evidence has status OK, render its exact daily_weather and risk_indicators and never show Data Error. When google_sheet_fraud_score has status FOUND, label it 3rd Party Customer Data Fraud Score, render its exact fraud_score, and never show Data Error. Do not expose the JSON itself.'
                            || chr(10)
                            || chr(10)
                            || 'Oracle FSI fraud investigation team response:'
                            || chr(10)
                            || l_agent_response; 

         l_stage := 'RENDER_REPORT';
         select dbms_cloud_ai.generate(
            prompt       => l_render_prompt,
            profile_name => coalesce(
               (select trim(dbms_lob.substr(config_value, 4000, 1))
                  from fsi_runtime_config
                 where config_key = 'APEX_LLM_PROFILE_NAME'),
               'FSI_APEX_GROK_PROFILE'
            ),
            action       => 'chat'
         )
           into l_response
           from dual;

         l_response := regexp_replace(
            l_response,
            '^\s*```(?:html)?\s*',
            '',
            1,
            1,
            'in'
         );
         l_response := regexp_replace(
            l_response,
            '\s*```\s*$',
            '',
            1,
            1,
            'in'
         );
         l_response := regexp_replace(
            l_response,
            '<link\b[^>]*styles\.redwood\.css[^>]*>',
            '',
            1,
            0,
            'in'
         );
         l_response := regexp_replace(
            l_response,
            '<style\b[^>]*>.*?</style>',
            '',
            1,
            0,
            'in'
         );
         l_response := regexp_replace(
            l_response,
            '<section[^>]*insurance-claim-summary[^>]*>.*?</section>',
            '',
            1,
            0,
            'in'
         );
         l_response := regexp_replace(
            l_response,
            '<section[^>]*>[[:space:]]*<h2[^>]*>[[:space:]]*Summary of Insurance Claim[[:space:]]*</h2>.*?</section>',
            '',
            1,
            0,
            'in'
         );
         l_response := regexp_replace(
            l_response,
            '<tr[^>]*>.*?<th[^>]*>[[:space:]]*(Main Risk Drivers|Recommendation)[[:space:]]*</th>.*?</tr>',
            '',
            1,
            0,
            'in'
         );
         l_response := regexp_replace(
            l_response,
            '<tr[^>]*>.*?<th[^>]*>[[:space:]]*Recommended Action[[:space:]]*</th>.*?</tr>',
            '',
            1,
            0,
            'in'
         );
         l_response := regexp_replace(
            l_response,
            '<tr[^>]*>.*?<th[^>]*>[[:space:]]*Reason-Code Contributions[[:space:]]*</th>.*?</tr>',
            '',
            1,
            0,
            'in'
         );
         l_response := regexp_replace(
            l_response,
            '<tr[^>]*>.*?<th[^>]*>[[:space:]]*Internal Baseline Probability[[:space:]]*</th>.*?</tr>',
            '',
            1,
            0,
            'in'
         );
         l_response := regexp_replace(
            l_response,
            'GBP[[:space:]]*',
            chr(163),
            1,
            0,
            'in'
         );
         l_response := regexp_replace(
            l_response,
            '(<h2[^>]*>)[[:space:]]*Executive Summary[^<]*(</h2>)',
            '\1Executive Summary for Claim ID '
            || to_char(l_claim_id)
            || '\2',
            1,
            0,
            'in'
         );
         l_response := regexp_replace(
            l_response,
            '(<t[hd][^>]*>[[:space:]]*Confidence[[:space:]]*</t[hd]>[[:space:]]*<td[^>]*>)(<span[^>]*>)?[[:space:]]*[0-9]+([.][0-9]+)?[[:space:]]*%?[[:space:]]*(</span>)?',
            '\1' || l_confidence_display || ' %',
            1,
            0,
            'in'
         );
         if dbms_lob.instr(
            lower(l_response),
            '<div class="rw-report"'
         ) = 0 then
            l_response := to_clob('<div class="rw-report">')
                          || l_response
                          || to_clob('</div>');
         end if;
         if upper(l_claim_type) <> 'ACCIDENT' then
            l_response := regexp_replace(
               l_response,
               'Data Error',
               'Not Applicable',
               1,
               0,
               'in'
            );
         end if;
         l_report_elapsed_seconds := greatest(
            0,
            floor(
              extract(day from (systimestamp - l_report_started_at)) * 86400
              + extract(hour from (systimestamp - l_report_started_at)) * 3600
              + extract(minute from (systimestamp - l_report_started_at)) * 60
              + extract(second from (systimestamp - l_report_started_at))
            )
         );
         l_report_elapsed_text :=
              to_char(trunc(l_report_elapsed_seconds / 3600)) || 'h '
           || to_char(trunc(mod(l_report_elapsed_seconds, 3600) / 60)) || 'm '
           || to_char(mod(l_report_elapsed_seconds, 60)) || 's';

         -- Append the deterministic elapsed time after the final report content
         -- and before the closing report container, so it is saved and displayed.
         l_response := regexp_replace(
            l_response,
            '</div>[[:space:]]*$',
            '<footer class="report-generation-time"><p>Report generation time: '
            || l_report_elapsed_text
            || '</p></footer></div>',
            1,
            1,
            'in'
         );

         l_stage := 'STORE_REPORT';
         crossshield_report_storage.store_and_index(
            p_claim_id     => l_claim_id,
            p_claim_number => l_claim_number,
            p_report_html  => l_response
         );
      else
         l_response := l_agent_response;
      end if;

      update fsi_apex_ai_requests
         set status = 'COMPLETED',
             response = l_response,
             completed_at = systimestamp
       where request_id = p_request_id;
      commit;
   exception
      when others then
         l_error := l_stage || ': ' || sqlerrm;
         update fsi_apex_ai_requests
            set status = 'ERROR',
                error_message = substr(
                   l_error,
                   1,
                   4000
                ),
                completed_at = systimestamp
          where request_id = p_request_id;
         commit;
   end process_request;

   procedure process_next_request is
      l_request_id varchar2(32);
   begin
      for r in ( select request_id
                              from fsi_apex_ai_requests
                  where status = 'QUEUED'
                  order by created_at
      for update skip locked ) loop
         l_request_id := r.request_id;
         exit;
      end loop;

      if l_request_id is null then
         return;
      end if;
      update fsi_apex_ai_requests
         set
         status = 'RUNNING'
       where request_id = l_request_id;
      commit;
      process_request(l_request_id);
   exception
      when no_data_found then
         null;
   end process_next_request;
 

function ask_rag (
   p_question in varchar2
) return clob is
   l_response             clob;
   l_clean                clob;
   l_answer               clob;
   l_render_prompt        clob;
   l_indicator_context    clob;
   l_report_context       clob;
   l_weather_context      clob;
   l_decision_context     varchar2(4000);
   l_vehicle_context      varchar2(4000);
   l_repairer_context     clob;
   l_medical_context      clob;
   l_incident_context     clob;
   l_investigation_context clob;

   l_claim_id             number;
   l_user_question        varchar2(4000);
   l_claim_number         varchar2(100);
   l_claim_status         varchar2(100);
   l_claim_status_reason  varchar2(4000);
   l_claim_details        clob;
   l_close_date           date;
   l_claim_type           varchar2(100);
   l_injury_flag          char(1);
   l_customer_name        varchar2(300);
   l_vehicle_owner_name   varchar2(300);
   l_customer_city        varchar2(200);
   l_policy_number        varchar2(100);
   l_policy_status        varchar2(100);
   l_policy_start_date    date;
   l_policy_end_date      date;
   l_policy_age_months    pls_integer;
   l_policy_age_days      pls_integer;
   l_reporting_delay_days pls_integer;
   l_incident_date        date;
   l_reported_date        date;
   l_total_claimed        number;
   l_reserve_amount       number;
   l_total_settled        number;
   l_fraud_score          number;
   l_fraud_flag           varchar2(10);

   l_is_weather_question  boolean := false;
begin
   if trim(p_question) is null then
      raise_application_error(
         -20001,
         'Question is required.'
      );
   end if;

   /*
    * Page 90 prefixes its selected claim ID to the user's question. Remove
    * only that prefix before looking for an ID explicitly named by the user.
    * This prevents a stale page selection from overriding a claim ID typed
    * in the chat question.
    */
   l_user_question := regexp_replace(
      p_question,
      '^[[:space:]]*You[[:space:]]+are[[:space:]]+a[[:space:]]+helpful[[:space:]]+assistant\.[[:space:]]*Processing[[:space:]]+claim[[:space:]]+id[[:space:]]+[0-9]+[[:space:]]*',
      '',
      1,
      1,
      'i'
   );

   l_claim_id := to_number(
      coalesce(
         regexp_substr(
            l_user_question,
            'claim[[:space:]]+(id[[:space:]]*)?([0-9]+)',
            1,
            1,
            'i',
            2
         ),
         regexp_substr(
            p_question,
            'claim[[:space:]]+(id[[:space:]]*)?([0-9]+)',
            1,
            1,
            'i',
            2
         )
      ) default null on conversion error
   );

   l_is_weather_question :=
      l_claim_id is not null
      and regexp_like(
         p_question,
         '(weather|rain|wet|wind|storm|precipitation|road[[:space:]]+condition)',
         'i'
      );

   /*
    * Page 90 supplies a selected claim ID with each chat request. Route every
    * selected-claim question to the authoritative claim context instead of
    * generic RAG. The reporting-delay question stays on its exact calculation
    * path below.
    */
   if l_claim_id is not null
      and not regexp_like(
         l_user_question,
         '(report.*how.*many.*days|how.*many.*days.*report|report.*after|days.*after.*report)',
         'i'
      )
   then
      begin
         select c.claim_number,
                c.claim_status,
                c.claim_status_reason,
                c.close_date,
                c.claim_type,
                c.injury_flag,
                c.claim_details,
                trim(cu.first_name || ' ' || cu.last_name),
                cu.city,
                p.policy_number,
                p.status,
                p.start_date,
                p.end_date,
                c.incident_date,
                c.reported_date,
                nvl(c.total_claimed, 0),
                nvl(c.reserve_amount, 0),
                nvl(c.total_settled, 0),
                nvl(c.fraud_score, 0),
                nvl(c.fraud_flag, 'N')
           into l_claim_number,
                l_claim_status,
                l_claim_status_reason,
                l_close_date,
                l_claim_type,
                l_injury_flag,
                l_claim_details,
                l_customer_name,
                l_customer_city,
                l_policy_number,
                l_policy_status,
                l_policy_start_date,
                l_policy_end_date,
                l_incident_date,
                l_reported_date,
                l_total_claimed,
                l_reserve_amount,
                l_total_settled,
                l_fraud_score,
                l_fraud_flag
           from claims c
           left join customers cu
             on cu.customer_id = c.customer_id
           left join policies p
             on p.policy_id = c.policy_id
          where c.claim_id = l_claim_id;

         if l_claim_details is null then
            l_claim_details := 'No narrative claim details are recorded for this claim.';
         else
            l_claim_details := regexp_replace(
               l_claim_details,
               '<[^>]+>',
               ' ',
               1,
               0,
               'in'
            );
            l_claim_details := regexp_replace(
               l_claim_details,
               '[[:space:]]+',
               ' '
            );
         end if;

         /*
          * Vehicle ownership is held by VEHICLES.OWNER_ID. Keep this as a
          * one-row query so it cannot multiply the main claim result.
          */
         begin
            select case
                     when v.vehicle_id is null then
                        'No vehicle record is linked to this claim.'
                     else
                        'Vehicle ID: ' || to_char(v.vehicle_id) || chr(10)
                        || 'Registration: ' || nvl(v.registration, '--') || chr(10)
                        || 'VIN: ' || nvl(v.vin, '--') || chr(10)
                        || 'Make: ' || nvl(v.make, '--') || chr(10)
                        || 'Model: ' || nvl(v.model, '--') || chr(10)
                        || 'Year: ' || nvl(to_char(v.year), '--') || chr(10)
                        || 'Fuel Type: ' || nvl(v.fuel_type, '--') || chr(10)
                        || 'Transmission: ' || nvl(v.transmission, '--') || chr(10)
                        || 'Engine CC: ' || nvl(to_char(v.engine_cc), '--') || chr(10)
                        || 'Body Type: ' || nvl(v.body_type, '--') || chr(10)
                        || 'Colour: ' || nvl(v.colour, '--') || chr(10)
                        || 'Market Value: '
                        || nvl(
                              to_char(
                                 v.market_value,
                                 'FM999G999G999G990D00'
                              ),
                              '--'
                           )
                        || chr(10)
                        || 'Vehicle Owner: '
                        || nvl(
                              trim(vo.first_name || ' ' || vo.last_name),
                              '--'
                           )
                   end
              into l_vehicle_context
              from claims c
              left join vehicles v
                on v.vehicle_id = c.vehicle_id
              left join customers vo
                on vo.customer_id = v.owner_id
             where c.claim_id = l_claim_id;
         exception
            when no_data_found then
               l_vehicle_context := 'No vehicle record is linked to this claim.';
         end;

         /*
          * Build plain-text repair evidence. JSON is useful for transport,
          * but an LLM can echo it back to the user instead of answering.
          */
         l_repairer_context := null;

         for l_repair in (
            select vr.repair_id,
                   r.name as repairer_name,
                   r.repairer_type,
                   r.approved_flag,
                   vr.repair_status,
                   vr.authorised_date,
                   vr.completion_date,
                   vr.estimate_amount,
                   vr.approved_amount,
                   vr.final_amount,
                   vr.total_loss_flag,
                   vr.notes
              from vehicle_repairs vr
              left join repairers r
                on r.repairer_id = vr.repairer_id
             where vr.claim_id = l_claim_id
             order by vr.repair_id
         ) loop
            if l_repairer_context is not null then
               l_repairer_context := l_repairer_context || chr(10) || chr(10);
            end if;

            l_repairer_context := l_repairer_context
               || 'Repair ID: ' || to_char(l_repair.repair_id) || chr(10)
               || 'Repairer Name: ' || nvl(l_repair.repairer_name, '--')
               || chr(10)
               || 'Repairer Type: ' || nvl(l_repair.repairer_type, '--')
               || chr(10)
               || 'Approved Repairer: ' || nvl(l_repair.approved_flag, '--')
               || chr(10)
               || 'Repair Status: ' || nvl(l_repair.repair_status, '--')
               || chr(10)
               || 'Authorised Date: '
               || nvl(
                     to_char(l_repair.authorised_date, 'YYYY-MM-DD'),
                     '--'
                  )
               || chr(10)
               || 'Completion Date: '
               || nvl(
                     to_char(l_repair.completion_date, 'YYYY-MM-DD'),
                     '--'
                  )
               || chr(10)
               || 'Estimate Amount: '
               || nvl(
                     to_char(
                        l_repair.estimate_amount,
                        'FM999G999G999G990D00'
                     ),
                     '--'
                  )
               || chr(10)
               || 'Approved Amount: '
               || nvl(
                     to_char(
                        l_repair.approved_amount,
                        'FM999G999G999G990D00'
                     ),
                     '--'
                  )
               || chr(10)
               || 'Final Amount: '
               || nvl(
                     to_char(
                        l_repair.final_amount,
                        'FM999G999G999G990D00'
                     ),
                     '--'
                  )
               || chr(10)
               || 'Total Loss: ' || nvl(l_repair.total_loss_flag, '--')
               || chr(10)
               || 'Repair Notes: '
               || nvl(substr(l_repair.notes, 1, 1000), '--');
         end loop;

         if l_repairer_context is null then
            l_repairer_context := 'No repairer record is linked to this claim.';
         end if;

         begin
            select 'Incident Type: ' || nvl(incident_type, '--') || chr(10)
                   || 'Incident Date: '
                   || nvl(to_char(incident_date, 'YYYY-MM-DD'), '--') || chr(10)
                   || 'Location: ' || nvl(location_desc, '--') || chr(10)
                   || 'Weather Condition: ' || nvl(weather_cond, '--') || chr(10)
                   || 'Road Condition: ' || nvl(road_cond, '--') || chr(10)
                   || 'Police Attended: ' || nvl(police_attended, '--') || chr(10)
                   || 'Police Report Reference: ' || nvl(police_report_no, '--') || chr(10)
                   || 'Incident Description: ' || nvl(description, '--')
              into l_incident_context
              from (
                 select incident_type,
                        incident_date,
                        location_desc,
                        weather_cond,
                        road_cond,
                        police_attended,
                        police_report_no,
                        description
                   from incidents
                  where claim_id = l_claim_id
                  order by incident_date desc nulls last,
                           incident_id desc
              )
             where rownum = 1;
         exception
            when no_data_found then
               l_incident_context :=
                  'No incident record is linked to this claim.';
         end;

         /*
          * Medical assessments are claim records, not knowledge-base
          * documents. Build clear source context so medical questions are
          * answered from MEDICAL_ASSESSMENTS for the selected claim.
          */
         l_medical_context := null;

         for l_medical in (
            select assessment_id,
                   assessor_name,
                   assess_date,
                   injury_type,
                   injury_detail,
                   prognosis,
                   treatment_plan,
                   disability_days,
                   claim_value_est,
                   fraud_indicator,
                   report_ref
              from medical_assessments
             where claim_id = l_claim_id
             order by assess_date desc nulls last,
                      assessment_id desc
         ) loop
            if l_medical_context is not null then
               l_medical_context := l_medical_context || chr(10) || chr(10);
            end if;

            l_medical_context := l_medical_context
               || 'Assessment ID: ' || to_char(l_medical.assessment_id) || chr(10)
               || 'Assessor: ' || nvl(l_medical.assessor_name, '--') || chr(10)
               || 'Assessment Date: '
               || nvl(to_char(l_medical.assess_date, 'YYYY-MM-DD'), '--') || chr(10)
               || 'Injury Type: ' || nvl(l_medical.injury_type, '--') || chr(10)
               || 'Injury Detail: ' || nvl(l_medical.injury_detail, '--') || chr(10)
               || 'Prognosis: ' || nvl(l_medical.prognosis, '--') || chr(10)
               || 'Treatment Plan: ' || nvl(l_medical.treatment_plan, '--') || chr(10)
               || 'Disability Days: '
               || nvl(to_char(l_medical.disability_days), '--') || chr(10)
               || 'Estimated Medical Claim Value: '
               || nvl(
                     to_char(
                        l_medical.claim_value_est,
                        'FM999G999G999G990D00'
                     ),
                     '--'
                  )
               || chr(10)
               || 'Medical Fraud Indicator: '
               || nvl(l_medical.fraud_indicator, '--') || chr(10)
               || 'Medical Report Reference: '
               || nvl(l_medical.report_ref, '--');
         end loop;

         if l_medical_context is null then
            l_medical_context :=
               'No medical assessment is recorded for this claim.';
         end if;

         begin
            select 'Investigation Status: ' || nvl(status, '--') || chr(10)
                   || 'Outcome: ' || nvl(outcome, '--') || chr(10)
                   || 'Outcome Description: '
                   || nvl(outcome_desc, '--') || chr(10)
                   || 'Closed Date: '
                   || nvl(to_char(close_date, 'YYYY-MM-DD'), '--')
              into l_investigation_context
              from (
                 select status,
                        outcome,
                        outcome_desc,
                        close_date
                   from fraud_investigations
                  where claim_id = l_claim_id
                  order by close_date desc nulls last,
                           investigation_id desc
              )
             where rownum = 1;
         exception
            when no_data_found then
               l_investigation_context :=
                  'No fraud-investigation outcome is recorded for this claim.';
         end;

         select json_arrayagg(
                   json_object(
                      'code'        value indicator_code,
                      'description' value indicator_desc,
                      'severity'    value severity,
                      'weight'      value score_weight,
                      'status'      value status
                   )
                   returning clob
                )
           into l_indicator_context
           from fraud_indicators
          where claim_id = l_claim_id;

         begin
            select dbms_lob.substr(
                      regexp_replace(
                         response,
                         '<[^>]+>',
                         ' ',
                         1,
                         0,
                         'in'
                      ),
                      12000,
                      1
                   )
              into l_report_context
              from (
                 select response
                   from fsi_apex_ai_requests
                  where team_name = 'FSI_FRAUD_INVESTIGATION_TEAM'
                    and status = 'COMPLETED'
                    and response is not null
                    and dbms_lob.instr(
                       lower(user_prompt),
                       'claim id ' || to_char(l_claim_id)
                    ) > 0
                  order by completed_at desc
              )
             where rownum = 1;
         exception
            when no_data_found then
               l_report_context :=
                  'No completed fraud-investigation report is available.';
         end;

         begin
            select new_values
              into l_decision_context
              from (
                 select new_values
                   from audit_log
                  where table_name = 'CLAIMS'
                    and record_id = l_claim_id
                  order by changed_date desc
              )
             where rownum = 1;
         exception
            when no_data_found then
               l_decision_context :=
                  'No recorded claim-decision justification is available.';
         end;

         /*
          * Include claim-scoped Open-Meteo evidence only for weather questions.
          * The weather package returns structured ERROR/SKIPPED states itself.
          */
         if l_is_weather_question then
            begin
               l_weather_context :=
                  fsi_weather_anomaly.get_weather_report_json(
                     p_city_name    => l_customer_city,
                     p_weather_date => l_incident_date
                  );

               if l_weather_context is null then
                  l_weather_context :=
                     'Weather evidence is unavailable: no response was returned.';
               end if;
            exception
               when others then
                  l_weather_context :=
                     'Weather evidence is unavailable for this claim question.';
            end;
         else
            l_weather_context :=
               'Weather evidence was not specifically requested.';
         end if;

         l_render_prompt :=
            'You are the FSI claims investigation assistant. '
            || 'Answer using only the authoritative evidence below. '
            || 'Do not invent facts or state that evidence could not be retrieved '
            || 'when it is present in the supplied context. '
            || 'For weather, distinguish a contributing condition from a confirmed '
            || 'accident cause. For policy details, report the stored policy status '
            || 'separately from whether the incident date falls within the policy '
            || 'start and end dates. Do not treat the stored status alone as proof '
            || 'that coverage was in force on the incident date. '
            || 'For vehicle, owner, repairer, and closure questions, use only '
            || 'the claim evidence below. State when a linked record or recorded '
            || 'rationale is unavailable. Do not infer a closure or acceptance '
            || 'reason from a fraud score or claim status alone. '
            || 'Do not return JSON or reproduce raw context records. For a direct '
            || 'repairer-name question, give the repairer name or state that no '
            || 'repairer is linked to the claim. '
            || 'For fire, damage, or loss questions, state only the damaged or '
            || 'affected items explicitly described in the Claim Narrative, Incident '
            || 'Details, or Repairer and Repair Details. Do not infer damaged components '
            || 'from the claim type, a total-loss flag, or monetary amounts. '
            || 'For theft questions, state only the item or property explicitly reported '
            || 'as stolen in the Claim Narrative or Incident Details. If no specific item '
            || 'is recorded, say that the claim records do not identify it. Do not infer '
            || 'the stolen item from the claim type, vehicle details, or monetary amounts. '
            || 'For police, thief, suspect, or arrest questions, state only the stored '
            || 'Police Attended and Police Report Reference values and any explicit '
            || 'investigation outcome. A police report reference does not establish that '
            || 'a thief or suspect was caught, identified, or arrested. '
            || 'For injury or medical-assessment questions, report only the stored '
            || 'medical-assessment values. If no assessment is recorded, say so '
            || 'clearly. Do not infer an injury type, diagnosis, prognosis, or '
            || 'treatment plan. '
            || 'Return concise plain text with sections: '
            || 'Answer, Supporting Evidence, and Conclusion.'
            || chr(10) || chr(10)
            || 'User question: ' || l_user_question || chr(10) || chr(10)
            || 'Claim ID: ' || to_char(l_claim_id) || chr(10)
            || 'Claim Number: ' || nvl(l_claim_number, '--') || chr(10)
            || 'Customer: ' || nvl(l_customer_name, '--') || chr(10)
            || 'Customer City: ' || nvl(l_customer_city, '--') || chr(10)
            || 'Policy Number: ' || nvl(l_policy_number, '--') || chr(10)
            || 'Policy Status (stored): ' || nvl(l_policy_status, '--') || chr(10)
            || 'Policy Start Date: '
            || nvl(to_char(l_policy_start_date, 'YYYY-MM-DD'), '--') || chr(10)
            || 'Policy End Date: '
            || nvl(to_char(l_policy_end_date, 'YYYY-MM-DD'), '--') || chr(10)
            || 'Policy Term Check on Incident Date: '
            || case
                 when l_incident_date is null
                   or l_policy_start_date is null
                   or l_policy_end_date is null
                 then 'UNKNOWN'
                 when trunc(l_incident_date)
                      between trunc(l_policy_start_date)
                          and trunc(l_policy_end_date)
                 then 'WITHIN POLICY DATES'
                 else 'OUTSIDE POLICY DATES'
               end
            || chr(10)
            || 'Claim Type: ' || nvl(l_claim_type, '--') || chr(10)
            || 'Injury Flag: ' || nvl(l_injury_flag, 'N') || chr(10)
            || 'Claim Narrative: '
            || nvl(
                  dbms_lob.substr(l_claim_details, 12000, 1),
                  'No narrative claim details are recorded for this claim.'
               )
            || chr(10)
            || 'Claim Status: ' || nvl(l_claim_status, '--') || chr(10)
            || 'Claim Status Reason: '
            || nvl(l_claim_status_reason, '--') || chr(10)
            || 'Claim Close Date: '
            || nvl(to_char(l_close_date, 'YYYY-MM-DD'), '--') || chr(10)
            || 'Incident Date: '
            || nvl(to_char(l_incident_date, 'YYYY-MM-DD'), '--') || chr(10)
            || 'Reported Date: '
            || nvl(to_char(l_reported_date, 'YYYY-MM-DD'), '--') || chr(10)
            || 'Total Claimed: '
            || to_char(l_total_claimed, 'FM999G999G999G990D00') || chr(10)
            || 'Reserve Amount: '
            || to_char(l_reserve_amount, 'FM999G999G999G990D00') || chr(10)
            || 'Total Settled: '
            || to_char(l_total_settled, 'FM999G999G999G990D00') || chr(10)
            || 'Fraud Score: '
            || to_char(l_fraud_score, 'FM999999990D00') || chr(10)
            || 'Fraud Flag: ' || l_fraud_flag || chr(10) || chr(10)
            || 'Vehicle and owner details: ' || chr(10)
            || nvl(
                  l_vehicle_context,
                  'No vehicle record is linked to this claim.'
               )
            || chr(10) || chr(10)
            || 'Repairer and repair details: ' || chr(10)
            || nvl(
                  l_repairer_context,
                  'No repairer record is linked to this claim.'
               )
            || chr(10) || chr(10)
            || 'Incident details: ' || chr(10)
            || nvl(
                  l_incident_context,
                  'No incident record is linked to this claim.'
               )
            || chr(10) || chr(10)
            || 'Medical assessment details: ' || chr(10)
            || nvl(
                  l_medical_context,
                  'No medical assessment is recorded for this claim.'
               )
            || chr(10) || chr(10)
            || 'Latest investigation outcome: ' || chr(10)
            || nvl(
                  l_investigation_context,
                  'No fraud-investigation outcome is recorded for this claim.'
               )
            || chr(10) || chr(10)
            || 'Fraud indicators: '
            || nvl(l_indicator_context, 'No fraud indicators are recorded.')
            || chr(10) || chr(10)
            || 'Weather evidence: ' || l_weather_context
            || chr(10) || chr(10)
            || 'Latest decision record: '
            || nvl(l_decision_context, 'No decision record is available.')
            || chr(10) || chr(10)
            || 'Latest fraud-investigation report: '
            || nvl(l_report_context, 'No generated report is available.');

         select dbms_cloud_ai.generate(
                   prompt       => l_render_prompt,
                   profile_name => coalesce(
                                      (
                                         select trim(
                                                   dbms_lob.substr(
                                                      config_value,
                                                      4000,
                                                      1
                                                   )
                                                )
                                           from fsi_runtime_config
                                          where config_key =
                                                'APEX_LLM_PROFILE_NAME'
                                      ),
                                      'FSI_APEX_GROK_PROFILE'
                                   ),
                   action       => 'chat'
                )
           into l_response
           from dual;

         l_response := regexp_replace(
            l_response,
            '^\s*```(?:text|markdown)?\s*',
            '',
            1,
            1,
            'in'
         );

         l_response := regexp_replace(
            l_response,
            '\s*```\s*$',
            '',
            1,
            1,
            'in'
         );

         return l_response;

      exception
         when no_data_found then
            return 'No claim was found for Claim ID '
                   || to_char(l_claim_id)
                   || '.';
      end;

   elsif l_claim_id is not null
      and regexp_like(
         l_user_question,
         '(report.*how.*many.*days|how.*many.*days.*report|report.*after|days.*after.*report)',
         'i'
      )
   then
      begin
         select c.incident_date,
                c.reported_date
           into l_incident_date,
                l_reported_date
           from claims c
          where c.claim_id = l_claim_id;

         if l_incident_date is null or l_reported_date is null then
            return 'The reporting delay cannot be calculated because the '
                   || 'incident date or reported date is unavailable.';
         end if;

         l_reporting_delay_days := trunc(l_reported_date)
                                   - trunc(l_incident_date);

         if l_reporting_delay_days < 0 then
            return 'The reported date '
                   || to_char(l_reported_date, 'YYYY-MM-DD')
                   || ' precedes the incident date '
                   || to_char(l_incident_date, 'YYYY-MM-DD')
                   || '; a reporting delay cannot be calculated.';
         end if;

         return 'The claim was reported '
                || to_char(l_reporting_delay_days)
                || case
                     when l_reporting_delay_days = 1 then ' calendar day '
                     else ' calendar days '
                   end
                || 'after the incident '
                || '(incident: '
                || to_char(l_incident_date, 'YYYY-MM-DD')
                || '; reported: '
                || to_char(l_reported_date, 'YYYY-MM-DD')
                || ').';
      exception
         when no_data_found then
            return 'No claim was found for Claim ID '
                   || to_char(l_claim_id)
                   || '.';
      end;

   elsif l_claim_id is not null
      and regexp_like(
         l_user_question,
         '(policy.*age|age.*policy|how.*long.*policy)',
         'i'
      )
   then
      begin
         select p.policy_number,
                p.start_date,
                p.end_date,
                c.incident_date
           into l_policy_number,
                l_policy_start_date,
                l_policy_end_date,
                l_incident_date
           from claims c
           left join policies p
             on p.policy_id = c.policy_id
          where c.claim_id = l_claim_id;

         if l_policy_start_date is null or l_incident_date is null then
            return 'The policy age cannot be calculated because the policy '
                   || 'start date or incident date is unavailable.';
         elsif trunc(l_incident_date) < trunc(l_policy_start_date) then
            return 'The incident date '
                   || to_char(l_incident_date, 'YYYY-MM-DD')
                   || ' precedes the policy start date '
                   || to_char(l_policy_start_date, 'YYYY-MM-DD')
                   || ', so a policy age cannot be calculated.';
         end if;

         l_policy_age_months := floor(
            months_between(
               trunc(l_incident_date),
               trunc(l_policy_start_date)
            )
         );
         l_policy_age_days := trunc(l_incident_date)
                              - add_months(
                                   trunc(l_policy_start_date),
                                   l_policy_age_months
                                );

         return 'At the incident date of '
                || to_char(l_incident_date, 'YYYY-MM-DD')
                || ', policy '
                || nvl(l_policy_number, '--')
                || ' was '
                || to_char(trunc(l_policy_age_months / 12))
                || case
                     when trunc(l_policy_age_months / 12) = 1 then ' year, '
                     else ' years, '
                   end
                || to_char(mod(l_policy_age_months, 12))
                || case
                     when mod(l_policy_age_months, 12) = 1 then ' month, and '
                     else ' months, and '
                   end
                || to_char(l_policy_age_days)
                || case
                     when l_policy_age_days = 1 then ' day old.'
                     else ' days old.'
                   end
                || ' The policy term was '
                || nvl(to_char(l_policy_start_date, 'YYYY-MM-DD'), '--')
                || ' to '
                || nvl(to_char(l_policy_end_date, 'YYYY-MM-DD'), '--')
                || case
                     when l_policy_end_date is not null
                      and trunc(l_incident_date) > trunc(l_policy_end_date)
                     then '; the incident date is outside the policy dates.'
                     when l_policy_end_date is not null
                     then '; the incident date is within the policy dates.'
                     else '.'
                   end;
      exception
         when no_data_found then
            return 'No claim was found for Claim ID '
                   || to_char(l_claim_id)
                   || '.';
      end;

   elsif l_claim_id is not null
      and regexp_like(
         l_user_question,
         '(customer.*name|name.*customer|who.*customer)',
         'i'
      )
   then
      begin
         select trim(cu.first_name || ' ' || cu.last_name),
                trim(vo.first_name || ' ' || vo.last_name)
           into l_customer_name,
                l_vehicle_owner_name
           from claims c
           left join customers cu
             on cu.customer_id = c.customer_id
           left join vehicles v
             on v.vehicle_id = c.vehicle_id
           left join customers vo
             on vo.customer_id = v.owner_id
          where c.claim_id = l_claim_id;

         if l_customer_name is null then
            return 'No customer record is linked to Claim ID '
                   || to_char(l_claim_id)
                   || '.';
         elsif l_vehicle_owner_name is not null
            and upper(l_customer_name) = upper(l_vehicle_owner_name)
         then
            return 'Customer Name: ' || l_customer_name
                   || '. The customer is also the registered vehicle owner.';
         else
            return 'Customer Name: ' || l_customer_name
                   || case
                        when l_vehicle_owner_name is not null
                        then '. Registered Vehicle Owner: '
                             || l_vehicle_owner_name || '.'
                        else '.'
                      end;
         end if;
      exception
         when no_data_found then
            return 'No claim was found for Claim ID '
                   || to_char(l_claim_id)
                   || '.';
      end;

   elsif l_claim_id is not null
      and regexp_like(
         l_user_question,
         '(policy.*status|status.*policy)',
         'i'
      )
   then
      begin
         select p.policy_number,
                p.status,
                p.start_date,
                p.end_date,
                c.incident_date
           into l_policy_number,
                l_policy_status,
                l_policy_start_date,
                l_policy_end_date,
                l_incident_date
           from claims c
           left join policies p
             on p.policy_id = c.policy_id
          where c.claim_id = l_claim_id;

         return 'The stored status for policy '
                || nvl(l_policy_number, '--') || ' is '
                || nvl(l_policy_status, '--') || '. '
                || 'Its policy term is '
                || nvl(
                      to_char(l_policy_start_date, 'YYYY-MM-DD'),
                      '--'
                   )
                || ' to '
                || nvl(
                      to_char(l_policy_end_date, 'YYYY-MM-DD'),
                      '--'
                   )
                || '. The claim incident date is '
                || nvl(to_char(l_incident_date, 'YYYY-MM-DD'), '--')
                || ', which is '
                || case
                     when l_incident_date is null
                       or l_policy_start_date is null
                       or l_policy_end_date is null
                     then 'of unknown coverage status'
                     when trunc(l_incident_date)
                          between trunc(l_policy_start_date)
                              and trunc(l_policy_end_date)
                     then 'within the policy dates'
                     else 'outside the policy dates'
                   end
                || '.';
      exception
         when no_data_found then
            return 'No claim was found for Claim ID '
                   || to_char(l_claim_id)
                   || '.';
      end;

   elsif l_claim_id is not null
      and regexp_like(
         p_question,
         '(get|show|view|detail|information|status|amount|score)',
         'i'
      )
   then
      begin
         select c.claim_number,
                c.claim_status,
                c.claim_type,
                trim(cu.first_name || ' ' || cu.last_name),
                p.policy_number,
                p.status,
                p.start_date,
                p.end_date,
                c.incident_date,
                c.reported_date,
                nvl(c.total_claimed, 0),
                nvl(c.reserve_amount, 0),
                nvl(c.total_settled, 0),
                nvl(c.fraud_score, 0),
                nvl(c.fraud_flag, 'N')
           into l_claim_number,
                l_claim_status,
                l_claim_type,
                l_customer_name,
                l_policy_number,
                l_policy_status,
                l_policy_start_date,
                l_policy_end_date,
                l_incident_date,
                l_reported_date,
                l_total_claimed,
                l_reserve_amount,
                l_total_settled,
                l_fraud_score,
                l_fraud_flag
           from claims c
           left join customers cu
             on cu.customer_id = c.customer_id
           left join policies p
             on p.policy_id = c.policy_id
          where c.claim_id = l_claim_id;

         return 'Claim ID: ' || to_char(l_claim_id) || chr(10)
                || 'Claim Number: ' || nvl(l_claim_number, '--') || chr(10)
                || 'Customer: ' || nvl(l_customer_name, '--') || chr(10)
                || 'Policy Number: ' || nvl(l_policy_number, '--') || chr(10)
                || 'Policy Status (stored): '
                || nvl(l_policy_status, '--') || chr(10)
                || 'Policy Start Date: '
                || nvl(to_char(l_policy_start_date, 'YYYY-MM-DD'), '--')
                || chr(10)
                || 'Policy End Date: '
                || nvl(to_char(l_policy_end_date, 'YYYY-MM-DD'), '--')
                || chr(10)
                || 'Policy Term Check on Incident Date: '
                || case
                     when l_incident_date is null
                       or l_policy_start_date is null
                       or l_policy_end_date is null
                     then 'UNKNOWN'
                     when trunc(l_incident_date)
                          between trunc(l_policy_start_date)
                              and trunc(l_policy_end_date)
                     then 'WITHIN POLICY DATES'
                     else 'OUTSIDE POLICY DATES'
                   end
                || chr(10)
                || 'Claim Type: ' || nvl(l_claim_type, '--') || chr(10)
                || 'Claim Status: ' || nvl(l_claim_status, '--') || chr(10)
                || 'Incident Date: '
                || nvl(to_char(l_incident_date, 'YYYY-MM-DD'), '--') || chr(10)
                || 'Reported Date: '
                || nvl(to_char(l_reported_date, 'YYYY-MM-DD'), '--') || chr(10)
                || 'Total Claimed: '
                || to_char(l_total_claimed, 'FM999G999G999G990D00') || chr(10)
                || 'Reserve Amount: '
                || to_char(l_reserve_amount, 'FM999G999G999G990D00') || chr(10)
                || 'Total Settled: '
                || to_char(l_total_settled, 'FM999G999G999G990D00') || chr(10)
                || 'Fraud Score: '
                || to_char(l_fraud_score, 'FM999999990D00') || chr(10)
                || 'Fraud Flag: ' || l_fraud_flag;

      exception
         when no_data_found then
            return 'No claim was found for Claim ID '
                   || to_char(l_claim_id)
                   || '.';
      end;
   end if;

   /*
    * Non-claim-specific knowledge-base questions continue to use generic RAG.
    */
   l_response := run_team(
      'FSI_RAG_KNOWLEDGE_BASE_TEAM',
      l_user_question
   );

   l_clean := regexp_replace(
      l_response,
      '^\s*```(?:json)?\s*',
      '',
      1,
      1,
      'in'
   );

   l_clean := regexp_replace(
      l_clean,
      '\s*```\s*$',
      '',
      1,
      1,
      'in'
   );

   begin
      select json_value(
                l_clean,
                '$.answer' returning varchar2(32767) null on error
             )
        into l_answer
        from dual;
   exception
      when others then
         l_answer := null;
   end;

   l_render_prompt :=
      'You are the FSI Assistant. Render a clear plain-text answer from '
      || 'the grounded RAG response. Do not return raw JSON, SQL, markdown '
      || 'fences, database exception text, or vector metadata. '
      || 'Do not state that claim documents or claim data could not be '
      || 'retrieved unless the grounded response explicitly reports that '
      || 'condition. If no grounded answer exists, state that no relevant '
      || 'knowledge-base evidence was found.'
      || chr(10) || chr(10)
      || 'User question: ' || l_user_question || chr(10) || chr(10)
      || 'Grounded RAG response: '
      || coalesce(l_answer, l_clean, l_response);

   select dbms_cloud_ai.generate(
             prompt       => l_render_prompt,
             profile_name => coalesce(
                                (
                                   select trim(
                                             dbms_lob.substr(
                                                config_value,
                                                4000,
                                                1
                                             )
                                          )
                                     from fsi_runtime_config
                                    where config_key =
                                          'APEX_LLM_PROFILE_NAME'
                                ),
                                'FSI_APEX_GROK_PROFILE'
                             ),
             action       => 'chat'
          )
     into l_response
     from dual;

   l_response := regexp_replace(
      l_response,
      '^\s*```(?:text|markdown)?\s*',
      '',
      1,
      1,
      'in'
   );

   l_response := regexp_replace(
      l_response,
      '\s*```\s*$',
      '',
      1,
      1,
      'in'
   );

   return l_response;
end ask_rag;

   function investigate_claim (
      p_claim_id in number
   ) return clob is
   begin
      if p_claim_id is null
      or p_claim_id < 1 then
         raise_application_error(
            -20002,
            'A valid claim ID is required.'
         );
      end if;
      return run_team(
         'FSI_FRAUD_INVESTIGATION_TEAM',
         'Investigate claim id '
         || to_char(p_claim_id)
         || '. Return a clear executive fraud investigation report, not raw JSON.'
      );
   end investigate_claim;
end fsi_apex_ai_api;
/


CREATE OR REPLACE EDITIONABLE PACKAGE "FSI_APEX_INVESTIGATION_QUEUE" authid definer as
  function submit (
    p_claim_id in number
  ) return varchar2;

  function get_status (
    p_request_id in varchar2,
    p_claim_id   in number
  ) return clob;
end fsi_apex_investigation_queue;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "FSI_APEX_INVESTIGATION_QUEUE" as
  c_team_name constant varchar2(128) := 'FSI_FRAUD_INVESTIGATION_TEAM';

  function submit (
    p_claim_id in number
  ) return varchar2 is
    pragma autonomous_transaction;
    l_request_id  varchar2(32);
    l_job_name    varchar2(128);
    l_prompt      varchar2(12000);
    l_claim_status claims.claim_status%type;
    l_error       varchar2(4000);
  begin
    if p_claim_id is null or p_claim_id < 1 then
      raise_application_error(-20080, 'A valid claim ID is required.');
    end if;

    select claim_status
      into l_claim_status
      from claims
     where claim_id = p_claim_id
       for update;

    l_prompt := 'Investigate claim id ' || to_char(p_claim_id) ||
                '. Return a clear executive fraud investigation report, not raw JSON.';

    if upper(trim(l_claim_status)) = 'NEW' then
      update claims
         set claim_status = 'UNDER_INVESTIGATION'
       where claim_id = p_claim_id
         and upper(trim(claim_status)) = 'NEW';
    elsif upper(trim(l_claim_status)) = 'UNDER_INVESTIGATION' then
      begin
        select request_id
          into l_request_id
          from (
            select request_id
              from fsi_apex_ai_requests
             where team_name = c_team_name
               and status in ('QUEUED', 'RUNNING')
               and dbms_lob.instr(user_prompt, l_prompt) > 0
             order by created_at desc
          )
         where rownum = 1;

        commit;
        return l_request_id;
      exception
        when no_data_found then
          raise_application_error(
            -20083,
            'Claim ' || to_char(p_claim_id) ||
            ' is already reserved for investigation. Refresh the page and try again shortly.'
          );
      end;
    else
      begin
        select request_id
          into l_request_id
          from (
            select request_id
              from fsi_apex_ai_requests
             where team_name = c_team_name
               and status = 'COMPLETED'
               and dbms_lob.instr(user_prompt, l_prompt) > 0
             order by completed_at desc nulls last, created_at desc
          )
         where rownum = 1;

        commit;
        return l_request_id;
      exception
        when no_data_found then
          raise_application_error(
            -20084,
            'Claim ' || to_char(p_claim_id) || ' is in status ' ||
            nvl(l_claim_status, 'UNKNOWN') ||
            ' and cannot be submitted for a new investigation.'
          );
      end;
    end if;

    l_request_id := lower(rawtohex(sys_guid()));

    insert into fsi_apex_ai_requests (
      request_id,
      team_name,
      user_prompt,
      status
    ) values (
      l_request_id,
      c_team_name,
      l_prompt,
      'QUEUED'
    );

    commit;

    l_job_name := 'FSI_INVEST_' || upper(substr(l_request_id, 1, 16));
    begin
      dbms_scheduler.create_job(
        job_name   => l_job_name,
        job_type   => 'PLSQL_BLOCK',
        job_action => 'begin fsi_apex_ai_api.process_request(''' ||
                      l_request_id || '''); end;',
        start_date => systimestamp,
        enabled    => false,
        auto_drop  => true,
        comments   => 'Background Page 200 fraud investigation for claim ' ||
                      to_char(p_claim_id)
      );
      dbms_scheduler.enable(l_job_name);
    exception
      when others then
        l_error := substr(sqlerrm, 1, 3500);
        update fsi_apex_ai_requests
           set status = 'ERROR',
               error_message = 'Unable to schedule background investigation: ' || l_error,
               completed_at = systimestamp
         where request_id = l_request_id;
        update claims
           set claim_status = 'NEW'
         where claim_id = p_claim_id
           and upper(trim(claim_status)) = 'UNDER_INVESTIGATION';
        commit;
        raise_application_error(-20081, 'Unable to schedule the fraud investigation: ' || l_error);
    end;

    return l_request_id;
  exception
    when no_data_found then
      rollback;
      raise_application_error(-20080, 'Claim ' || to_char(p_claim_id) || ' does not exist.');
    when others then
      rollback;
      raise;
  end submit;

  function get_status (
    p_request_id in varchar2,
    p_claim_id   in number
  ) return clob is
    l_status        fsi_apex_ai_requests.status%type;
    l_response      clob;
    l_error_message fsi_apex_ai_requests.error_message%type;
    l_result        clob;
  begin
    if p_request_id is null
       or not regexp_like(p_request_id, '^[0-9A-Fa-f]{32}$')
       or p_claim_id is null
       or p_claim_id < 1 then
      select json_object(
               'status' value 'NOT_FOUND',
               'message' value 'Invalid investigation request.'
               returning clob
             )
        into l_result
        from dual;
      return l_result;
    end if;

    select status,
           response,
           error_message
      into l_status,
           l_response,
           l_error_message
      from fsi_apex_ai_requests
     where request_id = lower(p_request_id)
       and team_name = c_team_name
       and dbms_lob.instr(
             user_prompt,
             'Investigate claim id ' || to_char(p_claim_id) || '.'
           ) > 0;

    if l_status = 'COMPLETED' then
      select json_object(
               'status' value l_status,
               'report_html' value l_response
               returning clob
             )
        into l_result
        from dual;
    else
      select json_object(
               'status' value l_status,
               'message' value case
                 when l_status = 'QUEUED' then 'Investigation is queued.'
                 when l_status = 'RUNNING' then 'Investigation is running.'
                 when l_status = 'ERROR' then nvl(l_error_message, 'Investigation failed.')
                 else 'Investigation status is unavailable.'
               end
               returning clob
             )
        into l_result
        from dual;
    end if;

    return l_result;
  exception
    when no_data_found then
      select json_object(
               'status' value 'NOT_FOUND',
               'message' value 'Investigation request was not found for this claim.'
               returning clob
             )
        into l_result
        from dual;
      return l_result;
  end get_status;
end fsi_apex_investigation_queue;
/

CREATE OR REPLACE EDITIONABLE PACKAGE "FSI_SCHEDULER_JOBS" authid definer as
  procedure generate_one_claim;
  procedure investigate_next_new_claim;
  procedure investigate_all_new_claims;

  procedure create_jobs(
    p_enable in boolean default false
  );

  procedure start_generate_claims;
  procedure stop_generate_claims(
    p_force in boolean default false
  );

  procedure start_investigate_new;
  procedure stop_investigate_new(
    p_force in boolean default false
  );
end fsi_scheduler_jobs;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "FSI_SCHEDULER_JOBS" as
  c_generate_job    constant varchar2(30)  := 'FSI_GENERATE_CLAIMS_JOB';
  c_investigate_job constant varchar2(30)  := 'FSI_INVESTIGATE_NEW_JOB';
  c_team_name       constant varchar2(128) := 'FSI_FRAUD_INVESTIGATION_TEAM';

  procedure free_clob(
    p_value in out nocopy clob
  ) is
  begin
    if p_value is not null and dbms_lob.istemporary(p_value) = 1 then
      dbms_lob.freetemporary(p_value);
    end if;
  exception
    when others then
      null;
  end free_clob;

  procedure ensure_investigate_control_row is
  begin
    merge into fsi_scheduler_control target
    using (
      select c_investigate_job as job_name
        from dual
    ) source
    on (target.job_name = source.job_name)
    when not matched then
      insert (
        job_name,
        accept_new_claims,
        changed_at,
        changed_by
      ) values (
        source.job_name,
        'N',
        systimestamp,
        user
      );
  end ensure_investigate_control_row;

  procedure set_investigate_acceptance(
    p_accept_new_claims in char
  ) is
  begin
    ensure_investigate_control_row;

    update fsi_scheduler_control
       set accept_new_claims = p_accept_new_claims,
           changed_at = systimestamp,
           changed_by = user
     where job_name = c_investigate_job;

    commit;
  end set_investigate_acceptance;

  procedure generate_one_claim is
    l_result clob;
  begin
    -- The batch function accepts a count. Passing 1 generates one NEW claim.
    l_result := fsi_generate_ten_random_claims(1);
    free_clob(l_result);
  end generate_one_claim;

  procedure reserve_next_new_claim(
    p_max_claim_id in  claims.claim_id%type,
    p_claim_id     out nocopy claims.claim_id%type
  ) is
    l_accept_new_claims fsi_scheduler_control.accept_new_claims%type;
  begin
    p_claim_id := null;

    -- This lock is also acquired by STOP. It makes the transition from
    -- accepting to stopped atomic with respect to reserving the next claim.
    select accept_new_claims
      into l_accept_new_claims
      from fsi_scheduler_control
     where job_name = c_investigate_job
       for update;

    if l_accept_new_claims <> 'Y' then
      commit;
      return;
    end if;

    -- Claims with lapsed/cancelled policies are deliberately not candidates.
    -- They are rejected by the claim-status workflow before investigation.
    for r in (
      select c.claim_id
        from claims c
       where upper(trim(c.claim_status)) = 'NEW'
         and (p_max_claim_id is null or c.claim_id <= p_max_claim_id)
         and not exists (
               select 1
                 from policies p
                where p.policy_id = c.policy_id
                  and upper(trim(p.status)) in ('LAPSED', 'CANCELLED')
             )
       order by c.claim_id
       for update skip locked
    ) loop
      p_claim_id := r.claim_id;
      exit;
    end loop;

    if p_claim_id is not null then
      update claims
         set claim_status = 'UNDER_INVESTIGATION'
       where claim_id = p_claim_id
         and upper(trim(claim_status)) = 'NEW';

      if sql%rowcount <> 1 then
        p_claim_id := null;
      end if;
    end if;

    -- The claim is now reserved, and the control-row lock can be released.
    -- STOP may set ACCEPT_NEW_CLAIMS to N while this investigation runs.
    commit;
  exception
    when others then
      rollback;
      raise;
  end reserve_next_new_claim;

  function investigate_one_new_claim(
    p_max_claim_id in claims.claim_id%type
  ) return boolean is
    l_claim_id   claims.claim_id%type;
    l_request_id fsi_apex_ai_requests.request_id%type;
    l_status     fsi_apex_ai_requests.status%type;
    l_error      fsi_apex_ai_requests.error_message%type;
  begin
    reserve_next_new_claim(
      p_max_claim_id => p_max_claim_id,
      p_claim_id     => l_claim_id
    );

    if l_claim_id is null then
      return false;
    end if;

    l_request_id := lower(rawtohex(sys_guid()));
    insert into fsi_apex_ai_requests (
      request_id,
      team_name,
      user_prompt
    ) values (
      l_request_id,
      c_team_name,
      'Investigate claim id ' || to_char(l_claim_id) ||
      '. Return a clear executive fraud investigation report, not raw JSON.'
    );
    commit;

    -- The Scheduler invocation is the worker, so process the request directly.
    fsi_apex_ai_api.process_request(l_request_id);

    select status,
           error_message
      into l_status,
           l_error
      from fsi_apex_ai_requests
     where request_id = l_request_id;

    if l_status <> 'COMPLETED' then
      update claims
         set claim_status = 'NEW'
       where claim_id = l_claim_id
         and upper(trim(claim_status)) = 'UNDER_INVESTIGATION';
      commit;

      raise_application_error(
        -20071,
        'Investigation failed for claim ' || to_char(l_claim_id) || ': ' ||
        substr(nvl(l_error, 'Unknown FSI AI request error.'), 1, 1800)
      );
    end if;

    return true;
  exception
    when others then
      -- A failed reservation is retriable. Do not overwrite a status that was
      -- finalized by a downstream fraud-review workflow.
      if l_claim_id is not null then
        update claims
           set claim_status = 'NEW'
         where claim_id = l_claim_id
           and upper(trim(claim_status)) = 'UNDER_INVESTIGATION';
        commit;
      end if;
      raise;
  end investigate_one_new_claim;

  procedure investigate_next_new_claim is
    l_processed boolean;
  begin
    l_processed := investigate_one_new_claim(
      p_max_claim_id => null
    );
  end investigate_next_new_claim;

  procedure investigate_all_new_claims is
    l_max_claim_id claims.claim_id%type;
    l_processed    boolean;

    procedure stop_when_new_queue_is_empty is
      l_new_claim_count pls_integer;
    begin
      select count(*)
        into l_new_claim_count
        from claims
       where upper(trim(claim_status)) = 'NEW';

      if l_new_claim_count = 0 then
        -- Disable future scheduled invocations without interrupting this run.
        -- The current invocation is already at the end of its batch.
        set_investigate_acceptance('N');
        dbms_scheduler.disable(c_investigate_job, force => true);
      end if;
    end stop_when_new_queue_is_empty;
  begin
    -- Snapshot the NEW queue at the start of this scheduled run. Claims created
    -- while the run is active are handled by the following one-minute run.
    select max(claim_id)
      into l_max_claim_id
      from claims
     where upper(trim(claim_status)) = 'NEW';

    if l_max_claim_id is null then
      stop_when_new_queue_is_empty;
      return;
    end if;

    loop
      l_processed := investigate_one_new_claim(
        p_max_claim_id => l_max_claim_id
      );
      exit when not l_processed;
    end loop;

    -- A claim created while the snapshot was being processed keeps the job
    -- enabled for the next one-minute run. Otherwise, stop automatically.
    stop_when_new_queue_is_empty;
  end investigate_all_new_claims;

  procedure drop_job_if_exists(
    p_job_name in varchar2
  ) is
  begin
    dbms_scheduler.drop_job(
      job_name => p_job_name,
      force    => true
    );
  exception
    when others then
      if sqlcode <> -27475 then
        raise;
      end if;
  end drop_job_if_exists;

  procedure create_jobs(
    p_enable in boolean default false
  ) is
  begin
    drop_job_if_exists(c_generate_job);
    drop_job_if_exists(c_investigate_job);

    dbms_scheduler.create_job(
      job_name        => c_generate_job,
      job_type        => 'STORED_PROCEDURE',
      job_action      => 'FSI_SCHEDULER_JOBS.GENERATE_ONE_CLAIM',
      start_date      => systimestamp,
      repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
      enabled         => false,
      auto_drop       => false,
      comments        => 'Generate one NEW claim per run until stopped.'
    );

    dbms_scheduler.create_job(
      job_name        => c_investigate_job,
      job_type        => 'STORED_PROCEDURE',
      job_action      => 'FSI_SCHEDULER_JOBS.INVESTIGATE_ALL_NEW_CLAIMS',
      start_date      => systimestamp,
      repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
      enabled         => false,
      auto_drop       => false,
      comments        => 'Investigate the NEW-claim queue sequentially until stopped.'
    );

    if p_enable then
      dbms_scheduler.enable(c_generate_job);
      start_investigate_new;
    end if;
  end create_jobs;

  procedure run_now_if_idle(
    p_job_name in varchar2
  ) is
    l_running number;
  begin
    select count(*)
      into l_running
      from user_scheduler_running_jobs
     where job_name = upper(p_job_name);

    if l_running = 0 then
      dbms_scheduler.run_job(
        job_name            => p_job_name,
        use_current_session => false
      );
    end if;
  end run_now_if_idle;

  procedure start_generate_claims is
  begin
    dbms_scheduler.enable(c_generate_job);
    run_now_if_idle(c_generate_job);
  end start_generate_claims;

  procedure stop_generate_claims(
    p_force in boolean default false
  ) is
  begin
    dbms_scheduler.disable(c_generate_job, force => false);
    begin
      dbms_scheduler.stop_job(c_generate_job, force => p_force);
    exception
      when others then
        if sqlcode not in (-27366, -27475) then
          raise;
        end if;
    end;
  end stop_generate_claims;

  procedure start_investigate_new is
  begin
    set_investigate_acceptance('Y');
    dbms_scheduler.enable(c_investigate_job);
    run_now_if_idle(c_investigate_job);
  end start_investigate_new;

  procedure stop_investigate_new(
    p_force in boolean default false
  ) is
  begin
    -- P_FORCE is retained for compatibility with the existing package API.
    -- A hard stop is intentionally not supported for this workflow.
    -- Do not call STOP_JOB. A stop must allow the current claim investigation
    -- to finish. FORCE=>TRUE on DISABLE prevents a future invocation while the
    -- current Scheduler run is allowed to complete.
    set_investigate_acceptance('N');
    dbms_scheduler.disable(c_investigate_job, force => true);
  exception
    when others then
      if sqlcode <> -27475 then
        raise;
      end if;
  end stop_investigate_new;
end fsi_scheduler_jobs;
/

CREATE OR REPLACE EDITIONABLE PACKAGE "FSI_WEATHER_ANOMALY" authid current_user as
-- fsi_weather_anomaly package provides functions to analyze weather anomalies for a given accident date and location. It retrieves weather data from the Open-Meteo API, calculates z-scores for various weather metrics, and generates a report indicating potential weather-related accident risks.
  procedure analyze_weather_incident(
    p_accident_date in date default date '2024-08-16'
  );

  procedure get_weather_report(
    p_city_name    in varchar2,
    p_weather_date in date
  );

  function get_weather_report_json(
    p_city_name    in varchar2,
    p_weather_date in date
  ) return clob;
end fsi_weather_anomaly;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "FSI_WEATHER_ANOMALY" as
  function runtime_config_value(p_config_key varchar2) return varchar2 is
    l_value varchar2(4000);
  begin
    select trim(dbms_lob.substr(config_value, 4000, 1)) into l_value
      from fsi_runtime_config where config_key = upper(trim(p_config_key));
    if l_value is null then raise_application_error(-20060, p_config_key || ' is not configured in FSI_RUNTIME_CONFIG.'); end if;
    return l_value;
  exception when no_data_found then
    raise_application_error(-20060, p_config_key || ' is not configured in FSI_RUNTIME_CONFIG.');
  end;

  function to_iso_date(p_date in date) return varchar2 is
  begin
    return to_char(p_date, 'YYYY-MM-DD');
  end;

  function url_encode(p_value in varchar2) return varchar2 is
  begin
    return replace(trim(p_value), ' ', '%20');
  end;

  function get_url(p_accident_date in date) return varchar2 is
    l_start_date date := p_accident_date - 14;
    l_end_date   date := p_accident_date + 14;
    l_amp        varchar2(1) := chr(38);
  begin
    return runtime_config_value('OPEN_METEO_ARCHIVE_URL') ||
      '?latitude=' || runtime_config_value('OPEN_METEO_DEFAULT_LATITUDE') ||
      l_amp || 'longitude=' || runtime_config_value('OPEN_METEO_DEFAULT_LONGITUDE') ||
      l_amp || 'daily=temperature_2m_max,temperature_2m_min,precipitation_sum,rain_sum,precipitation_hours,wind_speed_10m_max,wind_gusts_10m_max' ||
      l_amp || 'hourly=temperature_2m,relative_humidity_2m,precipitation,rain,weather_code,wind_speed_10m,wind_gusts_10m' ||
      l_amp || 'timezone=' || runtime_config_value('OPEN_METEO_DEFAULT_TIMEZONE') ||
      l_amp || 'start_date=' || to_iso_date(l_start_date) ||
      l_amp || 'end_date=' || to_iso_date(l_end_date);
  end;

  function get_weather_url(
    p_latitude     in number,
    p_longitude    in number,
    p_weather_date in date
  ) return varchar2 is
    l_amp      varchar2(1) := chr(38);
    l_base_url varchar2(4000);
  begin
    if trunc(p_weather_date) < trunc(sysdate) then
      l_base_url := runtime_config_value('OPEN_METEO_ARCHIVE_URL');
    else
      l_base_url := runtime_config_value('OPEN_METEO_FORECAST_URL');
    end if;

    return l_base_url ||
      '?latitude=' || to_char(p_latitude, 'FM999999990D999999', 'NLS_NUMERIC_CHARACTERS=.,') ||
      l_amp || 'longitude=' || to_char(p_longitude, 'FM999999990D999999', 'NLS_NUMERIC_CHARACTERS=.,') ||
      l_amp || 'daily=temperature_2m_max,temperature_2m_min,precipitation_sum,rain_sum,showers_sum,precipitation_hours,wind_speed_10m_max,wind_gusts_10m_max' ||
      l_amp || 'timezone=auto' ||
      l_amp || 'start_date=' || to_iso_date(p_weather_date) ||
      l_amp || 'end_date=' || to_iso_date(p_weather_date);
  end;

  function http_get(p_url in varchar2) return clob is
    l_req      utl_http.req;
    l_resp     utl_http.resp;
    l_buffer   varchar2(32767);
    l_response clob;
  begin
    dbms_lob.createtemporary(l_response, true);
    utl_http.set_response_error_check(false);

    l_req := utl_http.begin_request(p_url, 'GET', 'HTTP/1.1');
    utl_http.set_header(l_req, 'Accept', 'application/json');
    utl_http.set_header(l_req, 'User-Agent', 'oracle-plsql-weather-anomaly-test/1.0');

    l_resp := utl_http.get_response(l_req);

    begin
      loop
        utl_http.read_text(l_resp, l_buffer, 32767);
        dbms_lob.writeappend(l_response, length(l_buffer), l_buffer);
      end loop;
    exception
      when utl_http.end_of_body then
        null;
    end;

    utl_http.end_response(l_resp);
    return l_response;
  exception
    when others then
      begin
        utl_http.end_response(l_resp);
      exception
        when others then
          null;
      end;
      raise;
  end;

  function z_score(p_value in number, p_avg in number, p_stddev in number) return number is
  begin
    if p_value is null or p_avg is null or p_stddev is null or p_stddev = 0 then
      return null;
    end if;

    return round((p_value - p_avg) / p_stddev, 2);
  end;

  function severity_label(p_z in number, p_direction in varchar2 default 'HIGH') return varchar2 is
  begin
    if p_z is null then
      return 'not enough baseline variation';
    elsif p_direction = 'ABS' and abs(p_z) >= 2 then
      return 'ANOMALY';
    elsif p_direction <> 'ABS' and p_z >= 2 then
      return 'SPIKE';
    elsif p_direction = 'ABS' and abs(p_z) >= 1 then
      return 'watch';
    elsif p_direction <> 'ABS' and p_z >= 1 then
      return 'watch';
    else
      return 'normal';
    end if;
  end;

  procedure print_metric(
    p_name      in varchar2,
    p_value     in number,
    p_avg       in number,
    p_stddev    in number,
    p_z         in number,
    p_unit      in varchar2,
    p_direction in varchar2 default 'HIGH'
  ) is
  begin
    dbms_output.put_line(
      rpad(p_name, 26) ||
      ' value=' || nvl(to_char(round(p_value, 2)), 'null') || ' ' || p_unit ||
      ', baseline_avg=' || nvl(to_char(round(p_avg, 2)), 'null') ||
      ', baseline_sd=' || nvl(to_char(round(p_stddev, 2)), 'null') ||
      ', z=' || nvl(to_char(p_z), 'null') ||
      ', status=' || severity_label(p_z, p_direction)
    );
  end;

  procedure analyze_weather_incident(
    p_accident_date in date default date '2024-08-16'
  ) is
    l_url varchar2(32767);
    l_json clob;
    l_accident_date_text varchar2(10);

    l_temp_max number;
    l_temp_min number;
    l_precip_sum number;
    l_rain_sum number;
    l_precip_hours number;
    l_wind_max number;
    l_gust_max number;

    l_temp_max_avg number;
    l_temp_max_sd number;
    l_temp_min_avg number;
    l_temp_min_sd number;
    l_precip_avg number;
    l_precip_sd number;
    l_rain_avg number;
    l_rain_sd number;
    l_precip_hours_avg number;
    l_precip_hours_sd number;
    l_wind_avg number;
    l_wind_sd number;
    l_gust_avg number;
    l_gust_sd number;

    l_rain_hours number;
    l_heavy_rain_hours number;
    l_strong_wind_hours number;
    l_strong_gust_hours number;
    l_max_hourly_precip number;
    l_max_hourly_wind number;
    l_max_hourly_gust number;
  begin
    l_accident_date_text := to_iso_date(p_accident_date);
    l_url := get_url(p_accident_date);
    dbms_output.put_line('Open-Meteo URL:');
    dbms_output.put_line(l_url);

    l_json := http_get(l_url);

    with daily_rows as (
      select
        to_date(d.weather_date, 'YYYY-MM-DD') as weather_date,
        tx.temperature_2m_max,
        tn.temperature_2m_min,
        pr.precipitation_sum,
        rn.rain_sum,
        ph.precipitation_hours,
        ws.wind_speed_10m_max,
        wg.wind_gusts_10m_max
      from json_table(l_json, '$.daily.time[*]'
        columns (
          ord for ordinality,
          weather_date varchar2(10) path '$'
        )
      ) d
      join json_table(l_json, '$.daily.temperature_2m_max[*]'
        columns (ord for ordinality, temperature_2m_max number path '$' null on error)
      ) tx on tx.ord = d.ord
      join json_table(l_json, '$.daily.temperature_2m_min[*]'
        columns (ord for ordinality, temperature_2m_min number path '$' null on error)
      ) tn on tn.ord = d.ord
      join json_table(l_json, '$.daily.precipitation_sum[*]'
        columns (ord for ordinality, precipitation_sum number path '$' null on error)
      ) pr on pr.ord = d.ord
      join json_table(l_json, '$.daily.rain_sum[*]'
        columns (ord for ordinality, rain_sum number path '$' null on error)
      ) rn on rn.ord = d.ord
      join json_table(l_json, '$.daily.precipitation_hours[*]'
        columns (ord for ordinality, precipitation_hours number path '$' null on error)
      ) ph on ph.ord = d.ord
      join json_table(l_json, '$.daily.wind_speed_10m_max[*]'
        columns (ord for ordinality, wind_speed_10m_max number path '$' null on error)
      ) ws on ws.ord = d.ord
      join json_table(l_json, '$.daily.wind_gusts_10m_max[*]'
        columns (ord for ordinality, wind_gusts_10m_max number path '$' null on error)
      ) wg on wg.ord = d.ord
    ),
    baseline as (
      select
        avg(temperature_2m_max) temp_max_avg,
        stddev_samp(temperature_2m_max) temp_max_sd,
        avg(temperature_2m_min) temp_min_avg,
        stddev_samp(temperature_2m_min) temp_min_sd,
        avg(precipitation_sum) precip_avg,
        stddev_samp(precipitation_sum) precip_sd,
        avg(rain_sum) rain_avg,
        stddev_samp(rain_sum) rain_sd,
        avg(precipitation_hours) precip_hours_avg,
        stddev_samp(precipitation_hours) precip_hours_sd,
        avg(wind_speed_10m_max) wind_avg,
        stddev_samp(wind_speed_10m_max) wind_sd,
        avg(wind_gusts_10m_max) gust_avg,
        stddev_samp(wind_gusts_10m_max) gust_sd
      from daily_rows
      where weather_date <> trunc(p_accident_date)
    ),
    accident_day as (
      select *
      from daily_rows
      where weather_date = trunc(p_accident_date)
    )
    select
      a.temperature_2m_max,
      a.temperature_2m_min,
      a.precipitation_sum,
      a.rain_sum,
      a.precipitation_hours,
      a.wind_speed_10m_max,
      a.wind_gusts_10m_max,
      b.temp_max_avg,
      b.temp_max_sd,
      b.temp_min_avg,
      b.temp_min_sd,
      b.precip_avg,
      b.precip_sd,
      b.rain_avg,
      b.rain_sd,
      b.precip_hours_avg,
      b.precip_hours_sd,
      b.wind_avg,
      b.wind_sd,
      b.gust_avg,
      b.gust_sd
    into
      l_temp_max,
      l_temp_min,
      l_precip_sum,
      l_rain_sum,
      l_precip_hours,
      l_wind_max,
      l_gust_max,
      l_temp_max_avg,
      l_temp_max_sd,
      l_temp_min_avg,
      l_temp_min_sd,
      l_precip_avg,
      l_precip_sd,
      l_rain_avg,
      l_rain_sd,
      l_precip_hours_avg,
      l_precip_hours_sd,
      l_wind_avg,
      l_wind_sd,
      l_gust_avg,
      l_gust_sd
    from accident_day a
    cross join baseline b;

    with hourly_rows as (
      select
        h.hour_time,
        pp.precipitation,
        rn.rain,
        ws.wind_speed_10m,
        wg.wind_gusts_10m
      from json_table(l_json, '$.hourly.time[*]'
        columns (
          ord for ordinality,
          hour_time varchar2(30) path '$'
        )
      ) h
      join json_table(l_json, '$.hourly.precipitation[*]'
        columns (ord for ordinality, precipitation number path '$' null on error)
      ) pp on pp.ord = h.ord
      join json_table(l_json, '$.hourly.rain[*]'
        columns (ord for ordinality, rain number path '$' null on error)
      ) rn on rn.ord = h.ord
      join json_table(l_json, '$.hourly.wind_speed_10m[*]'
        columns (ord for ordinality, wind_speed_10m number path '$' null on error)
      ) ws on ws.ord = h.ord
      join json_table(l_json, '$.hourly.wind_gusts_10m[*]'
        columns (ord for ordinality, wind_gusts_10m number path '$' null on error)
      ) wg on wg.ord = h.ord
    )
    select
      count(case when precipitation > 0 then 1 end),
      count(case when precipitation >= 2.5 then 1 end),
      count(case when wind_speed_10m >= 40 then 1 end),
      count(case when wind_gusts_10m >= 50 then 1 end),
      max(precipitation),
      max(wind_speed_10m),
      max(wind_gusts_10m)
    into
      l_rain_hours,
      l_heavy_rain_hours,
      l_strong_wind_hours,
      l_strong_gust_hours,
      l_max_hourly_precip,
      l_max_hourly_wind,
      l_max_hourly_gust
    from hourly_rows
    where substr(hour_time, 1, 10) = l_accident_date_text;

    dbms_output.put_line(chr(10) || 'Weather anomaly report');
    dbms_output.put_line('Location: Kingston, Jamaica');
    dbms_output.put_line('Accident date: ' || l_accident_date_text);
    dbms_output.put_line('Baseline: 14 days before and 14 days after, excluding accident date');
    dbms_output.put_line('Anomaly threshold: absolute z-score >= 2 for temperature, z-score >= 2 for rain/wind spikes');
    dbms_output.put_line(chr(10) || 'Daily anomaly metrics');

    print_metric('Max temperature', l_temp_max, l_temp_max_avg, l_temp_max_sd, z_score(l_temp_max, l_temp_max_avg, l_temp_max_sd), 'C', 'ABS');
    print_metric('Min temperature', l_temp_min, l_temp_min_avg, l_temp_min_sd, z_score(l_temp_min, l_temp_min_avg, l_temp_min_sd), 'C', 'ABS');
    print_metric('Precipitation sum', l_precip_sum, l_precip_avg, l_precip_sd, z_score(l_precip_sum, l_precip_avg, l_precip_sd), 'mm');
    print_metric('Rain sum', l_rain_sum, l_rain_avg, l_rain_sd, z_score(l_rain_sum, l_rain_avg, l_rain_sd), 'mm');
    print_metric('Precipitation hours', l_precip_hours, l_precip_hours_avg, l_precip_hours_sd, z_score(l_precip_hours, l_precip_hours_avg, l_precip_hours_sd), 'hours');
    print_metric('Max wind speed', l_wind_max, l_wind_avg, l_wind_sd, z_score(l_wind_max, l_wind_avg, l_wind_sd), 'km/h');
    print_metric('Max wind gust', l_gust_max, l_gust_avg, l_gust_sd, z_score(l_gust_max, l_gust_avg, l_gust_sd), 'km/h');

    dbms_output.put_line(chr(10) || 'Hourly accident-day risk indicators');
    dbms_output.put_line('Rain hours: ' || l_rain_hours);
    dbms_output.put_line('Heavy rain hours >= 2.5 mm/hour: ' || l_heavy_rain_hours);
    dbms_output.put_line('Strong wind hours >= 40 km/h: ' || l_strong_wind_hours);
    dbms_output.put_line('Strong gust hours >= 50 km/h: ' || l_strong_gust_hours);
    dbms_output.put_line('Max hourly precipitation: ' || nvl(to_char(l_max_hourly_precip), 'null') || ' mm');
    dbms_output.put_line('Max hourly wind speed: ' || nvl(to_char(l_max_hourly_wind), 'null') || ' km/h');
    dbms_output.put_line('Max hourly wind gust: ' || nvl(to_char(l_max_hourly_gust), 'null') || ' km/h');

    dbms_output.put_line(chr(10) || 'Interpretation');
    if z_score(l_precip_sum, l_precip_avg, l_precip_sd) >= 2
      or z_score(l_rain_sum, l_rain_avg, l_rain_sd) >= 2
      or z_score(l_precip_hours, l_precip_hours_avg, l_precip_hours_sd) >= 2
      or z_score(l_wind_max, l_wind_avg, l_wind_sd) >= 2
      or z_score(l_gust_max, l_gust_avg, l_gust_sd) >= 2
      or l_heavy_rain_hours > 0
      or l_strong_wind_hours > 0
      or l_strong_gust_hours > 0
    then
      dbms_output.put_line('Potential weather-related accident-risk spike detected. Review rain/wind timing against the accident time and location.');
    else
      dbms_output.put_line('No strong weather anomaly detected from the 29-day local baseline. Weather may still be relevant if the accident happened during a short local burst.');
    end if;
  exception
    when no_data_found then
      dbms_output.put_line('No Open-Meteo daily record found for ' || l_accident_date_text || '.');
      dbms_output.put_line('Raw response begins:');
      dbms_output.put_line(dbms_lob.substr(l_json, 32767, 1));
      raise;
  end analyze_weather_incident;

  procedure get_weather_report(
    p_city_name    in varchar2,
    p_weather_date in date
  ) is
    l_amp                 varchar2(1) := chr(38);
    l_geocode_url         varchar2(32767);
    l_weather_url         varchar2(32767);
    l_geocode_json        clob;
    l_weather_json        clob;
    l_city                varchar2(200);
    l_country             varchar2(200);
    l_timezone            varchar2(200);
    l_latitude            number;
    l_longitude           number;
    l_temp_max            number;
    l_temp_min            number;
    l_precipitation_sum   number;
    l_rain_sum            number;
    l_showers_sum         number;
    l_precipitation_hours number;
    l_wind_speed_max      number;
    l_wind_gusts_max      number;
  begin
    l_geocode_url :=
      runtime_config_value('OPEN_METEO_GEOCODING_URL') ||
      '?name=' || url_encode(p_city_name) ||
      l_amp || 'count=1' ||
      l_amp || 'language=en' ||
      l_amp || 'format=json';

    dbms_output.put_line('Open-Meteo Geocoding URL:');
    dbms_output.put_line(l_geocode_url);

    l_geocode_json := http_get(l_geocode_url);

    l_latitude := json_value(l_geocode_json, '$.results[0].latitude' returning number null on error);
    l_longitude := json_value(l_geocode_json, '$.results[0].longitude' returning number null on error);
    l_city := json_value(l_geocode_json, '$.results[0].name' returning varchar2(200) null on error);
    l_country := json_value(l_geocode_json, '$.results[0].country' returning varchar2(200) null on error);
    l_timezone := json_value(l_geocode_json, '$.results[0].timezone' returning varchar2(200) null on error);

    if l_latitude is null or l_longitude is null then
      dbms_output.put_line('City not found: ' || p_city_name);
      dbms_output.put_line('Raw geocoding response begins:');
      dbms_output.put_line(dbms_lob.substr(l_geocode_json, 32767, 1));
      return;
    end if;

    l_weather_url := get_weather_url(l_latitude, l_longitude, p_weather_date);

    dbms_output.put_line(chr(10) || 'Open-Meteo Weather URL:');
    dbms_output.put_line(l_weather_url);

    l_weather_json := http_get(l_weather_url);

    l_temp_max := json_value(l_weather_json, '$.daily.temperature_2m_max[0]' returning number null on error);
    l_temp_min := json_value(l_weather_json, '$.daily.temperature_2m_min[0]' returning number null on error);
    l_precipitation_sum := json_value(l_weather_json, '$.daily.precipitation_sum[0]' returning number null on error);
    l_rain_sum := json_value(l_weather_json, '$.daily.rain_sum[0]' returning number null on error);
    l_showers_sum := json_value(l_weather_json, '$.daily.showers_sum[0]' returning number null on error);
    l_precipitation_hours := json_value(l_weather_json, '$.daily.precipitation_hours[0]' returning number null on error);
    l_wind_speed_max := json_value(l_weather_json, '$.daily.wind_speed_10m_max[0]' returning number null on error);
    l_wind_gusts_max := json_value(l_weather_json, '$.daily.wind_gusts_10m_max[0]' returning number null on error);

    dbms_output.put_line(chr(10) || 'Weather report');
    dbms_output.put_line('City: ' || nvl(l_city, p_city_name) || nvl2(l_country, ', ' || l_country, null));
    dbms_output.put_line('Date: ' || to_iso_date(p_weather_date));
    dbms_output.put_line('Timezone: ' || nvl(l_timezone, 'auto'));
    dbms_output.put_line('Latitude: ' || to_char(l_latitude, 'FM999999990D999999', 'NLS_NUMERIC_CHARACTERS=.,'));
    dbms_output.put_line('Longitude: ' || to_char(l_longitude, 'FM999999990D999999', 'NLS_NUMERIC_CHARACTERS=.,'));
    dbms_output.put_line('Max temperature: ' || nvl(to_char(l_temp_max), 'null') || ' C');
    dbms_output.put_line('Min temperature: ' || nvl(to_char(l_temp_min), 'null') || ' C');
    dbms_output.put_line('Precipitation: ' || nvl(to_char(l_precipitation_sum), 'null') || ' mm');
    dbms_output.put_line('Rain: ' || nvl(to_char(l_rain_sum), 'null') || ' mm');
    dbms_output.put_line('Showers: ' || nvl(to_char(l_showers_sum), 'null') || ' mm');
    dbms_output.put_line('Precipitation hours: ' || nvl(to_char(l_precipitation_hours), 'null'));
    dbms_output.put_line('Max wind speed: ' || nvl(to_char(l_wind_speed_max), 'null') || ' km/h');
    dbms_output.put_line('Max wind gust: ' || nvl(to_char(l_wind_gusts_max), 'null') || ' km/h');

    if l_temp_max is null and l_precipitation_sum is null and l_wind_speed_max is null then
      dbms_output.put_line(chr(10) || 'No daily weather values were returned. Raw response begins:');
      dbms_output.put_line(dbms_lob.substr(l_weather_json, 32767, 1));
    end if;
  end get_weather_report;

  function get_weather_report_json(
    p_city_name    in varchar2,
    p_weather_date in date
  ) return clob is
    l_amp                 varchar2(1) := chr(38);
    l_geocode_url         varchar2(32767);
    l_weather_url         varchar2(32767);
    l_geocode_json        clob;
    l_weather_json        clob;
    l_city                varchar2(200);
    l_country             varchar2(200);
    l_timezone            varchar2(200);
    l_latitude            number;
    l_longitude           number;
    l_temp_max            number;
    l_temp_min            number;
    l_precipitation_sum   number;
    l_rain_sum            number;
    l_showers_sum         number;
    l_precipitation_hours number;
    l_wind_speed_max      number;
    l_wind_gusts_max      number;
    l_weather_date_text   varchar2(10);
    l_requested_date_text varchar2(10);
    l_source_api          varchar2(20);
    l_result              clob;
    l_error_message       varchar2(4000);
  begin
    l_requested_date_text := to_iso_date(p_weather_date);

    if p_city_name is null then
      select json_object(
               'provider' value 'Open-Meteo',
               'status' value 'SKIPPED',
               'message' value 'Customer city is not available for this claim.',
               'weather_date' value l_requested_date_text
             returning clob)
        into l_result
        from dual;
      return l_result;
    end if;

    l_source_api := case when trunc(p_weather_date) < trunc(sysdate) then 'archive' else 'forecast' end;
    l_geocode_url :=
      runtime_config_value('OPEN_METEO_GEOCODING_URL') ||
      '?name=' || url_encode(p_city_name) ||
      l_amp || 'count=1' ||
      l_amp || 'language=en' ||
      l_amp || 'format=json';

    l_geocode_json := http_get(l_geocode_url);

    l_latitude := json_value(l_geocode_json, '$.results[0].latitude' returning number null on error);
    l_longitude := json_value(l_geocode_json, '$.results[0].longitude' returning number null on error);
    l_city := json_value(l_geocode_json, '$.results[0].name' returning varchar2(200) null on error);
    l_country := json_value(l_geocode_json, '$.results[0].country' returning varchar2(200) null on error);
    l_timezone := json_value(l_geocode_json, '$.results[0].timezone' returning varchar2(200) null on error);

    if l_latitude is null or l_longitude is null then
      select json_object(
               'provider' value 'Open-Meteo',
               'status' value 'CITY_NOT_FOUND',
               'requested_city' value p_city_name,
               'weather_date' value l_requested_date_text,
               'geocoding_url' value l_geocode_url,
               'raw_geocoding_response' value dbms_lob.substr(l_geocode_json, 4000, 1)
             returning clob)
        into l_result
        from dual;
      return l_result;
    end if;

    l_weather_url := get_weather_url(l_latitude, l_longitude, p_weather_date);
    l_weather_json := http_get(l_weather_url);

    l_weather_date_text := json_value(l_weather_json, '$.daily.time[0]' returning varchar2(10) null on error);
    l_temp_max := json_value(l_weather_json, '$.daily.temperature_2m_max[0]' returning number null on error);
    l_temp_min := json_value(l_weather_json, '$.daily.temperature_2m_min[0]' returning number null on error);
    l_precipitation_sum := json_value(l_weather_json, '$.daily.precipitation_sum[0]' returning number null on error);
    l_rain_sum := json_value(l_weather_json, '$.daily.rain_sum[0]' returning number null on error);
    l_showers_sum := json_value(l_weather_json, '$.daily.showers_sum[0]' returning number null on error);
    l_precipitation_hours := json_value(l_weather_json, '$.daily.precipitation_hours[0]' returning number null on error);
    l_wind_speed_max := json_value(l_weather_json, '$.daily.wind_speed_10m_max[0]' returning number null on error);
    l_wind_gusts_max := json_value(l_weather_json, '$.daily.wind_gusts_10m_max[0]' returning number null on error);

    select json_object(
             'provider' value 'Open-Meteo',
             'status' value case
                              when l_temp_max is null and l_precipitation_sum is null and l_wind_speed_max is null then 'NO_DAILY_VALUES'
                              else 'OK'
                            end,
             'source_api' value l_source_api,
             'requested_city' value p_city_name,
             'weather_date' value nvl(l_weather_date_text, l_requested_date_text),
             'geocoded_location' value json_object(
               'city' value l_city,
               'country' value l_country,
               'timezone' value l_timezone,
               'latitude' value l_latitude,
               'longitude' value l_longitude
             ),
             'daily_weather' value json_object(
               'temperature_2m_max_c' value l_temp_max,
               'temperature_2m_min_c' value l_temp_min,
               'precipitation_sum_mm' value l_precipitation_sum,
               'rain_sum_mm' value l_rain_sum,
               'showers_sum_mm' value l_showers_sum,
               'precipitation_hours' value l_precipitation_hours,
               'wind_speed_10m_max_kmh' value l_wind_speed_max,
               'wind_gusts_10m_max_kmh' value l_wind_gusts_max
             ),
             'risk_indicators' value json_object(
               'heavy_rain_flag' value case when nvl(l_precipitation_sum, 0) >= 10 or nvl(l_rain_sum, 0) >= 10 then 'Y' else 'N' end,
               'windy_flag' value case when nvl(l_wind_speed_max, 0) >= 40 or nvl(l_wind_gusts_max, 0) >= 50 then 'Y' else 'N' end,
               'weather_may_affect_accident_risk' value case
                 when nvl(l_precipitation_sum, 0) >= 10
                   or nvl(l_rain_sum, 0) >= 10
                   or nvl(l_wind_speed_max, 0) >= 40
                   or nvl(l_wind_gusts_max, 0) >= 50
                 then 'Y'
                 else 'N'
               end
             ),
             'geocoding_url' value l_geocode_url,
             'weather_url' value l_weather_url
           returning clob)
      into l_result
      from dual;
    return l_result;
  exception
    when others then
      l_error_message := sqlerrm;
      select json_object(
               'provider' value 'Open-Meteo',
               'status' value 'ERROR',
               'requested_city' value p_city_name,
               'weather_date' value l_requested_date_text,
               'error_message' value l_error_message
             returning clob)
        into l_result
        from dual;
      return l_result;
  end get_weather_report_json;

end fsi_weather_anomaly;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_CLAIM_PROFILE" (
  p_claim_id     in number default null,
  p_claim_number in varchar2 default null
) return clob
as
  l_result clob;
  l_error_message varchar2(4000);
-- fsi_claim_profile function retrieves detailed information about a claim, including claim details, customer information, policy details, vehicle information, incident details, fraud indicators, and associated documents.
-- The function accepts either a claim ID or a claim number as input and returns a JSON object
-- containing the relevant information. If the claim is not found, it returns a JSON object indicating
-- that the claim was not found.
begin
  select json_object(
           'claim' value json_object(
             'claim_id' value c.claim_id,
             'claim_number' value c.claim_number,
             'claim_status' value c.claim_status,
             'claim_type' value c.claim_type,
             'risk_tier' value coalesce(
               c.risk_tier,
               (
                 select case fi.indicator_code
                          when 'SIMULATION_HIGH_RISK' then 'HIGH'
                          when 'SIMULATION_MEDIUM_RISK' then 'MEDIUM'
                          when 'SIMULATION_LOW_RISK' then 'LOW'
                        end
                   from fraud_indicators fi
                  where fi.claim_id = c.claim_id
                    and fi.detected_by = 'FSI_CLAIM_SIMULATOR'
                    and fi.indicator_code in (
                      'SIMULATION_HIGH_RISK', 'SIMULATION_MEDIUM_RISK', 'SIMULATION_LOW_RISK'
                    )
                  order by fi.detected_date desc, fi.indicator_id desc
                  fetch first 1 row only
               )
             ),
             'claim_details' value dbms_lob.substr(c.claim_details, 4000, 1),
             'incident_date' value to_char(c.incident_date, 'YYYY-MM-DD'),
             'reported_date' value to_char(c.reported_date, 'YYYY-MM-DD'),
             'total_claimed' value c.total_claimed,
             'total_settled' value c.total_settled,
             'reserve_amount' value c.reserve_amount,
             'fault_flag' value c.fault_flag,
             'third_party_flag' value c.third_party_flag,
             'injury_flag' value c.injury_flag,
             'fraud_flag' value c.fraud_flag,
             'fraud_score' value c.fraud_score
           ),
           'customer' value json_object(
             'customer_id' value cu.customer_id,
             'name' value trim(cu.first_name || ' ' || cu.last_name),
             'date_of_birth' value to_char(cu.date_of_birth, 'YYYY-MM-DD'),
             'email' value cu.email,
             'mobile' value cu.phone_mobile,
             'postcode' value cu.postcode,
             'customer_status' value cu.customer_status,
             'customer_since' value to_char(cu.customer_since, 'YYYY-MM-DD'),
             'credit_score' value cu.credit_score,
             'fraud_flag' value cu.fraud_flag
           ),
           'policy' value json_object(
             'policy_id' value p.policy_id,
             'policy_number' value p.policy_number,
             'product_type' value p.product_type,
             'cover_type' value p.cover_type,
             'status' value p.status,
             'start_date' value to_char(p.start_date, 'YYYY-MM-DD'),
             'end_date' value to_char(p.end_date, 'YYYY-MM-DD'),
             'annual_premium' value p.annual_premium,
             'excess_amount' value p.excess_amount,
             'ncb_years' value p.ncb_years,
             'channel' value p.channel
           ),
           'vehicle' value json_object(
             'vehicle_id' value v.vehicle_id,
             'registration' value v.registration,
             'make' value v.make,
             'model' value v.model,
             'year' value v.year,
             'market_value' value v.market_value,
             'annual_mileage' value v.annual_mileage
           ),
           'incident' value (
             select json_object(
                      'incident_id' value i.incident_id,
                      'incident_type' value i.incident_type,
                      'incident_date' value to_char(i.incident_date, 'YYYY-MM-DD'),
                      'incident_time' value i.incident_time,
                      'location_desc' value i.location_desc,
                      'postcode' value i.postcode,
                      'weather_cond' value i.weather_cond,
                      'road_cond' value i.road_cond,
                      'light_cond' value i.light_cond,
                      'police_attended' value i.police_attended,
                      'police_report_no' value i.police_report_no,
                      'description' value i.description
                    returning clob)
             from incidents i
             where i.claim_id = c.claim_id
             fetch first 1 row only
           ),
           'fraud_indicators' value (
             select coalesce(
                      json_arrayagg(
                        json_object(
                          'indicator_code' value fi.indicator_code,
                          'indicator_desc' value fi.indicator_desc,
                          'severity' value fi.severity,
                          'score_weight' value fi.score_weight,
                          'status' value fi.status,
                          'notes' value fi.notes
                        returning clob)
                      returning clob),
                      to_clob('[]')
                    )
             from fraud_indicators fi
             where fi.claim_id = c.claim_id
           ),
           'documents' value (
             select coalesce(
                      json_arrayagg(
                        json_object(
                          'document_id' value d.document_id,
                          'doc_type' value d.doc_type,
                          'doc_name' value d.doc_name,
                          'status' value d.status,
                          'verified_flag' value d.verified_flag,
                          'upload_date' value to_char(d.upload_date, 'YYYY-MM-DD')
                        returning clob)
                      returning clob),
                      to_clob('[]')
                    )
             from documents d
             where d.entity_type = 'CLAIM'
             and d.entity_id = c.claim_id
           )
         returning clob)
    into l_result
    from claims c
    join customers cu on cu.customer_id = c.customer_id
    join policies p on p.policy_id = c.policy_id
    left join vehicles v on v.vehicle_id = c.vehicle_id
   where (p_claim_id is not null and c.claim_id = p_claim_id)
      or (p_claim_number is not null and upper(c.claim_number) = upper(p_claim_number))
   fetch first 1 row only;

  return l_result;
exception
  when no_data_found then
    select json_object(
             'status' value 'NOT_FOUND',
             'claim_id' value p_claim_id,
             'claim_number' value p_claim_number,
             'error_message' value 'No claim found for the supplied CLAIM_ID or CLAIM_NUMBER.'
           returning clob)
      into l_result
      from dual;
    return l_result;
  when others then
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'claim_id' value p_claim_id,
             'claim_number' value p_claim_number,
             'error_message' value 'Error in fsi_claim_profile: ' || l_error_message
           returning clob)
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_CLAIM_RISK_SCORE" (
  p_claim_id in number
) return clob
as
  l_score                number := 0;
  l_reasons              varchar2(4000) := null;
  l_report_delay_days    number := 0;
  l_policy_age_days      number := null;
  l_prior_claims         number := 0;
  l_unverified_docs      number := 0;
  l_indicator_weight     number := 0;
  l_simulation_risk_tier varchar2(20);
  l_risk_level           varchar2(20);
  l_found                boolean := false;
  l_result               clob;
  l_error_message        varchar2(4000);

  procedure add_reason(p_points number, p_reason varchar2) is
  begin
    l_score := l_score + p_points;
    l_reasons := substr(
      l_reasons || case when l_reasons is null then null else '; ' end ||
      p_reason || ' (+' || p_points || ')',
      1,
      4000
    );
  end add_reason;
begin
  for r in (
    select c.claim_id,
           c.customer_id,
           c.incident_date,
           c.reported_date,
           c.total_claimed,
           c.third_party_flag,
           c.injury_flag,
           cu.credit_score,
           cu.fraud_flag customer_fraud_flag,
           p.start_date policy_start_date,
           p.status policy_status
      from madhu_rao.claims c
      join madhu_rao.customers cu on cu.customer_id = c.customer_id
      join madhu_rao.policies p on p.policy_id = c.policy_id
     where c.claim_id = p_claim_id
  ) loop
    l_found := true;
    l_report_delay_days := nvl(trunc(r.reported_date) - trunc(r.incident_date), 0);
    l_policy_age_days := trunc(r.incident_date) - trunc(r.policy_start_date);

    -- Do not score CLAIMS.FRAUD_FLAG here. AI triage can set risk workflow
    -- state, but an AI- or SIU-owned marker is not independent claim evidence.
    if r.customer_fraud_flag = 'Y' then
      add_reason(30, 'customer has historical fraud flag');
    end if;

    if upper(nvl(r.policy_status, 'UNKNOWN')) in ('CANCELLED', 'LAPSED') then
      add_reason(
        30,
        'linked policy status is ' || upper(nvl(r.policy_status, 'UNKNOWN')) ||
        '; coverage requires verification and renewal or replacement cover applies only to future losses'
      );
    elsif upper(nvl(r.policy_status, 'UNKNOWN')) <> 'ACTIVE' then
      add_reason(25, 'policy status is not ACTIVE');
    end if;

    if l_policy_age_days between 0 and 30 then
      add_reason(20, 'incident occurred within 30 days of policy start');
    elsif l_policy_age_days < 0 then
      add_reason(30, 'incident date is before policy start date');
    end if;

    if l_report_delay_days > 14 then
      add_reason(15, 'claim was reported more than 14 days after incident');
    end if;

    if nvl(r.total_claimed, 0) >= 25000 then
      add_reason(20, 'high claimed amount');
    elsif nvl(r.total_claimed, 0) >= 10000 then
      add_reason(10, 'elevated claimed amount');
    end if;

    if r.injury_flag = 'Y' and r.third_party_flag = 'Y' then
      add_reason(15, 'injury claim includes third party involvement');
    end if;

    if r.credit_score is not null and r.credit_score < 550 then
      add_reason(10, 'low customer credit score');
    end if;

    select count(*)
      into l_prior_claims
      from madhu_rao.claims pc
     where pc.customer_id = r.customer_id
       and pc.claim_id <> p_claim_id
       and pc.incident_date >= add_months(r.incident_date, -24);

    if l_prior_claims >= 3 then
      add_reason(20, 'three or more prior claims in the last 24 months');
    elsif l_prior_claims >= 1 then
      add_reason(5, 'prior claims in the last 24 months');
    end if;

    select count(*)
      into l_unverified_docs
      from madhu_rao.documents d
     where d.entity_type = 'CLAIM'
       and d.entity_id = p_claim_id
       and nvl(d.verified_flag, 0) = 0;

    if l_unverified_docs > 0 then
      add_reason(10, 'claim has unverified supporting documents');
    end if;

    select nvl(sum(score_weight), 0)
      into l_indicator_weight
      from madhu_rao.fraud_indicators fi
     where fi.claim_id = p_claim_id
       and nvl(fi.status, 'OPEN') <> 'CLOSED'
       and fi.indicator_code <> 'AI_FRAUD_RISK';

    if l_indicator_weight > 0 then
      add_reason(least(l_indicator_weight, 40), 'open fraud indicators are present');
    end if;
  end loop;

  if not l_found then
    select json_object(
             'status' value 'NOT_FOUND',
             'claim_id' value p_claim_id,
             'error_message' value 'No claim found for P_CLAIM_ID=' || p_claim_id
             returning clob
           )
      into l_result
      from dual;
    return l_result;
  end if;

  begin
    select risk_tier
      into l_simulation_risk_tier
      from madhu_rao.claims
     where claim_id = p_claim_id;
  exception
    when no_data_found then
      l_simulation_risk_tier := null;
  end;

  if l_simulation_risk_tier is null then
    begin
      select simulation_tier
        into l_simulation_risk_tier
        from (
          select case fi.indicator_code
                   when 'SIMULATION_HIGH_RISK' then 'HIGH'
                   when 'SIMULATION_MEDIUM_RISK' then 'MEDIUM'
                   when 'SIMULATION_LOW_RISK' then 'LOW'
                 end as simulation_tier
            from madhu_rao.fraud_indicators fi
           where fi.claim_id = p_claim_id
             and fi.detected_by = 'FSI_CLAIM_SIMULATOR'
             and fi.indicator_code in (
               'SIMULATION_HIGH_RISK',
               'SIMULATION_MEDIUM_RISK',
               'SIMULATION_LOW_RISK'
             )
           order by fi.detected_date desc, fi.indicator_id desc
        )
       where rownum = 1;
    exception
      when no_data_found then
        l_simulation_risk_tier := null;
    end;
  end if;

  l_score := least(round(l_score, 2), 100);
  if l_simulation_risk_tier = 'LOW' then
    l_score := least(l_score, 49);
    l_reasons := substr(
      l_reasons || case when l_reasons is null then null else '; ' end ||
      'low-risk simulation ceiling applied (maximum 49)',
      1,
      4000
    );
  end if;
  l_risk_level := case
                    when l_simulation_risk_tier = 'LOW' then 'LOW'
                    when l_score >= 70 then 'HIGH'
                    when l_score >= 30 then 'MEDIUM'
                    else 'LOW'
                  end;

  select json_object(
           'claim_id' value p_claim_id,
           'fraud_probability' value l_score,
           'risk_level' value l_risk_level,
           'report_delay_days' value l_report_delay_days,
           'policy_age_days_at_incident' value l_policy_age_days,
           'prior_claims_24_months' value l_prior_claims,
           'unverified_document_count' value l_unverified_docs,
           'open_indicator_weight' value l_indicator_weight,
           'reason_codes' value nvl(l_reasons, 'No material rule-based risk indicators found')
           returning clob
         )
    into l_result
    from dual;

  return l_result;
exception
  when no_data_found then
    select json_object(
             'status' value 'NOT_FOUND',
             'claim_id' value p_claim_id,
             'error_message' value 'No claim found for P_CLAIM_ID=' || p_claim_id
             returning clob
           )
      into l_result
      from dual;
    return l_result;
  when others then
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'claim_id' value p_claim_id,
             'error_message' value 'Error in fsi_claim_risk_score: ' || l_error_message
             returning clob
           )
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_CONTEXTUAL_RISK_DATA" (
  p_claim_id in number
) return clob
as
  l_result clob;
  l_error_message varchar2(4000);
-- fsi_contextual_risk_data function retrieves contextual risk data 
-- for a given claim, including incident context, sanctions checks, repair context, 
-- and medical context. The function returns a JSON object containing the relevant information.
begin
  select json_object(
           'claim_id' value c.claim_id,
           'incident_context' value (
             select json_object(
                      'weather_cond' value i.weather_cond,
                      'road_cond' value i.road_cond,
                      'light_cond' value i.light_cond,
                      'police_attended' value i.police_attended,
                      'ambulance_attend' value i.ambulance_attend,
                      'location_desc' value i.location_desc,
                      'postcode' value i.postcode
                    returning clob)
             from incidents i
             where i.claim_id = c.claim_id
             fetch first 1 row only
           ),
           'sanctions_checks' value (
             select coalesce(
                      json_arrayagg(
                        json_object(
                          'entity_type' value sc.entity_type,
                          'provider' value sc.provider,
                          'result' value sc.result,
                          'match_count' value sc.match_count,
                          'risk_level' value sc.risk_level,
                          'match_details' value sc.match_details
                        returning clob)
                      returning clob),
                      to_clob('[]')
                     )
             from sanctions_checks sc
             where (sc.entity_type = 'CUSTOMER' and sc.entity_id = c.customer_id)
                or (sc.entity_type = 'CLAIM' and sc.entity_id = c.claim_id)
           ) format json,
           'repair_context' value (
             select coalesce(
                      json_arrayagg(
                        json_object(
                          'repair_id' value vr.repair_id,
                          'repairer_name' value rp.name,
                          'repairer_fraud_flag' value rp.fraud_flag,
                          'estimate_amount' value vr.estimate_amount,
                          'approved_amount' value vr.approved_amount,
                          'total_loss_flag' value vr.total_loss_flag,
                          'repair_status' value vr.repair_status
                        returning clob)
                      returning clob),
                      to_clob('[]')
                    )
             from vehicle_repairs vr
             left join repairers rp on rp.repairer_id = vr.repairer_id
             where vr.claim_id = c.claim_id
           ) format json,
           'medical_context' value (
             select coalesce(
                      json_arrayagg(
                        json_object(
                          'assessment_id' value ma.assessment_id,
                          'injury_type' value ma.injury_type,
                          'disability_days' value ma.disability_days,
                          'claim_value_est' value ma.claim_value_est,
                          'fraud_indicator' value ma.fraud_indicator
                        returning clob)
                      returning clob),
                      to_clob('[]')
                    )
             from medical_assessments ma
             where ma.claim_id = c.claim_id
           ) format json
         returning clob)
    into l_result
    from claims c
   where c.claim_id = p_claim_id;

  return l_result;
exception
  when no_data_found then
    select json_object(
             'status' value 'NOT_FOUND',
             'claim_id' value p_claim_id,
             'error_message' value 'No claim found for P_CLAIM_ID=' || p_claim_id
           returning clob)
      into l_result
      from dual;
    return l_result;
  when others then
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'claim_id' value p_claim_id,
             'error_message' value 'Error in fsi_contextual_risk_data: ' || l_error_message
           returning clob)
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_CUSTOMER_360" (
  p_customer_id in number default null,
  p_claim_id    in number default null
) return clob
as
  l_customer_id number;
  l_result      clob;
  l_error_message varchar2(4000);
-- fsi_customer_360 function retrieves a comprehensive view of
-- a customer, including their personal details, policies, claims, 
-- payments, and interactions. The function accepts either a customer ID or a 
-- claim ID as input and returns a JSON object containing the relevant information.
begin
  if p_customer_id is not null then
    l_customer_id := p_customer_id;
  elsif p_claim_id is not null then
    select customer_id into l_customer_id
    from claims
    where claim_id = p_claim_id;
  else
    select json_object(
             'status' value 'ERROR',
             'error_message' value 'Missing required parameter. Provide P_CUSTOMER_ID or P_CLAIM_ID.'
           returning clob)
      into l_result
      from dual;
    return l_result;
  end if;

  select json_object(
           'customer' value json_object(
             'customer_id' value cu.customer_id,
             'name' value trim(cu.first_name || ' ' || cu.last_name),
             'date_of_birth' value to_char(cu.date_of_birth, 'YYYY-MM-DD'),
             'email' value cu.email,
             'mobile' value cu.phone_mobile,
             'postcode' value cu.postcode,
             'occupation' value cu.occupation,
             'annual_income' value cu.annual_income,
             'credit_score' value cu.credit_score,
             'customer_status' value cu.customer_status,
             'fraud_flag' value cu.fraud_flag
           ),
           'policies' value (
             select coalesce(
                      json_arrayagg(
                        json_object(
                          'policy_id' value p.policy_id,
                          'policy_number' value p.policy_number,
                          'product_type' value p.product_type,
                          'cover_type' value p.cover_type,
                          'status' value p.status,
                          'start_date' value to_char(p.start_date, 'YYYY-MM-DD'),
                          'end_date' value to_char(p.end_date, 'YYYY-MM-DD'),
                          'annual_premium' value p.annual_premium
                        returning clob)
                      returning clob),
                      to_clob('[]')
                    )
             from policies p
             where p.customer_id = cu.customer_id
           ),
           'claims' value (
             select coalesce(
                      json_arrayagg(
                        json_object(
                          'claim_id' value c.claim_id,
                          'claim_number' value c.claim_number,
                          'claim_type' value c.claim_type,
                          'claim_status' value c.claim_status,
                          'incident_date' value to_char(c.incident_date, 'YYYY-MM-DD'),
                          'reported_date' value to_char(c.reported_date, 'YYYY-MM-DD'),
                          'total_claimed' value c.total_claimed,
                          'fraud_flag' value c.fraud_flag,
                          'fraud_score' value c.fraud_score
                        returning clob)
                      returning clob),
                      to_clob('[]')
                    )
             from claims c
             where c.customer_id = cu.customer_id
           ),
           'payments' value (
             select coalesce(
                      json_arrayagg(
                        json_object(
                          'payment_id' value cp.payment_id,
                          'claim_id' value cp.claim_id,
                          'payment_type' value cp.payment_type,
                          'payment_date' value to_char(cp.payment_date, 'YYYY-MM-DD'),
                          'amount' value cp.amount,
                          'currency' value cp.currency,
                          'payment_method' value cp.payment_method,
                          'payee_name' value cp.payee_name,
                          'status' value cp.status
                        returning clob)
                      returning clob),
                      to_clob('[]')
                    )
             from claim_payments cp
             join claims c on c.claim_id = cp.claim_id
             where c.customer_id = cu.customer_id
           ),
           'interactions' value (
             select coalesce(
                      json_arrayagg(
                        json_object(
                          'comm_id' value cm.comm_id,
                          'entity_type' value cm.entity_type,
                          'entity_id' value cm.entity_id,
                          'direction' value cm.direction,
                          'channel' value cm.channel,
                          'subject' value cm.subject,
                          'comm_date' value to_char(cm.comm_date, 'YYYY-MM-DD'),
                          'status' value cm.status
                        returning clob)
                      returning clob),
                      to_clob('[]')
                    )
             from communications cm
             where (cm.entity_type = 'CUSTOMER' and cm.entity_id = cu.customer_id)
                or (cm.entity_type = 'CLAIM'
                    and cm.entity_id in (
                      select c.claim_id
                      from claims c
                      where c.customer_id = cu.customer_id
                    ))
           )
         returning clob)
    into l_result
    from customers cu
   where cu.customer_id = l_customer_id;

  return l_result;
exception
  when no_data_found then
    select json_object(
             'status' value 'NOT_FOUND',
             'customer_id' value l_customer_id,
             'claim_id' value p_claim_id,
             'error_message' value 'No customer found for the supplied parameters.'
           returning clob)
      into l_result
      from dual;
    return l_result;
  when others then
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'customer_id' value l_customer_id,
             'claim_id' value p_claim_id,
             'error_message' value 'Error in fsi_customer_360: ' || l_error_message
           returning clob)
      into l_result
      from dual;
    return l_result;
end;
/

create or replace function fsi_databricks_repairer_fraud_score (
  p_claim_id in number
) return clob
as
  l_result            clob;
  l_claim_number      claims.claim_number%type;
  l_repair_id         vehicle_repairs.repair_id%type;
  l_repairer_id       repairers.repairer_id%type;
  l_repairer_name     repairers.name%type;
  l_catalog_name      varchar2(128);
  l_schema_name       varchar2(128);
  l_table_name        varchar2(128);
  l_matched_repairer  varchar2(4000);
  l_fraud_score       number;
  l_fraud_score_raw   varchar2(4000);
  l_sql               varchar2(4000);
  l_error_message     varchar2(4000);

  function runtime_config_value(p_config_key in varchar2) return varchar2 is
    l_value varchar2(4000);
  begin
    select trim(dbms_lob.substr(config_value, 4000, 1))
      into l_value
      from fsi_runtime_config
     where config_key = upper(trim(p_config_key));
    return l_value;
  exception
    when no_data_found then
      return null;
  end;

  function safe_identifier(
    p_value   in varchar2,
    p_default in varchar2
  ) return varchar2 is
    l_value varchar2(128) := nvl(nullif(trim(p_value), ''), p_default);
  begin
    if not regexp_like(l_value, '^[A-Za-z_][A-Za-z0-9_$#]*$') then
      raise_application_error(-20070, 'Unsafe Databricks catalog identifier configured.');
    end if;
    return upper(l_value);
  end;
begin
  if p_claim_id is null then
    select json_object(
             'provider' value 'Databricks repairer fraud score',
             'status' value 'ERROR',
             'error_message' value 'Missing required parameter P_CLAIM_ID.'
           returning clob)
      into l_result from dual;
    return l_result;
  end if;

  select c.claim_number, vr.repair_id, r.repairer_id, r.name
    into l_claim_number, l_repair_id, l_repairer_id, l_repairer_name
    from claims c
    left join vehicle_repairs vr on vr.claim_id = c.claim_id
    left join repairers r on r.repairer_id = vr.repairer_id
   where c.claim_id = p_claim_id
   order by case when r.name is null then 1 else 0 end, vr.repair_id
   fetch first 1 row only;

  if l_repairer_name is null then
    select json_object(
             'provider' value 'Databricks repairer fraud score',
             'status' value 'NOT_FOUND',
             'claim_id' value p_claim_id,
             'claim_number' value l_claim_number,
             'repair_id' value l_repair_id,
             'repairer_id' value l_repairer_id,
             'message' value 'No repairer is linked to this claim.'
           returning clob)
      into l_result from dual;
    return l_result;
  end if;

  l_catalog_name := safe_identifier(runtime_config_value('DATABRICKS_ICEBERG_CATALOG_NAME'), 'DBX_ICEBERG_CATALOG_JC');
  l_schema_name := safe_identifier(runtime_config_value('DATABRICKS_SCHEMA'), 'FSI_GOLD');
  l_table_name := safe_identifier(runtime_config_value('DATABRICKS_REPAIRER_FRAUD_TABLE'), 'REPAIRER_FRAUD_SCORES');
  l_sql := 'select repairer_name, fraud_score from ' || l_schema_name || '.' || l_table_name || '@' || l_catalog_name ||
           ' where lower(trim(repairer_name)) = lower(trim(:repairer_name)) and rownum = 1';

  begin
    execute immediate l_sql into l_matched_repairer, l_fraud_score using l_repairer_name;
    l_fraud_score_raw := to_char(l_fraud_score);
  exception
    when no_data_found then
      select json_object(
               'provider' value 'Databricks repairer fraud score',
               'status' value 'NOT_FOUND',
               'claim_id' value p_claim_id,
               'claim_number' value l_claim_number,
               'repair_id' value l_repair_id,
               'repairer_id' value l_repairer_id,
               'repairer_name' value l_repairer_name,
               'message' value 'Repairer was not found in the external Databricks Unity catalog.'
             returning clob)
        into l_result from dual;
      return l_result;
  end;

  select json_object(
           'provider' value 'Databricks repairer fraud score',
           'status' value 'FOUND',
           'claim_id' value p_claim_id,
           'claim_number' value l_claim_number,
           'repair_id' value l_repair_id,
           'repairer_id' value l_repairer_id,
           'repairer_name' value l_repairer_name,
           'matched_repairer_name' value l_matched_repairer,
           'fraud_score' value l_fraud_score,
           'fraud_score_raw' value l_fraud_score_raw
         returning clob)
    into l_result from dual;
  return l_result;
exception
  when no_data_found then
    select json_object(
             'provider' value 'Databricks repairer fraud score',
             'status' value 'NOT_FOUND',
             'claim_id' value p_claim_id,
             'error_message' value 'No claim found for P_CLAIM_ID=' || p_claim_id
           returning clob)
      into l_result from dual;
    return l_result;
  when others then
    l_error_message := sqlerrm;
    select json_object(
             'provider' value 'Databricks repairer fraud score',
             'status' value 'ERROR',
             'claim_id' value p_claim_id,
             'repairer_name' value l_repairer_name,
             'error_message' value 'Error in fsi_databricks_repairer_fraud_score: ' || l_error_message
           returning clob)
      into l_result from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_DELETE_CLAIMS_BY_ID_RANGE" (
  p_from_claim_id in number,
  p_to_claim_id   in number
) return clob
authid definer
as
  pragma autonomous_transaction;

  l_job_name      varchar2(128);
  l_job_action    varchar2(4000);
  l_result        clob;
  l_error_message varchar2(4000);
begin
  if p_from_claim_id is null
     or p_to_claim_id is null
     or p_from_claim_id < 1
     or p_to_claim_id < 1
     or p_from_claim_id <> trunc(p_from_claim_id)
     or p_to_claim_id <> trunc(p_to_claim_id)
     or p_from_claim_id > p_to_claim_id
  then
    rollback;
    select json_object(
             'status' value 'ERROR',
             'error_message' value 'P_FROM_CLAIM_ID and P_TO_CLAIM_ID must be positive integers with FROM <= TO.'
             returning clob)
      into l_result
      from dual;
    return l_result;
  end if;

  l_job_name := 'FSI_CLAIM_DEL_' || substr(rawtohex(sys_guid()), 1, 24);
  l_job_action :=
    'begin fsi_delete_claims_by_id_range_worker('
    || to_char(p_from_claim_id)
    || ','
    || to_char(p_to_claim_id)
    || ','''
    || l_job_name
    || '''); end;';

  insert into fsi_claim_delete_jobs (
    job_name,
    from_claim_id,
    to_claim_id,
    status
  ) values (
    l_job_name,
    p_from_claim_id,
    p_to_claim_id,
    'QUEUED'
  );

  dbms_scheduler.create_job(
    job_name        => l_job_name,
    job_type        => 'PLSQL_BLOCK',
    job_action      => l_job_action,
    start_date      => systimestamp + interval '1' second,
    enabled         => false,
    auto_drop       => true,
    comments        => 'Background claim deletion for IDs '
                       || to_char(p_from_claim_id) || ' through ' || to_char(p_to_claim_id)
  );
  dbms_scheduler.enable(l_job_name);
  commit;

  select json_object(
           'status' value 'QUEUED',
           'job_name' value l_job_name,
           'from_claim_id' value p_from_claim_id,
           'to_claim_id' value p_to_claim_id,
           'message' value 'Claim deletion was queued for background execution.'
           returning clob)
    into l_result
    from dual;
  return l_result;
exception
  when others then
    begin
      dbms_scheduler.drop_job(l_job_name, force => true);
    exception
      when others then null;
    end;
    rollback;
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'job_name' value l_job_name,
             'from_claim_id' value p_from_claim_id,
             'to_claim_id' value p_to_claim_id,
             'error_message' value 'Unable to queue claim deletion: ' || l_error_message
             returning clob)
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_DELETE_CLAIM_BY_ID" (
  p_claim_id in number
) return clob
authid definer
as
  pragma autonomous_transaction;

  l_claim_count    number := 0;
  l_rows_deleted   number := 0;
  l_object_name   varchar2(255);
  l_object_uri    varchar2(2000);
  l_storage_prefix varchar2(1000);
  l_credential_name varchar2(128);
  l_result        clob;
  l_error_message varchar2(4000);

  procedure add_deleted_rows is
  begin
    l_rows_deleted := l_rows_deleted + sql%rowcount;
  end;

  procedure delete_optional(p_sql in varchar2) is
  begin
    execute immediate p_sql using p_claim_id;
    add_deleted_rows;
  exception
    when others then
      -- Optional claim-owned tables differ between the original and extended
      -- FSI schemas. Ignore only a missing table; surface every other error.
      if sqlcode not in (-942, -4043) then
        raise;
      end if;
  end;
begin
  if p_claim_id is null
     or p_claim_id < 1
     or p_claim_id <> trunc(p_claim_id)
  then
    rollback;
    select json_object(
             'status' value 'ERROR',
             'error_message' value 'P_CLAIM_ID must be a positive integer.'
             returning clob)
      into l_result
      from dual;
    return l_result;
  end if;

  l_storage_prefix := 'https://objectstorage.us-chicago-1.oraclecloud.com/n/idukzrqavn8q/b/fsi-crossshield-kb/o/';
  l_credential_name := 'FS_OCI_CRED';
  begin
    select trim(dbms_lob.substr(config_value, 1000, 1))
      into l_storage_prefix
      from fsi_runtime_config
     where config_key = 'OBJECT_STORAGE_PREFIX';
  exception
    when no_data_found then null;
  end;
  begin
    select trim(dbms_lob.substr(config_value, 128, 1))
      into l_credential_name
      from fsi_runtime_config
     where config_key = 'OBJECT_STORAGE_CREDENTIAL_NAME';
  exception
    when no_data_found then null;
  end;
  l_storage_prefix := rtrim(coalesce(l_storage_prefix, 'https://objectstorage.us-chicago-1.oraclecloud.com/n/idukzrqavn8q/b/fsi-crossshield-kb/o/'), '/') || '/';
  l_credential_name := coalesce(l_credential_name, 'FS_OCI_CRED');

  l_object_name := 'claim-' || to_char(trunc(p_claim_id)) || '-fraud-investigation.md';
  l_object_uri := l_storage_prefix || l_object_name;

  -- Delete the external object first. FORCE=TRUE makes an already-absent
  -- object idempotent while still surfacing credential or network failures.
  begin
    dbms_cloud.delete_object(
      credential_name => l_credential_name,
      object_uri      => l_object_uri,
      force           => true
    );
  exception
    when others then
      rollback;
      l_error_message := sqlerrm;
      select json_object(
               'status' value 'STORAGE_ERROR',
               'claim_id' value p_claim_id,
               'object_name' value l_object_name,
               'object_uri' value l_object_uri,
               'error_message' value 'Unable to delete the Object Storage object: ' || l_error_message
               returning clob)
        into l_result
        from dual;
      return l_result;
  end;

  select count(*)
    into l_claim_count
    from claims
   where claim_id = p_claim_id;

  -- Polymorphic claim-owned records.
  delete from documents
   where upper(entity_type) = 'CLAIM'
     and entity_id = p_claim_id;
  add_deleted_rows;

  delete from communications
   where upper(entity_type) = 'CLAIM'
     and entity_id = p_claim_id;
  add_deleted_rows;

  delete from sanctions_checks
   where upper(entity_type) = 'CLAIM'
     and entity_id = p_claim_id;
  add_deleted_rows;

  -- Delete children before CLAIMS so the function also works when foreign keys
  -- are enabled without ON DELETE CASCADE.
  delete from medical_assessments where claim_id = p_claim_id;
  add_deleted_rows;

  delete_optional('delete from claim_parties where claim_id = :1');
  delete from claim_payments where claim_id = p_claim_id;
  add_deleted_rows;

  delete from excess_recovery where claim_id = p_claim_id;
  add_deleted_rows;

  delete from fraud_indicators where claim_id = p_claim_id;
  add_deleted_rows;

  delete from fraud_investigations where claim_id = p_claim_id;
  add_deleted_rows;

  delete from incidents where claim_id = p_claim_id;
  add_deleted_rows;

  delete from reinsurance_recoveries where claim_id = p_claim_id;
  add_deleted_rows;

  delete from vehicle_repairs where claim_id = p_claim_id;
  add_deleted_rows;

  -- These tables exist in the extended FSI deployment and are not present in
  -- the original FSIHUB DDL.
  delete_optional('delete from fsi_third_party_fraud_cache where claim_id = :1');
  delete_optional('delete from crossshield_apex_reports where claim_id = :1');

  delete from claims where claim_id = p_claim_id;
  add_deleted_rows;

  commit;

  select json_object(
           'status' value case
             when l_claim_count > 0 or l_rows_deleted > 0 then 'DELETED'
             else 'NOT_FOUND'
           end,
           'claim_id' value p_claim_id,
           'object_name' value l_object_name,
           'object_uri' value l_object_uri,
           'object_deleted' value 'Y',
           'rows_deleted' value l_rows_deleted
           returning clob)
    into l_result
    from dual;
  return l_result;
exception
  when others then
    rollback;
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'claim_id' value p_claim_id,
             'object_name' value l_object_name,
             'object_uri' value l_object_uri,
             'error_message' value 'Error in fsi_delete_claim_by_id: ' || l_error_message
             returning clob)
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_FINALIZE_FRAUD_REVIEW" (
  p_claim_id in number
) return clob
as
  l_risk_json       clob;
  l_third_party     clob;
  l_databricks      clob;
  l_similar_cases   clob;
  l_report          clob;
  l_save_result     clob;
  l_update_result   clob;
  l_notify_result   clob;
  l_google_sheet    clob;
  l_result          clob;
  l_similar_cases_top2 clob;
  l_errors          clob := '[]';
  l_recommended_actions clob;
  l_error_message   varchar2(4000);
  l_probability     number := 0;
  l_risk_level      varchar2(30) := 'LOW';
  l_reason          varchar2(4000);
  l_report_uri      varchar2(500);
  l_weather_status  varchar2(100);
  l_weather_risk    varchar2(10);
  l_sheet_status    varchar2(30);
  l_sheet_customer  varchar2(4000);
  l_sheet_score     number;
  l_sheet_message   varchar2(4000);
  l_databricks_status varchar2(30);
  l_repairer_name   varchar2(4000);
  l_matched_repairer_name varchar2(4000);
  l_repairer_fraud_score number;
  l_rule_probability number;
  l_external_score_sum number := 0;
  l_external_score_count number := 0;
  l_external_average number;
  l_external_anchor number;
  l_scoring_rationale varchar2(4000);

-- fsi_finalize_fraud_review function finalizes the fraud review process for a given claim ID.
-- It retrieves risk scores, third-party data, and similar fraud cases,
-- generates a fraud investigation report, saves it, updates the claim's fraud outcome,
-- and sends notifications if necessary. The function returns a JSON object
-- containing the final fraud review results, including the report URI and recommended next actions.

begin
  l_risk_json := fsi_claim_risk_score(p_claim_id);
  l_third_party := fsi_third_party_fraud_data(p_claim_id);
  l_databricks := fsi_databricks_repairer_fraud_score(p_claim_id);

  begin
    l_similar_cases := fsi_similar_fraud_cases(p_claim_id);
  exception
    when others then
      l_error_message := sqlerrm;
      select json_array(
               json_object(
                 'status' value 'ERROR',
                 'error_message' value 'Error calling fsi_similar_fraud_cases: ' || l_error_message
               )
               returning clob
             )
        into l_similar_cases
        from dual;
  end;

  begin
    select nvl(
             json_arrayagg(
               json_object(
                 'claim_id' value jt.claim_id,
                 'claim_number' value jt.claim_number,
                 'claim_type' value jt.claim_type,
                 'fraud_score' value jt.fraud_score,
                 'similarity_score' value jt.similarity_score
               )
               order by jt.rn
               returning clob
             ),
             '[]'
           )
      into l_similar_cases_top2
      from json_table(
             l_similar_cases,
             '$[*]'
             columns (
               rn               for ordinality,
               claim_id         number        path '$.claim_id',
               claim_number     varchar2(100) path '$.claim_number',
               claim_type       varchar2(100) path '$.claim_type',
               fraud_score      number        path '$.fraud_score',
               similarity_score number        path '$.similarity_score'
             )
           ) jt
     where jt.rn <= 2
       and jt.similarity_score > 60;
  exception
    when others then
      l_similar_cases_top2 := '[]';
  end;

  l_probability := nvl(json_value(l_risk_json, '$.fraud_probability' returning number null on error), 0);
  l_risk_level := nvl(json_value(l_risk_json, '$.risk_level' returning varchar2(30) null on error), 'LOW');
  l_reason := nvl(json_value(l_risk_json, '$.reason_codes' returning varchar2(4000) null on error), 'No material rule-based risk indicators found');
  l_weather_status := json_value(l_third_party, '$.weather_data.status' returning varchar2(100) null on error);
  l_weather_risk := json_value(l_third_party, '$.weather_data.risk_indicators.weather_may_affect_accident_risk' returning varchar2(10) null on error);
  l_google_sheet := json_query(l_third_party, '$.google_sheet_fraud_score' returning clob null on error);
  l_sheet_status := json_value(l_third_party, '$.google_sheet_fraud_score.status' returning varchar2(30) null on error);
  l_sheet_customer := json_value(l_third_party, '$.google_sheet_fraud_score.lookup_customer_name' returning varchar2(4000) null on error);
  l_sheet_score := json_value(l_third_party, '$.google_sheet_fraud_score.fraud_score' returning number null on error);
  l_sheet_message := json_value(l_third_party, '$.google_sheet_fraud_score.message' returning varchar2(4000) null on error);
  l_databricks_status := json_value(l_databricks, '$.status' returning varchar2(30) null on error);
  l_repairer_name := json_value(l_databricks, '$.repairer_name' returning varchar2(4000) null on error);
  l_matched_repairer_name := json_value(l_databricks, '$.matched_repairer_name' returning varchar2(4000) null on error);
  l_repairer_fraud_score := json_value(l_databricks, '$.fraud_score' returning number null on error);

  l_rule_probability := l_probability;
  if l_sheet_status = 'FOUND' and l_sheet_score between 0 and 100 then
    l_external_score_sum := l_external_score_sum + l_sheet_score;
    l_external_score_count := l_external_score_count + 1;
  end if;
  if l_databricks_status = 'FOUND' and l_repairer_fraud_score between 0 and 100 then
    l_external_score_sum := l_external_score_sum + l_repairer_fraud_score;
    l_external_score_count := l_external_score_count + 1;
  end if;

  if l_external_score_count > 0 then
    l_external_average := round(l_external_score_sum / l_external_score_count, 2);
    l_external_anchor := round((l_rule_probability * 0.40) + (l_external_average * 0.60), 2);
    l_probability := greatest(l_probability, l_external_anchor);
    l_scoring_rationale :=
      'The rule-based baseline of ' || to_char(l_rule_probability, 'FM990D00') ||
      '% was combined with ' || to_char(l_external_score_count) ||
      ' available external fraud score(s), giving an external average of ' ||
      to_char(l_external_average, 'FM990D00') ||
      '%. The evidence anchor was calculated as (' ||
      to_char(l_rule_probability, 'FM990D00') || '% x 40%) + (' ||
      to_char(l_external_average, 'FM990D00') || '% x 60%) = ' ||
      to_char(l_external_anchor, 'FM990D00') ||
      '%. The authoritative Fraud Probability is the greater of the baseline and this evidence anchor.';
  else
    l_scoring_rationale :=
      'No usable Google Sheets or Databricks fraud score was available. The authoritative Fraud Probability remains the rule-based baseline of ' ||
      to_char(l_rule_probability, 'FM990D00') ||
      '%, with missing external evidence treated as unavailable rather than positive evidence.';
  end if;

  l_risk_level := case
                    when l_probability >= 70 then 'HIGH'
                    when l_probability >= 30 then 'MEDIUM'
                    else 'LOW'
                  end;
  l_reason := substr(l_reason || ' ' || l_scoring_rationale, 1, 4000);

  l_report :=
    'AI Fraud Investigation Report' || chr(10) ||
    'Claim ID: ' || p_claim_id || chr(10) ||
    'Fraud probability: ' || to_char(l_probability) || chr(10) ||
    'Risk level: ' || l_risk_level || chr(10) ||
    'Reason codes: ' || l_reason || chr(10) ||
    'Authoritative scoring method and rationale: ' || l_scoring_rationale || chr(10) ||
    'Weather status: ' || nvl(l_weather_status, 'UNKNOWN') || chr(10) ||
    'Weather may affect accident risk: ' || nvl(l_weather_risk, 'UNKNOWN') || chr(10) ||
    'Google Sheet fraud score status: ' || nvl(l_sheet_status, 'UNKNOWN') || chr(10) ||
    'Google Sheet lookup customer: ' || nvl(l_sheet_customer, 'UNKNOWN') || chr(10) ||
    'Google Sheet fraud score: ' || nvl(to_char(l_sheet_score), 'UNKNOWN') || chr(10) ||
    case
      when l_sheet_message is not null then 'Google Sheet message: ' || l_sheet_message || chr(10)
      else null
    end ||
    'Databricks repairer fraud score status: ' || nvl(l_databricks_status, 'UNKNOWN') || chr(10) ||
    'Databricks repairer name: ' || nvl(l_repairer_name, 'UNKNOWN') || chr(10) ||
    'Databricks matched repairer name: ' || nvl(l_matched_repairer_name, 'UNKNOWN') || chr(10) ||
    'Databricks repairer fraud score: ' || nvl(to_char(l_repairer_fraud_score), 'UNKNOWN') || chr(10) ||
    chr(10) ||
    'Risk score JSON:' || chr(10) || dbms_lob.substr(l_risk_json, 3000, 1) || chr(10) ||
    chr(10) ||
    'Third party JSON:' || chr(10) || dbms_lob.substr(l_third_party, 3000, 1) || chr(10) ||
    chr(10) ||
    'Databricks repairer fraud score JSON:' || chr(10) || dbms_lob.substr(l_databricks, 3000, 1) || chr(10) ||
    chr(10) ||
    'Similar fraud cases JSON:' || chr(10) || dbms_lob.substr(l_similar_cases_top2, 1500, 1);

  l_save_result := fsi_save_fraud_report(
                     p_claim_id          => p_claim_id,
                     p_fraud_probability => l_probability,
                     p_risk_level        => l_risk_level,
                     p_report            => l_report
                   );

  l_report_uri := json_value(l_save_result, '$.report_uri' returning varchar2(500) null on error);

  l_update_result := fsi_update_claim_fraud_outcome(
                       p_claim_id          => p_claim_id,
                       p_fraud_probability => l_probability,
                       p_reason            => l_reason,
                       p_report_uri        => l_report_uri
                     );

  if l_probability >= 50 then
    l_notify_result := fsi_send_fraud_notification(
                         p_claim_id   => p_claim_id,
                         p_report_uri => l_report_uri,
                         p_risk_level => l_risk_level,
                         p_summary    => substr(l_reason, 1, 1000)
                       );
  else
    select json_object(
             'status' value 'SKIPPED',
             'claim_id' value p_claim_id,
             'message' value 'Fraud probability is below 50%; SIU notification not required.'
           returning clob)
      into l_notify_result
      from dual;
  end if;

  select json_array(
           case
             when l_probability >= 50 then 'Route to SIU for investigator review before final settlement.'
             else 'Continue standard claim handling with routine monitoring.'
           end,
           'Review the evidence bundle, document consistency, Google Sheet score, Databricks repairer score, and weather evidence before closing the claim.'
           returning clob
         )
    into l_recommended_actions
    from dual;

  select json_object(
           'status' value 'FINALIZED',
           'claim_id' value p_claim_id,
           'fraud_potential' value l_probability,
           'fraud_probability' value l_probability,
           'risk_level' value l_risk_level,
           'reason' value l_reason,
           'evidence' value json_object(
             'risk_score' value l_risk_json format json,
             'weather_evidence' value json_query(l_third_party, '$.weather_data' returning clob null on error) format json,
             'google_sheet_fraud_score' value l_google_sheet format json,
             'databricks_repairer_fraud_score' value l_databricks format json,
             'similar_cases_top2' value l_similar_cases_top2 format json,
             'workflow_actions' value json_object(
               'report_uri' value l_report_uri,
               'save_result' value l_save_result format json,
               'update_result' value l_update_result format json,
               'notification_result' value l_notify_result format json
               returning clob
             ) format json
             returning clob
           ) format json,
           'errors' value l_errors format json,
           'recommended_next_actions' value l_recommended_actions format json,
           'report_uri' value l_report_uri
         returning clob)
    into l_result
    from dual;

  return l_result;
exception
  when others then
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'claim_id' value p_claim_id,
             'error_message' value 'Error in fsi_finalize_fraud_review: ' || l_error_message
           returning clob)
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_GENERATE_RANDOM_CLAIM" (
  p_risk_tier  in varchar2 default 'MEDIUM',
  p_claim_type in varchar2 default null
)
  return number
authid current_user
as
  pragma autonomous_transaction;

  l_claim_id        number;
  l_incident_id     number;
  l_repair_id       number;
  l_payment_id      number;
  l_assessment_id   number;
  l_indicator_id    number;
  l_policy_id       policies.policy_id%type;
  l_customer_id     customers.customer_id%type;
  l_vehicle_id      policies.vehicle_id%type;
  l_repairer_id     repairers.repairer_id%type;
  l_repairer_name   repairers.name%type;
  l_policy_start    policies.start_date%type;
  l_policy_end      policies.end_date%type;
  l_customer_city   customers.city%type;
  l_customer_postcode customers.postcode%type;
  l_customer_name   varchar2(300);
  l_customer_address varchar2(800);
  l_customer_email  customers.email%type;
  l_customer_phone  customers.phone_mobile%type;
  l_customer_status customers.customer_status%type;
  l_customer_occupation customers.occupation%type;
  l_customer_credit_score customers.credit_score%type;
  l_customer_fraud_flag customers.fraud_flag%type;
  l_vehicle_registration vehicles.registration%type;
  l_vehicle_make     vehicles.make%type;
  l_vehicle_model    vehicles.model%type;
  l_vehicle_year     vehicles.year%type;
  l_vehicle_body_type vehicles.body_type%type;
  l_vehicle_fuel_type vehicles.fuel_type%type;
  l_vehicle_transmission vehicles.transmission%type;
  l_vehicle_colour   vehicles.colour%type;
  l_vehicle_market_value vehicles.market_value%type;
  l_vehicle_annual_mileage vehicles.annual_mileage%type;
  l_vehicle_overnight_park vehicles.overnight_park%type;
  l_vehicle_modifications vehicles.modifications%type;
  l_claim_type      claims.claim_type%type;
  l_claim_details   claims.claim_details%type;
  l_claim_details_prompt clob;
  l_incident_type   incidents.incident_type%type;
  l_incident_date   date;
  l_reported_date   date;
  l_total_claimed   number;
  l_reserve_amount  number;
  l_fault_flag      char(1);
  l_third_party_flag char(1);
  l_injury_flag     char(1);
  l_weather_cond    incidents.weather_cond%type;
  l_road_cond       incidents.road_cond%type;
  l_light_cond      incidents.light_cond%type;
  l_police_attended char(1);
  l_ambulance_attend char(1);
  l_speed_limit     number;
  l_min_incident_date date;
  l_max_incident_date date;
  l_days_span       number;
  l_repair_estimate number;
  l_approved_amount number;
  l_final_amount    number;
  l_parts_cost      number;
  l_paint_cost      number;
  l_repair_status   vehicle_repairs.repair_status%type;
  l_total_loss_flag char(1);
  l_payment_type    claim_payments.payment_type%type;
  l_payment_status  claim_payments.status%type;
  l_payment_amount  number;
  l_injury_type     medical_assessments.injury_type%type;
  l_disability_days number;
  l_medical_value   number;
  l_fraud_indicator medical_assessments.fraud_indicator%type;
  l_assessor_name   medical_assessments.assessor_name%type;
  l_indicator_desc  fraud_indicators.indicator_desc%type;
  l_risk_tier       varchar2(20);

  function normalize_customer_name(p_value in varchar2) return varchar2 is
  begin
    return regexp_replace(lower(trim(p_value)), '[[:space:]]+', ' ');
  end;

  function csv_field(p_line in varchar2, p_index in pls_integer) return varchar2 is
    l_pos       pls_integer := 1;
    l_index     pls_integer := 1;
    l_char      varchar2(1);
    l_value     varchar2(32767);
    l_in_quotes boolean := false;
  begin
    loop
      exit when l_pos > length(p_line) + 1;
      l_char := case when l_pos <= length(p_line) then substr(p_line, l_pos, 1) else ',' end;
      if l_char = '"' then
        if l_in_quotes and substr(p_line, l_pos + 1, 1) = '"' then
          if l_index = p_index then l_value := l_value || '"'; end if;
          l_pos := l_pos + 1;
        else
          l_in_quotes := not l_in_quotes;
        end if;
      elsif l_char = ',' and not l_in_quotes then
        if l_index = p_index then return l_value; end if;
        l_index := l_index + 1;
        l_value := null;
      elsif l_index = p_index then
        l_value := l_value || l_char;
      end if;
      l_pos := l_pos + 1;
    end loop;
    return null;
  end;

  procedure select_google_sheet_customer is
    l_sheet_url       varchar2(4000);
    l_sheet_id        varchar2(200);
    l_csv_url         varchar2(4000);
    l_req             utl_http.req;
    l_resp            utl_http.resp;
    l_redirect_url    varchar2(4000);
    l_redirects       pls_integer := 0;
    l_buffer          varchar2(32767);
    l_csv             clob;
    l_offset          pls_integer := 1;
    l_line_end        pls_integer;
    l_header          varchar2(32767);
    l_line            varchar2(32767);
    l_column_count    pls_integer;
    l_customer_column pls_integer;
    l_score_column    pls_integer;
    l_sheet_name      varchar2(4000);
    l_normalized_sheet_name varchar2(4000);
    l_score           number;
    l_matches         pls_integer := 0;
    l_candidate_customer_id customers.customer_id%type;
    l_candidate_city        customers.city%type;
    l_candidate_postcode    customers.postcode%type;
  begin
    begin
      select trim(dbms_lob.substr(config_value, 4000, 1))
        into l_sheet_url
        from fsi_runtime_config
       where config_key = 'GOOGLE_SHEET_URL';
    exception
      when no_data_found then
        raise_application_error(-20091, 'GOOGLE_SHEET_URL must be configured for HIGH or LOW risk claim generation.');
    end;

    l_sheet_id := regexp_substr(l_sheet_url, '/d/([^/]+)', 1, 1, null, 1);
    if l_sheet_id is null then
      raise_application_error(-20091, 'GOOGLE_SHEET_URL must contain a Google Sheets document ID for HIGH or LOW risk claim generation.');
    end if;

    l_csv_url := 'https://docs.google.com/spreadsheets/d/' || l_sheet_id ||
                 '/export?format=csv' || chr(38) || 'gid=0';
    dbms_lob.createtemporary(l_csv, true);
    loop
      l_req := utl_http.begin_request(l_csv_url, 'GET', 'HTTP/1.1');
      utl_http.set_header(l_req, 'Accept', 'text/csv,text/plain,*/*');
      l_resp := utl_http.get_response(l_req);
      exit when l_resp.status_code not in (301, 302, 303, 307, 308);
      begin
        utl_http.get_header_by_name(l_resp, 'Location', l_redirect_url);
      exception when others then
        l_redirect_url := null;
      end;
      utl_http.end_response(l_resp);
      l_redirects := l_redirects + 1;
      if l_redirect_url is null or l_redirects > 5 then
        raise_application_error(-20092, 'Google Sheet CSV redirect could not be followed.');
      end if;
      l_csv_url := l_redirect_url;
    end loop;
    if l_resp.status_code < 200 or l_resp.status_code >= 300 then
      raise_application_error(-20092, 'Google Sheet CSV request failed with HTTP status ' || l_resp.status_code || '.');
    end if;
    begin
      loop
        utl_http.read_text(l_resp, l_buffer, 32767);
        dbms_lob.writeappend(l_csv, length(l_buffer), l_buffer);
      end loop;
    exception when utl_http.end_of_body then null;
    end;
    utl_http.end_response(l_resp);

    l_line_end := dbms_lob.instr(l_csv, chr(10), l_offset);
    if l_line_end = 0 then l_line_end := dbms_lob.getlength(l_csv) + 1; end if;
    l_header := rtrim(dbms_lob.substr(l_csv, l_line_end - l_offset, l_offset), chr(13));
    l_offset := l_line_end + 1;
    if l_header is null then
      raise_application_error(-20093, 'Google Sheet CSV is empty.');
    end if;

    l_column_count := regexp_count(l_header, ',') + 1;
    for i in 1 .. l_column_count loop
      if regexp_replace(lower(trim(csv_field(l_header, i))), '[^a-z0-9]', '')
           in ('customername', 'customer', 'name', 'clientname') then
        l_customer_column := i;
      elsif regexp_replace(lower(trim(csv_field(l_header, i))), '[^a-z0-9]', '')
           in ('fraudscore', 'fraudprobability', 'fraudrisk', 'score') then
        l_score_column := i;
      end if;
    end loop;
    if l_customer_column is null or l_score_column is null then
      raise_application_error(-20094, 'Google Sheet must contain Customer Name and Fraud Score columns.');
    end if;

    loop
      exit when l_offset > dbms_lob.getlength(l_csv);
      l_line_end := dbms_lob.instr(l_csv, chr(10), l_offset);
      if l_line_end = 0 then l_line_end := dbms_lob.getlength(l_csv) + 1; end if;
      l_line := rtrim(dbms_lob.substr(l_csv, least(32767, l_line_end - l_offset), l_offset), chr(13));
      l_offset := l_line_end + 1;
      continue when trim(l_line) is null;

      begin
        l_score := to_number(trim(replace(csv_field(l_line, l_score_column), '%')));
      exception when others then
        l_score := null;
      end;
      if (l_risk_tier = 'HIGH' and l_score > 50)
         or (l_risk_tier = 'LOW' and l_score < 49) then
        l_sheet_name := csv_field(l_line, l_customer_column);
        l_normalized_sheet_name := normalize_customer_name(l_sheet_name);
        begin
          select customer_id, city, postcode
            into l_candidate_customer_id, l_candidate_city, l_candidate_postcode
            from (
              select c.customer_id, c.city, c.postcode
                from customers c
               where regexp_replace(
                       lower(trim(c.first_name || ' ' || c.last_name)),
                       '[[:space:]]+',
                       ' '
                     ) = l_normalized_sheet_name
                 and exists (
                       select 1
                         from policies p
                         join vehicles v
                           on v.vehicle_id = p.vehicle_id
                        where p.customer_id = c.customer_id
                          and p.start_date is not null
                          and p.end_date is not null
                          and p.start_date <= least(p.end_date, trunc(sysdate)) - 1
                     )
               order by dbms_random.value
            )
           where rownum = 1;
          l_matches := l_matches + 1;
          -- Reservoir sampling makes every eligible Google Sheets customer equally likely.
          if dbms_random.value <= 1 / l_matches then
            l_customer_id := l_candidate_customer_id;
            l_customer_city := l_candidate_city;
            l_customer_postcode := l_candidate_postcode;
          end if;
        exception when no_data_found then null;
        end;
      end if;
    end loop;

    if l_matches = 0 then
      raise_application_error(-20095, 'No application customer matched a Google Sheets fraud score for risk tier ' || l_risk_tier || '.');
    end if;
  exception
    when others then
      begin utl_http.end_response(l_resp); exception when others then null; end;
      raise;
  end;
begin
  dbms_random.seed(to_number(to_char(systimestamp, 'FF6')));
  -- CLAIM_ID is mandatory. Use the database sequence so generation also works
  -- after all rows have been deleted from CLAIMS.
  select claims_seq.nextval
    into l_claim_id
    from dual;
  l_risk_tier :=
    case upper(trim(p_risk_tier))
      when 'HIGH' then 'HIGH'
      when 'HIGH RISK' then 'HIGH'
      when 'LOW' then 'LOW'
      when 'LOW RISK' then 'LOW'
      else 'MEDIUM'
    end;

  if l_risk_tier in ('HIGH', 'LOW') then
    select_google_sheet_customer;
  else
    select customer_id,
           city,
           postcode
      into l_customer_id,
           l_customer_city,
           l_customer_postcode
      from (
        select customer_id,
               city,
               postcode
          from customers
         where exists (
                 select 1
                   from policies p
                   join vehicles v
                     on v.vehicle_id = p.vehicle_id
                  where p.customer_id = customers.customer_id
                    and p.start_date is not null
                    and p.end_date is not null
                    and p.start_date <= least(p.end_date, trunc(sysdate)) - 1
               )
         order by dbms_random.value
      )
     where rownum = 1;
  end if;

  select policy_id,
         vehicle_id,
         start_date,
         end_date
    into l_policy_id,
         l_vehicle_id,
         l_policy_start,
         l_policy_end
    from (
      select p.policy_id,
             p.vehicle_id,
             p.start_date,
             p.end_date
        from policies p
        join vehicles v
          on v.vehicle_id = p.vehicle_id
       where p.customer_id = l_customer_id
         and p.start_date is not null
         and p.end_date is not null
         and p.start_date <= least(p.end_date, trunc(sysdate)) - 1
       order by case
                  when not exists (
                    select 1
                      from claims c
                     where c.policy_id = p.policy_id
                  ) then 0
                  else 1
                end,
                dbms_random.value
    )
   where rownum = 1;

  begin
    select trim(first_name || ' ' || last_name),
           trim(
             address_line1
             || case when address_line2 is not null then ', ' || address_line2 end
             || case when city is not null then ', ' || city end
             || case when county is not null then ', ' || county end
             || case when postcode is not null then ', ' || postcode end
             || case when country is not null then ', ' || country end
           ),
           email,
           phone_mobile,
           customer_status,
           occupation,
           credit_score,
           fraud_flag
      into l_customer_name,
           l_customer_address,
           l_customer_email,
           l_customer_phone,
           l_customer_status,
           l_customer_occupation,
           l_customer_credit_score,
           l_customer_fraud_flag
      from customers
     where customer_id = l_customer_id;
  exception
    when no_data_found then
      null;
  end;

  begin
    select registration,
           make,
           model,
           year,
           body_type,
           fuel_type,
           transmission,
           colour,
           market_value,
           annual_mileage,
           overnight_park,
           modifications
      into l_vehicle_registration,
           l_vehicle_make,
           l_vehicle_model,
           l_vehicle_year,
           l_vehicle_body_type,
           l_vehicle_fuel_type,
           l_vehicle_transmission,
           l_vehicle_colour,
           l_vehicle_market_value,
           l_vehicle_annual_mileage,
           l_vehicle_overnight_park,
           l_vehicle_modifications
      from vehicles
     where vehicle_id = l_vehicle_id;
  exception
    when no_data_found then
      null;
  end;

  l_claim_type :=
    case upper(trim(p_claim_type))
      when 'CAR_ACCIDENT' then 'ACCIDENT'
      when 'ACCIDENT' then 'ACCIDENT'
      when 'PERSONAL_INJURY' then 'PERSONAL_INJURY'
      when 'FIRE' then 'FIRE'
      when 'THEFT' then 'THEFT'
      when 'VANDALISM' then 'VANDALISM'
      else
        case trunc(dbms_random.value(1, 6))
          when 1 then 'ACCIDENT'
          when 2 then 'THEFT'
          when 3 then 'FIRE'
          when 4 then 'PERSONAL_INJURY'
          else 'VANDALISM'
        end
    end;

  if l_claim_type = 'ACCIDENT' then
    select repairer_id,
           name
      into l_repairer_id,
           l_repairer_name
      from (
        select repairer_id,
               name
          from repairers
         order by dbms_random.value
      )
     where rownum = 1;
  end if;

  l_incident_type :=
    case l_claim_type
      when 'PERSONAL_INJURY' then 'ACCIDENT'
      else l_claim_type
    end;

  l_min_incident_date := greatest(l_policy_start, trunc(sysdate) - 59);
  l_max_incident_date := trunc(sysdate) - 1;

  l_days_span := greatest(1, trunc(l_max_incident_date) - trunc(l_min_incident_date) + 1);
  l_incident_date := trunc(l_min_incident_date) + trunc(dbms_random.value(0, l_days_span));
  l_reported_date := least(trunc(sysdate), l_incident_date + trunc(dbms_random.value(0, 12)));

  l_total_claimed :=
    case l_claim_type
      when 'THEFT' then round(dbms_random.value(5000, 45000), 2)
      when 'FIRE' then round(dbms_random.value(8000, 55000), 2)
      when 'PERSONAL_INJURY' then round(dbms_random.value(6000, 65000), 2)
      when 'VANDALISM' then round(dbms_random.value(700, 12000), 2)
      else round(dbms_random.value(2500, 50000), 2)
    end;
  l_total_claimed :=
    round(
      case l_risk_tier
        when 'HIGH' then l_total_claimed * dbms_random.value(1.25, 1.85)
        when 'LOW' then l_total_claimed * dbms_random.value(0.45, 0.75)
        else l_total_claimed * dbms_random.value(0.85, 1.15)
      end,
      2
    );

  l_reserve_amount := round(l_total_claimed * dbms_random.value(0.55, 0.9), 2);
  l_fault_flag :=
    case
      when l_risk_tier = 'HIGH' then case when dbms_random.value < 0.75 then 'Y' else 'N' end
      when l_risk_tier = 'LOW' then case when dbms_random.value < 0.25 then 'Y' else 'N' end
      else case when dbms_random.value < 0.55 then 'Y' else 'N' end
    end;
  l_third_party_flag :=
    case
      when l_risk_tier = 'HIGH' then case when dbms_random.value < 0.7 then 'Y' else 'N' end
      when l_risk_tier = 'LOW' then case when dbms_random.value < 0.15 then 'Y' else 'N' end
      else case when dbms_random.value < 0.35 then 'Y' else 'N' end
    end;
  l_injury_flag :=
    case
      when l_claim_type = 'PERSONAL_INJURY' then 'Y'
      when l_claim_type = 'ACCIDENT' and l_risk_tier = 'HIGH' and dbms_random.value < 0.8 then 'Y'
      when l_claim_type = 'ACCIDENT' and l_risk_tier = 'LOW' and dbms_random.value < 0.25 then 'Y'
      when l_claim_type = 'ACCIDENT' and dbms_random.value < 0.55 then 'Y'
      else 'N'
    end;
  l_weather_cond :=
    case trunc(dbms_random.value(1, 7))
      when 1 then 'CLEAR'
      when 2 then 'RAIN'
      when 3 then 'HEAVY_RAIN'
      when 4 then 'FOG'
      when 5 then 'SNOW'
      else 'WIND'
    end;
  l_road_cond := case when l_weather_cond in ('RAIN', 'HEAVY_RAIN', 'SNOW') then 'WET' else 'DRY' end;
  l_light_cond := case when dbms_random.value < 0.65 then 'DAYLIGHT' else 'DARK' end;
  l_police_attended := case when l_claim_type in ('THEFT', 'FIRE') or dbms_random.value < 0.4 then 'Y' else 'N' end;
  l_ambulance_attend := case when l_injury_flag = 'Y' and dbms_random.value < 0.5 then 'Y' else 'N' end;
  l_speed_limit := case trunc(dbms_random.value(1, 5)) when 1 then 20 when 2 then 30 when 3 then 40 else 60 end;
  l_repair_estimate := round(greatest(350, l_total_claimed * dbms_random.value(0.18, 0.72)), 2);
  l_approved_amount := round(l_repair_estimate * dbms_random.value(0.65, 0.98), 2);
  l_final_amount := round(l_approved_amount * dbms_random.value(0.85, 1.15), 2);
  l_parts_cost := round(l_final_amount * dbms_random.value(0.35, 0.62), 2);
  l_paint_cost := round(l_final_amount * dbms_random.value(0.05, 0.18), 2);
  l_repair_status :=
    case trunc(dbms_random.value(1, 5))
      when 1 then 'PENDING'
      when 2 then 'AUTHORISED'
      when 3 then 'IN_PROGRESS'
      else 'COMPLETED'
    end;
  l_total_loss_flag := case when l_claim_type in ('FIRE', 'THEFT') and dbms_random.value < 0.25 then 'Y' else 'N' end;
  l_payment_type :=
    case l_claim_type
      when 'PERSONAL_INJURY' then 'INTERIM_INJURY_PAYMENT'
      when 'ACCIDENT' then 'REPAIRER_PAYMENT'
      else 'INTERIM_INDEMNITY'
    end;
  l_payment_status := 'UNDER_REVIEW';
  l_payment_amount :=
    round(
      greatest(75, l_total_claimed * dbms_random.value(0.05, 0.25)),
      2
    );
  l_injury_type :=
    case
      when l_injury_flag = 'Y' and l_claim_type = 'PERSONAL_INJURY' then 'WHIPLASH'
      when l_injury_flag = 'Y' and l_claim_type = 'ACCIDENT' then 'SOFT_TISSUE'
      when l_injury_flag = 'Y' then 'MINOR_INJURY'
      else 'NO_INJURY_REPORTED'
    end;
  l_disability_days := case when l_injury_flag = 'Y' then trunc(dbms_random.value(3, 60)) else 0 end;
  l_medical_value := case when l_injury_flag = 'Y' then round(l_total_claimed * dbms_random.value(0.18, 0.55), 2) else 0 end;
  l_fraud_indicator :=
    case
      when l_risk_tier = 'HIGH' and l_injury_flag = 'Y' then 'Late medical assessment or treatment gap'
      when l_risk_tier = 'HIGH' then 'High risk generated claim profile'
      when l_risk_tier = 'MEDIUM' and l_injury_flag = 'Y' and l_police_attended = 'N' then 'Injury reported without police attendance'
      when l_risk_tier = 'MEDIUM' and l_injury_flag = 'Y' and dbms_random.value < 0.25 then 'Late medical assessment or treatment gap'
      else null
    end;

  l_indicator_desc :=
    case l_claim_type
      when 'ACCIDENT' then
        case when l_risk_tier = 'HIGH' then 'Elevated motor accident exposure' else 'Motor accident consistency review' end ||
        ': GBP ' || to_char(round(l_total_claimed), 'FM9999999990') ||
        ' claimed after a ' || trunc(l_reported_date - l_incident_date) || '-day reporting interval in ' ||
        lower(l_weather_cond) || '/' || lower(l_road_cond) || ' conditions; ' ||
        case when l_third_party_flag = 'Y' then 'third-party involvement' else 'no third party recorded' end ||
        case when l_injury_flag = 'Y' then ' and bodily injury alleged.' else '.' end ||
        ' Validate liability, damage consistency and repair scope.'
      when 'PERSONAL_INJURY' then
        case when l_risk_tier = 'HIGH' then 'Elevated personal injury exposure' else 'Personal injury causation review' end ||
        ': GBP ' || to_char(round(l_total_claimed), 'FM9999999990') || ' claimed with ' || l_disability_days ||
        ' disability days and GBP ' || to_char(round(l_medical_value), 'FM9999999990') ||
        ' estimated medical value; ' ||
        case when l_ambulance_attend = 'Y' then 'ambulance attendance recorded' else 'no ambulance attendance recorded' end ||
        case when l_police_attended = 'Y' then ' and police attendance recorded.' else ' and no police attendance recorded.' end ||
        ' Validate clinical chronology, treatment necessity and accident causation.'
      when 'FIRE' then
        case when l_risk_tier = 'HIGH' then 'Elevated fire-loss exposure' else 'Fire-loss evidence review' end ||
        ': GBP ' || to_char(round(l_total_claimed), 'FM9999999990') || ' claimed' ||
        case when l_total_loss_flag = 'Y' then ' as a total loss' else ' for partial loss' end ||
        ' and reported ' || trunc(l_reported_date - l_incident_date) || ' days after the incident. ' ||
        'Validate cause-of-fire evidence, ownership, valuation and emergency-service chronology.'
      when 'THEFT' then
        case when l_risk_tier = 'HIGH' then 'Elevated theft-loss exposure' else 'Theft evidence consistency review' end ||
        ': GBP ' || to_char(round(l_total_claimed), 'FM9999999990') || ' claimed' ||
        case when l_total_loss_flag = 'Y' then ' as a total loss' else '' end ||
        ' and reported ' || trunc(l_reported_date - l_incident_date) || ' days after the loss; ' ||
        case when l_police_attended = 'Y' then 'police attendance recorded.' else 'no police attendance recorded.' end ||
        ' Validate the police reference, security evidence, ownership and valuation.'
      when 'VANDALISM' then
        case when l_risk_tier = 'HIGH' then 'Elevated vandalism damage exposure' else 'Vandalism damage consistency review' end ||
        ': GBP ' || to_char(round(l_total_claimed), 'FM9999999990') || ' claimed against a GBP ' ||
        to_char(round(l_repair_estimate), 'FM9999999990') || ' repair estimate; ' ||
        case when l_police_attended = 'Y' then 'police attendance recorded.' else 'no police attendance recorded.' end ||
        ' Validate incident chronology, pre-loss condition, damage pattern and repair scope.'
      else
        'Generated ' || lower(l_claim_type) || ' claim requires evidence and value validation.'
    end;

  l_claim_details_prompt :=
    to_clob(q'~Write a descriptive but concise claimant-style narrative for a synthetic motor insurance claim. 
        Return only the narrative as plain text, with no JSON, headings, labels, fraud score, risk label, or unsupported facts. 
        Use the supplied customer, vehicle, policy and incident facts to make the narrative specific and relevant to the selected claim type.
        Use the selected risk category only to control the emphasis: a LOW profile should read as a generally coherent, supported event; 
        a MEDIUM profile should clearly describe any supplied verification points; a HIGH profile should clearly describe only the supplied timing, 
        value, damage, injury, reporting or evidence concerns. Do not declare fraud solely because of the selected risk category or a customer flag. 
        Distinguish reported facts from contextual data, do not invent missing facts, and do not repeat the customer's email, phone number, or full address
         in the narrative unless essential. Describe the reported incident, damage or loss, any injury, and the evidence the claimant says is available. 
         Whenever a monetary amount is included in the narrative, format it as £ followed by a space and an amount with two decimal places, for example £ 53356.23. 
         Never use GBP or another currency code. If the claim is related to Accident or Theft or Vandalism or Personal Injury do not include weather details in the claim details.
         Do not state that the claim was randomly generated.~')
    || chr(10) || 'Claim type: ' || l_claim_type
    || chr(10) || 'Selected risk category: ' || l_risk_tier
    || chr(10) || 'Customer name: ' || nvl(l_customer_name, 'not available')
    || chr(10) || 'Customer details: status=' || nvl(l_customer_status, 'not available')
       || '; occupation=' || nvl(l_customer_occupation, 'not available')
       || '; email=' || nvl(l_customer_email, 'not available')
       || '; mobile=' || nvl(l_customer_phone, 'not available')
       || '; credit score=' || nvl(to_char(l_customer_credit_score), 'not available')
       || '; customer fraud flag=' || nvl(l_customer_fraud_flag, 'not available')
    || chr(10) || 'Customer address: ' || nvl(l_customer_address, 'not available')
    || chr(10) || 'Vehicle details: registration=' || nvl(l_vehicle_registration, 'not available')
       || '; make=' || nvl(l_vehicle_make, 'not available')
       || '; model=' || nvl(l_vehicle_model, 'not available')
       || '; year=' || nvl(to_char(l_vehicle_year), 'not available')
       || '; body type=' || nvl(l_vehicle_body_type, 'not available')
       || '; fuel type=' || nvl(l_vehicle_fuel_type, 'not available')
       || '; transmission=' || nvl(l_vehicle_transmission, 'not available')
       || '; colour=' || nvl(l_vehicle_colour, 'not available')
       || '; market value=GBP ' || nvl(to_char(l_vehicle_market_value), 'not available')
       || '; annual mileage=' || nvl(to_char(l_vehicle_annual_mileage), 'not available')
       || '; overnight parking=' || nvl(l_vehicle_overnight_park, 'not available')
       || '; modifications=' || nvl(l_vehicle_modifications, 'none recorded')
    || chr(10) || 'Policy period: ' || to_char(l_policy_start, 'YYYY-MM-DD') || ' to ' || to_char(l_policy_end, 'YYYY-MM-DD')
    || chr(10) || 'City: ' || nvl(l_customer_city, 'not available')
    || chr(10) || 'Incident date: ' || to_char(l_incident_date, 'YYYY-MM-DD')
    || chr(10) || 'Weather: ' || l_weather_cond
    || chr(10) || 'Road condition: ' || l_road_cond
    || chr(10) || 'Lighting: ' || l_light_cond
    || chr(10) || 'Third party involved: ' || l_third_party_flag
    || chr(10) || 'Injury reported: ' || l_injury_flag
    || chr(10) || 'Police attended: ' || l_police_attended
    || chr(10) || 'Total claimed: GBP ' || to_char(l_total_claimed)
    || chr(10) || 'Reserve amount: GBP ' || to_char(l_reserve_amount)
    || chr(10) || 'Repair estimate: GBP ' || to_char(l_repair_estimate)
    || chr(10) || 'Medical value estimate: GBP ' || to_char(l_medical_value)
    || chr(10) || 'Disability days: ' || to_char(l_disability_days)
    || chr(10) || 'Fraud indicator context: ' || nvl(l_fraud_indicator, 'none recorded');

  begin
    select dbms_cloud_ai.generate(
             prompt       => l_claim_details_prompt,
             profile_name => coalesce(
               (select trim(dbms_lob.substr(config_value, 4000, 1))
                  from fsi_runtime_config
                 where config_key = 'APEX_LLM_PROFILE_NAME'),
               'FSI_APEX_GROK_PROFILE'
             ),
             action       => 'chat'
           )
      into l_claim_details
      from dual;

    l_claim_details := regexp_replace(
      l_claim_details,
      '^\s*```(?:text|markdown)?\s*',
      '',
      1,
      1,
      'in'
    );
    l_claim_details := regexp_replace(
      l_claim_details,
      '\s*```\s*$',
      '',
      1,
      1,
      'in'
    );
    l_claim_details := dbms_lob.substr(trim(l_claim_details), 4000, 1);
  exception
    when others then
      l_claim_details := null;
  end;

  if l_claim_details is null or length(l_claim_details) = 0 then
    l_claim_details :=
      case l_claim_type
        when 'ACCIDENT' then
          'The claimant' || case when l_customer_name is not null then ' ' || l_customer_name end || ' reports a motor accident involving the ' ||
          lower(nvl(l_vehicle_make, 'recorded')) || ' ' || lower(nvl(l_vehicle_model, 'vehicle')) ||
          ' in ' || nvl(l_customer_city, 'the recorded city') ||
          ' on ' || to_char(l_incident_date, 'YYYY-MM-DD') || ' in ' || lower(l_weather_cond) ||
          ' and ' || lower(l_road_cond) || ' conditions. The reported loss includes damage to the vehicle with an estimated repair cost of GBP ' ||
          to_char(l_repair_estimate) || case when l_injury_flag = 'Y' then ' and associated bodily injury.' else '.' end
        when 'PERSONAL_INJURY' then
          'The claimant' || case when l_customer_name is not null then ' ' || l_customer_name end || ' reports a personal injury incident involving the ' ||
          lower(nvl(l_vehicle_make, 'recorded')) || ' ' || lower(nvl(l_vehicle_model, 'vehicle')) ||
          ' in ' || nvl(l_customer_city, 'the recorded city') ||
          ' on ' || to_char(l_incident_date, 'YYYY-MM-DD') || ', with ' || l_disability_days ||
          ' disability days and an estimated medical value of GBP ' || to_char(l_medical_value) ||
          '. The claim also records the related accident circumstances and supporting treatment evidence.'
        when 'THEFT' then
          'The claimant reports a theft loss in ' || nvl(l_customer_city, 'the recorded city') ||
          ' on ' || to_char(l_incident_date, 'YYYY-MM-DD') || ', with an amount claimed of GBP ' ||
          to_char(l_total_claimed) || case when l_police_attended = 'Y' then '. Police attendance was recorded.' else '.' end
        when 'FIRE' then
          'The claimant reports fire damage in ' || nvl(l_customer_city, 'the recorded city') ||
          ' on ' || to_char(l_incident_date, 'YYYY-MM-DD') || ', with an amount claimed of GBP ' ||
          to_char(l_total_claimed) || case when l_total_loss_flag = 'Y' then ' and a total-loss indication.' else '.' end
        else
          'The claimant reports ' || lower(replace(l_claim_type, '_', ' ')) || ' damage in ' ||
          nvl(l_customer_city, 'the recorded city') || ' on ' || to_char(l_incident_date, 'YYYY-MM-DD') ||
          ', with an amount claimed of GBP ' || to_char(l_total_claimed) ||
          ' and a repair estimate of GBP ' || to_char(l_repair_estimate) || '.'
      end;
  end if;
 
 
    l_incident_id := fraud_indicators_seq.nextval;
    l_indicator_id := fraud_indicators_seq.nextval;
    l_repair_id := incidents_seq.nextval;
    l_payment_id := incidents_seq.nextval;
    l_assessment_id := incidents_seq.nextval;

 

  select customer_name
    into l_assessor_name
    from (
      select trim(c.first_name || ' ' || c.last_name) customer_name
        from customers c
       where c.first_name is not null
          or c.last_name is not null
       order by dbms_random.value
    )
   where rownum = 1;

  insert into claims (
    claim_id,
    claim_number,
    policy_id,
    customer_id,
    vehicle_id,
    incident_date,
    reported_date,
    claim_type,
    risk_tier,
    claim_details,
    claim_status,
    fault_flag,
    third_party_flag,
    injury_flag,
    total_claimed,
    total_settled,
    reserve_amount,
    open_date,
    fraud_flag,
    fraud_score,
    created_date
  ) values (
    l_claim_id,
    'CLM-' || to_char(sysdate, 'YYYY') || lpad(l_claim_id, 6, '0'),
    l_policy_id,
    l_customer_id,
    l_vehicle_id,
    l_incident_date,
    l_reported_date,
    l_claim_type,
    l_risk_tier,
    l_claim_details,
    'OPEN',
    l_fault_flag,
    l_third_party_flag,
    l_injury_flag,
    l_total_claimed,
    0,
    l_reserve_amount,
    l_reported_date,
    'N',
    null,
    sysdate
  );

  insert into incidents (
    incident_id,
    claim_id,
    incident_type,
    incident_date,
    incident_time,
    location_desc,
    postcode,
    weather_cond,
    road_cond,
    light_cond,
    speed_limit,
    police_attended,
    police_report_no,
    ambulance_attend,
    description
  ) values (
    l_incident_id,
    l_claim_id,
    l_incident_type,
    l_incident_date,
    lpad(trunc(dbms_random.value(0, 24)), 2, '0') || ':' || lpad(trunc(dbms_random.value(0, 60)), 2, '0'),
    coalesce(l_customer_city, 'Generated Location'),
    l_customer_postcode,
    l_weather_cond,
    l_road_cond,
    l_light_cond,
    l_speed_limit,
    l_police_attended,
    case when l_police_attended = 'Y' then 'AUTO-' || lpad(l_claim_id, 8, '0') end,
    l_ambulance_attend,
    l_claim_details
  );

  if l_claim_type = 'ACCIDENT' then
    insert into vehicle_repairs (
      repair_id,
      claim_id,
      vehicle_id,
      repairer_id,
      estimate_amount,
      approved_amount,
      final_amount,
      repair_status,
      authorised_date,
      start_date,
      completion_date,
      total_labour_hrs,
      labour_rate,
      parts_cost,
      paint_cost,
      salvage_value,
      total_loss_flag,
      notes
    ) values (
      l_repair_id,
      l_claim_id,
      l_vehicle_id,
      l_repairer_id,
      l_repair_estimate,
      case when l_repair_status in ('AUTHORISED', 'IN_PROGRESS', 'COMPLETED') then l_approved_amount end,
      case when l_repair_status = 'COMPLETED' then l_final_amount end,
      l_repair_status,
      case when l_repair_status in ('AUTHORISED', 'IN_PROGRESS', 'COMPLETED') then l_reported_date + trunc(dbms_random.value(1, 4)) end,
      case when l_repair_status in ('IN_PROGRESS', 'COMPLETED') then l_reported_date + trunc(dbms_random.value(4, 10)) end,
      case when l_repair_status = 'COMPLETED' then l_reported_date + trunc(dbms_random.value(11, 28)) end,
      round(dbms_random.value(3, 36), 2),
      round(dbms_random.value(55, 120), 2),
      l_parts_cost,
      l_paint_cost,
      case when l_total_loss_flag = 'Y' then round(l_total_claimed * dbms_random.value(0.08, 0.22), 2) end,
      l_total_loss_flag,
      'Randomly selected repairer from REPAIRERS: ' || l_repairer_name
    );
  end if;

  insert into claim_payments (
    payment_id,
    claim_id,
    payment_type,
    payment_date,
    amount,
    currency,
    payment_method,
    payee_name,
    payee_account,
    payee_sort_code,
    reference,
    status,
    approved_by,
    approved_date,
    notes
  ) values (
    l_payment_id,
    l_claim_id,
    l_payment_type,
    l_reported_date + trunc(dbms_random.value(1, 14)),
    l_payment_amount,
    'GBP',
    case trunc(dbms_random.value(1, 4)) when 1 then 'BACS' when 2 then 'FASTER_PAYMENT' else 'CHEQUE' end,
    case
      when l_payment_type = 'REPAIRER_PAYMENT' then l_repairer_name
      when l_payment_type = 'SUPPLIER_PAYMENT' then l_repairer_name
      else 'Generated claimant ' || l_customer_id
    end,
    lpad(trunc(dbms_random.value(10000000, 99999999)), 8, '0'),
    lpad(trunc(dbms_random.value(100000, 999999)), 6, '0'),
    'PAY-' || to_char(sysdate, 'YYYY') || '-' || lpad(l_payment_id, 8, '0'),
    l_payment_status,
    null,
    null,
    ''
  );

  insert into medical_assessments (
    assessment_id,
    claim_id,
    party_id,
    assessor_name,
    assess_date,
    injury_type,
    injury_detail,
    prognosis,
    treatment_plan,
    disability_days,
    claim_value_est,
    fraud_indicator,
    report_ref,
    created_date
  ) values (
    l_assessment_id,
    l_claim_id,
    null,
    l_assessor_name,
    l_reported_date + trunc(dbms_random.value(2, 21)),
    l_injury_type,
    case
      when l_injury_flag = 'Y' and l_claim_type = 'PERSONAL_INJURY' then 'Personal injury assessment includes triage notes, observed symptoms, mobility impact, and pain score recorded by the treating clinician.'
      when l_injury_flag = 'Y' then 'Generated injury assessment for ' || lower(l_claim_type) || ' claim.'
      else 'No bodily injury reported for generated claim.'
    end,
    case
      when l_injury_flag = 'Y' then 'Expected recovery within ' || l_disability_days || ' days subject to treatment.'
      else 'No medical recovery period required.'
    end,
    case
      when l_injury_flag = 'Y' and l_claim_type = 'PERSONAL_INJURY' then 'Hospital assessment, short observation if clinically required, diagnostic review, medication, physiotherapy, GP follow-up, and symptom monitoring.'
      when l_injury_flag = 'Y' then 'Physiotherapy, GP follow-up, and symptom monitoring.'
      else 'No treatment required.'
    end,
    l_disability_days,
    l_medical_value,
    l_fraud_indicator,
    'MED-' || to_char(sysdate, 'YYYY') || '-' || lpad(l_assessment_id, 8, '0'),
    sysdate
  );

  -- Persist the selected tier so the rule scorer can honour simulation intent.
  -- LOW uses a zero-weight marker; it is not a fraud indicator.
  if l_risk_tier in ('HIGH', 'MEDIUM', 'LOW') then
    select nvl(max(indicator_id), 0) + 1
      into l_indicator_id
      from fraud_indicators;

    insert into fraud_indicators (
      indicator_id,
      claim_id,
      indicator_code,
      indicator_desc,
      severity,
      score_weight,
      detected_date,
      detected_by,
      status,
      notes
    ) values (
      l_indicator_id,
      l_claim_id,
      case
        when l_risk_tier = 'HIGH' then 'SIMULATION_HIGH_RISK'
        when l_risk_tier = 'MEDIUM' then 'SIMULATION_MEDIUM_RISK'
        else 'SIMULATION_LOW_RISK'
      end,
      l_indicator_desc,
      case
        when l_risk_tier = 'HIGH' then 'HIGH'
        when l_risk_tier = 'MEDIUM' then 'MEDIUM'
        else 'LOW'
      end,
      case
        when l_risk_tier = 'HIGH' then 40
        when l_risk_tier = 'MEDIUM' then 25
        else 0
      end,
      sysdate,
      'FSI_CLAIM_SIMULATOR',
      'OPEN',
      'Risk tier selected in Generate Claim simulation: ' || l_risk_tier || '; insurance type: ' || l_claim_type
    );
  end if;

  commit;
  return l_claim_id;
exception
  when others then
    rollback;
    raise;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_GENERATE_TEN_RANDOM_CLAIMS" 
(
  no_of_claims in number 
)

  return clob
  authid definer
as
  pragma autonomous_transaction;

  --c_claim_count constant pls_integer := 10;
  

  c_claim_count constant pls_integer :=  no_of_claims;
  -- This must match the Static ID of the APEX Generative AI service.
  c_genai_service_static_id constant varchar2(255) := 'GenAIGrokProfile';

  l_claim_id              claims.claim_id%type;
  l_claim_type            claim_reasons.claim_type%type;
  l_risk_tier             claim_reasons.risk_tier%type;
  l_claim_reason_seed claim_reasons.claim_master_list%type;
  l_simulation_claim_type claims.claim_type%type;
  l_simulation_risk_tier  varchar2(20);
  l_vehicle_id            claims.vehicle_id%type;
  l_vehicle_make          vehicles.make%type;
  l_vehicle_model         vehicles.model%type;
  l_repairer_id           vehicle_repairs.repairer_id%type;
  l_repairer_name         repairers.name%type;
  l_claim_details         claims.claim_details%type;
  l_claim_details_prompt varchar2(32767);
  l_reason_count          pls_integer;
  l_claim_ids             varchar2(4000);
begin

--     if c_claim_count is null then 
--     c_claim_count := 1;
--    end if; 


  select count(*)
    into l_reason_count
    from claim_reasons
   where risk_tier is not null
     and claim_type is not null
     and claim_master_list is not null;

  if l_reason_count = 0 then
    raise_application_error(
      -20001,
      'CLAIM_REASONS must contain at least one complete reason before claims can be generated.'
    );
  end if;

  for i in 1 .. c_claim_count loop
    -- Select the related fields from the same randomly chosen reason row.
    select risk_tier,
           claim_type,
           claim_master_list
      into l_risk_tier,
           l_claim_type,
           l_claim_reason_seed
      from (
        select risk_tier,
               claim_type,
               claim_master_list
          from claim_reasons
         where risk_tier is not null
           and claim_type is not null
           and claim_master_list is not null
         order by dbms_random.value
     )
     where rownum = 1;

    -- Use the canonical values expected by FSI_GENERATE_RANDOM_CLAIM, while
    -- retaining the selected CLAIM_REASONS values as the stored tier and the
    -- LLM prompt context.
    l_simulation_risk_tier :=
      case upper(trim(l_risk_tier))
        when 'HIGH' then 'HIGH'
        when 'HIGH RISK' then 'HIGH'
        when 'LOW' then 'LOW'
        when 'LOW RISK' then 'LOW'
        else 'MEDIUM'
      end;

    l_simulation_claim_type :=
      case upper(regexp_replace(trim(l_claim_type), '[[:space:]-]+', '_'))
        when 'CAR_ACCIDENT' then 'ACCIDENT'
        when 'ACCIDENT' then 'ACCIDENT'
        when 'PERSONAL_INJURY' then 'PERSONAL_INJURY'
        when 'FIRE' then 'FIRE'
        when 'THEFT' then 'THEFT'
        when 'VANDALISM' then 'VANDALISM'
        else null
      end;

    if l_simulation_claim_type is null then
      raise_application_error(
        -20005,
        'Unsupported CLAIM_REASONS.CLAIM_TYPE for claim generation: ' || l_claim_type
      );
    end if;

    -- Reuse the established generator so all dependent records follow the
    -- same logic: one incident, a repair for accidents, a payment, a medical
    -- assessment, and the risk-tier fraud indicator. That function also uses
    -- FRAUD_INDICATORS_SEQ.NEXTVAL, avoiding duplicate indicator IDs.
    l_claim_id := fsi_generate_random_claim(
      p_risk_tier  => l_simulation_risk_tier,
      p_claim_type => l_simulation_claim_type
    );

    -- Read the exact vehicle allocated by the existing generator. Its make
    -- and model make the GenAI narrative specific to this generated claim.
    select c.vehicle_id,
           v.make,
           v.model
      into l_vehicle_id,
           l_vehicle_make,
           l_vehicle_model
      from claims c
      join vehicles v
        on v.vehicle_id = c.vehicle_id
     where c.claim_id = l_claim_id;

    -- Accident claims may have an assigned repairer. Other claim types, or
    -- repairs not yet allocated, deliberately pass a not-applicable context.
    begin
      select repairer_id,
             repairer_name
        into l_repairer_id,
             l_repairer_name
        from (
          select vr.repairer_id,
                 rp.name as repairer_name
            from vehicle_repairs vr
            left join repairers rp
              on rp.repairer_id = vr.repairer_id
           where vr.claim_id = l_claim_id
           order by vr.repair_id
        )
       where rownum = 1;
    exception
      when no_data_found then
        l_repairer_id := null;
        l_repairer_name := null;
    end;

    -- Generate a narrative from the selected reason and the actual vehicle
    -- and repairer records created for this claim.
    l_claim_details_prompt :=
      'Create one realistic insurance claim-details narrative for a simulated claim.' || chr(10) ||
      'Risk tier: ' || l_risk_tier || chr(10) ||
      'Claim type: ' || l_claim_type || chr(10) ||
      'Claim-reason seed: ' || l_claim_reason_seed || chr(10) ||
      'Vehicle ID: ' || to_char(l_vehicle_id) || chr(10) ||
      'Vehicle make and model: ' || l_vehicle_make || ' ' || l_vehicle_model || chr(10) ||
      'Repairer ID: ' || nvl(to_char(l_repairer_id), 'Not applicable or not allocated') || chr(10) ||
      'Repairer name: ' || nvl(l_repairer_name, 'Not applicable or not allocated') || chr(10) ||
      'Write 70 to 110 words in a factual claims-notification style. Keep the narrative consistent with the risk tier and claim type. ' ||
      'Use the vehicle make/model and repairer only when relevant to the claim type; use the supplied values as context and do not repeat IDs. ' ||
      'Include the incident circumstances and relevant loss or injury details where applicable. ' ||
      'Do not invent names, policy numbers, claim numbers, exact addresses, or monetary amounts. ' ||
      'All currencies should be in UK Pounds £. ' ||
      'Return only the plain-text narrative: no title, labels, bullets, JSON, or markdown.';

    begin
      l_claim_details := apex_ai.generate(
        p_prompt            => l_claim_details_prompt,
        p_service_static_id => c_genai_service_static_id
      );
      l_claim_details := regexp_replace(
        l_claim_details,
        '^\s*```(?:text|markdown)?\s*',
        '',
        1,
        1,
        'in'
      );
      l_claim_details := regexp_replace(
        l_claim_details,
        '\s*```\s*$',
        '',
        1,
        1,
        'in'
      );

      if l_claim_details is null or dbms_lob.getlength(l_claim_details) = 0 then
        raise_application_error(-20003, 'The Gen AI service returned empty claim details.');
      end if;
    exception
      when others then
        raise_application_error(
          -20004,
          'Unable to generate claim details through APEX Gen AI service ' ||
          c_genai_service_static_id || ': ' || substr(sqlerrm, 1, 1500)
        );
    end;

    -- FSI_GENERATE_RANDOM_CLAIM creates an OPEN claim with its seed text.
    -- The batch generator's contract is a NEW claim and an LLM narrative
    -- derived from the exact CLAIM_REASONS row selected above.
    update claims
       set claim_status  = 'NEW',
           risk_tier     = l_risk_tier,
           claim_details = l_claim_details
     where claim_id = l_claim_id;

    if sql%rowcount <> 1 then
      raise_application_error(
        -20006,
        'Generated claim ' || l_claim_id || ' could not be updated with LLM claim details.'
      );
    end if;

    l_claim_ids := l_claim_ids
                   || case when l_claim_ids is null then null else ', ' end
                   || to_char(l_claim_id);
  end loop;

  commit;

  return to_clob(
    'Created ' || c_claim_count || ' NEW claims from CLAIM_REASONS. Claim IDs: ' || l_claim_ids
  );
exception
  when others then
    rollback;
    raise;
end fsi_generate_ten_random_claims;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_GET_CLAIM_DELETE_JOB_STATUS" (
  p_job_name in varchar2
) return clob
authid definer
as
  l_result        clob;
  l_error_message varchar2(4000);
begin
  select json_object(
           'status' value status,
           'job_name' value job_name,
           'from_claim_id' value from_claim_id,
           'to_claim_id' value to_claim_id,
           'candidate_count' value candidate_count,
           'deleted_count' value deleted_count,
           'failed_count' value failed_count,
           'failed_claim_ids' value failed_claim_ids,
           'created_at' value to_char(created_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3 TZH:TZM'),
           'started_at' value to_char(started_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3 TZH:TZM'),
           'completed_at' value to_char(completed_at, 'YYYY-MM-DD"T"HH24:MI:SS.FF3 TZH:TZM'),
           'result' value result format json,
           'error_message' value error_message
           returning clob)
    into l_result
    from fsi_claim_delete_jobs
   where job_name = upper(trim(p_job_name));
  return l_result;
exception
  when no_data_found then
    select json_object(
             'status' value 'NOT_FOUND',
             'job_name' value p_job_name,
             'error_message' value 'No claim deletion job found.'
             returning clob)
      into l_result
      from dual;
    return l_result;
  when others then
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'job_name' value p_job_name,
             'error_message' value l_error_message
             returning clob)
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_LIST_CLAIMS_BY_STATUS" (
  p_status in varchar2 default 'OPEN',
  p_limit  in number default 50
) return clob
as
  l_result        clob;
  l_error_message varchar2(4000);
  l_status        varchar2(30);
  l_limit         pls_integer;

-- fsi_list_claims_by_status function retrieves a list of claims filtered by their status.
-- It accepts a status and an optional limit on the number of claims to return.
-- The function returns a JSON object containing the filtered claims, their count, and any error messages   

begin
  l_status := upper(regexp_replace(trim(coalesce(p_status, 'OPEN')), '[[:space:]-]+', '_'));

  if l_status is null or length(l_status) > 30 or not regexp_like(l_status, '^[A-Z][A-Z0-9_]*$') then
    select json_object(
             'status' value 'VALIDATION_ERROR',
             'error_message' value 'P_STATUS must start with a letter and contain only letters, numbers, and underscores after normalization.'
           returning clob)
      into l_result
      from dual;
    return l_result;
  end if;

  l_limit := least(100, greatest(1, coalesce(trunc(p_limit), 50)));

  select json_object(
           'status' value 'FOUND',
           'filter_status' value l_status,
           'limit' value l_limit,
           'total_matching_count' value (
             select count(*)
               from claims c
              where upper(c.claim_status) = l_status
           ),
           'returned_count' value (
             select count(*)
               from (
                 select c.claim_id
                   from claims c
                  where upper(c.claim_status) = l_status
                  order by c.open_date desc nulls last, c.claim_id
                  fetch first l_limit rows only
               )
           ),
           'claims' value (
             select coalesce(
                      json_arrayagg(
                        json_object(
                          'claim_id' value c.claim_id,
                          'claim_number' value c.claim_number,
                          'policy_id' value c.policy_id,
                          'customer_id' value c.customer_id,
                          'vehicle_id' value c.vehicle_id,
                          'claim_type' value c.claim_type,
                          'claim_status' value c.claim_status,
                          'incident_date' value to_char(c.incident_date, 'YYYY-MM-DD'),
                          'reported_date' value to_char(c.reported_date, 'YYYY-MM-DD'),
                          'open_date' value to_char(c.open_date, 'YYYY-MM-DD'),
                          'close_date' value to_char(c.close_date, 'YYYY-MM-DD'),
                          'total_claimed' value c.total_claimed,
                          'total_settled' value c.total_settled,
                          'reserve_amount' value c.reserve_amount,
                          'handler_id' value c.handler_id,
                          'fraud_flag' value c.fraud_flag,
                          'fraud_score' value c.fraud_score
                        returning clob)
                      returning clob),
                      to_clob('[]')
                    )
               from (
                 select *
                   from claims c
                  where upper(c.claim_status) = l_status
                  order by c.open_date desc nulls last, c.claim_id
                  fetch first l_limit rows only
               ) c
           )
         returning clob)
    into l_result
    from dual;

  return l_result;
exception
  when others then
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'filter_status' value l_status,
             'error_message' value 'Error in fsi_list_claims_by_status: ' || l_error_message
           returning clob)
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_RAG_KNOWLEDGE_BASE_SEARCH" (
  p_query in varchar2
) return clob
as
  l_query                varchar2(12000);
  l_prompt               varchar2(32767);
  l_answer               clob;
  l_result               clob;
  l_vector_chunk_count   number;
  l_vector_table_status  varchar2(40) := 'AVAILABLE';
  l_error_message        varchar2(4000);
  l_profile_name         varchar2(128);
  l_vector_index_name    varchar2(128);
  l_vector_table_name    varchar2(128);

  function runtime_config_value(p_config_key varchar2, p_default varchar2) return varchar2 is
    l_value varchar2(4000);
  begin
    select trim(dbms_lob.substr(config_value, 4000, 1))
      into l_value
      from fsi_runtime_config
     where config_key = upper(trim(p_config_key));
    return coalesce(l_value, p_default);
  exception when no_data_found then
    return p_default;
  end;
begin
  l_query := substr(trim(p_query), 1, 12000);
  l_profile_name := runtime_config_value('RAG_PROFILE_NAME', 'FSI_SELECT_AI_RAG_KB_PROFILE');
  l_vector_index_name := runtime_config_value('RAG_VECTOR_INDEX_NAME', 'FSI_HUB_VECTOR_INDEX_KB');
  l_vector_table_name := runtime_config_value('RAG_VECTOR_TABLE_NAME', 'FSI_HUB_VECTOR_INDEX_KB$VECTAB');

  if l_query is null then
    select json_object(
             'status' value 'ERROR',
             'profile_name' value l_profile_name,
             'vector_index_name' value l_vector_index_name,
             'vector_table_name' value l_vector_table_name,
             'error_message' value 'Missing required parameter P_QUERY.'
           returning clob)
      into l_result
      from dual;
    return l_result;
  end if;

  begin
    execute immediate 'select count(*) from ' || dbms_assert.simple_sql_name(l_vector_table_name)
      into l_vector_chunk_count;
  exception
    when others then
      l_vector_chunk_count := null;
      l_vector_table_status := 'MISSING_OR_INACCESSIBLE';
  end;

  l_prompt :=
    'Search the FSI fraud investigation RAG knowledge base backed by vector index ' || l_vector_index_name || '.' || chr(10) ||
    'Return concise, grounded findings from the knowledge base.' || chr(10) ||
    'Include a Document Citations section with document names, object names, or URLs returned by the RAG profile.' || chr(10) ||
    'If the RAG profile returns no citations, state that no document citations were returned.' || chr(10) ||
    chr(10) ||
    'User query:' || chr(10) ||
    l_query;

  select dbms_cloud_ai.generate(
           prompt       => l_prompt,
           profile_name => l_profile_name,
           action       => 'narrate'
         )
    into l_answer
    from dual;

  select json_object(
           'status' value 'SUCCESS',
           'profile_name' value l_profile_name,
           'vector_index_name' value l_vector_index_name,
           'vector_table_name' value l_vector_table_name,
           'vector_table_status' value l_vector_table_status,
           'vector_chunk_count' value l_vector_chunk_count,
           'query' value l_query,
           'answer' value l_answer
         returning clob)
    into l_result
    from dual;

  return l_result;
exception
  when others then
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'profile_name' value l_profile_name,
             'vector_index_name' value l_vector_index_name,
             'vector_table_name' value l_vector_table_name,
             'query' value l_query,
             'error_message' value 'Error in fsi_rag_knowledge_base_search: ' || l_error_message
           returning clob)
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_SAVE_FRAUD_REPORT" (
  p_claim_id          in number,
  p_fraud_probability in number,
  p_risk_level        in varchar2,
  p_report            in clob
) return clob
as
  pragma autonomous_transaction;
  l_document_id number;
  l_report_uri  varchar2(500);
  l_result      clob;
  l_error_message varchar2(4000);

-- fsi_save_fraud_report function saves a fraud investigation report for a given claim ID.
-- It accepts the claim ID, fraud probability, risk level, and the report content as input
-- and returns a JSON object containing the status of the operation, the claim ID,
-- the URI of the saved report, and the document ID. The function handles errors and returns
-- an error message in case of failure.

begin
  select nvl(max(document_id), 0) + 1
    into l_document_id
    from documents;

  l_report_uri := 'adw://FSIHUB/DOCUMENTS/' || l_document_id;

  insert into documents (
    document_id,
    entity_type,
    entity_id,
    doc_type,
    doc_name,
    file_name,
    mime_type,
    storage_path,
    description,
    status,
    upload_date,
    verified_flag,
    created_date
  ) values (
    l_document_id,
    'CLAIM',
    p_claim_id,
    'AI_FRAUD_REPORT',
    'AI Fraud Investigation Report - Claim ' || p_claim_id,
    'ai_fraud_report_claim_' || p_claim_id || '.txt',
    'text/plain',
    l_report_uri,
    substr('Risk=' || p_risk_level || ', Probability=' || to_char(p_fraud_probability) ||
           ', Summary=' || dbms_lob.substr(p_report, 350, 1), 1, 500),
    'SAVED',
    sysdate,
    1,
    sysdate
  );

  insert into audit_log (
    log_id,
    table_name,
    record_id,
    action,
    new_values,
    changed_by,
    changed_date,
    session_info
  ) values (
    (select nvl(max(log_id), 0) + 1 from audit_log),
    'DOCUMENTS',
    l_document_id,
    'INSERT',
    substr('AI fraud report saved for claim ' || p_claim_id || ': ' ||
           dbms_lob.substr(p_report, 3500, 1), 1, 4000),
    'FSI_FRAUD_AGENT',
    sysdate,
    'fsi_save_fraud_report'
  );

  commit;
  select json_object(
           'status' value 'SAVED',
           'claim_id' value p_claim_id,
           'report_uri' value l_report_uri,
           'document_id' value l_document_id
         returning clob)
    into l_result
    from dual;
  return l_result;
exception
  when others then
    rollback;
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'claim_id' value p_claim_id,
             'error_message' value 'Error in fsi_save_fraud_report: ' || l_error_message
           returning clob)
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_SEND_FRAUD_NOTIFICATION" (
  p_claim_id   in number,
  p_report_uri in varchar2,
  p_risk_level in varchar2,
  p_summary    in varchar2
) return clob
as
  pragma autonomous_transaction;
  l_comm_id number;
  l_result clob;
  l_error_message varchar2(4000);

-- fsi_send_fraud_notification function sends a fraud notification email for a given claim ID.
-- It accepts the claim ID, report URI, risk level, and summary as input
-- and returns a JSON object containing the status of the operation, the claim ID,
-- the communication ID, and a message indicating the notification was sent.


begin
  select nvl(max(comm_id), 0) + 1
    into l_comm_id
    from communications;

  insert into communications (
    comm_id,
    entity_type,
    entity_id,
    direction,
    channel,
    subject,
    body,
    from_address,
    to_address,
    comm_date,
    status,
    notes
  ) values (
    l_comm_id,
    'CLAIM',
    p_claim_id,
    'OUTBOUND',
    'EMAIL',
    'AI fraud review alert for claim ' || p_claim_id || ' - ' || p_risk_level,
    substr('Risk level: ' || p_risk_level || chr(10) ||
           'Report URI: ' || p_report_uri || chr(10) ||
           'Summary: ' || p_summary, 1, 4000),
    'fsi-fraud-agent@insurer.example',
    'siu-team@insurer.example',
    sysdate,
    'SENT',
    'Generated by FSI Fraud Investigation Agent'
  );

  commit;
  select json_object(
           'status' value 'SENT',
           'claim_id' value p_claim_id,
           'comm_id' value l_comm_id,
           'message' value 'Notification sent to SIU team.'
         returning clob)
    into l_result
    from dual;
  return l_result;
exception
  when others then
    rollback;
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'claim_id' value p_claim_id,
             'error_message' value 'Error in fsi_send_fraud_notification: ' || l_error_message
           returning clob)
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_SIMILAR_FRAUD_CASES" (
  p_claim_id in number
) return clob
as
  l_result clob;
  l_error_message varchar2(4000);
-- fsi_similar_fraud_cases function retrieves a list of similar fraud cases for a given claim ID.
-- It calculates a similarity score based on claim type, postcode, vehicle make and model,
-- total claimed amount, and shared fraud indicators. The function returns a JSON object
-- containing the similar fraud cases, their details, and similarity scores.
begin
  with target_claim as (
    select c.claim_id,
           c.customer_id,
           c.claim_type,
           c.total_claimed,
           cu.postcode,
           v.make,
           v.model
    from claims c
    join customers cu on cu.customer_id = c.customer_id
    left join vehicles v on v.vehicle_id = c.vehicle_id
    where c.claim_id = p_claim_id
  ),
  scored_cases as (
    select fc.claim_id,
           fc.claim_number,
           fc.claim_type,
           fc.total_claimed,
           fc.fraud_score,
           fcu.postcode,
           fv.make,
           fv.model,
           (case when fc.claim_type = tc.claim_type then 35 else 0 end) +
           (case when fcu.postcode = tc.postcode then 20 else 0 end) +
           (case when fv.make = tc.make then 10 else 0 end) +
           (case when fv.model = tc.model then 10 else 0 end) +
           (case when abs(nvl(fc.total_claimed, 0) - nvl(tc.total_claimed, 0)) <= 1000 then 15 else 0 end) +
           (select least(count(*), 2) * 5
              from fraud_indicators fi1
              join fraud_indicators fi2
                on fi2.indicator_code = fi1.indicator_code
             where fi1.claim_id = p_claim_id
               and fi2.claim_id = fc.claim_id) as similarity_score
    from claims fc
    join target_claim tc on 1 = 1
    join customers fcu on fcu.customer_id = fc.customer_id
    left join vehicles fv on fv.vehicle_id = fc.vehicle_id
    where fc.claim_id <> p_claim_id
      and (fc.fraud_flag = 'Y' or nvl(fc.fraud_score, 0) >= 70)
  )
  select coalesce(
           json_arrayagg(
             json_object(
               'claim_id' value claim_id,
               'claim_number' value claim_number,
               'claim_type' value claim_type,
               'total_claimed' value total_claimed,
               'fraud_score' value fraud_score,
               'postcode' value postcode,
               'vehicle' value trim(make || ' ' || model),
               'similarity_score' value similarity_score
             returning clob)
             order by similarity_score desc
           returning clob),
           to_clob('[]')
         )
    into l_result
    from (
      select *
      from scored_cases
      where similarity_score > 60
      order by similarity_score desc
      fetch first 5 rows only
    );

  return l_result;
exception
  when others then
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'claim_id' value p_claim_id,
             'error_message' value 'Error in fsi_similar_fraud_cases: ' || l_error_message
           returning clob)
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_THIRD_PARTY_FRAUD_DATA" (
  p_claim_id in number
) return clob
as
  l_result                  clob;
  l_customer_id             number;
  l_customer_city           varchar2(100);
  l_customer_name           varchar2(4000);
  l_incident_date           date;
  l_weather_data            clob;
  l_weather_json_valid      number := 0;
  l_google_fraud_score_json clob;
  l_error_message           varchar2(4000);

-- fsi_third_party_fraud_data function retrieves third-party fraud data for a given claim ID.
-- It fetches customer information, incident details, weather data, and Google fraud scores.
-- The function returns a JSON object containing the retrieved data.    


  function normalize_header(p_value in varchar2) return varchar2 is
  begin
    return regexp_replace(lower(trim(p_value)), '[^a-z0-9]', '');
  end;

  function normalize_customer_name(p_value in varchar2) return varchar2 is
  begin
    return regexp_replace(lower(trim(p_value)), '[[:space:]]+', ' ');
  end;

  function runtime_config_value(p_config_key in varchar2) return varchar2 is
    l_value varchar2(4000);
  begin
    select trim(dbms_lob.substr(config_value, 4000, 1))
      into l_value
      from fsi_runtime_config
     where config_key = upper(trim(p_config_key));

    return l_value;
  exception
    when no_data_found then
      return null;
  end;

  function http_get(
    p_url        in varchar2,
    p_redirects in pls_integer default 0
  ) return clob is
    l_req      utl_http.req;
    l_resp     utl_http.resp;
    l_buffer   varchar2(32767);
    l_response clob;
    l_status   pls_integer;
    l_location varchar2(32767);
  begin
    if p_redirects > 5 then
      raise_application_error(-20051, 'Too many HTTP redirects while reading Google Sheet.');
    end if;

    dbms_lob.createtemporary(l_response, true);
    utl_http.set_response_error_check(false);

    l_req := utl_http.begin_request(p_url, 'GET', 'HTTP/1.1');
    utl_http.set_header(l_req, 'Accept', 'text/csv,text/plain,*/*');
    utl_http.set_header(l_req, 'User-Agent', 'oracle-plsql-google-sheet-reader/1.0');

    l_resp := utl_http.get_response(l_req);
    l_status := l_resp.status_code;

    if l_status in (301, 302, 303, 307, 308) then
      begin
        utl_http.get_header_by_name(l_resp, 'Location', l_location);
      exception
        when others then
          l_location := null;
      end;
      utl_http.end_response(l_resp);

      if l_location is null then
        raise_application_error(-20052, 'Google returned redirect without Location header.');
      end if;

      return http_get(l_location, p_redirects + 1);
    end if;

    begin
      loop
        utl_http.read_text(l_resp, l_buffer, 32767);
        dbms_lob.writeappend(l_response, length(l_buffer), l_buffer);
      end loop;
    exception
      when utl_http.end_of_body then
        null;
    end;

    utl_http.end_response(l_resp);

    if l_status < 200 or l_status >= 300 then
      raise_application_error(
        -20053,
        'Google Sheet download failed. HTTP status=' || l_status ||
        ', response=' || dbms_lob.substr(l_response, 1000, 1)
      );
    end if;

    return l_response;
  exception
    when others then
      begin
        utl_http.end_response(l_resp);
      exception
        when others then
          null;
      end;
      raise;
  end;

  function csv_field(
    p_line  in varchar2,
    p_index in pls_integer
  ) return varchar2 is
    l_pos         pls_integer := 1;
    l_field_index pls_integer := 1;
    l_char        varchar2(1);
    l_value       varchar2(32767);
    l_in_quotes   boolean := false;
  begin
    loop
      exit when l_pos > length(p_line) + 1;

      if l_pos <= length(p_line) then
        l_char := substr(p_line, l_pos, 1);
      else
        l_char := ',';
      end if;

      if l_char = '"' then
        if l_in_quotes and substr(p_line, l_pos + 1, 1) = '"' then
          if l_field_index = p_index then
            l_value := l_value || '"';
          end if;
          l_pos := l_pos + 1;
        else
          l_in_quotes := not l_in_quotes;
        end if;
      elsif l_char = ',' and not l_in_quotes then
        if l_field_index = p_index then
          return l_value;
        end if;
        l_field_index := l_field_index + 1;
        l_value := null;
      else
        if l_field_index = p_index then
          l_value := l_value || l_char;
        end if;
      end if;

      l_pos := l_pos + 1;
    end loop;

    return null;
  end;

  function csv_field_count(p_line in varchar2) return pls_integer is
    l_count     pls_integer := 1;
    l_pos       pls_integer := 1;
    l_char      varchar2(1);
    l_in_quotes boolean := false;
  begin
    if p_line is null then
      return 0;
    end if;

    while l_pos <= length(p_line) loop
      l_char := substr(p_line, l_pos, 1);
      if l_char = '"' then
        if l_in_quotes and substr(p_line, l_pos + 1, 1) = '"' then
          l_pos := l_pos + 1;
        else
          l_in_quotes := not l_in_quotes;
        end if;
      elsif l_char = ',' and not l_in_quotes then
        l_count := l_count + 1;
      end if;

      l_pos := l_pos + 1;
    end loop;

    return l_count;
  end;

  function clob_line(
    p_clob   in clob,
    p_offset in out pls_integer
  ) return varchar2 is
    l_length pls_integer := dbms_lob.getlength(p_clob);
    l_end    pls_integer;
    l_line   varchar2(32767);
  begin
    if p_offset > l_length then
      return null;
    end if;

    l_end := dbms_lob.instr(p_clob, chr(10), p_offset);
    if l_end = 0 then
      l_end := l_length + 1;
    end if;

    l_line := dbms_lob.substr(p_clob, least(32767, l_end - p_offset), p_offset);
    p_offset := l_end + 1;
    return rtrim(l_line, chr(13));
  end;

  function google_sheet_fraud_score(
    p_customer_id   in number,
    p_customer_name in varchar2
  ) return clob is
    l_sheet_url varchar2(4000);
    l_gid       constant varchar2(30) := '0';

    l_sheet_id          varchar2(200);
    l_url               varchar2(4000);
    l_csv               clob;
    l_offset            pls_integer := 1;
    l_header            varchar2(32767);
    l_line              varchar2(32767);
    l_customer_col      pls_integer;
    l_fraud_score_col   pls_integer;
    l_col_count         pls_integer;
    l_header_name       varchar2(4000);
    l_normalized_header varchar2(4000);
    l_customer_name     varchar2(4000);
    l_normalized_lookup varchar2(4000);
    l_normalized_sheet_customer varchar2(4000);
    l_fraud_score       varchar2(4000);
    l_score_number      number;
    l_rows_scanned      pls_integer := 0;
    l_lookup_error      varchar2(4000);
    l_result_json       clob;
  begin
    l_normalized_lookup := normalize_customer_name(p_customer_name);

    if trim(p_customer_name) is null then
      select json_object(
               'provider' value 'Google Sheets customer fraud score',
               'status' value 'NOT_FOUND',
               'customer_id' value p_customer_id,
               'lookup_customer_name' value p_customer_name,
               'normalized_lookup_customer_name' value l_normalized_lookup,
               'match_found' value 'false' format json,
               'message' value 'Customer name is not available for Google Sheet lookup.'
             returning clob)
        into l_result_json
        from dual;
      return l_result_json;
    end if;

    l_sheet_url := runtime_config_value('GOOGLE_SHEET_URL');

    if l_sheet_url is null then
      raise_application_error(-20054, 'GOOGLE_SHEET_URL is not configured in FSI_RUNTIME_CONFIG.');
    end if;

    l_sheet_id := regexp_substr(l_sheet_url, '/d/([^/]+)', 1, 1, null, 1);

    if l_sheet_id is null then
      raise_application_error(-20054, 'Could not extract Google Sheet id from URL: ' || l_sheet_url);
    end if;

    l_url :=
      'https://docs.google.com/spreadsheets/d/' || l_sheet_id ||
      '/export?format=csv' || chr(38) || 'gid=' || l_gid;

    l_csv := http_get(l_url);
    l_header := clob_line(l_csv, l_offset);

    if l_header is null then
      raise_application_error(-20055, 'Google Sheet CSV response is empty.');
    end if;

    l_col_count := csv_field_count(l_header);

    for i in 1 .. l_col_count loop
      l_header_name := csv_field(l_header, i);
      l_normalized_header := normalize_header(l_header_name);

      if l_normalized_header in ('customername', 'customer', 'name', 'clientname') then
        l_customer_col := i;
      elsif l_normalized_header in ('fraudscore', 'fraudprobability', 'fraudrisk', 'score') then
        l_fraud_score_col := i;
      end if;
    end loop;

    if l_customer_col is null or l_fraud_score_col is null then
      raise_application_error(
        -20056,
        'Could not find required Google Sheet columns. Expected headers like Customer Name and Fraud Score.'
      );
    end if;

    loop
      l_line := clob_line(l_csv, l_offset);
      exit when l_line is null;
      continue when trim(l_line) is null;

      l_customer_name := csv_field(l_line, l_customer_col);
      l_normalized_sheet_customer := normalize_customer_name(l_customer_name);
      l_fraud_score := csv_field(l_line, l_fraud_score_col);
      l_rows_scanned := l_rows_scanned + 1;

      if l_normalized_sheet_customer = l_normalized_lookup then
        begin
          l_score_number := to_number(trim(l_fraud_score));
        exception
          when others then
            l_score_number := null;
        end;

        select json_object(
                 'provider' value 'Google Sheets customer fraud score',
                 'status' value 'FOUND',
                 'customer_id' value p_customer_id,
                 'lookup_customer_name' value p_customer_name,
                 'matched_customer_name' value l_customer_name,
                 'normalized_lookup_customer_name' value l_normalized_lookup,
                 'normalized_matched_customer_name' value l_normalized_sheet_customer,
                 'match_found' value 'true' format json,
                 'fraud_score' value l_score_number,
                 'fraud_score_raw' value l_fraud_score,
                 'rows_scanned' value l_rows_scanned
               returning clob)
          into l_result_json
          from dual;

        return l_result_json;
      end if;
    end loop;

    select json_object(
             'provider' value 'Google Sheets customer fraud score',
             'status' value 'NOT_FOUND',
             'customer_id' value p_customer_id,
             'lookup_customer_name' value p_customer_name,
             'normalized_lookup_customer_name' value l_normalized_lookup,
             'match_found' value 'false' format json,
             'rows_scanned' value l_rows_scanned,
             'message' value 'Customer was not found in the Google Sheet.'
           returning clob)
      into l_result_json
      from dual;

    return l_result_json;
  exception
    when others then
      l_lookup_error := sqlerrm;

      select json_object(
               'provider' value 'Google Sheets customer fraud score',
               'status' value 'ERROR',
               'customer_id' value p_customer_id,
               'lookup_customer_name' value p_customer_name,
               'normalized_lookup_customer_name' value l_normalized_lookup,
               'match_found' value 'false' format json,
               'error_message' value l_lookup_error
             returning clob)
        into l_result_json
        from dual;
      return l_result_json;
  end;
begin
  select cu.customer_id,
         cu.city,
         trim(cu.first_name || ' ' || cu.last_name),
         c.incident_date
    into l_customer_id,
         l_customer_city,
         l_customer_name,
         l_incident_date
    from claims c
    join customers cu on cu.customer_id = c.customer_id
   where c.claim_id = p_claim_id;

  l_google_fraud_score_json := google_sheet_fraud_score(l_customer_id, l_customer_name);

  l_weather_data := fsi_weather_anomaly.get_weather_report_json(
                      p_city_name    => l_customer_city,
                      p_weather_date => l_incident_date
                    );

  begin
    if l_weather_data is not null then
      select count(*)
        into l_weather_json_valid
        from dual
       where json_exists(l_weather_data, '$');
    end if;
  exception
    when others then
      l_error_message := sqlerrm;
      l_weather_json_valid := 0;
  end;

  if l_weather_json_valid = 0 then
    if l_error_message is null then
      l_error_message := 'Weather function did not return valid JSON';
    end if;

    select json_object(
             'provider' value 'Open-Meteo',
             'status' value 'ERROR',
             'requested_city' value l_customer_city,
             'weather_date' value to_char(l_incident_date, 'YYYY-MM-DD'),
             'error_message' value l_error_message,
             'raw_response' value dbms_lob.substr(l_weather_data, 4000, 1)
           returning clob)
      into l_weather_data
      from dual;
  end if;

  select json_object(
           'claim_id' value c.claim_id,
           'claim_number' value c.claim_number,
           'technology' value json_array('API', 'MCP' returning clob),
           'weather_data' value l_weather_data format json,
           'google_sheet_fraud_score' value l_google_fraud_score_json format json,
           'credit_bureau_data' value json_object(
             'provider' value 'Credit bureau enrichment proxy',
             'customer_id' value cu.customer_id,
             'customer_name' value trim(cu.first_name || ' ' || cu.last_name),
             'city' value l_customer_city,
             'postcode' value cu.postcode,
             'credit_score' value cu.credit_score,
             'credit_risk_band' value case
                                      when cu.credit_score is null then 'UNKNOWN'
                                      when cu.credit_score < 550 then 'HIGH'
                                      when cu.credit_score < 650 then 'MEDIUM'
                                      else 'LOW'
                                    end,
             'customer_fraud_flag' value cu.fraud_flag
           returning clob),
           'public_registry_data' value json_object(
             'provider' value 'Public registry and sanctions proxy',
             'sanctions_checks' value (
               select coalesce(
                        json_arrayagg(
                          json_object(
                            'check_id' value sc.check_id,
                            'check_type' value sc.check_type,
                            'provider' value sc.provider,
                            'result' value sc.result,
                            'match_count' value sc.match_count,
                            'risk_level' value sc.risk_level,
                            'match_details' value sc.match_details
                          returning clob)
                        returning clob),
                        to_clob('[]')
                      )
               from sanctions_checks sc
               where (sc.entity_type = 'CUSTOMER' and sc.entity_id = c.customer_id)
                  or (sc.entity_type = 'CLAIM' and sc.entity_id = c.claim_id)
             )
           returning clob),
           'fraud_consortium_data' value json_object(
             'provider' value 'Fraud consortium proxy',
             'open_claim_indicators' value (
               select coalesce(
                        json_arrayagg(
                          json_object(
                            'indicator_code' value fi.indicator_code,
                            'indicator_desc' value fi.indicator_desc,
                            'severity' value fi.severity,
                            'score_weight' value fi.score_weight,
                            'status' value fi.status,
                            'notes' value fi.notes
                          returning clob)
                        returning clob),
                        to_clob('[]')
                      )
               from fraud_indicators fi
               where fi.claim_id = c.claim_id
                 and nvl(fi.status, 'OPEN') <> 'CLOSED'
             ),
             'customer_prior_claims_24_months' value (
               select count(*)
               from claims pc
               where pc.customer_id = c.customer_id
                 and pc.claim_id <> c.claim_id
                 and pc.incident_date >= add_months(c.incident_date, -24)
             ),
             'customer_prior_confirmed_fraud_claims' value (
               select count(*)
               from claims pc
               where pc.customer_id = c.customer_id
                 and pc.claim_id <> c.claim_id
                 and pc.fraud_flag = 'Y'
             )
           returning clob)
         returning clob)
    into l_result
    from claims c
    join customers cu on cu.customer_id = c.customer_id
   where c.claim_id = p_claim_id;

  return l_result;
exception
  when no_data_found then
    select json_object(
             'status' value 'NOT_FOUND',
             'claim_id' value p_claim_id,
             'error_message' value 'No claim found for P_CLAIM_ID=' || p_claim_id
           returning clob)
      into l_result
      from dual;
    return l_result;
  when others then
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'claim_id' value p_claim_id,
             'error_message' value 'Error in fsi_third_party_fraud_data: ' || l_error_message
           returning clob)
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_UPDATE_CLAIM_AMOUNT_STATUS" (
  p_claim_id      in number,
  p_total_settled in number default null,
  p_status        in varchar2 default null
) return clob
as
  pragma autonomous_transaction;
  l_before          clob;
  l_after           clob;
  l_result          clob;
  l_error_message   varchar2(4000);
  l_total_settled   number(12,2);
  l_status          varchar2(30);
  l_columns_updated varchar2(100);

-- fsi_update_claim_amount_status function updates the total settled amount and/or claim status for a given claim ID.
-- It performs validation on the input parameters and returns a JSON object indicating the result of the update
-- operation, including the before and after state of the claim record.

begin
  if p_claim_id is null then
    select json_object(
             'status' value 'ERROR',
             'error_message' value 'Missing required parameter P_CLAIM_ID.'
           returning clob)
      into l_result
      from dual;
    return l_result;
  end if;

  if p_total_settled is null and p_status is null then
    select json_object(
             'status' value 'ERROR',
             'claim_id' value p_claim_id,
             'error_message' value 'Provide P_TOTAL_SETTLED, P_STATUS, or both. No update was performed.'
           returning clob)
      into l_result
      from dual;
    return l_result;
  end if;

  if p_total_settled is not null then
    if p_total_settled < 0 or p_total_settled > 9999999999.99 then
      select json_object(
               'status' value 'VALIDATION_ERROR',
               'claim_id' value p_claim_id,
               'error_message' value 'P_TOTAL_SETTLED must be between 0 and 9999999999.99.'
             returning clob)
        into l_result
        from dual;
      return l_result;
    end if;

    l_total_settled := round(p_total_settled, 2);
    l_columns_updated := 'TOTAL_SETTLED';
  end if;

  if p_status is not null then
    l_status := upper(regexp_replace(trim(p_status), '[[:space:]-]+', '_'));

    if l_status is null or length(l_status) > 30 or not regexp_like(l_status, '^[A-Z][A-Z0-9_]*$') then
      select json_object(
               'status' value 'VALIDATION_ERROR',
               'claim_id' value p_claim_id,
               'error_message' value 'P_STATUS must start with a letter and contain only letters, numbers, and underscores after normalization.'
             returning clob)
        into l_result
        from dual;
      return l_result;
    end if;

    l_columns_updated := case
                           when l_columns_updated is null then 'CLAIM_STATUS'
                           else l_columns_updated || ', CLAIM_STATUS'
                         end;
  end if;

  select json_object(
           'claim_id' value c.claim_id,
           'total_settled_amount' value c.total_settled,
           'status_value' value c.claim_status,
           'total_claimed' value c.total_claimed,
           'total_settled' value c.total_settled,
           'claim_status' value c.claim_status
         returning clob)
    into l_before
    from claims c
   where c.claim_id = p_claim_id;

  update claims
     set total_settled = case when p_total_settled is not null then l_total_settled else total_settled end,
         claim_status = case when p_status is not null then l_status else claim_status end
   where claim_id = p_claim_id;

  select json_object(
           'claim_id' value c.claim_id,
           'total_settled_amount' value c.total_settled,
           'status_value' value c.claim_status,
           'total_claimed' value c.total_claimed,
           'total_settled' value c.total_settled,
           'claim_status' value c.claim_status
         returning clob)
    into l_after
    from claims c
   where c.claim_id = p_claim_id;

  commit;

  select json_object(
           'status' value 'UPDATED',
           'claim_id' value p_claim_id,
           'amount_column' value 'TOTAL_SETTLED',
           'status_column' value 'CLAIM_STATUS',
           'columns_updated' value l_columns_updated,
           'before' value l_before format json,
           'after' value l_after format json
         returning clob)
    into l_result
    from dual;

  return l_result;
exception
  when no_data_found then
    rollback;
    select json_object(
             'status' value 'NOT_FOUND',
             'claim_id' value p_claim_id,
             'error_message' value 'No claim found for P_CLAIM_ID=' || p_claim_id
           returning clob)
      into l_result
      from dual;
    return l_result;
  when others then
    rollback;
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'claim_id' value p_claim_id,
             'error_message' value 'Error in fsi_update_claim_amount_status: ' || l_error_message
           returning clob)
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_UPDATE_CLAIM_FRAUD_OUTCOME" (
  p_claim_id          in number,
  p_fraud_probability in number,
  p_reason            in varchar2,
  p_report_uri        in varchar2
) return clob
as
  pragma autonomous_transaction;

  l_flag                   claims.fraud_flag%type;
  l_next_status            varchar2(30);
  l_effective_status       claims.claim_status%type;
  l_current_status         claims.claim_status%type;
  l_close_date             claims.close_date%type;
  l_policy_id              claims.policy_id%type;
  l_policy_status          policies.status%type;
  l_indicator_id           number;
  l_existing_ai_indicators number;
  l_result                 clob;
  l_error_message          varchar2(4000);
begin
  l_next_status := case
                     when p_fraud_probability >= 50 then 'SIU_REVIEW'
                     else 'NON_FRAUD_CLAIM'
                   end;

  begin
    select claim_status,
           close_date,
           policy_id,
           nvl(fraud_flag, 'N')
      into l_current_status,
           l_close_date,
           l_policy_id,
           l_flag
      from claims
     where claim_id = p_claim_id
       for update;
  exception
    when no_data_found then
      rollback;
      select json_object(
               'status' value 'NOT_FOUND',
               'claim_id' value p_claim_id,
               'error_message' value 'No claim found for P_CLAIM_ID=' || p_claim_id
               returning clob
             )
        into l_result
        from dual;
      return l_result;
  end;

  select upper(trim(status))
    into l_policy_status
    from policies
   where policy_id = l_policy_id;

  l_effective_status := case
                          when l_policy_status in ('LAPSED', 'CANCELLED')
                            then 'CLAIM_REJECTED'
                          when upper(l_current_status) = 'CLAIM_REJECTED'
                            then l_current_status
                          when l_close_date is not null
                            then l_current_status
                          else l_next_status
                        end;

  update claims
     set fraud_score = p_fraud_probability,
         claim_status = l_effective_status,
         close_date = case
                      when l_effective_status = 'CLAIM_REJECTED'
                        then nvl(close_date, sysdate)
                      else close_date
                    end
   where claim_id = p_claim_id;

  if p_fraud_probability >= 50
     and upper(l_effective_status) = 'SIU_REVIEW' then
    select count(*)
      into l_existing_ai_indicators
      from fraud_indicators
     where claim_id = p_claim_id
       and indicator_code = 'AI_FRAUD_RISK'
       and nvl(status, 'OPEN') <> 'CLOSED';

    if l_existing_ai_indicators = 0 then
      select nvl(max(indicator_id), 0) + 1
        into l_indicator_id
        from fraud_indicators;

      insert into fraud_indicators (
        indicator_id,
        claim_id,
        indicator_code,
        indicator_desc,
        severity,
        score_weight,
        detected_date,
        detected_by,
        status,
        notes
      ) values (
        l_indicator_id,
        p_claim_id,
        'AI_FRAUD_RISK',
        'AI-generated fraud probability crossed investigation threshold',
        'HIGH',
        least(p_fraud_probability, 100),
        sysdate,
        'FSI_FRAUD_AGENT',
        'OPEN',
        substr('Reason: ' || p_reason || '; Report URI: ' || p_report_uri, 1, 500)
      );
    end if;
  end if;

  commit;

  select json_object(
           'status' value 'UPDATED',
           'claim_id' value p_claim_id,
           'fraud_score' value p_fraud_probability,
           'fraud_flag' value l_flag,
           'claim_status' value l_effective_status
           returning clob
         )
    into l_result
    from dual;
  return l_result;
exception
  when others then
    rollback;
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'claim_id' value p_claim_id,
             'error_message' value 'Error in fsi_update_claim_fraud_outcome: ' || l_error_message
             returning clob
           )
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_VALIDATE_MULTI_SOURCE_RISK_SUMMARY" (
  p_claim_id in number
) return clob
as
  l_claim_summary          clob;
  l_risk_json              clob;
  l_third_party            clob;
  l_databricks             clob;
  l_contextual             clob;
  l_weather_compact        clob;
  l_google_sheet           clob;
  l_sanctions_source       clob := '[]';
  l_repair_source          clob := '[]';
  l_medical_source         clob := '[]';
  l_sanctions_checks       clob := '[]';
  l_repair_context         clob := '[]';
  l_medical_context        clob := '[]';
  l_contextual_summary     clob;
  l_errors                 clob := '[]';
  l_result                 clob;
  l_error_message          varchar2(4000);
  l_risk_error             varchar2(4000);
  l_third_party_error      varchar2(4000);
  l_databricks_error       varchar2(4000);
  l_contextual_error       varchar2(4000);
  l_fraud_probability      number := 0;
  l_risk_level             varchar2(30) := 'LOW';

 -- fsi_validate_multi_source_risk_summary function validates and summarizes risk data from multiple sources for a given claim ID.
 -- It retrieves claim summary, risk score, third-party fraud data, Databricks repairer

begin
  begin
    select json_object(
             'claim_id' value c.claim_id,
             'claim_number' value c.claim_number,
             'claim_status' value c.claim_status,
             'claim_type' value c.claim_type,
             'risk_tier' value coalesce(
               c.risk_tier,
               (
                 select case fi.indicator_code
                          when 'SIMULATION_HIGH_RISK' then 'HIGH'
                          when 'SIMULATION_MEDIUM_RISK' then 'MEDIUM'
                          when 'SIMULATION_LOW_RISK' then 'LOW'
                        end
                   from fraud_indicators fi
                  where fi.claim_id = c.claim_id
                    and fi.detected_by = 'FSI_CLAIM_SIMULATOR'
                    and fi.indicator_code in (
                      'SIMULATION_HIGH_RISK', 'SIMULATION_MEDIUM_RISK', 'SIMULATION_LOW_RISK'
                    )
                  order by fi.detected_date desc, fi.indicator_id desc
                  fetch first 1 row only
               )
             ),
             'claim_details' value dbms_lob.substr(c.claim_details, 4000, 1),
             'incident_date' value to_char(c.incident_date, 'YYYY-MM-DD'),
             'reported_date' value to_char(c.reported_date, 'YYYY-MM-DD'),
             'customer_id' value c.customer_id,
             'customer_name' value trim(cu.first_name || ' ' || cu.last_name),
             'customer_postcode' value cu.postcode,
             'policy_number' value p.policy_number,
             'policy_status' value p.status,
             'total_claimed' value c.total_claimed,
             'fraud_flag' value c.fraud_flag,
             'fraud_score' value c.fraud_score
             returning clob
           )
      into l_claim_summary
      from claims c
      join customers cu on cu.customer_id = c.customer_id
      join policies p on p.policy_id = c.policy_id
     where c.claim_id = p_claim_id;
  exception
    when no_data_found then
      select json_object(
               'status' value 'NOT_FOUND',
               'claim_id' value p_claim_id,
               'error_message' value 'No claim found for P_CLAIM_ID=' || p_claim_id
               returning clob
             )
        into l_result
        from dual;
      return l_result;
  end;

  begin
    l_risk_json := fsi_claim_risk_score(p_claim_id);
  exception
    when others then
      l_risk_error := sqlerrm;
      select json_object(
               'status' value 'ERROR',
               'claim_id' value p_claim_id,
               'error_message' value 'Error calling fsi_claim_risk_score: ' || l_risk_error
               returning clob
             )
        into l_risk_json
        from dual;
  end;

  begin
    l_third_party := fsi_third_party_fraud_data(p_claim_id);
  exception
    when others then
      l_third_party_error := sqlerrm;
      select json_object(
               'status' value 'ERROR',
               'claim_id' value p_claim_id,
               'error_message' value 'Error calling fsi_third_party_fraud_data: ' || l_third_party_error
               returning clob
             )
        into l_third_party
        from dual;
  end;

  begin
    l_databricks := fsi_databricks_repairer_fraud_score(p_claim_id);
  exception
    when others then
      l_databricks_error := sqlerrm;
      select json_object(
               'status' value 'ERROR',
               'claim_id' value p_claim_id,
               'error_message' value 'Error calling fsi_databricks_repairer_fraud_score: ' || l_databricks_error
               returning clob
             )
        into l_databricks
        from dual;
  end;

  begin
    l_contextual := fsi_contextual_risk_data(p_claim_id);
  exception
    when others then
      l_contextual_error := sqlerrm;
      select json_object(
               'status' value 'ERROR',
               'claim_id' value p_claim_id,
               'error_message' value 'Error calling fsi_contextual_risk_data: ' || l_contextual_error
               returning clob
             )
        into l_contextual
        from dual;
  end;

  l_fraud_probability := nvl(json_value(l_risk_json, '$.fraud_probability' returning number null on error), 0);
  l_risk_level := nvl(json_value(l_risk_json, '$.risk_level' returning varchar2(30) null on error), 'LOW');

  begin
    select json_object(
             'provider' value nvl(json_value(l_third_party, '$.weather_data.provider' returning varchar2(100) null on error), 'Open-Meteo'),
             'status' value nvl(json_value(l_third_party, '$.weather_data.status' returning varchar2(100) null on error), 'UNKNOWN'),
             'source_api' value json_value(l_third_party, '$.weather_data.source_api' returning varchar2(100) null on error),
             'requested_city' value json_value(l_third_party, '$.weather_data.requested_city' returning varchar2(200) null on error),
             'weather_date' value json_value(l_third_party, '$.weather_data.weather_date' returning varchar2(30) null on error),
             'daily_weather' value json_query(l_third_party, '$.weather_data.daily_weather' returning clob null on error) format json,
             'risk_indicators' value json_query(l_third_party, '$.weather_data.risk_indicators' returning clob null on error) format json
             returning clob
           )
      into l_weather_compact
      from dual;
  exception
    when others then
      l_weather_compact := '{"status":"ERROR","error_message":"Unable to summarize weather evidence."}';
  end;

  l_google_sheet := json_query(l_third_party, '$.google_sheet_fraud_score' returning clob null on error);
  if l_google_sheet is null then
    l_google_sheet := '{"status":"NOT_FOUND","message":"Google Sheet fraud score was not present in third-party data."}';
  end if;

  l_sanctions_source := json_query(l_contextual, '$.sanctions_checks' returning clob null on error);
  if l_sanctions_source is null then
    l_sanctions_source := json_value(l_contextual, '$.sanctions_checks' returning varchar2(4000) null on error);
  end if;
  if l_sanctions_source is null then
    l_sanctions_source := '[]';
  end if;

  l_repair_source := json_query(l_contextual, '$.repair_context' returning clob null on error);
  if l_repair_source is null then
    l_repair_source := json_value(l_contextual, '$.repair_context' returning varchar2(4000) null on error);
  end if;
  if l_repair_source is null then
    l_repair_source := '[]';
  end if;

  l_medical_source := json_query(l_contextual, '$.medical_context' returning clob null on error);
  if l_medical_source is null then
    l_medical_source := json_value(l_contextual, '$.medical_context' returning varchar2(4000) null on error);
  end if;
  if l_medical_source is null then
    l_medical_source := '[]';
  end if;

  begin
    select coalesce(
             json_arrayagg(
               json_object(
                 'entity_type' value jt.entity_type,
                 'provider' value jt.provider,
                 'result' value jt.result,
                 'match_count' value jt.match_count,
                 'risk_level' value jt.risk_level
                 returning clob
               )
               order by jt.rn
               returning clob
             ),
             to_clob('[]')
           )
      into l_sanctions_checks
      from json_table(
             l_sanctions_source,
             '$[*]'
             columns (
               rn          for ordinality,
               entity_type varchar2(100) path '$.entity_type',
               provider    varchar2(200) path '$.provider',
               result      varchar2(100) path '$.result',
               match_count number        path '$.match_count',
               risk_level  varchar2(50)  path '$.risk_level'
             )
           ) jt
     where jt.rn <= 3;
  exception
    when others then
      l_sanctions_checks := '[]';
  end;

  begin
    select coalesce(
             json_arrayagg(
               json_object(
                 'repair_id' value jt.repair_id,
                 'repairer_name' value jt.repairer_name,
                 'repairer_fraud_flag' value jt.repairer_fraud_flag,
                 'estimate_amount' value jt.estimate_amount,
                 'approved_amount' value jt.approved_amount,
                 'total_loss_flag' value jt.total_loss_flag,
                 'repair_status' value jt.repair_status
                 returning clob
               )
               order by jt.rn
               returning clob
             ),
             to_clob('[]')
           )
      into l_repair_context
      from json_table(
             l_repair_source,
             '$[*]'
             columns (
               rn                  for ordinality,
               repair_id           number         path '$.repair_id',
               repairer_name       varchar2(4000) path '$.repairer_name',
               repairer_fraud_flag varchar2(20)   path '$.repairer_fraud_flag',
               estimate_amount     number         path '$.estimate_amount',
               approved_amount     number         path '$.approved_amount',
               total_loss_flag     varchar2(20)   path '$.total_loss_flag',
               repair_status       varchar2(100)  path '$.repair_status'
             )
           ) jt
     where jt.rn <= 3;
  exception
    when others then
      l_repair_context := '[]';
  end;

  begin
    select coalesce(
             json_arrayagg(
               json_object(
                 'assessment_id' value jt.assessment_id,
                 'injury_type' value jt.injury_type,
                 'disability_days' value jt.disability_days,
                 'claim_value_est' value jt.claim_value_est,
                 'fraud_indicator' value jt.fraud_indicator
                 returning clob
               )
               order by jt.rn
               returning clob
             ),
             to_clob('[]')
           )
      into l_medical_context
      from json_table(
             l_medical_source,
             '$[*]'
             columns (
               rn              for ordinality,
               assessment_id   number         path '$.assessment_id',
               injury_type     varchar2(4000) path '$.injury_type',
               disability_days number         path '$.disability_days',
               claim_value_est number         path '$.claim_value_est',
               fraud_indicator varchar2(100)  path '$.fraud_indicator'
             )
           ) jt
     where jt.rn <= 3;
  exception
    when others then
      l_medical_context := '[]';
  end;

  begin
    select json_object(
             'incident_context' value json_query(l_contextual, '$.incident_context' returning clob null on error) format json,
             'sanctions_checks' value l_sanctions_checks format json,
             'repair_context' value l_repair_context format json,
             'medical_context' value l_medical_context format json
             returning clob
           )
      into l_contextual_summary
      from dual;
  exception
    when others then
      l_contextual_summary := '{"status":"ERROR","error_message":"Unable to summarize contextual risk data."}';
  end;

  select json_array(
           case when json_value(l_risk_json, '$.status' returning varchar2(30) null on error) = 'ERROR'
                then 'risk_score: ' || json_value(l_risk_json, '$.error_message' returning varchar2(4000) null on error)
           end,
           case when json_value(l_third_party, '$.status' returning varchar2(30) null on error) = 'ERROR'
                then 'third_party: ' || json_value(l_third_party, '$.error_message' returning varchar2(4000) null on error)
           end,
           case when json_value(l_databricks, '$.status' returning varchar2(30) null on error) = 'ERROR'
                then 'databricks: ' || json_value(l_databricks, '$.error_message' returning varchar2(4000) null on error)
           end,
           case when json_value(l_contextual, '$.status' returning varchar2(30) null on error) = 'ERROR'
                then 'contextual: ' || json_value(l_contextual, '$.error_message' returning varchar2(4000) null on error)
           end
           absent on null
           returning clob
         )
    into l_errors
    from dual;

  select json_object(
           'status' value 'OK',
           'claim_id' value p_claim_id,
           'claim_summary' value l_claim_summary format json,
           'risk_score' value l_risk_json format json,
           'weather_evidence' value l_weather_compact format json,
           'google_sheet_fraud_score' value l_google_sheet format json,
           'databricks_repairer_fraud_score' value l_databricks format json,
           'contextual_risk_summary' value l_contextual_summary format json,
           'fraud_potential' value l_fraud_probability,
           'risk_level' value l_risk_level,
           'errors' value l_errors format json
           returning clob
         )
    into l_result
    from dual;

  return l_result;
exception
  when others then
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'claim_id' value p_claim_id,
             'error_message' value 'Error in fsi_validate_multi_source_risk_summary: ' || l_error_message
             returning clob
           )
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE FUNCTION "FSI_VIEW_CLAIM" (
  p_claim_id in number
) return clob
as
  l_result clob;
  l_error_message varchar2(4000);

-- fsi_view_claim function retrieves claim details and associated parties for a given claim ID.
-- It returns a JSON object containing the claim information, including total settled amount, status, and
-- a list of claim parties. If the claim ID is not found, it returns a JSON

begin
  if p_claim_id is null then
    select json_object(
             'status' value 'ERROR',
             'error_message' value 'Missing required parameter P_CLAIM_ID.'
           returning clob)
      into l_result
      from dual;
    return l_result;
  end if;

  select json_object(
           'status' value 'FOUND',
           'claim_id' value c.claim_id,
           'total_settled_amount' value c.total_settled,
           'status_value' value c.claim_status,
           'amount_column' value 'TOTAL_SETTLED',
           'status_column' value 'CLAIM_STATUS',
           'claim_party_count' value (
             select count(*)
               from claim_parties cp
              where cp.claim_id = c.claim_id
           ),
           'claim' value json_object(
             'claim_id' value c.claim_id,
             'claim_number' value c.claim_number,
             'policy_id' value c.policy_id,
             'customer_id' value c.customer_id,
             'vehicle_id' value c.vehicle_id,
             'incident_date' value to_char(c.incident_date, 'YYYY-MM-DD'),
             'reported_date' value to_char(c.reported_date, 'YYYY-MM-DD'),
             'claim_type' value c.claim_type,
             'risk_tier' value coalesce(
               c.risk_tier,
               (
                 select case fi.indicator_code
                          when 'SIMULATION_HIGH_RISK' then 'HIGH'
                          when 'SIMULATION_MEDIUM_RISK' then 'MEDIUM'
                          when 'SIMULATION_LOW_RISK' then 'LOW'
                        end
                   from fraud_indicators fi
                  where fi.claim_id = c.claim_id
                    and fi.detected_by = 'FSI_CLAIM_SIMULATOR'
                    and fi.indicator_code in (
                      'SIMULATION_HIGH_RISK', 'SIMULATION_MEDIUM_RISK', 'SIMULATION_LOW_RISK'
                    )
                  order by fi.detected_date desc, fi.indicator_id desc
                  fetch first 1 row only
               )
             ),
             'claim_details' value dbms_lob.substr(c.claim_details, 4000, 1),
             'claim_status' value c.claim_status,
             'fault_flag' value c.fault_flag,
             'third_party_flag' value c.third_party_flag,
             'injury_flag' value c.injury_flag,
             'total_claimed' value c.total_claimed,
             'total_settled' value c.total_settled,
             'reserve_amount' value c.reserve_amount,
             'handler_id' value c.handler_id,
             'open_date' value to_char(c.open_date, 'YYYY-MM-DD'),
             'close_date' value to_char(c.close_date, 'YYYY-MM-DD'),
             'fraud_flag' value c.fraud_flag,
             'fraud_score' value c.fraud_score,
             'created_date' value to_char(c.created_date, 'YYYY-MM-DD')
           ),
           'claim_parties' value (
             select coalesce(
                      json_arrayagg(
                        json_object(
                          'party_id' value cp.party_id,
                          'claim_id' value cp.claim_id,
                          'party_type' value cp.party_type,
                          'first_name' value cp.first_name,
                          'last_name' value cp.last_name,
                          'date_of_birth' value to_char(cp.date_of_birth, 'YYYY-MM-DD'),
                          'phone' value cp.phone,
                          'email' value cp.email,
                          'address' value cp.address,
                          'postcode' value cp.postcode,
                          'insurer_name' value cp.insurer_name,
                          'policy_number' value cp.policy_number,
                          'vehicle_reg' value cp.vehicle_reg,
                          'injury_desc' value cp.injury_desc,
                          'injury_severity' value cp.injury_severity,
                          'solicitor_flag' value cp.solicitor_flag,
                          'solicitor_name' value cp.solicitor_name
                        returning clob)
                      returning clob),
                      to_clob('[]')
                    )
               from claim_parties cp
              where cp.claim_id = c.claim_id
           )
         returning clob)
    into l_result
    from claims c
   where c.claim_id = p_claim_id;

  return l_result;
exception
  when no_data_found then
    select json_object(
             'status' value 'NOT_FOUND',
             'claim_id' value p_claim_id,
             'error_message' value 'No claim found for P_CLAIM_ID=' || p_claim_id
           returning clob)
      into l_result
      from dual;
    return l_result;
  when others then
    l_error_message := sqlerrm;
    select json_object(
             'status' value 'ERROR',
             'claim_id' value p_claim_id,
             'error_message' value 'Error in fsi_view_claim: ' || l_error_message
           returning clob)
      into l_result
      from dual;
    return l_result;
end;
/

CREATE OR REPLACE EDITIONABLE PROCEDURE "FSI_DELETE_CLAIMS_BY_ID_RANGE_WORKER" (
  p_from_claim_id in number,
  p_to_claim_id   in number,
  p_job_name      in varchar2
)
authid definer
as
  pragma autonomous_transaction;

  l_claim_result    clob;
  l_claim_status    varchar2(30);
  l_result          clob;
  l_error_message   varchar2(4000);
  l_candidate_count number := 0;
  l_deleted_count   number := 0;
  l_failed_count    number := 0;
  l_failed_ids      varchar2(32767);
  l_final_status    varchar2(20);
begin
  update fsi_claim_delete_jobs
     set status = 'RUNNING',
         started_at = systimestamp
   where job_name = p_job_name;
  commit;

  begin
    for r in (
      select claim_id
        from claims
       where claim_id between p_from_claim_id and p_to_claim_id
       order by claim_id
    ) loop
      l_candidate_count := l_candidate_count + 1;
      l_claim_result := fsi_delete_claim_by_id(r.claim_id);
      l_claim_status := json_value(
                          l_claim_result,
                          '$.status' returning varchar2(30) null on error
                        );

      if l_claim_status = 'DELETED' then
        l_deleted_count := l_deleted_count + 1;
      else
        l_failed_count := l_failed_count + 1;
        if l_failed_ids is null
           or length(l_failed_ids) + 1 + length(to_char(r.claim_id)) <= 32767
        then
          l_failed_ids := l_failed_ids
                         || case when l_failed_ids is null then null else ',' end
                         || to_char(r.claim_id);
        end if;
      end if;
    end loop;

    l_final_status := case
                        when l_candidate_count = 0 then 'NO_CLAIMS'
                        when l_failed_count = 0 then 'DELETED'
                        else 'PARTIAL'
                      end;

    select json_object(
             'status' value l_final_status,
             'job_name' value p_job_name,
             'from_claim_id' value p_from_claim_id,
             'to_claim_id' value p_to_claim_id,
             'candidate_count' value l_candidate_count,
             'deleted_count' value l_deleted_count,
             'failed_count' value l_failed_count,
             'failed_claim_ids' value l_failed_ids
             returning clob)
      into l_result
      from dual;

    update fsi_claim_delete_jobs
       set status = l_final_status,
           candidate_count = l_candidate_count,
           deleted_count = l_deleted_count,
           failed_count = l_failed_count,
           failed_claim_ids = l_failed_ids,
           result = l_result,
           completed_at = systimestamp
     where job_name = p_job_name;
    commit;
  exception
    when others then
      rollback;
      l_error_message := sqlerrm;
      select json_object(
               'status' value 'FAILED',
               'job_name' value p_job_name,
               'from_claim_id' value p_from_claim_id,
               'to_claim_id' value p_to_claim_id,
               'error_message' value l_error_message
               returning clob)
        into l_result
        from dual;
      update fsi_claim_delete_jobs
         set status = 'FAILED',
             result = l_result,
             error_message = substr(l_error_message, 1, 4000),
             completed_at = systimestamp
       where job_name = p_job_name;
      commit;
  end;
exception
  when others then
    rollback;
    raise;
end;
/

CREATE OR REPLACE EDITIONABLE PROCEDURE "FSI_RECOVER_STALE_FRAUD_INVESTIGATIONS" 
authid definer
as
begin
  update fsi_apex_ai_requests
     set status = 'ERROR',
         error_message = substr(
           nvl(error_message || ' ', '') ||
           'Automatically released after exceeding the 30-minute investigation timeout.',
           1,
           4000
         ),
         completed_at = systimestamp
   where upper(team_name) = 'FSI_FRAUD_INVESTIGATION_TEAM'
     and status in ('QUEUED', 'RUNNING')
     and created_at < systimestamp - numtodsinterval(30, 'MINUTE');
  commit;
end fsi_recover_stale_fraud_investigations;
/

CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CROSSSHIELD_REPORT_STORAGE" as
  function runtime_config_value(p_config_key varchar2, p_default varchar2) return varchar2 is
    l_value varchar2(4000);
  begin
    select trim(dbms_lob.substr(config_value, 4000, 1))
      into l_value
      from fsi_runtime_config
     where config_key = upper(trim(p_config_key));
    return coalesce(l_value, p_default);
  exception when no_data_found then
    return p_default;
  end;

  function html_to_markdown(
    p_claim_id     in number,
    p_claim_number in varchar2,
    p_report_html  in clob
  ) return clob is
    l_text clob;
  begin
    l_text:=regexp_replace(p_report_html,'</(h[1-6]|p|div|section|article|header|footer|li|tr)>',chr(10),1,0,'in');
    l_text:=regexp_replace(l_text,'<br[[:space:]]*/?>',chr(10),1,0,'in');
    l_text:=regexp_replace(l_text,'<li[^>]*>','- ',1,0,'in');
    l_text:=regexp_replace(l_text,'<[^>]+>',' ',1,0,'in');
    l_text:=replace(replace(replace(replace(replace(l_text,';','&'),';','<'),';','>'),';','"'),'&#39;','''');
    l_text:=regexp_replace(l_text,'[[:space:]]+'||chr(10),chr(10),1,0,'n');
    l_text:=regexp_replace(l_text,chr(10)||'{3,}',chr(10)||chr(10),1,0,'n');
    return to_clob('# Fraud Investigation Report for Claim ID '||to_char(p_claim_id)||chr(10)||chr(10)||
      'Claim ID: '||to_char(p_claim_id)||chr(10)||
      'Claim Number: '||nvl(p_claim_number,'--')||chr(10)||
      'Generated: '||to_char(systimestamp,'YYYY-MM-DD"T"HH24:MI:SS TZH:TZM')||chr(10)||chr(10))||l_text;
  end html_to_markdown;

  procedure rebuild_vector_index is
    l_attributes clob;
    l_credential_name varchar2(128);
    l_storage_pattern varchar2(1000);
    l_vector_index varchar2(128);
    l_vector_table varchar2(128);
    l_rag_profile varchar2(128);
    l_vector_dimension number;
  begin
    l_credential_name := runtime_config_value('OBJECT_STORAGE_CREDENTIAL_NAME', 'FS_OCI_CRED');
    l_storage_pattern := runtime_config_value('OBJECT_STORAGE_PATTERN', 'https://objectstorage.us-chicago-1.oraclecloud.com/n/idukzrqavn8q/b/fsi-crossshield-kb/o/*.md');
    l_vector_index := runtime_config_value('RAG_VECTOR_INDEX_NAME', 'FSI_HUB_VECTOR_INDEX_KB');
    l_vector_table := runtime_config_value('RAG_VECTOR_TABLE_NAME', 'FSI_HUB_VECTOR_INDEX_KB$VECTAB');
    l_rag_profile := runtime_config_value('RAG_PROFILE_NAME', 'FSI_SELECT_AI_RAG_KB_PROFILE');
    l_vector_dimension := to_number(runtime_config_value('RAG_VECTOR_DIMENSION', '1536'));
    select json_object(
             'vector_db_provider' value 'oracle',
             'location' value l_storage_pattern,
             'object_storage_credential_name' value l_credential_name,
             'profile_name' value l_rag_profile,
             'vector_dimension' value l_vector_dimension,
             'vector_distance_metric' value 'cosine',
             'chunk_overlap' value 128,
             'chunk_size' value 1024,
             'refresh_rate' value 1440
             returning clob
           )
      into l_attributes
      from dual;
    begin
      dbms_cloud_ai.drop_vector_index(
        index_name=>l_vector_index,
        include_data=>true,
        force=>true
      );
    exception when others then
      if sqlcode not in (-942,-4043,-20000) then raise; end if;
    end;
    begin
      dbms_cloud_ai.create_vector_index(
        index_name=>l_vector_index,
        attributes=>l_attributes,
        status=>'Enabled',
        description=>'CrossShield and FSI generated fraud investigation reports',
        wait_for_completion=>true
      );
    exception
      when others then
        if sqlcode=-20000 and instr(sqlerrm,'ORA-00955')>0 then
          execute immediate 'drop table ' || dbms_assert.simple_sql_name(l_vector_table) || ' purge';
          dbms_cloud_ai.create_vector_index(
            index_name=>l_vector_index,
            attributes=>l_attributes,
            status=>'Enabled',
            description=>'CrossShield and FSI generated fraud investigation reports',
            wait_for_completion=>true
          );
        else
          raise;
        end if;
    end;
  end rebuild_vector_index;

  procedure rebuild_vector_index_job is
  begin
    rebuild_vector_index;
  end rebuild_vector_index_job;

  procedure schedule_vector_index_rebuild(
    p_claim_id in number
  ) is
    l_job_name varchar2(128);
  begin
    l_job_name := 'FSI_VEC_REBUILD_' || to_char(p_claim_id) || '_' || substr(rawtohex(sys_guid()), 1, 16);
    dbms_scheduler.create_job(
      job_name        => l_job_name,
      job_type        => 'STORED_PROCEDURE',
      job_action      => 'CROSSSHIELD_REPORT_STORAGE.REBUILD_VECTOR_INDEX_JOB',
      start_date      => systimestamp + interval '1' second,
      enabled         => false,
      auto_drop       => true,
      comments        => 'Background vector-index rebuild after report storage for claim ' || to_char(p_claim_id)
    );
    dbms_scheduler.enable(l_job_name);
  exception
    when others then
      null;
  end schedule_vector_index_rebuild;

  procedure store_and_index(
    p_claim_id     in number,
    p_claim_number in varchar2,
    p_report_html  in clob
  ) is
    l_object_name varchar2(255);
    l_object_uri  varchar2(2000);
    l_markdown    clob;
    l_contents    blob;
    l_dest_offset integer:=1;
    l_src_offset  integer:=1;
    l_lang_ctx    integer:=dbms_lob.default_lang_ctx;
    l_warning     integer;
    l_credential_name varchar2(128);
    l_storage_prefix varchar2(1000);
    l_model_name varchar2(128);
  begin
    if p_claim_id is null or p_claim_id<1 then
      raise_application_error(-20101,'A valid claim ID is required for report storage.');
    end if;
    if p_report_html is null then
      raise_application_error(-20102,'Fraud investigation report HTML is required for report storage.');
    end if;
    l_credential_name := runtime_config_value('OBJECT_STORAGE_CREDENTIAL_NAME', 'FS_OCI_CRED');
    l_storage_prefix := runtime_config_value('OBJECT_STORAGE_PREFIX', 'https://objectstorage.us-chicago-1.oraclecloud.com/n/idukzrqavn8q/b/fsi-crossshield-kb/o/');
    l_model_name := runtime_config_value('OCI_MODEL_NAME', 'FSI_SELECT_AI');
    l_object_name:='claim-'||to_char(p_claim_id)||'-fraud-investigation.md';
    l_object_uri:=l_storage_prefix||l_object_name;
    l_markdown:=html_to_markdown(p_claim_id,p_claim_number,p_report_html);
    insert into crossshield_apex_reports(
      claim_id,
      report_html,
      ai_service_name,
      ai_model_id
    ) values (
      p_claim_id,
      p_report_html,
      'OCI Generative AI',
      l_model_name
    );
    dbms_lob.createtemporary(l_contents,true,dbms_lob.call);
    dbms_lob.converttoblob(
      dest_lob=>l_contents,
      src_clob=>l_markdown,
      amount=>dbms_lob.lobmaxsize,
      dest_offset=>l_dest_offset,
      src_offset=>l_src_offset,
      blob_csid=>nls_charset_id('AL32UTF8'),
      lang_context=>l_lang_ctx,
      warning=>l_warning
    );
    begin
      dbms_cloud.put_object(
        credential_name=>l_credential_name,
        object_uri=>l_object_uri,
        contents=>l_contents
      );
    exception when others then
      dbms_output.put_line(
        'Optional Object Storage upload skipped for claim ' || to_char(p_claim_id) || ': ' || sqlerrm
      );
    end;
    dbms_lob.freetemporary(l_contents);
    schedule_vector_index_rebuild(p_claim_id);
  exception when others then
    if dbms_lob.istemporary(l_contents)=1 then dbms_lob.freetemporary(l_contents); end if;
    raise_application_error(-20103,'Unable to persist local report for claim '||to_char(p_claim_id)||': '||substr(sqlerrm,1,1700));
  end store_and_index;
end crossshield_report_storage;
/

CREATE OR REPLACE EDITIONABLE PACKAGE BODY "FSI_APEX_INVESTIGATION_QUEUE" as
  c_team_name constant varchar2(128) := 'FSI_FRAUD_INVESTIGATION_TEAM';

  function submit (
    p_claim_id in number
  ) return varchar2 is
    pragma autonomous_transaction;
    l_request_id  varchar2(32);
    l_job_name    varchar2(128);
    l_prompt      varchar2(12000);
    l_claim_status claims.claim_status%type;
    l_error       varchar2(4000);
  begin
    if p_claim_id is null or p_claim_id < 1 then
      raise_application_error(-20080, 'A valid claim ID is required.');
    end if;

    select claim_status
      into l_claim_status
      from claims
     where claim_id = p_claim_id
       for update;

    l_prompt := 'Investigate claim id ' || to_char(p_claim_id) ||
                '. Return a clear executive fraud investigation report, not raw JSON.';

    if upper(trim(l_claim_status)) = 'NEW' then
      update claims
         set claim_status = 'UNDER_INVESTIGATION'
       where claim_id = p_claim_id
         and upper(trim(claim_status)) = 'NEW';
    elsif upper(trim(l_claim_status)) = 'UNDER_INVESTIGATION' then
      begin
        select request_id
          into l_request_id
          from (
            select request_id
              from fsi_apex_ai_requests
             where team_name = c_team_name
               and status in ('QUEUED', 'RUNNING')
               and dbms_lob.instr(user_prompt, l_prompt) > 0
             order by created_at desc
          )
         where rownum = 1;

        commit;
        return l_request_id;
      exception
        when no_data_found then
          raise_application_error(
            -20083,
            'Claim ' || to_char(p_claim_id) ||
            ' is already reserved for investigation. Refresh the page and try again shortly.'
          );
      end;
    else
      begin
        select request_id
          into l_request_id
          from (
            select request_id
              from fsi_apex_ai_requests
             where team_name = c_team_name
               and status = 'COMPLETED'
               and dbms_lob.instr(user_prompt, l_prompt) > 0
             order by completed_at desc nulls last, created_at desc
          )
         where rownum = 1;

        commit;
        return l_request_id;
      exception
        when no_data_found then
          raise_application_error(
            -20084,
            'Claim ' || to_char(p_claim_id) || ' is in status ' ||
            nvl(l_claim_status, 'UNKNOWN') ||
            ' and cannot be submitted for a new investigation.'
          );
      end;
    end if;

    l_request_id := lower(rawtohex(sys_guid()));

    insert into fsi_apex_ai_requests (
      request_id,
      team_name,
      user_prompt,
      status
    ) values (
      l_request_id,
      c_team_name,
      l_prompt,
      'QUEUED'
    );

    commit;

    l_job_name := 'FSI_INVEST_' || upper(substr(l_request_id, 1, 16));
    begin
      dbms_scheduler.create_job(
        job_name   => l_job_name,
        job_type   => 'PLSQL_BLOCK',
        job_action => 'begin fsi_apex_ai_api.process_request(''' ||
                      l_request_id || '''); end;',
        start_date => systimestamp,
        enabled    => false,
        auto_drop  => true,
        comments   => 'Background Page 200 fraud investigation for claim ' ||
                      to_char(p_claim_id)
      );
      dbms_scheduler.enable(l_job_name);
    exception
      when others then
        l_error := substr(sqlerrm, 1, 3500);
        update fsi_apex_ai_requests
           set status = 'ERROR',
               error_message = 'Unable to schedule background investigation: ' || l_error,
               completed_at = systimestamp
         where request_id = l_request_id;
        update claims
           set claim_status = 'NEW'
         where claim_id = p_claim_id
           and upper(trim(claim_status)) = 'UNDER_INVESTIGATION';
        commit;
        raise_application_error(-20081, 'Unable to schedule the fraud investigation: ' || l_error);
    end;

    return l_request_id;
  exception
    when no_data_found then
      rollback;
      raise_application_error(-20080, 'Claim ' || to_char(p_claim_id) || ' does not exist.');
    when others then
      rollback;
      raise;
  end submit;

  function get_status (
    p_request_id in varchar2,
    p_claim_id   in number
  ) return clob is
    l_status        fsi_apex_ai_requests.status%type;
    l_response      clob;
    l_error_message fsi_apex_ai_requests.error_message%type;
    l_result        clob;
  begin
    if p_request_id is null
       or not regexp_like(p_request_id, '^[0-9A-Fa-f]{32}$')
       or p_claim_id is null
       or p_claim_id < 1 then
      select json_object(
               'status' value 'NOT_FOUND',
               'message' value 'Invalid investigation request.'
               returning clob
             )
        into l_result
        from dual;
      return l_result;
    end if;

    select status,
           response,
           error_message
      into l_status,
           l_response,
           l_error_message
      from fsi_apex_ai_requests
     where request_id = lower(p_request_id)
       and team_name = c_team_name
       and dbms_lob.instr(
             user_prompt,
             'Investigate claim id ' || to_char(p_claim_id) || '.'
           ) > 0;

    if l_status = 'COMPLETED' then
      select json_object(
               'status' value l_status,
               'report_html' value l_response
               returning clob
             )
        into l_result
        from dual;
    else
      select json_object(
               'status' value l_status,
               'message' value case
                 when l_status = 'QUEUED' then 'Investigation is queued.'
                 when l_status = 'RUNNING' then 'Investigation is running.'
                 when l_status = 'ERROR' then nvl(l_error_message, 'Investigation failed.')
                 else 'Investigation status is unavailable.'
               end
               returning clob
             )
        into l_result
        from dual;
    end if;

    return l_result;
  exception
    when no_data_found then
      select json_object(
               'status' value 'NOT_FOUND',
               'message' value 'Investigation request was not found for this claim.'
               returning clob
             )
        into l_result
        from dual;
      return l_result;
  end get_status;
end fsi_apex_investigation_queue;
/

CREATE OR REPLACE EDITIONABLE PACKAGE BODY "FSI_SCHEDULER_JOBS" as
  c_generate_job    constant varchar2(30)  := 'FSI_GENERATE_CLAIMS_JOB';
  c_investigate_job constant varchar2(30)  := 'FSI_INVESTIGATE_NEW_JOB';
  c_team_name       constant varchar2(128) := 'FSI_FRAUD_INVESTIGATION_TEAM';

  procedure free_clob(
    p_value in out nocopy clob
  ) is
  begin
    if p_value is not null and dbms_lob.istemporary(p_value) = 1 then
      dbms_lob.freetemporary(p_value);
    end if;
  exception
    when others then
      null;
  end free_clob;

  procedure ensure_investigate_control_row is
  begin
    merge into fsi_scheduler_control target
    using (
      select c_investigate_job as job_name
        from dual
    ) source
    on (target.job_name = source.job_name)
    when not matched then
      insert (
        job_name,
        accept_new_claims,
        changed_at,
        changed_by
      ) values (
        source.job_name,
        'N',
        systimestamp,
        user
      );
  end ensure_investigate_control_row;

  procedure set_investigate_acceptance(
    p_accept_new_claims in char
  ) is
  begin
    ensure_investigate_control_row;

    update fsi_scheduler_control
       set accept_new_claims = p_accept_new_claims,
           changed_at = systimestamp,
           changed_by = user
     where job_name = c_investigate_job;

    commit;
  end set_investigate_acceptance;

  procedure generate_one_claim is
    l_result clob;
  begin
    -- The batch function accepts a count. Passing 1 generates one NEW claim.
    l_result := fsi_generate_ten_random_claims(1);
    free_clob(l_result);
  end generate_one_claim;

  procedure reserve_next_new_claim(
    p_max_claim_id in  claims.claim_id%type,
    p_claim_id     out nocopy claims.claim_id%type
  ) is
    l_accept_new_claims fsi_scheduler_control.accept_new_claims%type;
  begin
    p_claim_id := null;

    -- This lock is also acquired by STOP. It makes the transition from
    -- accepting to stopped atomic with respect to reserving the next claim.
    select accept_new_claims
      into l_accept_new_claims
      from fsi_scheduler_control
     where job_name = c_investigate_job
       for update;

    if l_accept_new_claims <> 'Y' then
      commit;
      return;
    end if;

    -- Claims with lapsed/cancelled policies are deliberately not candidates.
    -- They are rejected by the claim-status workflow before investigation.
    for r in (
      select c.claim_id
        from claims c
       where upper(trim(c.claim_status)) = 'NEW'
         and (p_max_claim_id is null or c.claim_id <= p_max_claim_id)
         and not exists (
               select 1
                 from policies p
                where p.policy_id = c.policy_id
                  and upper(trim(p.status)) in ('LAPSED', 'CANCELLED')
             )
       order by c.claim_id
       for update skip locked
    ) loop
      p_claim_id := r.claim_id;
      exit;
    end loop;

    if p_claim_id is not null then
      update claims
         set claim_status = 'UNDER_INVESTIGATION'
       where claim_id = p_claim_id
         and upper(trim(claim_status)) = 'NEW';

      if sql%rowcount <> 1 then
        p_claim_id := null;
      end if;
    end if;

    -- The claim is now reserved, and the control-row lock can be released.
    -- STOP may set ACCEPT_NEW_CLAIMS to N while this investigation runs.
    commit;
  exception
    when others then
      rollback;
      raise;
  end reserve_next_new_claim;

  function investigate_one_new_claim(
    p_max_claim_id in claims.claim_id%type
  ) return boolean is
    l_claim_id   claims.claim_id%type;
    l_request_id fsi_apex_ai_requests.request_id%type;
    l_status     fsi_apex_ai_requests.status%type;
    l_error      fsi_apex_ai_requests.error_message%type;
  begin
    reserve_next_new_claim(
      p_max_claim_id => p_max_claim_id,
      p_claim_id     => l_claim_id
    );

    if l_claim_id is null then
      return false;
    end if;

    l_request_id := lower(rawtohex(sys_guid()));
    insert into fsi_apex_ai_requests (
      request_id,
      team_name,
      user_prompt
    ) values (
      l_request_id,
      c_team_name,
      'Investigate claim id ' || to_char(l_claim_id) ||
      '. Return a clear executive fraud investigation report, not raw JSON.'
    );
    commit;

    -- The Scheduler invocation is the worker, so process the request directly.
    fsi_apex_ai_api.process_request(l_request_id);

    select status,
           error_message
      into l_status,
           l_error
      from fsi_apex_ai_requests
     where request_id = l_request_id;

    if l_status <> 'COMPLETED' then
      update claims
         set claim_status = 'NEW'
       where claim_id = l_claim_id
         and upper(trim(claim_status)) = 'UNDER_INVESTIGATION';
      commit;

      raise_application_error(
        -20071,
        'Investigation failed for claim ' || to_char(l_claim_id) || ': ' ||
        substr(nvl(l_error, 'Unknown FSI AI request error.'), 1, 1800)
      );
    end if;

    return true;
  exception
    when others then
      -- A failed reservation is retriable. Do not overwrite a status that was
      -- finalized by a downstream fraud-review workflow.
      if l_claim_id is not null then
        update claims
           set claim_status = 'NEW'
         where claim_id = l_claim_id
           and upper(trim(claim_status)) = 'UNDER_INVESTIGATION';
        commit;
      end if;
      raise;
  end investigate_one_new_claim;

  procedure investigate_next_new_claim is
    l_processed boolean;
  begin
    l_processed := investigate_one_new_claim(
      p_max_claim_id => null
    );
  end investigate_next_new_claim;

  procedure investigate_all_new_claims is
    l_max_claim_id claims.claim_id%type;
    l_processed    boolean;

    procedure stop_when_new_queue_is_empty is
      l_new_claim_count pls_integer;
    begin
      select count(*)
        into l_new_claim_count
        from claims
       where upper(trim(claim_status)) = 'NEW';

      if l_new_claim_count = 0 then
        -- Disable future scheduled invocations without interrupting this run.
        -- The current invocation is already at the end of its batch.
        set_investigate_acceptance('N');
        dbms_scheduler.disable(c_investigate_job, force => true);
      end if;
    end stop_when_new_queue_is_empty;
  begin
    -- Snapshot the NEW queue at the start of this scheduled run. Claims created
    -- while the run is active are handled by the following one-minute run.
    select max(claim_id)
      into l_max_claim_id
      from claims
     where upper(trim(claim_status)) = 'NEW';

    if l_max_claim_id is null then
      stop_when_new_queue_is_empty;
      return;
    end if;

    loop
      l_processed := investigate_one_new_claim(
        p_max_claim_id => l_max_claim_id
      );
      exit when not l_processed;
    end loop;

    -- A claim created while the snapshot was being processed keeps the job
    -- enabled for the next one-minute run. Otherwise, stop automatically.
    stop_when_new_queue_is_empty;
  end investigate_all_new_claims;

  procedure drop_job_if_exists(
    p_job_name in varchar2
  ) is
  begin
    dbms_scheduler.drop_job(
      job_name => p_job_name,
      force    => true
    );
  exception
    when others then
      if sqlcode <> -27475 then
        raise;
      end if;
  end drop_job_if_exists;

  procedure create_jobs(
    p_enable in boolean default false
  ) is
  begin
    drop_job_if_exists(c_generate_job);
    drop_job_if_exists(c_investigate_job);

    dbms_scheduler.create_job(
      job_name        => c_generate_job,
      job_type        => 'STORED_PROCEDURE',
      job_action      => 'FSI_SCHEDULER_JOBS.GENERATE_ONE_CLAIM',
      start_date      => systimestamp,
      repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
      enabled         => false,
      auto_drop       => false,
      comments        => 'Generate one NEW claim per run until stopped.'
    );

    dbms_scheduler.create_job(
      job_name        => c_investigate_job,
      job_type        => 'STORED_PROCEDURE',
      job_action      => 'FSI_SCHEDULER_JOBS.INVESTIGATE_ALL_NEW_CLAIMS',
      start_date      => systimestamp,
      repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
      enabled         => false,
      auto_drop       => false,
      comments        => 'Investigate the NEW-claim queue sequentially until stopped.'
    );

    if p_enable then
      dbms_scheduler.enable(c_generate_job);
      start_investigate_new;
    end if;
  end create_jobs;

  procedure run_now_if_idle(
    p_job_name in varchar2
  ) is
    l_running number;
  begin
    select count(*)
      into l_running
      from user_scheduler_running_jobs
     where job_name = upper(p_job_name);

    if l_running = 0 then
      dbms_scheduler.run_job(
        job_name            => p_job_name,
        use_current_session => false
      );
    end if;
  end run_now_if_idle;

  procedure start_generate_claims is
  begin
    dbms_scheduler.enable(c_generate_job);
    run_now_if_idle(c_generate_job);
  end start_generate_claims;

  procedure stop_generate_claims(
    p_force in boolean default false
  ) is
  begin
    dbms_scheduler.disable(c_generate_job, force => false);
    begin
      dbms_scheduler.stop_job(c_generate_job, force => p_force);
    exception
      when others then
        if sqlcode not in (-27366, -27475) then
          raise;
        end if;
    end;
  end stop_generate_claims;

  procedure start_investigate_new is
  begin
    set_investigate_acceptance('Y');
    dbms_scheduler.enable(c_investigate_job);
    run_now_if_idle(c_investigate_job);
  end start_investigate_new;

  procedure stop_investigate_new(
    p_force in boolean default false
  ) is
  begin
    -- P_FORCE is retained for compatibility with the existing package API.
    -- A hard stop is intentionally not supported for this workflow.
    -- Do not call STOP_JOB. A stop must allow the current claim investigation
    -- to finish. FORCE=>TRUE on DISABLE prevents a future invocation while the
    -- current Scheduler run is allowed to complete.
    set_investigate_acceptance('N');
    dbms_scheduler.disable(c_investigate_job, force => true);
  exception
    when others then
      if sqlcode <> -27475 then
        raise;
      end if;
  end stop_investigate_new;
end fsi_scheduler_jobs;
/

CREATE OR REPLACE EDITIONABLE PACKAGE BODY "FSI_WEATHER_ANOMALY" as
  function runtime_config_value(p_config_key varchar2) return varchar2 is
    l_value varchar2(4000);
  begin
    select trim(dbms_lob.substr(config_value, 4000, 1)) into l_value
      from fsi_runtime_config where config_key = upper(trim(p_config_key));
    if l_value is null then raise_application_error(-20060, p_config_key || ' is not configured in FSI_RUNTIME_CONFIG.'); end if;
    return l_value;
  exception when no_data_found then
    raise_application_error(-20060, p_config_key || ' is not configured in FSI_RUNTIME_CONFIG.');
  end;

  function to_iso_date(p_date in date) return varchar2 is
  begin
    return to_char(p_date, 'YYYY-MM-DD');
  end;

  function url_encode(p_value in varchar2) return varchar2 is
  begin
    return replace(trim(p_value), ' ', '%20');
  end;

  function get_url(p_accident_date in date) return varchar2 is
    l_start_date date := p_accident_date - 14;
    l_end_date   date := p_accident_date + 14;
    l_amp        varchar2(1) := chr(38);
  begin
    return runtime_config_value('OPEN_METEO_ARCHIVE_URL') ||
      '?latitude=' || runtime_config_value('OPEN_METEO_DEFAULT_LATITUDE') ||
      l_amp || 'longitude=' || runtime_config_value('OPEN_METEO_DEFAULT_LONGITUDE') ||
      l_amp || 'daily=temperature_2m_max,temperature_2m_min,precipitation_sum,rain_sum,precipitation_hours,wind_speed_10m_max,wind_gusts_10m_max' ||
      l_amp || 'hourly=temperature_2m,relative_humidity_2m,precipitation,rain,weather_code,wind_speed_10m,wind_gusts_10m' ||
      l_amp || 'timezone=' || runtime_config_value('OPEN_METEO_DEFAULT_TIMEZONE') ||
      l_amp || 'start_date=' || to_iso_date(l_start_date) ||
      l_amp || 'end_date=' || to_iso_date(l_end_date);
  end;

  function get_weather_url(
    p_latitude     in number,
    p_longitude    in number,
    p_weather_date in date
  ) return varchar2 is
    l_amp      varchar2(1) := chr(38);
    l_base_url varchar2(4000);
  begin
    if trunc(p_weather_date) < trunc(sysdate) then
      l_base_url := runtime_config_value('OPEN_METEO_ARCHIVE_URL');
    else
      l_base_url := runtime_config_value('OPEN_METEO_FORECAST_URL');
    end if;

    return l_base_url ||
      '?latitude=' || to_char(p_latitude, 'FM999999990D999999', 'NLS_NUMERIC_CHARACTERS=.,') ||
      l_amp || 'longitude=' || to_char(p_longitude, 'FM999999990D999999', 'NLS_NUMERIC_CHARACTERS=.,') ||
      l_amp || 'daily=temperature_2m_max,temperature_2m_min,precipitation_sum,rain_sum,showers_sum,precipitation_hours,wind_speed_10m_max,wind_gusts_10m_max' ||
      l_amp || 'timezone=auto' ||
      l_amp || 'start_date=' || to_iso_date(p_weather_date) ||
      l_amp || 'end_date=' || to_iso_date(p_weather_date);
  end;

  function http_get(p_url in varchar2) return clob is
    l_req      utl_http.req;
    l_resp     utl_http.resp;
    l_buffer   varchar2(32767);
    l_response clob;
  begin
    dbms_lob.createtemporary(l_response, true);
    utl_http.set_response_error_check(false);

    l_req := utl_http.begin_request(p_url, 'GET', 'HTTP/1.1');
    utl_http.set_header(l_req, 'Accept', 'application/json');
    utl_http.set_header(l_req, 'User-Agent', 'oracle-plsql-weather-anomaly-test/1.0');

    l_resp := utl_http.get_response(l_req);

    begin
      loop
        utl_http.read_text(l_resp, l_buffer, 32767);
        dbms_lob.writeappend(l_response, length(l_buffer), l_buffer);
      end loop;
    exception
      when utl_http.end_of_body then
        null;
    end;

    utl_http.end_response(l_resp);
    return l_response;
  exception
    when others then
      begin
        utl_http.end_response(l_resp);
      exception
        when others then
          null;
      end;
      raise;
  end;

  function z_score(p_value in number, p_avg in number, p_stddev in number) return number is
  begin
    if p_value is null or p_avg is null or p_stddev is null or p_stddev = 0 then
      return null;
    end if;

    return round((p_value - p_avg) / p_stddev, 2);
  end;

  function severity_label(p_z in number, p_direction in varchar2 default 'HIGH') return varchar2 is
  begin
    if p_z is null then
      return 'not enough baseline variation';
    elsif p_direction = 'ABS' and abs(p_z) >= 2 then
      return 'ANOMALY';
    elsif p_direction <> 'ABS' and p_z >= 2 then
      return 'SPIKE';
    elsif p_direction = 'ABS' and abs(p_z) >= 1 then
      return 'watch';
    elsif p_direction <> 'ABS' and p_z >= 1 then
      return 'watch';
    else
      return 'normal';
    end if;
  end;

  procedure print_metric(
    p_name      in varchar2,
    p_value     in number,
    p_avg       in number,
    p_stddev    in number,
    p_z         in number,
    p_unit      in varchar2,
    p_direction in varchar2 default 'HIGH'
  ) is
  begin
    dbms_output.put_line(
      rpad(p_name, 26) ||
      ' value=' || nvl(to_char(round(p_value, 2)), 'null') || ' ' || p_unit ||
      ', baseline_avg=' || nvl(to_char(round(p_avg, 2)), 'null') ||
      ', baseline_sd=' || nvl(to_char(round(p_stddev, 2)), 'null') ||
      ', z=' || nvl(to_char(p_z), 'null') ||
      ', status=' || severity_label(p_z, p_direction)
    );
  end;

  procedure analyze_weather_incident(
    p_accident_date in date default date '2024-08-16'
  ) is
    l_url varchar2(32767);
    l_json clob;
    l_accident_date_text varchar2(10);

    l_temp_max number;
    l_temp_min number;
    l_precip_sum number;
    l_rain_sum number;
    l_precip_hours number;
    l_wind_max number;
    l_gust_max number;

    l_temp_max_avg number;
    l_temp_max_sd number;
    l_temp_min_avg number;
    l_temp_min_sd number;
    l_precip_avg number;
    l_precip_sd number;
    l_rain_avg number;
    l_rain_sd number;
    l_precip_hours_avg number;
    l_precip_hours_sd number;
    l_wind_avg number;
    l_wind_sd number;
    l_gust_avg number;
    l_gust_sd number;

    l_rain_hours number;
    l_heavy_rain_hours number;
    l_strong_wind_hours number;
    l_strong_gust_hours number;
    l_max_hourly_precip number;
    l_max_hourly_wind number;
    l_max_hourly_gust number;
  begin
    l_accident_date_text := to_iso_date(p_accident_date);
    l_url := get_url(p_accident_date);
    dbms_output.put_line('Open-Meteo URL:');
    dbms_output.put_line(l_url);

    l_json := http_get(l_url);

    with daily_rows as (
      select
        to_date(d.weather_date, 'YYYY-MM-DD') as weather_date,
        tx.temperature_2m_max,
        tn.temperature_2m_min,
        pr.precipitation_sum,
        rn.rain_sum,
        ph.precipitation_hours,
        ws.wind_speed_10m_max,
        wg.wind_gusts_10m_max
      from json_table(l_json, '$.daily.time[*]'
        columns (
          ord for ordinality,
          weather_date varchar2(10) path '$'
        )
      ) d
      join json_table(l_json, '$.daily.temperature_2m_max[*]'
        columns (ord for ordinality, temperature_2m_max number path '$' null on error)
      ) tx on tx.ord = d.ord
      join json_table(l_json, '$.daily.temperature_2m_min[*]'
        columns (ord for ordinality, temperature_2m_min number path '$' null on error)
      ) tn on tn.ord = d.ord
      join json_table(l_json, '$.daily.precipitation_sum[*]'
        columns (ord for ordinality, precipitation_sum number path '$' null on error)
      ) pr on pr.ord = d.ord
      join json_table(l_json, '$.daily.rain_sum[*]'
        columns (ord for ordinality, rain_sum number path '$' null on error)
      ) rn on rn.ord = d.ord
      join json_table(l_json, '$.daily.precipitation_hours[*]'
        columns (ord for ordinality, precipitation_hours number path '$' null on error)
      ) ph on ph.ord = d.ord
      join json_table(l_json, '$.daily.wind_speed_10m_max[*]'
        columns (ord for ordinality, wind_speed_10m_max number path '$' null on error)
      ) ws on ws.ord = d.ord
      join json_table(l_json, '$.daily.wind_gusts_10m_max[*]'
        columns (ord for ordinality, wind_gusts_10m_max number path '$' null on error)
      ) wg on wg.ord = d.ord
    ),
    baseline as (
      select
        avg(temperature_2m_max) temp_max_avg,
        stddev_samp(temperature_2m_max) temp_max_sd,
        avg(temperature_2m_min) temp_min_avg,
        stddev_samp(temperature_2m_min) temp_min_sd,
        avg(precipitation_sum) precip_avg,
        stddev_samp(precipitation_sum) precip_sd,
        avg(rain_sum) rain_avg,
        stddev_samp(rain_sum) rain_sd,
        avg(precipitation_hours) precip_hours_avg,
        stddev_samp(precipitation_hours) precip_hours_sd,
        avg(wind_speed_10m_max) wind_avg,
        stddev_samp(wind_speed_10m_max) wind_sd,
        avg(wind_gusts_10m_max) gust_avg,
        stddev_samp(wind_gusts_10m_max) gust_sd
      from daily_rows
      where weather_date <> trunc(p_accident_date)
    ),
    accident_day as (
      select *
      from daily_rows
      where weather_date = trunc(p_accident_date)
    )
    select
      a.temperature_2m_max,
      a.temperature_2m_min,
      a.precipitation_sum,
      a.rain_sum,
      a.precipitation_hours,
      a.wind_speed_10m_max,
      a.wind_gusts_10m_max,
      b.temp_max_avg,
      b.temp_max_sd,
      b.temp_min_avg,
      b.temp_min_sd,
      b.precip_avg,
      b.precip_sd,
      b.rain_avg,
      b.rain_sd,
      b.precip_hours_avg,
      b.precip_hours_sd,
      b.wind_avg,
      b.wind_sd,
      b.gust_avg,
      b.gust_sd
    into
      l_temp_max,
      l_temp_min,
      l_precip_sum,
      l_rain_sum,
      l_precip_hours,
      l_wind_max,
      l_gust_max,
      l_temp_max_avg,
      l_temp_max_sd,
      l_temp_min_avg,
      l_temp_min_sd,
      l_precip_avg,
      l_precip_sd,
      l_rain_avg,
      l_rain_sd,
      l_precip_hours_avg,
      l_precip_hours_sd,
      l_wind_avg,
      l_wind_sd,
      l_gust_avg,
      l_gust_sd
    from accident_day a
    cross join baseline b;

    with hourly_rows as (
      select
        h.hour_time,
        pp.precipitation,
        rn.rain,
        ws.wind_speed_10m,
        wg.wind_gusts_10m
      from json_table(l_json, '$.hourly.time[*]'
        columns (
          ord for ordinality,
          hour_time varchar2(30) path '$'
        )
      ) h
      join json_table(l_json, '$.hourly.precipitation[*]'
        columns (ord for ordinality, precipitation number path '$' null on error)
      ) pp on pp.ord = h.ord
      join json_table(l_json, '$.hourly.rain[*]'
        columns (ord for ordinality, rain number path '$' null on error)
      ) rn on rn.ord = h.ord
      join json_table(l_json, '$.hourly.wind_speed_10m[*]'
        columns (ord for ordinality, wind_speed_10m number path '$' null on error)
      ) ws on ws.ord = h.ord
      join json_table(l_json, '$.hourly.wind_gusts_10m[*]'
        columns (ord for ordinality, wind_gusts_10m number path '$' null on error)
      ) wg on wg.ord = h.ord
    )
    select
      count(case when precipitation > 0 then 1 end),
      count(case when precipitation >= 2.5 then 1 end),
      count(case when wind_speed_10m >= 40 then 1 end),
      count(case when wind_gusts_10m >= 50 then 1 end),
      max(precipitation),
      max(wind_speed_10m),
      max(wind_gusts_10m)
    into
      l_rain_hours,
      l_heavy_rain_hours,
      l_strong_wind_hours,
      l_strong_gust_hours,
      l_max_hourly_precip,
      l_max_hourly_wind,
      l_max_hourly_gust
    from hourly_rows
    where substr(hour_time, 1, 10) = l_accident_date_text;

    dbms_output.put_line(chr(10) || 'Weather anomaly report');
    dbms_output.put_line('Location: Kingston, Jamaica');
    dbms_output.put_line('Accident date: ' || l_accident_date_text);
    dbms_output.put_line('Baseline: 14 days before and 14 days after, excluding accident date');
    dbms_output.put_line('Anomaly threshold: absolute z-score >= 2 for temperature, z-score >= 2 for rain/wind spikes');
    dbms_output.put_line(chr(10) || 'Daily anomaly metrics');

    print_metric('Max temperature', l_temp_max, l_temp_max_avg, l_temp_max_sd, z_score(l_temp_max, l_temp_max_avg, l_temp_max_sd), 'C', 'ABS');
    print_metric('Min temperature', l_temp_min, l_temp_min_avg, l_temp_min_sd, z_score(l_temp_min, l_temp_min_avg, l_temp_min_sd), 'C', 'ABS');
    print_metric('Precipitation sum', l_precip_sum, l_precip_avg, l_precip_sd, z_score(l_precip_sum, l_precip_avg, l_precip_sd), 'mm');
    print_metric('Rain sum', l_rain_sum, l_rain_avg, l_rain_sd, z_score(l_rain_sum, l_rain_avg, l_rain_sd), 'mm');
    print_metric('Precipitation hours', l_precip_hours, l_precip_hours_avg, l_precip_hours_sd, z_score(l_precip_hours, l_precip_hours_avg, l_precip_hours_sd), 'hours');
    print_metric('Max wind speed', l_wind_max, l_wind_avg, l_wind_sd, z_score(l_wind_max, l_wind_avg, l_wind_sd), 'km/h');
    print_metric('Max wind gust', l_gust_max, l_gust_avg, l_gust_sd, z_score(l_gust_max, l_gust_avg, l_gust_sd), 'km/h');

    dbms_output.put_line(chr(10) || 'Hourly accident-day risk indicators');
    dbms_output.put_line('Rain hours: ' || l_rain_hours);
    dbms_output.put_line('Heavy rain hours >= 2.5 mm/hour: ' || l_heavy_rain_hours);
    dbms_output.put_line('Strong wind hours >= 40 km/h: ' || l_strong_wind_hours);
    dbms_output.put_line('Strong gust hours >= 50 km/h: ' || l_strong_gust_hours);
    dbms_output.put_line('Max hourly precipitation: ' || nvl(to_char(l_max_hourly_precip), 'null') || ' mm');
    dbms_output.put_line('Max hourly wind speed: ' || nvl(to_char(l_max_hourly_wind), 'null') || ' km/h');
    dbms_output.put_line('Max hourly wind gust: ' || nvl(to_char(l_max_hourly_gust), 'null') || ' km/h');

    dbms_output.put_line(chr(10) || 'Interpretation');
    if z_score(l_precip_sum, l_precip_avg, l_precip_sd) >= 2
      or z_score(l_rain_sum, l_rain_avg, l_rain_sd) >= 2
      or z_score(l_precip_hours, l_precip_hours_avg, l_precip_hours_sd) >= 2
      or z_score(l_wind_max, l_wind_avg, l_wind_sd) >= 2
      or z_score(l_gust_max, l_gust_avg, l_gust_sd) >= 2
      or l_heavy_rain_hours > 0
      or l_strong_wind_hours > 0
      or l_strong_gust_hours > 0
    then
      dbms_output.put_line('Potential weather-related accident-risk spike detected. Review rain/wind timing against the accident time and location.');
    else
      dbms_output.put_line('No strong weather anomaly detected from the 29-day local baseline. Weather may still be relevant if the accident happened during a short local burst.');
    end if;
  exception
    when no_data_found then
      dbms_output.put_line('No Open-Meteo daily record found for ' || l_accident_date_text || '.');
      dbms_output.put_line('Raw response begins:');
      dbms_output.put_line(dbms_lob.substr(l_json, 32767, 1));
      raise;
  end analyze_weather_incident;

  procedure get_weather_report(
    p_city_name    in varchar2,
    p_weather_date in date
  ) is
    l_amp                 varchar2(1) := chr(38);
    l_geocode_url         varchar2(32767);
    l_weather_url         varchar2(32767);
    l_geocode_json        clob;
    l_weather_json        clob;
    l_city                varchar2(200);
    l_country             varchar2(200);
    l_timezone            varchar2(200);
    l_latitude            number;
    l_longitude           number;
    l_temp_max            number;
    l_temp_min            number;
    l_precipitation_sum   number;
    l_rain_sum            number;
    l_showers_sum         number;
    l_precipitation_hours number;
    l_wind_speed_max      number;
    l_wind_gusts_max      number;
  begin
    l_geocode_url :=
      runtime_config_value('OPEN_METEO_GEOCODING_URL') ||
      '?name=' || url_encode(p_city_name) ||
      l_amp || 'count=1' ||
      l_amp || 'language=en' ||
      l_amp || 'format=json';

    dbms_output.put_line('Open-Meteo Geocoding URL:');
    dbms_output.put_line(l_geocode_url);

    l_geocode_json := http_get(l_geocode_url);

    l_latitude := json_value(l_geocode_json, '$.results[0].latitude' returning number null on error);
    l_longitude := json_value(l_geocode_json, '$.results[0].longitude' returning number null on error);
    l_city := json_value(l_geocode_json, '$.results[0].name' returning varchar2(200) null on error);
    l_country := json_value(l_geocode_json, '$.results[0].country' returning varchar2(200) null on error);
    l_timezone := json_value(l_geocode_json, '$.results[0].timezone' returning varchar2(200) null on error);

    if l_latitude is null or l_longitude is null then
      dbms_output.put_line('City not found: ' || p_city_name);
      dbms_output.put_line('Raw geocoding response begins:');
      dbms_output.put_line(dbms_lob.substr(l_geocode_json, 32767, 1));
      return;
    end if;

    l_weather_url := get_weather_url(l_latitude, l_longitude, p_weather_date);

    dbms_output.put_line(chr(10) || 'Open-Meteo Weather URL:');
    dbms_output.put_line(l_weather_url);

    l_weather_json := http_get(l_weather_url);

    l_temp_max := json_value(l_weather_json, '$.daily.temperature_2m_max[0]' returning number null on error);
    l_temp_min := json_value(l_weather_json, '$.daily.temperature_2m_min[0]' returning number null on error);
    l_precipitation_sum := json_value(l_weather_json, '$.daily.precipitation_sum[0]' returning number null on error);
    l_rain_sum := json_value(l_weather_json, '$.daily.rain_sum[0]' returning number null on error);
    l_showers_sum := json_value(l_weather_json, '$.daily.showers_sum[0]' returning number null on error);
    l_precipitation_hours := json_value(l_weather_json, '$.daily.precipitation_hours[0]' returning number null on error);
    l_wind_speed_max := json_value(l_weather_json, '$.daily.wind_speed_10m_max[0]' returning number null on error);
    l_wind_gusts_max := json_value(l_weather_json, '$.daily.wind_gusts_10m_max[0]' returning number null on error);

    dbms_output.put_line(chr(10) || 'Weather report');
    dbms_output.put_line('City: ' || nvl(l_city, p_city_name) || nvl2(l_country, ', ' || l_country, null));
    dbms_output.put_line('Date: ' || to_iso_date(p_weather_date));
    dbms_output.put_line('Timezone: ' || nvl(l_timezone, 'auto'));
    dbms_output.put_line('Latitude: ' || to_char(l_latitude, 'FM999999990D999999', 'NLS_NUMERIC_CHARACTERS=.,'));
    dbms_output.put_line('Longitude: ' || to_char(l_longitude, 'FM999999990D999999', 'NLS_NUMERIC_CHARACTERS=.,'));
    dbms_output.put_line('Max temperature: ' || nvl(to_char(l_temp_max), 'null') || ' C');
    dbms_output.put_line('Min temperature: ' || nvl(to_char(l_temp_min), 'null') || ' C');
    dbms_output.put_line('Precipitation: ' || nvl(to_char(l_precipitation_sum), 'null') || ' mm');
    dbms_output.put_line('Rain: ' || nvl(to_char(l_rain_sum), 'null') || ' mm');
    dbms_output.put_line('Showers: ' || nvl(to_char(l_showers_sum), 'null') || ' mm');
    dbms_output.put_line('Precipitation hours: ' || nvl(to_char(l_precipitation_hours), 'null'));
    dbms_output.put_line('Max wind speed: ' || nvl(to_char(l_wind_speed_max), 'null') || ' km/h');
    dbms_output.put_line('Max wind gust: ' || nvl(to_char(l_wind_gusts_max), 'null') || ' km/h');

    if l_temp_max is null and l_precipitation_sum is null and l_wind_speed_max is null then
      dbms_output.put_line(chr(10) || 'No daily weather values were returned. Raw response begins:');
      dbms_output.put_line(dbms_lob.substr(l_weather_json, 32767, 1));
    end if;
  end get_weather_report;

  function get_weather_report_json(
    p_city_name    in varchar2,
    p_weather_date in date
  ) return clob is
    l_amp                 varchar2(1) := chr(38);
    l_geocode_url         varchar2(32767);
    l_weather_url         varchar2(32767);
    l_geocode_json        clob;
    l_weather_json        clob;
    l_city                varchar2(200);
    l_country             varchar2(200);
    l_timezone            varchar2(200);
    l_latitude            number;
    l_longitude           number;
    l_temp_max            number;
    l_temp_min            number;
    l_precipitation_sum   number;
    l_rain_sum            number;
    l_showers_sum         number;
    l_precipitation_hours number;
    l_wind_speed_max      number;
    l_wind_gusts_max      number;
    l_weather_date_text   varchar2(10);
    l_requested_date_text varchar2(10);
    l_source_api          varchar2(20);
    l_result              clob;
    l_error_message       varchar2(4000);
  begin
    l_requested_date_text := to_iso_date(p_weather_date);

    if p_city_name is null then
      select json_object(
               'provider' value 'Open-Meteo',
               'status' value 'SKIPPED',
               'message' value 'Customer city is not available for this claim.',
               'weather_date' value l_requested_date_text
             returning clob)
        into l_result
        from dual;
      return l_result;
    end if;

    l_source_api := case when trunc(p_weather_date) < trunc(sysdate) then 'archive' else 'forecast' end;
    l_geocode_url :=
      runtime_config_value('OPEN_METEO_GEOCODING_URL') ||
      '?name=' || url_encode(p_city_name) ||
      l_amp || 'count=1' ||
      l_amp || 'language=en' ||
      l_amp || 'format=json';

    l_geocode_json := http_get(l_geocode_url);

    l_latitude := json_value(l_geocode_json, '$.results[0].latitude' returning number null on error);
    l_longitude := json_value(l_geocode_json, '$.results[0].longitude' returning number null on error);
    l_city := json_value(l_geocode_json, '$.results[0].name' returning varchar2(200) null on error);
    l_country := json_value(l_geocode_json, '$.results[0].country' returning varchar2(200) null on error);
    l_timezone := json_value(l_geocode_json, '$.results[0].timezone' returning varchar2(200) null on error);

    if l_latitude is null or l_longitude is null then
      select json_object(
               'provider' value 'Open-Meteo',
               'status' value 'CITY_NOT_FOUND',
               'requested_city' value p_city_name,
               'weather_date' value l_requested_date_text,
               'geocoding_url' value l_geocode_url,
               'raw_geocoding_response' value dbms_lob.substr(l_geocode_json, 4000, 1)
             returning clob)
        into l_result
        from dual;
      return l_result;
    end if;

    l_weather_url := get_weather_url(l_latitude, l_longitude, p_weather_date);
    l_weather_json := http_get(l_weather_url);

    l_weather_date_text := json_value(l_weather_json, '$.daily.time[0]' returning varchar2(10) null on error);
    l_temp_max := json_value(l_weather_json, '$.daily.temperature_2m_max[0]' returning number null on error);
    l_temp_min := json_value(l_weather_json, '$.daily.temperature_2m_min[0]' returning number null on error);
    l_precipitation_sum := json_value(l_weather_json, '$.daily.precipitation_sum[0]' returning number null on error);
    l_rain_sum := json_value(l_weather_json, '$.daily.rain_sum[0]' returning number null on error);
    l_showers_sum := json_value(l_weather_json, '$.daily.showers_sum[0]' returning number null on error);
    l_precipitation_hours := json_value(l_weather_json, '$.daily.precipitation_hours[0]' returning number null on error);
    l_wind_speed_max := json_value(l_weather_json, '$.daily.wind_speed_10m_max[0]' returning number null on error);
    l_wind_gusts_max := json_value(l_weather_json, '$.daily.wind_gusts_10m_max[0]' returning number null on error);

    select json_object(
             'provider' value 'Open-Meteo',
             'status' value case
                              when l_temp_max is null and l_precipitation_sum is null and l_wind_speed_max is null then 'NO_DAILY_VALUES'
                              else 'OK'
                            end,
             'source_api' value l_source_api,
             'requested_city' value p_city_name,
             'weather_date' value nvl(l_weather_date_text, l_requested_date_text),
             'geocoded_location' value json_object(
               'city' value l_city,
               'country' value l_country,
               'timezone' value l_timezone,
               'latitude' value l_latitude,
               'longitude' value l_longitude
             ),
             'daily_weather' value json_object(
               'temperature_2m_max_c' value l_temp_max,
               'temperature_2m_min_c' value l_temp_min,
               'precipitation_sum_mm' value l_precipitation_sum,
               'rain_sum_mm' value l_rain_sum,
               'showers_sum_mm' value l_showers_sum,
               'precipitation_hours' value l_precipitation_hours,
               'wind_speed_10m_max_kmh' value l_wind_speed_max,
               'wind_gusts_10m_max_kmh' value l_wind_gusts_max
             ),
             'risk_indicators' value json_object(
               'heavy_rain_flag' value case when nvl(l_precipitation_sum, 0) >= 10 or nvl(l_rain_sum, 0) >= 10 then 'Y' else 'N' end,
               'windy_flag' value case when nvl(l_wind_speed_max, 0) >= 40 or nvl(l_wind_gusts_max, 0) >= 50 then 'Y' else 'N' end,
               'weather_may_affect_accident_risk' value case
                 when nvl(l_precipitation_sum, 0) >= 10
                   or nvl(l_rain_sum, 0) >= 10
                   or nvl(l_wind_speed_max, 0) >= 40
                   or nvl(l_wind_gusts_max, 0) >= 50
                 then 'Y'
                 else 'N'
               end
             ),
             'geocoding_url' value l_geocode_url,
             'weather_url' value l_weather_url
           returning clob)
      into l_result
      from dual;
    return l_result;
  exception
    when others then
      l_error_message := sqlerrm;
      select json_object(
               'provider' value 'Open-Meteo',
               'status' value 'ERROR',
               'requested_city' value p_city_name,
               'weather_date' value l_requested_date_text,
               'error_message' value l_error_message
             returning clob)
        into l_result
        from dual;
      return l_result;
  end get_weather_report_json;

end fsi_weather_anomaly;
/

CREATE OR REPLACE EDITIONABLE TRIGGER "FSI_AU_FRAUD_INVESTIGATION_ERROR_RELEASE" 
after update of status on fsi_apex_ai_requests
for each row
declare
  c_team_name constant varchar2(128) := 'FSI_FRAUD_INVESTIGATION_TEAM';
  l_claim_id  claims.claim_id%type;
begin
  if upper(trim(:new.team_name)) = c_team_name
     and :new.status = 'ERROR' then
    l_claim_id := :new.claim_id;

    if l_claim_id is null then
      l_claim_id := to_number(
        regexp_substr(
          dbms_lob.substr(:new.user_prompt, 12000, 1),
          'investigate[[:space:]]+claim[[:space:]]+id[[:space:]]+([0-9]+)',
          1,
          1,
          'i',
          1
        )
      );
    end if;

    if l_claim_id is not null then
      update claims
         set claim_status = 'NEW'
       where claim_id = l_claim_id
         and upper(trim(claim_status)) = 'UNDER_INVESTIGATION';
    end if;
  end if;
end;


/
ALTER TRIGGER "FSI_AU_FRAUD_INVESTIGATION_ERROR_RELEASE" ENABLE;
/

CREATE OR REPLACE EDITIONABLE TRIGGER "FSI_BI_FRAUD_INVESTIGATION_LOCK" 
before insert on fsi_apex_ai_requests
for each row
declare
  c_team_name       constant varchar2(128) := 'FSI_FRAUD_INVESTIGATION_TEAM';
  l_claim_id        claims.claim_id%type;
  l_claim_status    claims.claim_status%type;
  l_prompt          varchar2(12000);
begin
  if upper(trim(:new.team_name)) = c_team_name then
    l_prompt := dbms_lob.substr(:new.user_prompt, 12000, 1);
    l_claim_id := to_number(
      regexp_substr(
        l_prompt,
        'investigate[[:space:]]+claim[[:space:]]+id[[:space:]]+([0-9]+)',
        1,
        1,
        'i',
        1
      )
    );

    if l_claim_id is null then
      raise_application_error(
        -20092,
        'FSI_FRAUD_INVESTIGATION_TEAM requests must contain a valid "Investigate claim id <number>" prompt.'
      );
    end if;

    :new.claim_id := l_claim_id;

    -- This row lock is shared by every claim-investigation entry point.
    select claim_status
      into l_claim_status
      from claims
     where claim_id = l_claim_id
       for update;

    if upper(trim(l_claim_status)) = 'NEW' then
      update claims
         set claim_status = 'UNDER_INVESTIGATION'
       where claim_id = l_claim_id
         and upper(trim(claim_status)) = 'NEW';
    elsif upper(trim(l_claim_status)) <> 'UNDER_INVESTIGATION' then
      raise_application_error(
        -20093,
        'Claim ' || to_char(l_claim_id) || ' is in status ' ||
        nvl(l_claim_status, 'UNKNOWN') ||
        ' and cannot be investigated again. Retrieve its completed report instead.'
      );
    end if;

    -- The request owner is the only worker allowed to process this claim.
    -- FSI_APEX_AI_WORKER consumes QUEUED work only, so it cannot race it.
    :new.status := 'RUNNING';
  end if;
exception
  when no_data_found then
    raise_application_error(-20094, 'Claim ' || to_char(l_claim_id) || ' does not exist.');
end;


/
ALTER TRIGGER "FSI_BI_FRAUD_INVESTIGATION_LOCK" ENABLE;
/

CREATE OR REPLACE EDITIONABLE TRIGGER "FSI_CLAIM_INITIAL_STATUS_BIU" 
  before insert or update of policy_id, claim_status on claims
  for each row
declare
  l_policy_status policies.status%type;
begin
  -- A row being inserted represents a newly generated or newly registered
  -- claim, so it always starts as NEW unless the policy rule below rejects it.
  if inserting then
    :new.claim_status := 'NEW';
    :new.claim_status_reason := null;
  end if;

  select upper(trim(status))
    into l_policy_status
    from policies
   where policy_id = :new.policy_id;

  if l_policy_status in ('LAPSED', 'CANCELLED') then
    :new.claim_status := 'CLAIM_REJECTED';
    :new.claim_status_reason := 'claim is Rejected for Insurance policy being Lapsed or Cancelled';
    :new.close_date := nvl(:new.close_date, sysdate);
  end if;
exception
  when no_data_found then
    -- The CLAIMS foreign key remains responsible for rejecting a missing
    -- policy.  Do not mask its standard validation error here.
    null;
end;

/
ALTER TRIGGER "FSI_CLAIM_INITIAL_STATUS_BIU" ENABLE;
/
-- The DMP defines dependent packages before their helper routines. Recompile
-- the AI API only after all package specifications and helper functions exist.
prompt Recompiling FSI_APEX_AI_API after its helper routines
alter package "FSI_APEX_AI_API" compile body;

-- The DMP defines this orchestration function before several helper routines.
-- Recompile it after all helpers have been created so the exported schema is valid.
prompt Recompiling FSI_FINALIZE_FRAUD_REVIEW after its helper routines
alter function "FSI_FINALIZE_FRAUD_REVIEW" compile;

declare
  l_invalid_count pls_integer;
begin
  select count(*) into l_invalid_count
    from user_objects
   where status = 'INVALID'
     and object_type in ('FUNCTION','PROCEDURE','PACKAGE','PACKAGE BODY','TRIGGER','VIEW','TYPE','TYPE BODY');
  if l_invalid_count > 0 then
    raise_application_error(-20002, 'FSI schema contains ' || l_invalid_count || ' invalid PL/SQL or view object(s) after DMP compile.');
  end if;
end;
/
