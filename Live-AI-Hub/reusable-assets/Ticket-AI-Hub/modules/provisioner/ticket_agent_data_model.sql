whenever sqlerror exit sql.sqlcode
set define off;
set serveroutput on;

-- =============================================================================
-- TICKET RESPONSE AGENT — ORACLE SQL DATA MODEL
-- Description : Full data model to support the AI Ticket Response Agent, including ticket attachments.
-- Version     : 1.2  (ticket attachment support)
-- Date        : March 2026
-- =============================================================================

-- =============================================================================
-- TICKET RESPONSE AGENT — DROP ALL OBJECTS (safe / idempotent)
-- Description : Drops all views, indexes, triggers, and tables created by
-- ticket_agent_data_model.sql, in the correct dependency order.
-- Uses Oracle 26ai native IF EXISTS clause — no error if the
-- object does not exist.
-- Compatibility: Oracle 26ai and above.
-- Version     : 1.2
-- Date        : April 2026
-- =============================================================================

    -- =============================================================================
    -- 1. ANALYTICS VIEWS
    -- Drops, creates, and documents analytics views used for operational KPIs.
    -- =============================================================================
    DROP VIEW IF EXISTS v_analytics_recategorisation_impact;
    DROP VIEW IF EXISTS v_analytics_agent_kb_version_quality;
    DROP VIEW IF EXISTS v_analytics_escalation_sla;
    DROP VIEW IF EXISTS v_analytics_channel_performance;
    DROP VIEW IF EXISTS v_analytics_pipeline_health;
    DROP VIEW IF EXISTS v_analytics_agent_dispatch_queue;
    DROP VIEW IF EXISTS v_analytics_daily_throughput;
    DROP VIEW IF EXISTS v_analytics_accuracy_by_dept_category;
    DROP VIEW IF EXISTS v_analytics_escalation_by_team_category;
    DROP VIEW IF EXISTS v_analytics_categorisation_quality;
    DROP VIEW IF EXISTS v_analytics_resolution_timings;
    DROP VIEW IF EXISTS v_analytics_accuracy_by_resolution_type;
    DROP VIEW IF EXISTS v_analytics_tickets_by_dept_status_cat;

    -- =============================================================================
    -- 2. REPORTING VIEWS
    -- Drops, creates, and documents reporting views used by dashboards, exports, and APIs.
    -- =============================================================================
    DROP VIEW IF EXISTS v_agent_daily_stats;
    DROP VIEW IF EXISTS v_category_performance;
    DROP VIEW IF EXISTS v_department_ticket_summary;
    DROP VIEW IF EXISTS v_open_escalations;
    DROP VIEW IF EXISTS v_escalation_detail;
    DROP VIEW IF EXISTS v_categorisation_audit;
    DROP VIEW IF EXISTS v_ticket_accuracy_detail;
    DROP VIEW IF EXISTS v_ticket_status_timeline;
    DROP VIEW IF EXISTS v_ticket_overview;

    -- =============================================================================
    -- 3. INDEXES — ANSWERS_DELIVERED
    -- Drops or creates indexes for the related data model objects.
    -- =============================================================================
    DROP INDEX IF EXISTS idx_ad_delivered_at;
    DROP INDEX IF EXISTS idx_ad_status;
    DROP INDEX IF EXISTS idx_ad_department_id;
    DROP INDEX IF EXISTS idx_ad_category_id;
    DROP INDEX IF EXISTS idx_ad_ticket_id;

    -- =============================================================================
    -- 4. INDEXES — ESCALATIONS_HITL
    -- Drops or creates indexes for the related data model objects.
    -- =============================================================================
    DROP INDEX IF EXISTS idx_hitl_status;
    DROP INDEX IF EXISTS idx_hitl_category_id;
    DROP INDEX IF EXISTS idx_hitl_routing_rule_id;
    DROP INDEX IF EXISTS idx_hitl_department_id;
    DROP INDEX IF EXISTS idx_hitl_escalation_id;
    DROP INDEX IF EXISTS idx_hitl_ticket_id;

    -- =============================================================================
    -- 5. INDEXES — CATEGORIES
    -- Drops or creates indexes for the related data model objects.
    -- =============================================================================
    DROP INDEX IF EXISTS idx_cat_kb_cluster;
    DROP INDEX IF EXISTS idx_cat_parent_id;
    DROP INDEX IF EXISTS idx_cat_department_id;

    -- =============================================================================
    -- 6. INDEXES — ESCALATIONS
    -- Drops or creates indexes for the related data model objects.
    -- =============================================================================
    DROP INDEX IF EXISTS idx_esc_category_id;
    DROP INDEX IF EXISTS idx_esc_routing_rule_id;
    DROP INDEX IF EXISTS idx_esc_notified_at;
    DROP INDEX IF EXISTS idx_esc_department_id;
    DROP INDEX IF EXISTS idx_esc_ticket_id;

    -- =============================================================================
    -- 7. INDEXES — ROUTING_RULES
    -- Drops or creates indexes for the related data model objects.
    -- =============================================================================
    DROP INDEX IF EXISTS idx_rr_rule_notes_vec;
    DROP INDEX IF EXISTS idx_rr_active_eff;
    DROP INDEX IF EXISTS idx_rr_department_id;
    DROP INDEX IF EXISTS idx_rr_category_id;

    -- =============================================================================
    -- 8. INDEXES — ACCURACY_SCORES
    -- Drops or creates indexes for the related data model objects.
    -- =============================================================================
    DROP INDEX IF EXISTS idx_as_judge_model;
    DROP INDEX IF EXISTS idx_as_composite;
    DROP INDEX IF EXISTS idx_as_ticket_id;

    -- =============================================================================
    -- 9. INDEXES — TICKET_CATEGORISATION_LOG
    -- Drops or creates indexes for the related data model objects.
    -- =============================================================================
    DROP INDEX IF EXISTS idx_tcl_suggested_cat;
    DROP INDEX IF EXISTS idx_tcl_ticket_id;

    -- =============================================================================
    -- 10. INDEXES — TICKET_ATTACHMENTS
    -- Drops or creates indexes for the related data model objects.
    -- =============================================================================
    DROP INDEX IF EXISTS idx_ta_process_req;
    DROP INDEX IF EXISTS idx_ta_status;
    DROP INDEX IF EXISTS idx_ta_ticket_id;

    -- =============================================================================
    -- 11. INDEXES — TICKET_STATUS_HISTORY
    -- Drops or creates indexes for the related data model objects.
    -- =============================================================================
    DROP INDEX IF EXISTS idx_tsh_to_status;
    DROP INDEX IF EXISTS idx_tsh_created_at;
    DROP INDEX IF EXISTS idx_tsh_ticket_id;

    -- =============================================================================
    -- 12. INDEXES — TICKETS
    -- Drops or creates indexes for the related data model objects.
    -- =============================================================================
    DROP INDEX IF EXISTS idx_tickets_ext_ref;
    DROP INDEX IF EXISTS idx_tickets_worker_claim;
    DROP INDEX IF EXISTS idx_tickets_dispatch_queue;
    DROP INDEX IF EXISTS idx_tickets_accuracy;
    DROP INDEX IF EXISTS idx_tickets_ts_received;
    DROP INDEX IF EXISTS idx_tickets_source;
    DROP INDEX IF EXISTS idx_tickets_assigned_team;
    DROP INDEX IF EXISTS idx_tickets_department_id;
    DROP INDEX IF EXISTS idx_tickets_category_id;
    DROP INDEX IF EXISTS idx_tickets_status;
    DROP INDEX IF EXISTS idx_tickets_aar;

    -- =============================================================================
    -- 13. TRIGGERS
    -- Drops or creates triggers for timestamp and lifecycle maintenance.
    -- =============================================================================
    DROP TRIGGER IF EXISTS trg_routing_rules_updated_at;
    DROP TRIGGER IF EXISTS trg_ticket_attachments_updated;
    DROP TRIGGER IF EXISTS trg_tickets_timestamp_updated;
    DROP TRIGGER IF EXISTS trg_categories_updated_at;
    DROP TRIGGER IF EXISTS trg_departments_updated_at;

    -- =============================================================================
    -- 14. TABLES — child tables first (FK dependency order)
    -- Drops or creates tables in dependency-safe order.
    -- =============================================================================
    DROP TABLE IF EXISTS answers_delivered         PURGE;
    DROP TABLE IF EXISTS escalations_hitl          PURGE;
    DROP TABLE IF EXISTS escalations               PURGE;
    DROP TABLE IF EXISTS routing_rules             PURGE;
    DROP TABLE IF EXISTS accuracy_scores           PURGE;
    DROP TABLE IF EXISTS ticket_categorisation_log PURGE;
    DROP TABLE IF EXISTS ticket_status_history     PURGE;
    DROP TABLE IF EXISTS ticket_attachments          PURGE;
    DROP TABLE IF EXISTS tickets                   PURGE;
    DROP TABLE IF EXISTS categories                PURGE;
    DROP TABLE IF EXISTS departments               PURGE;


-- =============================================================================
-- TICKET RESPONSE AGENT — TABLES
-- Compatibility: Oracle 26ai and above.
-- Version     : 1.2
-- Date        : April 2026
-- =============================================================================

    -- =============================================================================
    -- 1. DEPARTMENTS
    -- Defines the DEPARTMENTS table, constraints, and related metadata.
    -- =============================================================================
    CREATE TABLE departments (
        department_id     NUMBER(10)      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        department_code   VARCHAR2(30)    NOT NULL,
        department_name   VARCHAR2(100)   NOT NULL,
        description       VARCHAR2(500),
        escalation_email  VARCHAR2(255),
        escalation_slack  VARCHAR2(255),
        kb_version        VARCHAR2(50),
        is_active         CHAR(1)         DEFAULT 'Y' NOT NULL,
        created_at        TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
        updated_at        TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
        CONSTRAINT uq_dept_code  UNIQUE (department_code),
        CONSTRAINT ck_dept_active CHECK (is_active IN ('Y', 'N'))
    );

    COMMENT ON TABLE  departments                  IS 'Master list of organisational departments that own ticket categories and act as escalation targets. Examples: IT Support, Customer Service, Finance, HR, Legal.';
    COMMENT ON COLUMN departments.department_id    IS 'Surrogate primary key, auto-generated sequence.';
    COMMENT ON COLUMN departments.department_code  IS 'Short unique code used in routing rules and integrations. Example: IT_SUPPORT, CUST_SVC, FINANCE.';
    COMMENT ON COLUMN departments.department_name  IS 'Human-readable full department name.';
    COMMENT ON COLUMN departments.description      IS 'Free-text description of what this department handles.';
    COMMENT ON COLUMN departments.escalation_email IS 'Email address used by the Notification Service to alert this department on escalation.';
    COMMENT ON COLUMN departments.escalation_slack IS 'Slack channel or webhook URL for escalation notifications.';
    COMMENT ON COLUMN departments.is_active        IS 'Soft-delete flag. Y=active and available for routing; N=inactive, excluded from routing rules.';
    COMMENT ON COLUMN departments.created_at       IS 'Timestamp when the department record was created.';
    COMMENT ON COLUMN departments.updated_at       IS 'Timestamp of the last update to this record.';
    COMMENT ON COLUMN departments.kb_version       IS 'Knowledge Base version identifier active for this department at ticket creation time (e.g. KB-2026-04). Stamped onto TICKETS.kb_version when a ticket is created for this department. Updated manually when the KB is refreshed.';

    CREATE OR REPLACE TRIGGER trg_departments_updated_at
    BEFORE UPDATE ON departments
    FOR EACH ROW
    BEGIN
        :NEW.updated_at := SYSTIMESTAMP;
    END;
    /
    -- =============================================================================
    -- CATEGORIES
    -- Defines the CATEGORIES table, constraints, and related metadata.
    -- =============================================================================
    CREATE TABLE categories (
        category_id         NUMBER(10)      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        department_id       NUMBER(10)      NOT NULL,
        category_code       VARCHAR2(50)    NOT NULL,
        category_name       VARCHAR2(150)   NOT NULL,
        description         VARCHAR2(4000),
        parent_category_id  NUMBER(10),
        kb_cluster_tag      VARCHAR2(100),
        accuracy_threshold  NUMBER(5,4)     DEFAULT 0.75 NOT NULL,
        notification_method VARCHAR2(30),
        escalation_email    VARCHAR2(255),
        escalation_slack    VARCHAR2(255),
        escalation_teams    VARCHAR2(255),
        routing_rule_evaluation_logic VARCHAR2(4000),
        auto_route          CHAR(1)         DEFAULT 'Y'  NOT NULL,
        auto_answer         CHAR(1)         DEFAULT 'Y'  NOT NULL,
        auto_answer_auto_route CHAR(1)      DEFAULT 'N'  NOT NULL,
        additional_metadata JSON (OBJECT),
        is_active           CHAR(1)         DEFAULT 'Y'  NOT NULL,
        created_at          TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
        updated_at          TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
        CONSTRAINT uq_cat_code        UNIQUE  (category_code),
        CONSTRAINT fk_cat_department  FOREIGN KEY (department_id)      REFERENCES departments(department_id),
        CONSTRAINT fk_cat_parent      FOREIGN KEY (parent_category_id) REFERENCES categories(category_id),
        CONSTRAINT ck_cat_active      CHECK (is_active   IN ('Y', 'N')),
        CONSTRAINT ck_cat_notif_meth  CHECK (notification_method IN ('EMAIL', 'SLACK', 'TEAMS', 'API')),
        CONSTRAINT ck_cat_threshold   CHECK (accuracy_threshold BETWEEN 0 AND 1),
        CONSTRAINT ck_cat_auto_route  CHECK (auto_route  IN ('Y', 'N')),
        CONSTRAINT ck_cat_auto_answer CHECK (auto_answer IN ('Y', 'N')),
        CONSTRAINT ck_cat_auto_answer_auto_route CHECK (auto_answer_auto_route IN ('Y', 'N')),
        CONSTRAINT ck_cat_aar_requires_both CHECK (
            auto_answer_auto_route = 'N'
            OR (auto_answer = 'Y' AND auto_route = 'Y')
        )
    );

    COMMENT ON TABLE  categories                        IS 'Hierarchical taxonomy of ticket categories, each belonging to a department. Used by the Categorisation Module to validate submitted categories and suggest alternatives.';
    COMMENT ON COLUMN categories.category_id            IS 'Surrogate primary key, auto-generated sequence.';
    COMMENT ON COLUMN categories.department_id          IS 'FK to DEPARTMENTS. Identifies which department owns and handles tickets of this category.';
    COMMENT ON COLUMN categories.category_code          IS 'Short unique code for the category. Example: PWD_RESET, BILLING_DISPUTE.';
    COMMENT ON COLUMN categories.category_name          IS 'Human-readable category label shown in the ticketing UI.';
    COMMENT ON COLUMN categories.description            IS 'Detailed description of what types of issues this category covers, used by the LLM categorisation prompt.';
    COMMENT ON COLUMN categories.parent_category_id     IS 'Self-referencing FK enabling a two-level hierarchy (parent → child). NULL for top-level categories.';
    COMMENT ON COLUMN categories.kb_cluster_tag         IS 'Tag matching the Knowledge Base topic cluster associated with this category, used by the Categorisation Module semantic search.';
    COMMENT ON COLUMN categories.accuracy_threshold     IS 'Configurable scoring threshold for this category. Default 0.75. If accuracy_score < accuracy_threshold the ticket is escalated.';
    COMMENT ON COLUMN categories.escalation_email       IS 'Email address used to notify the responsible team when a ticket in this category is escalated.';
    COMMENT ON COLUMN categories.escalation_slack       IS 'Slack channel or webhook URL used to notify the responsible team when a ticket in this category is escalated.';
    COMMENT ON COLUMN categories.escalation_teams       IS 'Microsoft Teams channel ID or webhook URL used to notify the responsible team when a ticket in this category is escalated.';
    COMMENT ON COLUMN categories.routing_rule_evaluation_logic IS 'Category-specific prompt and scoring guidance used by ESCALATE_TICKET_TASK when evaluating the routing rules returned by semantic routing search. This text is not embedded and is not used to build routing-rule vectors.';
    COMMENT ON COLUMN categories.auto_route             IS 'Controls automatic routing on escalation. Y=route the ticket automatically to the escalation target when the accuracy score falls below the threshold; N=require manual routing intervention.';
    COMMENT ON COLUMN categories.auto_answer            IS 'Controls automatic answer generation. Y=use the Knowledge Base to generate and send an answer automatically; N=hold the ticket for a human agent to respond.';
    COMMENT ON COLUMN categories.auto_answer_auto_route IS 'Special category policy. Y=generate and deliver an automated answer and also route/escalate the ticket by routing rule or category fallback, then close the ticket. Requires auto_answer=Y and auto_route=Y.';
    COMMENT ON COLUMN categories.additional_metadata    IS 'Free-form JSON object payload for category-specific configuration consumed by downstream agent tools or integrations. Used as a flex column in JSON Relational Duality Views.';
    COMMENT ON COLUMN categories.is_active              IS 'Soft-delete flag. Y=available for agent categorisation and routing; N=retired category.';
    COMMENT ON COLUMN categories.created_at             IS 'Timestamp when the category was created.';
    COMMENT ON COLUMN categories.updated_at             IS 'Timestamp of the last update.';
    COMMENT ON COLUMN categories.notification_method    IS 'Preferred notification channel for escalations in this category. Values: EMAIL | SLACK | TEAMS | API. NULL means no channel override; the escalation engine falls back to the department default.';

    CREATE OR REPLACE TRIGGER trg_categories_updated_at
    BEFORE UPDATE ON categories
    FOR EACH ROW
    BEGIN
        :NEW.updated_at := SYSTIMESTAMP;
    END;
    /
    -- =============================================================================
    -- TICKETS
    -- Defines the TICKETS table, constraints, and related metadata.
    -- =============================================================================
    CREATE TABLE tickets (
        ticket_id           VARCHAR2(36)    DEFAULT SYS_GUID() PRIMARY KEY,
        source              VARCHAR2(20)    NOT NULL,
        external_ref        VARCHAR2(200),
        department_id       NUMBER(10),
        subject             VARCHAR2(500)   NOT NULL,
        body                CLOB            NOT NULL,
        submitted_category  VARCHAR2(150),
        category_id         NUMBER(10),
        category_source     VARCHAR2(20)    DEFAULT 'SUBMITTER' NOT NULL,
        status              VARCHAR2(20)    DEFAULT 'RECEIVED'  NOT NULL,
        priority            VARCHAR2(10)    DEFAULT 'MEDIUM'    NOT NULL,
        submitter_email     VARCHAR2(255),
        submitter_name      VARCHAR2(200),
        accuracy_score      NUMBER(5,4),
        accuracy_threshold  NUMBER(5,4)     DEFAULT 0.75 NOT NULL,
        assigned_team_id    NUMBER(10),
        generated_answer    CLOB,
        suggested_answer    CLOB,
        resolution_notes    CLOB,
        kb_version          VARCHAR2(50),
        auto_answer  CHAR(1)  DEFAULT 'Y' NOT NULL,
        auto_route   CHAR(1)  DEFAULT 'Y' NOT NULL,
        auto_answer_auto_route CHAR(1) DEFAULT 'N' NOT NULL,
        process_attachments CHAR(1) DEFAULT 'N' NOT NULL,
        origin_ticket_id VARCHAR2(36),
        conversation_id  VARCHAR2(36),
        job_error VARCHAR2(4000),
        agent_retry_count NUMBER(5) DEFAULT 0 NOT NULL,
        agent_next_retry_at TIMESTAMP,
        agent_last_retry_at TIMESTAMP,
        agent_claim_id VARCHAR2(36),
        agent_claimed_by VARCHAR2(128),
        agent_claimed_at TIMESTAMP,
        agent_claim_expires_at TIMESTAMP,
        agent_run_started_at TIMESTAMP,
        agent_run_completed_at TIMESTAMP,
        timestamp_received  TIMESTAMP       NOT NULL,
        timestamp_updated   TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
        timestamp_resolved  TIMESTAMP,
        created_at          TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
        CONSTRAINT fk_tkt_category   FOREIGN KEY (category_id)      REFERENCES categories(category_id),
        CONSTRAINT fk_tkt_department FOREIGN KEY (department_id)    REFERENCES departments(department_id),
        CONSTRAINT fk_tkt_team       FOREIGN KEY (assigned_team_id) REFERENCES departments(department_id),
        CONSTRAINT ck_tkt_source     CHECK (source IN ('EMAIL','TICKETING_SYSTEM','API','CHAT')),
        CONSTRAINT ck_tkt_cat_source CHECK (category_source IN ('SUBMITTER', 'AGENT_SUGGESTED', 'HUMAN_OVERRIDE')),
        CONSTRAINT ck_tkt_status     CHECK (status IN ('RECEIVED', 'QUEUED', 'VALIDATING', 'CATEGORIZING', 'ANSWERING', 'SCORING', 'ANSWERED', 'ESCALATED', 'IN_REVIEW', 'RESOLVED', 'FAILED')),
        CONSTRAINT ck_tkt_priority   CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
        CONSTRAINT ck_tkt_score      CHECK (accuracy_score     BETWEEN 0 AND 1),
        CONSTRAINT ck_tkt_threshold  CHECK (accuracy_threshold BETWEEN 0 AND 1),
        CONSTRAINT ck_tkt_auto_answer CHECK (auto_answer IN ('Y', 'N')),
        CONSTRAINT ck_tkt_auto_route  CHECK (auto_route  IN ('Y', 'N')),
        CONSTRAINT ck_tkt_auto_answer_auto_route CHECK (auto_answer_auto_route IN ('Y', 'N')),
        CONSTRAINT ck_tkt_process_attachments CHECK (process_attachments IN ('Y', 'N')),
        CONSTRAINT ck_tkt_aar_requires_both CHECK (
            auto_answer_auto_route = 'N'
            OR (auto_answer = 'Y' AND auto_route = 'Y')
        )
    );

    COMMENT ON TABLE  tickets                        IS 'Core entity representing each incoming service request. Tracks the full lifecycle from RECEIVED through to ANSWERED, RESOLVED or FAILED. The generated_answer field contains the KB-grounded answer text including inline KB article references.';
    COMMENT ON COLUMN tickets.ticket_id              IS 'UUID primary key generated via SYS_GUID(). Immutable unique identifier across all integrations.';
    COMMENT ON COLUMN tickets.source                 IS 'Channel through which the ticket arrived. Values: EMAIL | TICKETING_SYSTEM | API | CHAT.';
    COMMENT ON COLUMN tickets.external_ref           IS 'Reference ID in the originating system (e.g. Zendesk ticket ID, Jira key, email message-ID).';
    COMMENT ON COLUMN tickets.department_id          IS 'FK to DEPARTMENTS. Resolved from the ticket category; identifies the owning department.';
    COMMENT ON COLUMN tickets.subject                IS 'Subject line of the ticket or email. Max 500 chars.';
    COMMENT ON COLUMN tickets.body                   IS 'Full text of the ticket message body stored as CLOB. Must be non-empty; empty body triggers FAILED status.';
    COMMENT ON COLUMN tickets.submitted_category     IS 'Raw category string as submitted by the end user before validation or agent override. Preserved for auditing.';
    COMMENT ON COLUMN tickets.category_id            IS 'FK to CATEGORIES. The validated or agent-suggested category. NULL until categorisation step completes.';
    COMMENT ON COLUMN tickets.category_source        IS 'Who assigned the final category. Values: SUBMITTER=original accepted | AGENT_SUGGESTED=agent overrode original | HUMAN_OVERRIDE=human reviewer changed it.';
    COMMENT ON COLUMN tickets.status                 IS 'Current lifecycle status. State machine: RECEIVED→QUEUED→VALIDATING→CATEGORIZING→ANSWERING→SCORING→ANSWERED or ESCALATED→IN_REVIEW→RESOLVED. Terminal states: ANSWERED, RESOLVED, FAILED.';
    COMMENT ON COLUMN tickets.priority               IS 'Ticket priority. Values: LOW | MEDIUM | HIGH | CRITICAL.';
    COMMENT ON COLUMN tickets.submitter_email        IS 'Email address of the ticket submitter.';
    COMMENT ON COLUMN tickets.submitter_name         IS 'Full name of the ticket submitter.';
    COMMENT ON COLUMN tickets.accuracy_score         IS 'Float 0.0000–1.0000 LLM-as-a-judge quality score. NULL until SCORING step. Compared against accuracy_threshold to decide ANSWERED vs ESCALATED.';
    COMMENT ON COLUMN tickets.accuracy_threshold     IS 'Configurable scoring threshold. Default 0.75. If accuracy_score < threshold the ticket is escalated.';
    COMMENT ON COLUMN tickets.assigned_team_id       IS 'FK to DEPARTMENTS. Populated during escalation; the team that will handle the ticket in IN_REVIEW.';
    COMMENT ON COLUMN tickets.generated_answer       IS 'Full answer text generated by the LLM Answer Engine, grounded on retrieved KB content. Includes inline citations to KB article IDs and section titles within the answer text.';
    COMMENT ON COLUMN tickets.suggested_answer       IS 'Copy of generated_answer surfaced to the assigned team during escalation along with the accuracy_score.';
    COMMENT ON COLUMN tickets.resolution_notes       IS 'Free-text notes added by the human resolver during IN_REVIEW.';
    COMMENT ON COLUMN tickets.kb_version             IS 'Version identifier of the Knowledge Base snapshot used when generating the answer, for reproducibility and audit.';
    COMMENT ON COLUMN tickets.timestamp_received     IS 'Exact timestamp when the ticket was ingested by the agent.';
    COMMENT ON COLUMN tickets.timestamp_updated      IS 'Timestamp of the most recent update to any field on this record.';
    COMMENT ON COLUMN tickets.timestamp_resolved     IS 'Timestamp when the ticket reached a terminal state (ANSWERED, RESOLVED or FAILED).';
    COMMENT ON COLUMN tickets.created_at             IS 'Timestamp when the row was inserted.';
    COMMENT ON COLUMN tickets.auto_answer            IS 'Copied from CATEGORIES.auto_answer at categorisation. Y=generate KB answer automatically; N=hold for human agent.';
    COMMENT ON COLUMN tickets.auto_route             IS 'Copied from CATEGORIES.auto_route at categorisation. Y=auto-route to escalation team; N=require manual routing.';
    COMMENT ON COLUMN tickets.auto_answer_auto_route IS 'Snapshot copied from CATEGORIES.auto_answer_auto_route at categorisation. Y=answer delivery and escalation/routing are both required, and the ticket is closed after both notifications succeed.';
    COMMENT ON COLUMN tickets.process_attachments    IS 'Controls optional attachment LLM processing for this ticket. Y=attachment processor fetches Object Storage objects and invokes the multimodal LLM. N=attachments are stored and sent in payloads but LLM processing is skipped.';
    COMMENT ON COLUMN tickets.origin_ticket_id       IS 'UUID of the original ticket this ticket is related to or follows up on. Populated during ticket creation when a valid ticket UUID is detected in the subject or body, or stamped by the validation agent via ORIGIN_TICKET_TOOL during the VALIDATE_TICKET_TASK step.';
    COMMENT ON COLUMN tickets.conversation_id        IS 'Select AI conversation UUID created via DBMS_CLOUD_AI.CREATE_CONVERSATION() and used when invoking TICKET_RESPONSE_TEAM. Stamped onto the ticket by the async scheduler job after the agent run completes. Used to correlate agent execution logs with the ticket record.';
    COMMENT ON COLUMN tickets.job_error              IS 'Last unhandled exception from the async DBMS_SCHEDULER agent job. Format: SQLERRM + newline + DBMS_UTILITY.FORMAT_ERROR_BACKTRACE. NULL when the job completed without error. Cleared to NULL on sp_reset_ticket. Populated only when status = FAILED via the scheduler path.';
    COMMENT ON COLUMN tickets.agent_retry_count      IS 'Number of retryable transient AI timeout or worker-claim recovery attempts for this ticket. Used to enforce the configured retry budget.';
    COMMENT ON COLUMN tickets.agent_next_retry_at    IS 'Earliest timestamp when a RECEIVED ticket is eligible for worker pickup after a transient AI timeout or claim recovery.';
    COMMENT ON COLUMN tickets.agent_last_retry_at    IS 'Timestamp when the most recent transient AI timeout retry was scheduled.';
    COMMENT ON COLUMN tickets.agent_claim_id         IS 'Unique claim identifier stamped by the scheduler worker instance that acquired the ticket. Cleared only when the ticket is reset to RECEIVED for retry.';
    COMMENT ON COLUMN tickets.agent_claimed_by       IS 'Scheduler worker job name that acquired the ticket, for example TKT_AGENT_WORKER_001.';
    COMMENT ON COLUMN tickets.agent_claimed_at       IS 'Timestamp when a worker atomically moved the ticket from RECEIVED to QUEUED.';
    COMMENT ON COLUMN tickets.agent_claim_expires_at IS 'Operational timeout used by recovery/monitoring to identify stale worker claims. Normal workers never acquire QUEUED tickets.';
    COMMENT ON COLUMN tickets.agent_run_started_at   IS 'Timestamp when the worker started DBMS_CLOUD_AI_AGENT.RUN_TEAM for this ticket.';
    COMMENT ON COLUMN tickets.agent_run_completed_at IS 'Timestamp when the worker completed or failed DBMS_CLOUD_AI_AGENT.RUN_TEAM for this ticket.';

    CREATE OR REPLACE TRIGGER trg_tickets_timestamp_updated
    BEFORE UPDATE ON tickets
    FOR EACH ROW
    BEGIN
        :NEW.timestamp_updated := SYSTIMESTAMP;
    END;
    /

    -- =============================================================================
    -- 4. TICKET_ATTACHMENTS
    -- Defines the TICKET_ATTACHMENTS table, constraints, and related metadata.
    -- =============================================================================
    CREATE TABLE ticket_attachments (
        attachment_id       NUMBER(18) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        ticket_id           VARCHAR2(36) NOT NULL,
        attachment_uri      VARCHAR2(4000) NOT NULL,
        file_name           VARCHAR2(1024),
        file_extension      VARCHAR2(50),
        mime_type           VARCHAR2(255),
        file_size_bytes     NUMBER(18),
        checksum_sha256     VARCHAR2(128),
        etag                VARCHAR2(256),
        description         VARCHAR2(1000),
        metadata            JSON (OBJECT),
        process_requested   CHAR(1) DEFAULT 'Y' NOT NULL,
        processing_status   VARCHAR2(20) DEFAULT 'RECEIVED' NOT NULL,
        llm_profile_name    VARCHAR2(125),
        llm_model           VARCHAR2(255),
        llm_prompt          CLOB,
        llm_output          CLOB,
        llm_raw_response    CLOB,
        llm_error           VARCHAR2(4000),
        processed_at        TIMESTAMP,
        created_at          TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
        updated_at          TIMESTAMP DEFAULT SYSTIMESTAMP NOT NULL,
        CONSTRAINT fk_ta_ticket FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id),
        CONSTRAINT ck_ta_process_requested CHECK (process_requested IN ('Y', 'N')),
        CONSTRAINT ck_ta_processing_status CHECK (
            processing_status IN ('RECEIVED', 'SKIPPED', 'PROCESSING', 'PROCESSED', 'FAILED')
        )
    );

    COMMENT ON TABLE ticket_attachments                    IS 'One-to-many child table for ticket attachments stored externally in Object Storage. Stores URI, optional/enriched metadata, attachment LLM processing output, raw response, status, and errors for traceability.';
    COMMENT ON COLUMN ticket_attachments.attachment_id     IS 'Surrogate primary key for a ticket attachment.';
    COMMENT ON COLUMN ticket_attachments.ticket_id         IS 'FK to TICKETS. Multiple attachment rows can belong to one ticket.';
    COMMENT ON COLUMN ticket_attachments.attachment_uri    IS 'Object Storage URI supplied by the API client. This is the only mandatory inbound field for each attachment.';
    COMMENT ON COLUMN ticket_attachments.file_name         IS 'Attachment file name supplied by the API client or inferred from attachment_uri during ingest/processing.';
    COMMENT ON COLUMN ticket_attachments.file_extension    IS 'File extension inferred from file_name.';
    COMMENT ON COLUMN ticket_attachments.mime_type         IS 'MIME type supplied by the API client or inferred from file_name during ingest/processing.';
    COMMENT ON COLUMN ticket_attachments.file_size_bytes   IS 'Attachment size in bytes, supplied by the API client or measured when fetched from Object Storage.';
    COMMENT ON COLUMN ticket_attachments.checksum_sha256   IS 'Optional SHA-256 checksum supplied by the API client for traceability.';
    COMMENT ON COLUMN ticket_attachments.etag              IS 'Optional Object Storage ETag or equivalent object version marker.';
    COMMENT ON COLUMN ticket_attachments.description       IS 'Optional free-text description supplied by the API client.';
    COMMENT ON COLUMN ticket_attachments.metadata          IS 'Optional JSON metadata supplied by the API client or later enrichment logic.';
    COMMENT ON COLUMN ticket_attachments.process_requested IS 'Snapshot of TICKETS.process_attachments at creation time. Y=eligible for LLM processing; N=stored and notified only.';
    COMMENT ON COLUMN ticket_attachments.processing_status IS 'Per-attachment processing state. RECEIVED at ingest, SKIPPED when processing is disabled, PROCESSING while invoking the helper, PROCESSED on success, FAILED on error.';
    COMMENT ON COLUMN ticket_attachments.llm_profile_name  IS 'Select AI profile name used for attachment processing.';
    COMMENT ON COLUMN ticket_attachments.llm_model         IS 'Multimodal LLM model used for attachment processing.';
    COMMENT ON COLUMN ticket_attachments.llm_prompt        IS 'Prompt sent to the multimodal LLM for this attachment.';
    COMMENT ON COLUMN ticket_attachments.llm_output        IS 'Normalized text output extracted from multimodal LLM processing. Used as supplemental context by the answer generator.';
    COMMENT ON COLUMN ticket_attachments.llm_raw_response  IS 'Raw response from the attachment LLM call, retained for traceability and debugging.';
    COMMENT ON COLUMN ticket_attachments.llm_error         IS 'Last error encountered while processing this attachment, if any.';
    COMMENT ON COLUMN ticket_attachments.processed_at      IS 'Timestamp when attachment processing completed, failed, or was skipped.';
    COMMENT ON COLUMN ticket_attachments.created_at        IS 'Timestamp when this attachment row was inserted.';
    COMMENT ON COLUMN ticket_attachments.updated_at        IS 'Timestamp of the last update.';

    CREATE OR REPLACE TRIGGER trg_ticket_attachments_updated
    BEFORE UPDATE ON ticket_attachments
    FOR EACH ROW
    BEGIN
        :NEW.updated_at := SYSTIMESTAMP;
    END;
    /

    -- =============================================================================
    -- 6. TICKET_STATUS_HISTORY
    -- Defines the TICKET_STATUS_HISTORY table, constraints, and related metadata.
    -- =============================================================================
    CREATE TABLE ticket_status_history (
        history_id        NUMBER(18)    GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        ticket_id         VARCHAR2(36)  NOT NULL,
        from_status       VARCHAR2(20),
        to_status         VARCHAR2(20)  NOT NULL,
        transition_reason VARCHAR2(4000),
        actor             VARCHAR2(100) DEFAULT 'AGENT' NOT NULL,
        created_at        TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
        CONSTRAINT fk_tsh_ticket    FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id),
        CONSTRAINT ck_tsh_to_status CHECK (to_status IN ('RECEIVED', 'QUEUED', 'VALIDATING', 'CATEGORIZING', 'ANSWERING', 'SCORING', 'ANSWERED', 'ESCALATED', 'IN_REVIEW', 'RESOLVED', 'FAILED'))
    );

    COMMENT ON TABLE  ticket_status_history                   IS 'Append-only audit log recording every status transition. Never updated or deleted. Used for full traceability, SLA reporting and per-stage duration analytics.';
    COMMENT ON COLUMN ticket_status_history.history_id        IS 'Surrogate primary key.';
    COMMENT ON COLUMN ticket_status_history.ticket_id         IS 'FK to TICKETS.';
    COMMENT ON COLUMN ticket_status_history.from_status       IS 'Status before the transition. NULL for the initial RECEIVED entry.';
    COMMENT ON COLUMN ticket_status_history.to_status         IS 'Status after the transition.';
    COMMENT ON COLUMN ticket_status_history.transition_reason IS 'Explanation of why this transition occurred. Stores concise operational details, including notification failure summaries, up to 4000 characters.';
    COMMENT ON COLUMN ticket_status_history.actor             IS 'Who triggered the transition. AGENT for automated; user identifier for human-triggered transitions.';
    COMMENT ON COLUMN ticket_status_history.created_at        IS 'Exact timestamp of the status transition.';

    -- =============================================================================
    -- 7. TICKET_CATEGORISATION_LOG
    -- Defines the TICKET_CATEGORISATION_LOG table, constraints, and related metadata.
    -- =============================================================================
    CREATE TABLE ticket_categorisation_log (
        log_id                NUMBER(18)    GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        ticket_id             VARCHAR2(36)  NOT NULL,
        original_category     VARCHAR2(150),
        suggested_category_id NUMBER(10),
        suggested_category    VARCHAR2(150),
        confidence_score      NUMBER(5,4),
        was_overridden        CHAR(1)       DEFAULT 'N' NOT NULL,
        override_reason       VARCHAR2(500),
        kb_cluster_matched    VARCHAR2(100),
        created_at            TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
        CONSTRAINT fk_tcl_ticket    FOREIGN KEY (ticket_id)             REFERENCES tickets(ticket_id),
        CONSTRAINT fk_tcl_category  FOREIGN KEY (suggested_category_id) REFERENCES categories(category_id),
        CONSTRAINT ck_tcl_overridden CHECK (was_overridden IN ('Y', 'N')),
        CONSTRAINT ck_tcl_confidence CHECK (confidence_score BETWEEN 0 AND 1)
    );

    COMMENT ON TABLE  ticket_categorisation_log                       IS 'Audit log of every categorisation decision. Records original vs. suggested category and confidence score. Used for model quality analysis and auditing.';
    COMMENT ON COLUMN ticket_categorisation_log.log_id                IS 'Surrogate primary key.';
    COMMENT ON COLUMN ticket_categorisation_log.ticket_id             IS 'FK to TICKETS.';
    COMMENT ON COLUMN ticket_categorisation_log.original_category     IS 'Raw category string submitted with the ticket. NULL if none was provided.';
    COMMENT ON COLUMN ticket_categorisation_log.suggested_category_id IS 'FK to CATEGORIES. Category the agent determined as most relevant.';
    COMMENT ON COLUMN ticket_categorisation_log.suggested_category    IS 'Denormalised label of the agent-suggested category for quick reporting.';
    COMMENT ON COLUMN ticket_categorisation_log.confidence_score      IS 'Float 0.0–1.0 representing agent confidence in the suggested category.';
    COMMENT ON COLUMN ticket_categorisation_log.was_overridden        IS 'Y if the agent changed the submitted category; N if accepted as-is.';
    COMMENT ON COLUMN ticket_categorisation_log.override_reason       IS 'Explanation of why the original category was overridden.';
    COMMENT ON COLUMN ticket_categorisation_log.kb_cluster_matched    IS 'KB topic cluster tag matched during semantic search.';
    COMMENT ON COLUMN ticket_categorisation_log.created_at            IS 'Timestamp of the categorisation decision.';

    -- =============================================================================
    -- 6. ACCURACY_SCORES
    -- Defines the ACCURACY_SCORES table, constraints, and related metadata.
    -- =============================================================================
    CREATE TABLE accuracy_scores (
        score_id            NUMBER(18)    GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        ticket_id           VARCHAR2(36)  NOT NULL,
        judge_model         VARCHAR2(100) NOT NULL,
        relevance_score     NUMBER(5,4),
        completeness_score  NUMBER(5,4),
        faithfulness_score  NUMBER(5,4),
        composite_score     NUMBER(5,4)   NOT NULL,
        threshold_applied   NUMBER(5,4)   NOT NULL,
        passed_threshold    CHAR(1)       NOT NULL,
        scoring_prompt_hash VARCHAR2(64),
        raw_judge_response  CLOB,
        created_at          TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
        CONSTRAINT fk_as_ticket       FOREIGN KEY (ticket_id) REFERENCES tickets(ticket_id),
        CONSTRAINT ck_as_relevance    CHECK (relevance_score    BETWEEN 0 AND 1),
        CONSTRAINT ck_as_completeness CHECK (completeness_score BETWEEN 0 AND 1),
        CONSTRAINT ck_as_faithfulness CHECK (faithfulness_score BETWEEN 0 AND 1),
        CONSTRAINT ck_as_composite    CHECK (composite_score    BETWEEN 0 AND 1),
        CONSTRAINT ck_as_threshold    CHECK (threshold_applied  BETWEEN 0 AND 1),
        CONSTRAINT ck_as_passed       CHECK (passed_threshold   IN ('Y', 'N'))
    );

    COMMENT ON TABLE  accuracy_scores                     IS 'Records each LLM-as-a-judge scoring event. Stores dimension scores (relevance, completeness, faithfulness) and the composite score used to route the ticket to ANSWERED or ESCALATED.';
    COMMENT ON COLUMN accuracy_scores.score_id            IS 'Surrogate primary key.';
    COMMENT ON COLUMN accuracy_scores.ticket_id           IS 'FK to TICKETS.';
    COMMENT ON COLUMN accuracy_scores.judge_model         IS 'LLM model used as judge (e.g. gpt-4o, claude-3-5-sonnet). Distinct from the answer generation model.';
    COMMENT ON COLUMN accuracy_scores.relevance_score     IS 'Float 0.0–1.0: how relevant the generated answer is to the ticket question.';
    COMMENT ON COLUMN accuracy_scores.completeness_score  IS 'Float 0.0–1.0: how completely the answer addresses all aspects of the question.';
    COMMENT ON COLUMN accuracy_scores.faithfulness_score  IS 'Float 0.0–1.0: how faithfully the answer stays within KB content without fabrication.';
    COMMENT ON COLUMN accuracy_scores.composite_score     IS 'Final composite score written to TICKETS.accuracy_score. Weighted average of dimension scores.';
    COMMENT ON COLUMN accuracy_scores.threshold_applied   IS 'Snapshot of the threshold used at scoring time, copied from TICKETS.accuracy_threshold for audit immutability.';
    COMMENT ON COLUMN accuracy_scores.passed_threshold    IS 'Y if composite_score >= threshold (ANSWERED); N if below (ESCALATED).';
    COMMENT ON COLUMN accuracy_scores.scoring_prompt_hash IS 'SHA-256 hash of the scoring prompt for reproducibility and prompt drift detection.';
    COMMENT ON COLUMN accuracy_scores.raw_judge_response  IS 'Full raw JSON or text response from the judge LLM stored for debugging and audit.';
    COMMENT ON COLUMN accuracy_scores.created_at          IS 'Timestamp of the scoring event.';

    -- =============================================================================
    -- 7. ROUTING_RULES
    -- Defines the ROUTING_RULES table, constraints, and related metadata.
    -- =============================================================================
    CREATE TABLE routing_rules (
        rule_id          NUMBER(10)    GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        rule_name        VARCHAR2(255) NOT NULL,
        category_id      NUMBER(10)    NOT NULL,
        department_id    NUMBER(10)    NOT NULL,
        priority_boost   NUMBER(3)     DEFAULT 0 NOT NULL,
        rule_notes       VARCHAR2(4000),
        is_active        CHAR(1)       DEFAULT 'Y' NOT NULL,
        effective_from   DATE          DEFAULT SYSDATE NOT NULL,
        effective_to     DATE,
        notification_method VARCHAR2(30),
        escalation_email VARCHAR2(255),
        escalation_slack VARCHAR2(255),
        escalation_teams VARCHAR2(255),
        additional_metadata JSON (OBJECT),
        rule_notes_embedding VECTOR(1024, FLOAT32),
        embedding_status VARCHAR2(30) DEFAULT 'STALE' NOT NULL,
        embedding_updated_at TIMESTAMP,
        embedding_error VARCHAR2(4000),
        created_at       TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
        updated_at       TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
        CONSTRAINT uq_routing_cat_dept UNIQUE (category_id, department_id, rule_name),
        CONSTRAINT fk_rr_category      FOREIGN KEY (category_id)   REFERENCES categories(category_id),
        CONSTRAINT fk_rr_department    FOREIGN KEY (department_id) REFERENCES departments(department_id),
        CONSTRAINT ck_rr_notif_meth     CHECK (notification_method IN ('EMAIL', 'SLACK', 'TEAMS', 'API')),
        CONSTRAINT ck_rr_priority_boost CHECK (priority_boost BETWEEN 0 AND 10),
        CONSTRAINT ck_rr_active        CHECK (is_active IN ('Y', 'N')),
        CONSTRAINT ck_rr_embedding_status CHECK (embedding_status IN ('STALE', 'READY', 'ERROR'))
    );

    COMMENT ON TABLE  routing_rules                     IS 'Maps ticket categories to responsible departments for escalation routing. Supports date-bound rules for seasonal or temporary changes.';
    COMMENT ON COLUMN routing_rules.rule_id             IS 'Surrogate primary key.';
    COMMENT ON COLUMN routing_rules.category_id         IS 'FK to CATEGORIES. The category this rule applies to.';
    COMMENT ON COLUMN routing_rules.department_id       IS 'FK to DEPARTMENTS. The team that receives escalated tickets of this category.';
    COMMENT ON COLUMN routing_rules.priority_boost      IS 'Integer offset (0=lowest … 10=highest) added to ticket priority score when routing. Default 0. Values outside 0–10 are rejected.';
    COMMENT ON COLUMN routing_rules.rule_notes          IS 'Free-text notes explaining the routing rationale or special handling instructions (up to 4000 characters).';
    COMMENT ON COLUMN routing_rules.is_active           IS 'Y=rule is active and used by the routing engine; N=inactive.';
    COMMENT ON COLUMN routing_rules.effective_from      IS 'Date from which this routing rule is effective.';
    COMMENT ON COLUMN routing_rules.effective_to        IS 'Date after which this rule expires. NULL means no expiry.';
    COMMENT ON COLUMN routing_rules.created_at          IS 'Timestamp when the rule was created.';
    COMMENT ON COLUMN routing_rules.updated_at          IS 'Timestamp of the last update.';
    COMMENT ON COLUMN routing_rules.rule_name           IS 'Human-readable name for the routing rule. Example: Critical Claims – Major Loss Team.';
    COMMENT ON COLUMN routing_rules.escalation_email    IS 'Override escalation email address for this rule. When populated, takes precedence over the category-level escalation_email.';
    COMMENT ON COLUMN routing_rules.escalation_slack    IS 'Override Slack channel or webhook URL for this rule. When populated, takes precedence over the category-level escalation_slack.';
    COMMENT ON COLUMN routing_rules.escalation_teams    IS 'Override Microsoft Teams channel ID or webhook URL for this rule. When populated, takes precedence over the category-level escalation_teams.';
    COMMENT ON COLUMN routing_rules.additional_metadata IS 'Free-form JSON object payload for rule-specific configuration consumed by downstream agent tools or integrations. Mirrors CATEGORIES.additional_metadata and is used as a flex column in JSON Relational Duality Views.';
    COMMENT ON COLUMN routing_rules.notification_method IS 'Preferred notification channel for escalations matched by this rule. Values: EMAIL | SLACK | TEAMS | API. When populated, takes precedence over the category-level notification_method.';
    COMMENT ON COLUMN routing_rules.rule_notes_embedding IS 'Vector embedding of ROUTING_RULES.rule_notes using cohere.embed-multilingual-v3.0. Used only to shortlist semantically similar routing rules; final rule selection is still performed by ESCALATE_TICKET_TASK.';
    COMMENT ON COLUMN routing_rules.embedding_status IS 'Embedding maintenance state. STALE means rule_notes changed or the embedding has not been generated; READY means the vector is current; ERROR means the last refresh failed.';
    COMMENT ON COLUMN routing_rules.embedding_updated_at IS 'Timestamp when rule_notes_embedding was last refreshed.';
    COMMENT ON COLUMN routing_rules.embedding_error IS 'Last error returned while refreshing rule_notes_embedding. NULL when the most recent refresh succeeded or has not failed.';

    CREATE OR REPLACE TRIGGER trg_routing_rules_updated_at
    BEFORE UPDATE ON routing_rules
    FOR EACH ROW
    BEGIN
        :NEW.updated_at := SYSTIMESTAMP;
        IF NVL(:OLD.rule_notes, CHR(0)) <> NVL(:NEW.rule_notes, CHR(0)) THEN
            :NEW.rule_notes_embedding := NULL;
            :NEW.embedding_status := 'STALE';
            :NEW.embedding_updated_at := NULL;
            :NEW.embedding_error := NULL;
        END IF;
    END;
    /
    -- =============================================================================
    -- ESCALATIONS
    -- Defines the ESCALATIONS table, constraints, and related metadata.
    -- =============================================================================
    CREATE TABLE escalations (
        escalation_id       NUMBER(18)    GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        ticket_id           VARCHAR2(36)  NOT NULL,
        department_id       NUMBER(10)    NOT NULL,
        category_id         NUMBER(10)    NOT NULL,
        accuracy_score      NUMBER(5,4)   NOT NULL,
        suggested_answer    CLOB,
        notified_at         TIMESTAMP,
        notification_method VARCHAR2(30),
        acknowledged_at     TIMESTAMP,
        acknowledged_by     VARCHAR2(200),
        rule_name          VARCHAR2(255),
        routing_rule_id    NUMBER(10),
        routing_rule_notes VARCHAR2(4000),
        routing_rule_accuracy_score NUMBER(5,4),
        escalation_reason VARCHAR2(4000),
        escalation_email   VARCHAR2(255),
        escalation_slack   VARCHAR2(255),
        escalation_teams   VARCHAR2(255),
        additional_metadata JSON (OBJECT),
        resolved_at         TIMESTAMP,
        created_at          TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
        CONSTRAINT fk_esc_ticket      FOREIGN KEY (ticket_id)     REFERENCES tickets(ticket_id),
        CONSTRAINT fk_esc_department  FOREIGN KEY (department_id) REFERENCES departments(department_id),
        CONSTRAINT fk_esc_category    FOREIGN KEY (category_id) REFERENCES categories(category_id),
        CONSTRAINT fk_esc_routing_rule FOREIGN KEY (routing_rule_id) REFERENCES routing_rules(rule_id),
        CONSTRAINT ck_esc_notif_meth  CHECK (notification_method IN ('EMAIL', 'SLACK', 'TEAMS', 'API')),
        CONSTRAINT ck_esc_rr_accuracy CHECK (routing_rule_accuracy_score BETWEEN 0 AND 1),
        CONSTRAINT ck_esc_score       CHECK (accuracy_score BETWEEN 0 AND 1)
    );

    COMMENT ON TABLE  escalations                             IS 'Records each escalation event. Captures a snapshot of agent context at escalation time and tracks notification, acknowledgement and resolution by the receiving team.';
    COMMENT ON COLUMN escalations.escalation_id               IS 'Surrogate primary key.';
    COMMENT ON COLUMN escalations.ticket_id                   IS 'FK to TICKETS.';
    COMMENT ON COLUMN escalations.department_id               IS 'FK to DEPARTMENTS. The team the ticket was escalated to.';
    COMMENT ON COLUMN escalations.category_id                 IS 'FK to CATEGORIES. Snapshot of the ticket category at escalation time. Used for escalation reporting and routing rule resolution without joining back to TICKETS.';
    COMMENT ON COLUMN escalations.accuracy_score              IS 'Snapshot of accuracy_score at escalation time, shown to the team to communicate agent confidence level.';
    COMMENT ON COLUMN escalations.suggested_answer            IS 'Snapshot of the agent-generated answer (with inline KB references) provided to the team as a starting point. Immutable after escalation.';
    COMMENT ON COLUMN escalations.notified_at                 IS 'Timestamp when the Notification Service sent the escalation alert.';
    COMMENT ON COLUMN escalations.notification_method         IS 'Channel used. Values: EMAIL | SLACK | TEAMS | API.';
    COMMENT ON COLUMN escalations.acknowledged_at             IS 'Timestamp when a team member acknowledged the escalation.';
    COMMENT ON COLUMN escalations.acknowledged_by             IS 'Username or email of the team member who acknowledged.';
    COMMENT ON COLUMN escalations.resolved_at                 IS 'Timestamp when the escalation was resolved (ticket → RESOLVED).';
    COMMENT ON COLUMN escalations.created_at                  IS 'Timestamp when the escalation record was created.';
    COMMENT ON COLUMN escalations.rule_name                   IS 'Snapshot of the routing rule name that triggered this escalation, copied from ROUTING_RULES.rule_name at escalation time.';
    COMMENT ON COLUMN escalations.routing_rule_id             IS 'FK to ROUTING_RULES.rule_id for the rule selected by the routing engine. NULL when no rule matched and category fallback was used, or when routing was manual.';
    COMMENT ON COLUMN escalations.routing_rule_notes          IS 'Snapshot of ROUTING_RULES.rule_notes copied at escalation time, preserving the matching rationale even if the rule is later edited.';
    COMMENT ON COLUMN escalations.escalation_email            IS 'Email address used to notify the team for this escalation. Resolved from the matching routing rule or category at escalation time.';
    COMMENT ON COLUMN escalations.escalation_slack            IS 'Slack channel or webhook URL used to notify the team for this escalation. Resolved from the matching routing rule or category at escalation time.';
    COMMENT ON COLUMN escalations.escalation_teams            IS 'Microsoft Teams channel ID or webhook URL used to notify the team for this escalation. Resolved from the matching routing rule or category at escalation time.';
    COMMENT ON COLUMN escalations.additional_metadata         IS 'Free-form JSON object payload snapshot copied from the matching routing rule or category at escalation time. Used as a flex column in JSON Relational Duality Views.';
    COMMENT ON COLUMN escalations.routing_rule_accuracy_score IS 'Confidence score (0.0000–1.0000) produced by the routing engine when selecting the routing rule for this escalation. NULL if routing was manual or rule matching was deterministic.';
    COMMENT ON COLUMN escalations.escalation_reason           IS 'Human-readable explanation of why the ticket was escalated. Set by the agent pipeline: indicates either a low accuracy score relative to the category threshold, or that the category requires routing only (auto_answer=N) and no AI response was generated.';

    -- =============================================================================
    -- INDEXES
    -- Creates supporting indexes for the ticket response agent data model.
    -- =============================================================================

    -- TICKETS
    CREATE INDEX idx_tickets_status        ON tickets (status);
    CREATE INDEX idx_tickets_worker_claim  ON tickets (status, agent_next_retry_at, timestamp_received, priority, agent_claimed_by);
    CREATE INDEX idx_tickets_category_id   ON tickets (category_id);
    CREATE INDEX idx_tickets_department_id ON tickets (department_id);
    CREATE INDEX idx_tickets_assigned_team ON tickets (assigned_team_id);
    CREATE INDEX idx_tickets_source        ON tickets (source);
    CREATE INDEX idx_tickets_ts_received   ON tickets (timestamp_received);
    CREATE INDEX idx_tickets_accuracy      ON tickets (accuracy_score);
    CREATE INDEX idx_tickets_ext_ref       ON tickets (external_ref);
    CREATE INDEX idx_tickets_aar           ON tickets (auto_answer_auto_route);

    -- TICKET_ATTACHMENTS
    CREATE INDEX idx_ta_ticket_id   ON ticket_attachments (ticket_id);
    CREATE INDEX idx_ta_status      ON ticket_attachments (processing_status);
    CREATE INDEX idx_ta_process_req ON ticket_attachments (process_requested);

    -- TICKET_STATUS_HISTORY
    CREATE INDEX idx_tsh_ticket_id  ON ticket_status_history (ticket_id);
    CREATE INDEX idx_tsh_created_at ON ticket_status_history (created_at);
    CREATE INDEX idx_tsh_to_status  ON ticket_status_history (to_status);

    -- TICKET_CATEGORISATION_LOG
    CREATE INDEX idx_tcl_ticket_id     ON ticket_categorisation_log (ticket_id);
    CREATE INDEX idx_tcl_suggested_cat ON ticket_categorisation_log (suggested_category_id);

    -- ACCURACY_SCORES
    CREATE INDEX idx_as_ticket_id   ON accuracy_scores (ticket_id);
    CREATE INDEX idx_as_composite   ON accuracy_scores (composite_score);
    CREATE INDEX idx_as_judge_model ON accuracy_scores (judge_model);

    -- ROUTING_RULES
    CREATE INDEX idx_rr_category_id   ON routing_rules (category_id);
    CREATE INDEX idx_rr_department_id ON routing_rules (department_id);
    CREATE INDEX idx_rr_active_eff    ON routing_rules (is_active, effective_from, effective_to);
    CREATE VECTOR INDEX idx_rr_rule_notes_vec ON routing_rules (rule_notes_embedding)
        ORGANIZATION INMEMORY NEIGHBOR GRAPH
        DISTANCE COSINE
        WITH TARGET ACCURACY 90 PARAMETERS (type HNSW, neighbors 40, efconstruction 500);

    -- ESCALATIONS
    CREATE INDEX idx_esc_ticket_id       ON escalations (ticket_id);
    CREATE INDEX idx_esc_department_id   ON escalations (department_id);
    CREATE INDEX idx_esc_notified_at     ON escalations (notified_at);
    CREATE INDEX idx_esc_category_id     ON escalations (category_id);
    CREATE INDEX idx_esc_routing_rule_id ON escalations (routing_rule_id);

    -- CATEGORIES
    CREATE INDEX idx_cat_department_id ON categories (department_id);
    CREATE INDEX idx_cat_parent_id     ON categories (parent_category_id);
    CREATE INDEX idx_cat_kb_cluster    ON categories (kb_cluster_tag);

-- =============================================================================
-- TICKET RESPONSE AGENT — REPORTING VIEWS
-- Description : Read-only views to simplify reporting and querying across
-- the Ticket Response Agent data model. All views are
-- non-updatable and intended for dashboards, exports and APIs.
-- Version     : 1.0
-- Date        : March 2026
-- =============================================================================

    -- =============================================================================
    -- V_TICKET_OVERVIEW
    -- One row per ticket with all key fields denormalised for general reporting.
    -- Joins tickets to category, department and assigned team in a single view.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_ticket_overview AS
        SELECT
            t.ticket_id,
            t.source,
            t.external_ref,
            t.subject,
            t.body,
            t.submitted_category,
            t.category_source,
            c.category_code,
            c.category_name,
            d.department_code           AS department_code,
            d.department_name           AS department_name,
            t.status,
            t.priority,
            t.submitter_email,
            t.submitter_name,
            t.accuracy_score,
            t.accuracy_threshold,
            CASE
                WHEN t.accuracy_score IS NULL     THEN 'NOT_SCORED'
                WHEN t.accuracy_score >= t.accuracy_threshold THEN 'PASSED'
                ELSE 'FAILED'
            END                         AS threshold_result,
            td.department_code          AS assigned_team_code,
            td.department_name          AS assigned_team_name,
            t.kb_version,
            t.timestamp_received,
            t.timestamp_updated,
            t.timestamp_resolved,
            CASE
                WHEN t.timestamp_resolved IS NOT NULL
                THEN ROUND((CAST(t.timestamp_resolved AS DATE) -
                    CAST(t.timestamp_received AS DATE)) * 24 * 60, 2)
                ELSE NULL
            END                         AS resolution_minutes
        FROM       tickets     t
        LEFT JOIN  categories  c  ON c.category_id   = t.category_id
        LEFT JOIN  departments d  ON d.department_id = t.department_id
        LEFT JOIN  departments td ON td.department_id = t.assigned_team_id;

    COMMENT ON TABLE  v_ticket_overview                    IS 'Master reporting view. One row per ticket with category, department, assigned team and key metrics denormalised. Use for dashboards, exports and general ticket queries.';
    COMMENT ON COLUMN v_ticket_overview.ticket_id          IS 'Unique ticket identifier (UUID).';
    COMMENT ON COLUMN v_ticket_overview.source             IS 'Ingestion channel: EMAIL | TICKETING_SYSTEM | API | CHAT.';
    COMMENT ON COLUMN v_ticket_overview.external_ref       IS 'Reference ID in the originating external system (e.g. Zendesk ID, Jira key).';
    COMMENT ON COLUMN v_ticket_overview.subject            IS 'Ticket subject line.';
    COMMENT ON COLUMN v_ticket_overview.submitted_category IS 'Raw category string originally submitted with the ticket, before agent validation.';
    COMMENT ON COLUMN v_ticket_overview.category_source    IS 'Who assigned the final category: SUBMITTER | AGENT_SUGGESTED | HUMAN_OVERRIDE.';
    COMMENT ON COLUMN v_ticket_overview.category_code      IS 'Short code of the validated/assigned category (from CATEGORIES).';
    COMMENT ON COLUMN v_ticket_overview.category_name      IS 'Human-readable name of the assigned category.';
    COMMENT ON COLUMN v_ticket_overview.department_code    IS 'Code of the department that owns the ticket category.';
    COMMENT ON COLUMN v_ticket_overview.department_name    IS 'Name of the department that owns the ticket category.';
    COMMENT ON COLUMN v_ticket_overview.status             IS 'Current ticket lifecycle status.';
    COMMENT ON COLUMN v_ticket_overview.priority           IS 'Ticket priority: LOW | MEDIUM | HIGH | CRITICAL.';
    COMMENT ON COLUMN v_ticket_overview.submitter_email    IS 'Email address of the ticket submitter.';
    COMMENT ON COLUMN v_ticket_overview.submitter_name     IS 'Full name of the ticket submitter.';
    COMMENT ON COLUMN v_ticket_overview.accuracy_score     IS 'LLM-as-a-judge composite score (0.0–1.0). NULL if scoring not yet completed.';
    COMMENT ON COLUMN v_ticket_overview.accuracy_threshold IS 'Threshold applied at scoring time for this ticket. Default 0.75.';
    COMMENT ON COLUMN v_ticket_overview.threshold_result   IS 'Derived scoring outcome: PASSED (score >= threshold) | FAILED (score < threshold) | NOT_SCORED (pending).';
    COMMENT ON COLUMN v_ticket_overview.assigned_team_code IS 'Department code of the team assigned to handle the escalation.';
    COMMENT ON COLUMN v_ticket_overview.assigned_team_name IS 'Department name of the team assigned to handle the escalation.';
    COMMENT ON COLUMN v_ticket_overview.kb_version         IS 'Knowledge Base version snapshot used when generating the answer.';
    COMMENT ON COLUMN v_ticket_overview.timestamp_received IS 'Timestamp when the ticket was ingested.';
    COMMENT ON COLUMN v_ticket_overview.timestamp_updated  IS 'Timestamp of the last update to the ticket record.';
    COMMENT ON COLUMN v_ticket_overview.timestamp_resolved IS 'Timestamp when the ticket reached a terminal state.';
    COMMENT ON COLUMN v_ticket_overview.resolution_minutes IS 'Total resolution time in minutes from ingestion to terminal state. NULL if not yet resolved.';
    COMMENT ON COLUMN v_ticket_overview.body               IS 'Full text of the ticket message body stored as CLOB. Must be non-empty; empty body triggers FAILED status.';

    -- =============================================================================
    -- V_TICKET_STATUS_TIMELINE
    -- Full status transition history per ticket with stage duration in minutes.
    -- Used for SLA analysis and bottleneck identification.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_ticket_status_timeline AS
        SELECT
            h.ticket_id,
            t.subject,
            t.source,
            t.status                            AS current_status,
            h.history_id,
            h.from_status,
            h.to_status,
            h.transition_reason,
            h.actor,
            h.created_at                        AS transition_at,
            LEAD(h.created_at) OVER (
                PARTITION BY h.ticket_id
        ORDER BY h.history_id
            )                                   AS next_transition_at,
            ROUND(
            (CAST(
                    LEAD(h.created_at) OVER (
                PARTITION BY h.ticket_id ORDER BY h.history_id
            ) AS DATE
            ) - CAST(h.created_at AS DATE)) * 24 * 60
            , 2)                                AS stage_duration_minutes
        FROM       ticket_status_history h
        JOIN       tickets               t ON t.ticket_id = h.ticket_id
        ORDER BY   h.ticket_id, h.history_id desc;

    COMMENT ON TABLE  v_ticket_status_timeline                        IS 'Detailed status transition timeline per ticket with per-stage duration in minutes. Used for SLA compliance reporting, stage bottleneck analysis and processing-time dashboards.';
    COMMENT ON COLUMN v_ticket_status_timeline.ticket_id              IS 'Ticket unique identifier.';
    COMMENT ON COLUMN v_ticket_status_timeline.subject                IS 'Ticket subject line for context.';
    COMMENT ON COLUMN v_ticket_status_timeline.source                 IS 'Ingestion channel of the ticket.';
    COMMENT ON COLUMN v_ticket_status_timeline.current_status         IS 'Current status of the ticket at query time.';
    COMMENT ON COLUMN v_ticket_status_timeline.history_id             IS 'Surrogate key of the status history record, reflecting insertion order.';
    COMMENT ON COLUMN v_ticket_status_timeline.from_status            IS 'Status before this transition. NULL for the initial RECEIVED entry.';
    COMMENT ON COLUMN v_ticket_status_timeline.to_status              IS 'Status after this transition.';
    COMMENT ON COLUMN v_ticket_status_timeline.transition_reason      IS 'Explanation of why the transition occurred.';
    COMMENT ON COLUMN v_ticket_status_timeline.actor                  IS 'Who triggered the transition: AGENT or a user identifier.';
    COMMENT ON COLUMN v_ticket_status_timeline.transition_at          IS 'Timestamp when this transition occurred.';
    COMMENT ON COLUMN v_ticket_status_timeline.next_transition_at     IS 'Timestamp of the next transition for this ticket (NULL for the latest row).';
    COMMENT ON COLUMN v_ticket_status_timeline.stage_duration_minutes IS 'Time in minutes spent in the to_status stage before moving to the next. NULL for the current/final stage.';

    -- =============================================================================
    -- V_TICKET_ACCURACY_DETAIL
    -- Joins each ticket to its accuracy scoring breakdown.
    -- Used for model performance monitoring and threshold calibration.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_ticket_accuracy_detail AS
        SELECT
            t.ticket_id,
            t.subject,
            t.status,
            c.category_name,
            d.department_name,
            a.score_id,
            a.judge_model,
            a.relevance_score,
            a.completeness_score,
            a.faithfulness_score,
            a.composite_score,
            a.threshold_applied,
            a.passed_threshold,
            a.scoring_prompt_hash,
            a.created_at                        AS scored_at,
            t.timestamp_received,
            ROUND(
            (CAST(a.created_at AS DATE) -
                    CAST(t.timestamp_received AS DATE)) * 24 * 60
            , 2)                                AS minutes_to_score
        FROM       tickets         t
        JOIN       accuracy_scores a  ON a.ticket_id    = t.ticket_id
        LEFT JOIN  categories      c  ON c.category_id  = t.category_id
        LEFT JOIN  departments     d  ON d.department_id = t.department_id;

    COMMENT ON TABLE  v_ticket_accuracy_detail                     IS 'Joins tickets with their LLM-as-a-judge scoring breakdown. Used for model performance monitoring, threshold calibration and identifying which categories or departments have the lowest answer quality.';
    COMMENT ON COLUMN v_ticket_accuracy_detail.ticket_id           IS 'Ticket unique identifier.';
    COMMENT ON COLUMN v_ticket_accuracy_detail.subject             IS 'Ticket subject line.';
    COMMENT ON COLUMN v_ticket_accuracy_detail.status              IS 'Current ticket status.';
    COMMENT ON COLUMN v_ticket_accuracy_detail.category_name       IS 'Assigned category name.';
    COMMENT ON COLUMN v_ticket_accuracy_detail.department_name     IS 'Owning department name.';
    COMMENT ON COLUMN v_ticket_accuracy_detail.score_id            IS 'Surrogate key of the accuracy score record.';
    COMMENT ON COLUMN v_ticket_accuracy_detail.judge_model         IS 'LLM model used as the judge for this scoring event.';
    COMMENT ON COLUMN v_ticket_accuracy_detail.relevance_score     IS 'How relevant the generated answer is to the question (0.0–1.0).';
    COMMENT ON COLUMN v_ticket_accuracy_detail.completeness_score  IS 'How completely the answer addresses the question (0.0–1.0).';
    COMMENT ON COLUMN v_ticket_accuracy_detail.faithfulness_score  IS 'How faithfully the answer stays within KB content without fabrication (0.0–1.0).';
    COMMENT ON COLUMN v_ticket_accuracy_detail.composite_score     IS 'Final weighted composite score used to route the ticket (0.0–1.0).';
    COMMENT ON COLUMN v_ticket_accuracy_detail.threshold_applied   IS 'Accuracy threshold snapshot used at scoring time.';
    COMMENT ON COLUMN v_ticket_accuracy_detail.passed_threshold    IS 'Y=ticket routed to ANSWERED; N=ticket routed to ESCALATED.';
    COMMENT ON COLUMN v_ticket_accuracy_detail.scoring_prompt_hash IS 'Hash of the scoring prompt for reproducibility tracking.';
    COMMENT ON COLUMN v_ticket_accuracy_detail.scored_at           IS 'Timestamp when the scoring event occurred.';
    COMMENT ON COLUMN v_ticket_accuracy_detail.timestamp_received  IS 'Timestamp when the ticket was ingested.';
    COMMENT ON COLUMN v_ticket_accuracy_detail.minutes_to_score    IS 'Time in minutes from ticket ingestion to scoring completion.';

    -- =============================================================================
    -- V_ESCALATION_DETAIL
    -- Full escalation context: ticket, assigned team, accuracy, notification
    -- and acknowledgement status. Used for escalation queue management.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_escalation_detail AS
        SELECT
            e.escalation_id,
            t.ticket_id,
            t.subject,
            t.priority,
            t.status                            AS ticket_status,
            c.category_code,
            c.category_name,
            od.department_name                  AS owning_department,
            e.accuracy_score,
            e.notified_at,
            e.notification_method,
            e.rule_name,
            e.routing_rule_id,
            e.routing_rule_notes,
            e.routing_rule_accuracy_score,
            e.escalation_reason,
            ad.department_code                  AS assigned_team_code,
            ad.department_name                  AS assigned_team_name,
            ad.escalation_email                 AS team_email,
            ad.escalation_slack                 AS team_slack,
            e.acknowledged_at,
            e.acknowledged_by,
            CASE
                WHEN e.acknowledged_at IS NOT NULL THEN 'ACKNOWLEDGED'
                WHEN e.notified_at     IS NOT NULL THEN 'NOTIFIED'
                ELSE 'PENDING'
            END                                 AS escalation_state,
            CASE
                WHEN e.acknowledged_at IS NOT NULL
                THEN ROUND((CAST(e.acknowledged_at AS DATE) -
                    CAST(e.notified_at    AS DATE)) * 24 * 60, 2)
                ELSE NULL
            END                                 AS ack_minutes,
            e.resolved_at,
            CASE
                WHEN e.resolved_at IS NOT NULL
                THEN ROUND((CAST(e.resolved_at AS DATE) -
                    CAST(e.created_at  AS DATE)) * 24 * 60, 2)
                ELSE NULL
            END                                 AS resolution_minutes,
            t.submitter_email,
            t.submitter_name,
            e.created_at                        AS escalated_at
        FROM       escalations  e
        JOIN       tickets      t   ON t.ticket_id    = e.ticket_id
        LEFT JOIN  categories   c   ON c.category_id  = t.category_id
        LEFT JOIN  departments  od  ON od.department_id = t.department_id
        JOIN       departments  ad  ON ad.department_id = e.department_id;

    COMMENT ON TABLE  v_escalation_detail                             IS 'Full escalation context view. Joins escalation events with the ticket, owning department, assigned team and notification status. Used for escalation queue dashboards, SLA tracking and team workload reporting.';
    COMMENT ON COLUMN v_escalation_detail.escalation_id               IS 'Unique escalation event identifier.';
    COMMENT ON COLUMN v_escalation_detail.ticket_id                   IS 'Ticket that was escalated.';
    COMMENT ON COLUMN v_escalation_detail.subject                     IS 'Ticket subject line.';
    COMMENT ON COLUMN v_escalation_detail.priority                    IS 'Ticket priority at time of escalation.';
    COMMENT ON COLUMN v_escalation_detail.ticket_status               IS 'Current ticket status.';
    COMMENT ON COLUMN v_escalation_detail.category_code               IS 'Category code of the escalated ticket.';
    COMMENT ON COLUMN v_escalation_detail.category_name               IS 'Category name of the escalated ticket.';
    COMMENT ON COLUMN v_escalation_detail.owning_department           IS 'Department that owns the ticket category.';
    COMMENT ON COLUMN v_escalation_detail.accuracy_score              IS 'Agent accuracy score snapshot at escalation time. Shown to the receiving team.';
    COMMENT ON COLUMN v_escalation_detail.notified_at                 IS 'Timestamp when the escalation notification was sent to the team.';
    COMMENT ON COLUMN v_escalation_detail.notification_method         IS 'Channel used to notify the team: EMAIL | SLACK | TEAMS | API.';
    COMMENT ON COLUMN v_escalation_detail.rule_name                   IS 'Routing rule name snapshot selected by the routing engine. NULL when category fallback was used.';
    COMMENT ON COLUMN v_escalation_detail.routing_rule_id             IS 'Routing rule primary key selected by the routing engine. NULL when category fallback was used.';
    COMMENT ON COLUMN v_escalation_detail.routing_rule_notes          IS 'Routing rule notes snapshot captured at escalation time for troubleshooting.';
    COMMENT ON COLUMN v_escalation_detail.routing_rule_accuracy_score IS 'Confidence score produced by the routing engine when selecting the routing rule.';
    COMMENT ON COLUMN v_escalation_detail.escalation_reason           IS 'Human-readable reason the agent escalated the ticket.';
    COMMENT ON COLUMN v_escalation_detail.assigned_team_code          IS 'Code of the department assigned to resolve the escalation.';
    COMMENT ON COLUMN v_escalation_detail.assigned_team_name          IS 'Name of the department assigned to resolve the escalation.';
    COMMENT ON COLUMN v_escalation_detail.team_email                  IS 'Escalation email address of the assigned team.';
    COMMENT ON COLUMN v_escalation_detail.team_slack                  IS 'Slack channel of the assigned team.';
    COMMENT ON COLUMN v_escalation_detail.acknowledged_at             IS 'Timestamp when the team acknowledged the escalation.';
    COMMENT ON COLUMN v_escalation_detail.acknowledged_by             IS 'Username or email of the team member who acknowledged.';
    COMMENT ON COLUMN v_escalation_detail.escalation_state            IS 'Derived escalation progress: PENDING (not yet notified) | NOTIFIED (sent, awaiting ack) | ACKNOWLEDGED (team has accepted).';
    COMMENT ON COLUMN v_escalation_detail.ack_minutes                 IS 'Time in minutes from notification to acknowledgement. NULL if not yet acknowledged.';
    COMMENT ON COLUMN v_escalation_detail.resolution_minutes          IS 'Total escalation resolution time in minutes from escalation creation to resolved_at. NULL if not yet resolved.';
    COMMENT ON COLUMN v_escalation_detail.submitter_email             IS 'Email of the original ticket submitter.';
    COMMENT ON COLUMN v_escalation_detail.submitter_name              IS 'Name of the original ticket submitter.';
    COMMENT ON COLUMN v_escalation_detail.escalated_at                IS 'Timestamp when the escalation record was created.';

    -- =============================================================================
    -- V_CATEGORISATION_AUDIT
    -- Shows every ticket with its original vs. agent-suggested category,
    -- confidence score and whether the agent overrode the original.
    -- Used for categorisation model quality monitoring.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_categorisation_audit AS
        SELECT
            cl.log_id,
            t.ticket_id,
            t.subject,
            t.source,
            t.status,
            cl.original_category,
            cl.suggested_category,
            sc.category_code                    AS suggested_category_code,
            sd.department_name                  AS suggested_department,
            cl.confidence_score,
            cl.was_overridden,
            cl.override_reason,
            cl.kb_cluster_matched,
            t.category_source                   AS final_category_source,
            fc.category_name                    AS final_category_name,
            fd.department_name                  AS final_department,
            cl.created_at                       AS categorised_at
        FROM       ticket_categorisation_log cl
        JOIN       tickets                   t   ON t.ticket_id      = cl.ticket_id
        LEFT JOIN  categories                sc  ON sc.category_id   = cl.suggested_category_id
        LEFT JOIN  departments               sd  ON sd.department_id = sc.department_id
        LEFT JOIN  categories                fc  ON fc.category_id   = t.category_id
        LEFT JOIN  departments               fd  ON fd.department_id = fc.department_id;

    COMMENT ON TABLE  v_categorisation_audit                         IS 'Audit view of every categorisation decision. Shows original vs. suggested category, confidence score, override flag and the final category applied. Used to evaluate agent categorisation accuracy, override rate and KB cluster effectiveness.';
    COMMENT ON COLUMN v_categorisation_audit.log_id                  IS 'Surrogate key of the categorisation log record.';
    COMMENT ON COLUMN v_categorisation_audit.ticket_id               IS 'Ticket unique identifier.';
    COMMENT ON COLUMN v_categorisation_audit.subject                 IS 'Ticket subject line.';
    COMMENT ON COLUMN v_categorisation_audit.source                  IS 'Ingestion channel of the ticket.';
    COMMENT ON COLUMN v_categorisation_audit.status                  IS 'Current ticket status.';
    COMMENT ON COLUMN v_categorisation_audit.original_category       IS 'Raw category string originally submitted with the ticket.';
    COMMENT ON COLUMN v_categorisation_audit.suggested_category      IS 'Denormalised category label the agent suggested.';
    COMMENT ON COLUMN v_categorisation_audit.suggested_category_code IS 'Category code of the agent suggestion.';
    COMMENT ON COLUMN v_categorisation_audit.suggested_department    IS 'Department name that owns the agent-suggested category.';
    COMMENT ON COLUMN v_categorisation_audit.confidence_score        IS 'Agent confidence score (0.0–1.0) in the suggested category.';
    COMMENT ON COLUMN v_categorisation_audit.was_overridden          IS 'Y=agent changed the submitted category; N=submitted category was accepted.';
    COMMENT ON COLUMN v_categorisation_audit.override_reason         IS 'Reason the original category was overridden by the agent.';
    COMMENT ON COLUMN v_categorisation_audit.kb_cluster_matched      IS 'KB topic cluster tag matched during semantic search.';
    COMMENT ON COLUMN v_categorisation_audit.final_category_source   IS 'Source of the final category applied: SUBMITTER | AGENT_SUGGESTED | HUMAN_OVERRIDE.';
    COMMENT ON COLUMN v_categorisation_audit.final_category_name     IS 'Name of the category ultimately applied to the ticket.';
    COMMENT ON COLUMN v_categorisation_audit.final_department        IS 'Department name that owns the final applied category.';
    COMMENT ON COLUMN v_categorisation_audit.categorised_at          IS 'Timestamp when the categorisation decision was recorded.';

    -- =============================================================================
    -- V_DEPARTMENT_TICKET_SUMMARY
    -- Aggregated ticket counts and average accuracy per department.
    -- Used for department-level performance dashboards.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_department_ticket_summary AS
        SELECT
            d.department_id,
            d.department_code,
            d.department_name,
            COUNT(t.ticket_id)                                          AS total_tickets,
            SUM(CASE WHEN t.status = 'ANSWERED'  THEN 1 ELSE 0 END)    AS answered_tickets,
            SUM(CASE WHEN t.status = 'ESCALATED'
            OR t.status = 'IN_REVIEW'      THEN 1 ELSE 0 END)    AS escalated_tickets,
            SUM(CASE WHEN t.status = 'RESOLVED'  THEN 1 ELSE 0 END)    AS resolved_tickets,
            SUM(CASE WHEN t.status = 'FAILED'    THEN 1 ELSE 0 END)    AS failed_tickets,
            SUM(CASE WHEN t.status NOT IN
            ('ANSWERED','ESCALATED','IN_REVIEW','RESOLVED','FAILED')
                THEN 1 ELSE 0 END)                                      AS in_progress_tickets,
            ROUND(AVG(t.accuracy_score), 4)                             AS avg_accuracy_score,
            ROUND(MIN(t.accuracy_score), 4)                             AS min_accuracy_score,
            ROUND(MAX(t.accuracy_score), 4)                             AS max_accuracy_score,
            SUM(CASE WHEN t.category_source = 'AGENT_SUGGESTED'
                THEN 1 ELSE 0 END)                                      AS agent_categorised,
            ROUND(
            SUM(CASE WHEN t.category_source = 'AGENT_SUGGESTED'
                THEN 1 ELSE 0 END)
            / NULLIF(COUNT(t.ticket_id), 0) * 100
            , 1)                                                        AS agent_categorised_pct,
            ROUND(
            SUM(CASE WHEN t.status IN ('ESCALATED', 'IN_REVIEW')
                THEN 1 ELSE 0 END)
            / NULLIF(COUNT(t.ticket_id), 0) * 100
            , 1)                                                        AS escalation_rate_pct
        FROM       departments d
        LEFT JOIN  tickets     t ON t.department_id = d.department_id
        GROUP BY   d.department_id, d.department_code, d.department_name;

    COMMENT ON TABLE  v_department_ticket_summary                       IS 'Aggregated ticket volume and quality metrics grouped by department. Used for department-level performance dashboards, escalation rate tracking and categorisation quality monitoring.';
    COMMENT ON COLUMN v_department_ticket_summary.department_id         IS 'Department unique identifier.';
    COMMENT ON COLUMN v_department_ticket_summary.department_code       IS 'Short department code.';
    COMMENT ON COLUMN v_department_ticket_summary.department_name       IS 'Full department name.';
    COMMENT ON COLUMN v_department_ticket_summary.total_tickets         IS 'Total number of tickets belonging to this department.';
    COMMENT ON COLUMN v_department_ticket_summary.answered_tickets      IS 'Tickets resolved autonomously by the agent with a passing accuracy score.';
    COMMENT ON COLUMN v_department_ticket_summary.escalated_tickets     IS 'Tickets currently in ESCALATED or IN_REVIEW status.';
    COMMENT ON COLUMN v_department_ticket_summary.resolved_tickets      IS 'Tickets fully resolved by a human reviewer after escalation.';
    COMMENT ON COLUMN v_department_ticket_summary.failed_tickets        IS 'Tickets that reached the FAILED terminal state.';
    COMMENT ON COLUMN v_department_ticket_summary.in_progress_tickets   IS 'Tickets still being processed by the agent (not in a terminal or escalated state).';
    COMMENT ON COLUMN v_department_ticket_summary.avg_accuracy_score    IS 'Average LLM-as-a-judge composite accuracy score across all scored tickets for this department.';
    COMMENT ON COLUMN v_department_ticket_summary.min_accuracy_score    IS 'Lowest accuracy score recorded for this department.';
    COMMENT ON COLUMN v_department_ticket_summary.max_accuracy_score    IS 'Highest accuracy score recorded for this department.';
    COMMENT ON COLUMN v_department_ticket_summary.agent_categorised     IS 'Number of tickets where the agent suggested or overrode the original category.';
    COMMENT ON COLUMN v_department_ticket_summary.agent_categorised_pct IS 'Percentage of tickets where the agent changed the submitted category.';
    COMMENT ON COLUMN v_department_ticket_summary.escalation_rate_pct   IS 'Percentage of tickets that were escalated (accuracy below threshold).';

    -- =============================================================================
    -- V_CATEGORY_PERFORMANCE
    -- Aggregated accuracy and escalation metrics per category.
    -- Used to identify categories with low KB coverage or poor answer quality.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_category_performance AS
        SELECT
            c.category_id,
            c.category_code,
            c.category_name,
            c.kb_cluster_tag,
            d.department_code,
            d.department_name,
            COUNT(t.ticket_id)                                              AS total_tickets,
            SUM(CASE WHEN t.status = 'ANSWERED' THEN 1 ELSE 0 END)         AS auto_answered,
            SUM(CASE WHEN t.status IN
            ('ESCALATED','IN_REVIEW','RESOLVED') THEN 1 ELSE 0 END)    AS escalated,
            ROUND(AVG(t.accuracy_score), 4)                                 AS avg_accuracy,
            ROUND(
            SUM(CASE WHEN t.status IN ('ESCALATED', 'IN_REVIEW', 'RESOLVED')
                THEN 1 ELSE 0 END)
            / NULLIF(COUNT(t.ticket_id), 0) * 100
            , 1)                                                            AS escalation_rate_pct,
            ROUND(AVG(
                    CASE WHEN t.timestamp_resolved IS NOT NULL
                THEN (CAST(t.timestamp_resolved AS DATE) -
                    CAST(t.timestamp_received AS DATE)) * 24 * 60
                ELSE NULL END
            ), 2)                                                           AS avg_resolution_minutes
        FROM       categories  c
        LEFT JOIN  tickets     t ON t.category_id   = c.category_id
        JOIN       departments d ON d.department_id = c.department_id
        GROUP BY   c.category_id, c.category_code, c.category_name,
            c.kb_cluster_tag, d.department_code, d.department_name;

    COMMENT ON TABLE  v_category_performance                        IS 'Aggregated accuracy and escalation metrics per ticket category. Used to identify which categories have low KB coverage, poor answer quality or high escalation rates, informing KB maintenance priorities.';
    COMMENT ON COLUMN v_category_performance.category_id            IS 'Category unique identifier.';
    COMMENT ON COLUMN v_category_performance.category_code          IS 'Short category code.';
    COMMENT ON COLUMN v_category_performance.category_name          IS 'Full category name.';
    COMMENT ON COLUMN v_category_performance.kb_cluster_tag         IS 'KB topic cluster tag linked to this category, for KB coverage analysis.';
    COMMENT ON COLUMN v_category_performance.department_code        IS 'Code of the owning department.';
    COMMENT ON COLUMN v_category_performance.department_name        IS 'Name of the owning department.';
    COMMENT ON COLUMN v_category_performance.total_tickets          IS 'Total tickets assigned to this category.';
    COMMENT ON COLUMN v_category_performance.auto_answered          IS 'Tickets where the agent produced a passing-score answer without escalation.';
    COMMENT ON COLUMN v_category_performance.escalated              IS 'Tickets that were escalated, in review or resolved by a human.';
    COMMENT ON COLUMN v_category_performance.avg_accuracy           IS 'Average composite accuracy score across all scored tickets in this category.';
    COMMENT ON COLUMN v_category_performance.escalation_rate_pct    IS 'Percentage of tickets in this category that required escalation.';
    COMMENT ON COLUMN v_category_performance.avg_resolution_minutes IS 'Average end-to-end resolution time in minutes for resolved tickets in this category.';

    -- =============================================================================
    -- V_OPEN_ESCALATIONS
    -- All escalations not yet resolved, ordered by age (oldest first).
    -- Used as the primary escalation queue view for support teams.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_open_escalations AS
        SELECT
            e.escalation_id,
            t.ticket_id,
            t.origin_ticket_id,
            t.status                            AS ticket_status,
            t.subject,
            t.priority,
            c.category_name,
            d.department_name                   AS owning_department,
            ad.department_name                  AS assigned_team,
            ad.escalation_email                 AS team_email,
            e.accuracy_score,
            e.notified_at,
            e.notification_method,
            e.rule_name,
            e.routing_rule_id,
            e.routing_rule_notes,
            e.routing_rule_accuracy_score,
            e.escalation_reason,
            e.acknowledged_at,
            e.acknowledged_by,
            CASE
                WHEN e.acknowledged_at IS NOT NULL THEN 'ACKNOWLEDGED'
                WHEN e.notified_at     IS NOT NULL THEN 'NOTIFIED'
                ELSE 'PENDING'
            END                                 AS escalation_state,
            ROUND(
            (CAST(SYSTIMESTAMP AS DATE) -
                    CAST(e.created_at  AS DATE)) * 24 * 60
            , 0)                                AS open_since_minutes,
            t.submitter_name,
            t.submitter_email,
            e.created_at                        AS escalated_at
        FROM       escalations  e
        JOIN       tickets      t   ON t.ticket_id     = e.ticket_id
        LEFT JOIN  categories   c   ON c.category_id   = t.category_id
        LEFT JOIN  departments  d   ON d.department_id = t.department_id
        JOIN       departments  ad  ON ad.department_id = e.department_id
        WHERE      t.status = 'IN_REVIEW'
        ORDER BY   e.created_at DESC;

    COMMENT ON TABLE  v_open_escalations                             IS 'Live queue of all unresolved escalations, ordered oldest-first. Used as the primary escalation management view for support team dashboards and on-call monitoring.';
    COMMENT ON COLUMN v_open_escalations.escalation_id               IS 'Unique escalation event identifier.';
    COMMENT ON COLUMN v_open_escalations.ticket_id                   IS 'Ticket unique identifier.';
    COMMENT ON COLUMN v_open_escalations.ticket_status               IS 'Ticket lifecycle status.';
    COMMENT ON COLUMN v_open_escalations.subject                     IS 'Ticket subject line.';
    COMMENT ON COLUMN v_open_escalations.priority                    IS 'Ticket priority.';
    COMMENT ON COLUMN v_open_escalations.category_name               IS 'Category of the escalated ticket.';
    COMMENT ON COLUMN v_open_escalations.owning_department           IS 'Department that owns the ticket category.';
    COMMENT ON COLUMN v_open_escalations.assigned_team               IS 'Team assigned to resolve this escalation.';
    COMMENT ON COLUMN v_open_escalations.team_email                  IS 'Email address of the assigned team.';
    COMMENT ON COLUMN v_open_escalations.accuracy_score              IS 'Agent accuracy score at escalation time. Indicates how confident the agent was before escalating.';
    COMMENT ON COLUMN v_open_escalations.notified_at                 IS 'Timestamp when the team was notified.';
    COMMENT ON COLUMN v_open_escalations.notification_method         IS 'Notification channel used.';
    COMMENT ON COLUMN v_open_escalations.rule_name                   IS 'Routing rule name snapshot selected by the routing engine. NULL when category fallback was used.';
    COMMENT ON COLUMN v_open_escalations.routing_rule_id             IS 'Routing rule primary key selected by the routing engine. NULL when category fallback was used.';
    COMMENT ON COLUMN v_open_escalations.routing_rule_notes          IS 'Routing rule notes snapshot captured at escalation time for troubleshooting.';
    COMMENT ON COLUMN v_open_escalations.routing_rule_accuracy_score IS 'Confidence score produced by the routing engine when selecting the routing rule.';
    COMMENT ON COLUMN v_open_escalations.escalation_reason           IS 'Human-readable reason the agent escalated the ticket.';
    COMMENT ON COLUMN v_open_escalations.acknowledged_at             IS 'Timestamp when the team acknowledged. NULL if not yet acknowledged.';
    COMMENT ON COLUMN v_open_escalations.acknowledged_by             IS 'Team member who acknowledged the escalation.';
    COMMENT ON COLUMN v_open_escalations.escalation_state            IS 'Derived state: PENDING | NOTIFIED | ACKNOWLEDGED.';
    COMMENT ON COLUMN v_open_escalations.open_since_minutes          IS 'Minutes elapsed since the escalation was created. Used for SLA breach alerting.';
    COMMENT ON COLUMN v_open_escalations.submitter_name              IS 'Name of the ticket submitter.';
    COMMENT ON COLUMN v_open_escalations.submitter_email             IS 'Email of the ticket submitter.';
    COMMENT ON COLUMN v_open_escalations.escalated_at                IS 'Timestamp when the escalation was created.';

    -- =============================================================================
    -- V_AGENT_DAILY_STATS
    -- Daily aggregated agent performance metrics.
    -- Status machine:
    -- auto_answer=Y path: ...SCORING → ANSWERED → (notify) → RESOLVED
    -- auto_answer=Y fail: ...SCORING → ESCALATED → (notify) → IN_REVIEW
    -- auto_answer_auto_route=Y: ...SCORING → ESCALATED → (answer notify) → (escalation notify) → RESOLVED
    -- auto_answer=N path: ...CATEGORIZING → ESCALATED → (notify) → RESOLVED
    -- auto_route=N hold : ...ESCALATED → IN_REVIEW (manual)
    -- Terminal states    : RESOLVED, FAILED
    -- ANSWERED is a transient state; completed auto-answered tickets land in RESOLVED.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_agent_daily_stats AS
    WITH escalation_flags AS (
        SELECT DISTINCT
            e.ticket_id,
            1 AS has_escalation
        FROM escalations e
    ),
    base AS (
        SELECT
            TRUNC(CAST(t.timestamp_received AS DATE)) AS stat_date,
            t.ticket_id,
            t.status AS ticket_status,
            t.auto_answer,
            t.category_source,
            t.category_id,
            t.accuracy_score,
            CAST(t.timestamp_received AS DATE) AS ts_received,
            CAST(t.timestamp_resolved AS DATE) AS ts_resolved,
            NVL(ef.has_escalation, 0) AS has_escalation
        FROM tickets t
        LEFT JOIN escalation_flags ef
            ON ef.ticket_id = t.ticket_id
    )
    SELECT
        b.stat_date,
        COUNT(*) AS tickets_received,

        SUM(
            CASE
                WHEN b.ticket_status = 'ANSWERED' THEN 1
                WHEN b.ticket_status = 'RESOLVED'
                     AND b.auto_answer = 'Y'
                     AND b.has_escalation = 0 THEN 1
                ELSE 0
            END
        ) AS auto_answered,

        SUM(
            CASE
                WHEN b.ticket_status IN ('ESCALATED', 'IN_REVIEW') THEN 1
                WHEN b.ticket_status = 'RESOLVED'
                     AND (b.auto_answer = 'N' OR b.has_escalation = 1) THEN 1
                ELSE 0
            END
        ) AS escalated,

        SUM(
            CASE
                WHEN b.ticket_status = 'FAILED' THEN 1
                ELSE 0
            END
        ) AS failed,

        ROUND(
            AVG(
                CASE
                    WHEN b.ticket_status = 'ANSWERED' THEN 1
                    WHEN b.ticket_status = 'RESOLVED'
                         AND b.auto_answer = 'Y'
                         AND b.has_escalation = 0 THEN 1
                    ELSE 0
                END
            ) * 100,
            1
        ) AS auto_answer_rate_pct,

        ROUND(
            AVG(
                CASE
                    WHEN b.ticket_status IN ('ESCALATED', 'IN_REVIEW') THEN 1
                    WHEN b.ticket_status = 'RESOLVED'
                         AND (b.auto_answer = 'N' OR b.has_escalation = 1) THEN 1
                    ELSE 0
                END
            ) * 100,
            1
        ) AS escalation_rate_pct,

        ROUND(AVG(b.accuracy_score) * 100, 2) AS avg_accuracy_score,

        ROUND(
            AVG(
                CASE
                    WHEN b.ts_resolved IS NOT NULL
                    THEN (b.ts_resolved - b.ts_received) * 24 * 60
                    ELSE NULL
                END
            ),
            2
        ) AS avg_resolution_minutes,

        SUM(
            CASE
                WHEN b.category_source = 'AGENT_SUGGESTED' THEN 1
                ELSE 0
            END
        ) AS agent_categorised,

        COUNT(DISTINCT b.category_id) AS distinct_categories,

        SUM(
            CASE
                WHEN b.ticket_status IN (
                    'QUEUED',
                    'VALIDATING',
                    'CATEGORIZING',
                    'ANSWERING',
                    'SCORING'
                ) THEN 1
                ELSE 0
            END
        ) AS in_progress,

        SUM(
            CASE
                WHEN b.ticket_status = 'RESOLVED'
                     AND b.auto_answer = 'Y'
                     AND b.has_escalation = 0 THEN 1
                ELSE 0
            END
        ) AS resolved_auto,

        SUM(
            CASE
                WHEN b.ticket_status = 'RESOLVED'
                     AND (b.auto_answer = 'N' OR b.has_escalation = 1) THEN 1
                ELSE 0
            END
        ) AS resolved_human,

        ROUND(
            AVG(
                CASE
                    WHEN b.auto_answer = 'N' THEN 1
                    ELSE 0
                END
            ) * 100,
            1
        ) AS no_auto_answer_rate_pct,

        ROUND(AVG(b.accuracy_score), 4) AS avg_accuracy_score_raw,

        ROUND(
            AVG(
                CASE
                    WHEN b.ts_resolved IS NOT NULL
                         AND b.auto_answer = 'Y'
                         AND b.has_escalation = 0
                    THEN (b.ts_resolved - b.ts_received) * 24 * 60
                    ELSE NULL
                END
            ),
            2
        ) AS avg_resolution_mins_auto,

        ROUND(
            AVG(
                CASE
                    WHEN b.ts_resolved IS NOT NULL
                         AND (b.auto_answer = 'N' OR b.has_escalation = 1)
                    THEN (b.ts_resolved - b.ts_received) * 24 * 60
                    ELSE NULL
                END
            ),
            2
        ) AS avg_resolution_mins_human

    FROM base b
    GROUP BY b.stat_date
    /

    COMMENT ON TABLE  v_agent_daily_stats                           IS 'Daily aggregated agent performance metrics. Provides a time-series view of ticket volumes, auto-answer rate, escalation rate and average accuracy. Used for operational trend dashboards and anomaly detection.';
    COMMENT ON COLUMN v_agent_daily_stats.stat_date                 IS 'Calendar date (truncated to midnight) for the aggregation period.';
    COMMENT ON COLUMN v_agent_daily_stats.tickets_received          IS 'Total tickets ingested on this date.';
    COMMENT ON COLUMN v_agent_daily_stats.auto_answered             IS 'Tickets answered autonomously by the agent: status=ANSWERED (delivery in-flight) plus status=RESOLVED via auto-answer path (auto_answer=Y, no escalation record).';
    COMMENT ON COLUMN v_agent_daily_stats.escalated                 IS 'Tickets that required human involvement: status ESCALATED or IN_REVIEW (open) plus status RESOLVED via escalation path (escalation record exists or auto_answer=N).';
    COMMENT ON COLUMN v_agent_daily_stats.failed                    IS 'Tickets that reached FAILED terminal status on this date.';
    COMMENT ON COLUMN v_agent_daily_stats.auto_answer_rate_pct      IS 'Percentage of received tickets answered autonomously by the agent without human involvement (auto_answered / tickets_received * 100).';
    COMMENT ON COLUMN v_agent_daily_stats.escalation_rate_pct       IS 'Percentage of received tickets that required any human involvement — open + resolved-via-human — divided by tickets_received * 100.';
    COMMENT ON COLUMN v_agent_daily_stats.avg_accuracy_score        IS 'Average LLM-as-a-judge composite score expressed as a percentage (0–100). Tickets without a score (auto_answer=N or not yet scored) contribute NULL and are excluded from the average.';
    COMMENT ON COLUMN v_agent_daily_stats.avg_resolution_minutes    IS 'Average end-to-end resolution time in minutes for all tickets that reached a terminal state (RESOLVED or FAILED) on this date.';
    COMMENT ON COLUMN v_agent_daily_stats.agent_categorised         IS 'Number of tickets where the agent overrode the submitted category (category_source=AGENT_SUGGESTED) on this date.';
    COMMENT ON COLUMN v_agent_daily_stats.distinct_categories       IS 'Number of distinct categories seen across all tickets ingested on this date.';
    COMMENT ON COLUMN v_agent_daily_stats.in_progress               IS 'Tickets still being processed or waiting in the agent pipeline (QUEUED, VALIDATING, CATEGORIZING, ANSWERING, SCORING) at query time.';
    COMMENT ON COLUMN v_agent_daily_stats.resolved_auto             IS 'RESOLVED tickets that completed the auto-answer path (auto_answer=Y, no escalation record).';
    COMMENT ON COLUMN v_agent_daily_stats.resolved_human            IS 'RESOLVED tickets that completed the human/escalation path (escalation record exists or auto_answer=N).';
    COMMENT ON COLUMN v_agent_daily_stats.no_auto_answer_rate_pct   IS 'Percentage of received tickets where auto_answer=N — categories configured for direct human routing with no AI answer generated.';
    COMMENT ON COLUMN v_agent_daily_stats.avg_accuracy_score_raw    IS 'Average LLM-as-a-judge composite score as a raw decimal (0.0000–1.0000) for direct threshold comparisons.';
    COMMENT ON COLUMN v_agent_daily_stats.avg_resolution_mins_auto  IS 'Average resolution time in minutes for tickets resolved via the auto-answer path only.';
    COMMENT ON COLUMN v_agent_daily_stats.avg_resolution_mins_human IS 'Average resolution time in minutes for tickets resolved via the human/escalation path only.';

-- =============================================================================
-- TICKET RESPONSE AGENT — ANALYTICS VIEWS
-- Description : Analytics and KPI views for the AI Ticket Response Agent.
-- These views are designed for dashboards, BI tools, and
-- operational reporting on top of the core data model.
-- Version     : 2.0
-- Date        : March 2026
-- =============================================================================

    -- ----------
    -- VIEW INDEX
    -- ----------
    --  1. V_ANALYTICS_TICKETS_BY_DEPT_STATUS_CAT   Ticket counts by dept/status/category
    --  2. V_ANALYTICS_ACCURACY_BY_RESOLUTION_TYPE  Avg accuracy: auto-answered vs escalated
    --  3. V_ANALYTICS_RESOLUTION_TIMINGS           Resolution time stats by resolution path
    --  4. V_ANALYTICS_CATEGORISATION_QUALITY       Categorisation success rates per category
    --  5. V_ANALYTICS_ESCALATION_BY_TEAM_CATEGORY  Escalation volume & SLA by team/category
    --  6. V_ANALYTICS_ACCURACY_BY_DEPT_CATEGORY    Full accuracy analytics by dept/category
    --  7. V_ANALYTICS_DAILY_THROUGHPUT             Daily operational throughput per dept
    --  8. V_ANALYTICS_PIPELINE_HEALTH              Live pipeline snapshot (non-terminal tickets)
    --  9. V_ANALYTICS_CHANNEL_PERFORMANCE          Performance metrics by ingestion channel
    -- 10. V_ANALYTICS_ESCALATION_SLA               SLA compliance for escalations
    -- 11. V_ANALYTICS_AGENT_KB_VERSION_QUALITY     Score quality per Knowledge Base version
    -- 12. V_ANALYTICS_RECATEGORISATION_IMPACT      Outcome impact of recategorisation events
    -- =============================================================================
    -- V_ANALYTICS_TICKETS_BY_DEPT_STATUS_CAT
    -- VIEW 1 : V_ANALYTICS_TICKETS_BY_DEPT_STATUS_CAT
    -- Purpose : Ticket counts broken down by department, status, category and
    -- priority. Exposes how many tickets were properly answered
    -- (ANSWERED / RESOLVED) versus those pending, escalated or failed.
    -- Key KPIs: total_tickets, properly_answered, escalated, failed,
    -- pct_answered, pct_escalated.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_analytics_tickets_by_dept_status_cat AS
        SELECT
            d.department_name,
            d.department_code,
            c.category_name,
            c.category_code,
            t.status,
            t.priority,
            COUNT(t.ticket_id)                                                         AS total_tickets,
            COUNT(CASE WHEN t.status IN ('ANSWERED','RESOLVED')       THEN 1 END)     AS properly_answered,
            COUNT(CASE WHEN t.status = 'ESCALATED'                    THEN 1 END)     AS escalated,
            COUNT(CASE WHEN t.status = 'IN_REVIEW'                    THEN 1 END)     AS in_review,
            COUNT(CASE WHEN t.status = 'FAILED'                       THEN 1 END)     AS failed,
            COUNT(CASE WHEN t.status NOT IN
            ('ANSWERED','RESOLVED','FAILED','ESCALATED','IN_REVIEW')
                THEN 1 END)     AS in_progress,
            ROUND(
            COUNT(CASE WHEN t.status IN ('ANSWERED','RESOLVED') THEN 1 END)
            / NULLIF(COUNT(t.ticket_id), 0) * 100
            , 2)                                                                       AS pct_answered,
            ROUND(
            COUNT(CASE WHEN t.status = 'ESCALATED' THEN 1 END)
            / NULLIF(COUNT(t.ticket_id), 0) * 100
            , 2)                                                                       AS pct_escalated,
            ROUND(
            COUNT(CASE WHEN t.status = 'FAILED' THEN 1 END)
            / NULLIF(COUNT(t.ticket_id), 0) * 100
            , 2)                                                                       AS pct_failed
        FROM tickets t
        LEFT JOIN categories  c ON c.category_id   = t.category_id
        LEFT JOIN departments d ON d.department_id = t.department_id
        GROUP BY
            d.department_name,
            d.department_code,
            c.category_name,
            c.category_code,
            t.status,
            t.priority;

    COMMENT ON TABLE v_analytics_tickets_by_dept_status_cat IS 'KPI view: ticket counts broken down by department, category, status and priority. Shows properly answered (ANSWERED/RESOLVED) vs escalated, in-review, failed and in-progress counts with percentage rates per grouping. Use for operational dashboards and department-level reporting. Sources: tickets, categories, departments.';

    COMMENT ON COLUMN v_analytics_tickets_by_dept_status_cat.department_name   IS 'Full name of the department owning the tickets in this grouping.';
    COMMENT ON COLUMN v_analytics_tickets_by_dept_status_cat.department_code   IS 'Short alphanumeric code identifying the department; matches DEPARTMENTS.DEPARTMENT_CODE.';
    COMMENT ON COLUMN v_analytics_tickets_by_dept_status_cat.category_name     IS 'Full display name of the ticket category in this grouping.';
    COMMENT ON COLUMN v_analytics_tickets_by_dept_status_cat.category_code     IS 'Short alphanumeric code identifying the ticket category; matches CATEGORIES.CATEGORY_CODE.';
    COMMENT ON COLUMN v_analytics_tickets_by_dept_status_cat.status            IS 'Current lifecycle status of the tickets in this grouping (ANSWERED, RESOLVED, ESCALATED, IN_REVIEW, FAILED, or an active in-progress status).';
    COMMENT ON COLUMN v_analytics_tickets_by_dept_status_cat.priority          IS 'Priority level assigned to the tickets in this grouping (e.g. LOW, MEDIUM, HIGH, CRITICAL).';
    COMMENT ON COLUMN v_analytics_tickets_by_dept_status_cat.total_tickets     IS 'Total number of tickets in this department / category / status / priority combination.';
    COMMENT ON COLUMN v_analytics_tickets_by_dept_status_cat.properly_answered IS 'Count of tickets whose final status is ANSWERED or RESOLVED, indicating the agent or team provided a complete response.';
    COMMENT ON COLUMN v_analytics_tickets_by_dept_status_cat.escalated         IS 'Count of tickets whose current status is ESCALATED, indicating they were handed off to a human team.';
    COMMENT ON COLUMN v_analytics_tickets_by_dept_status_cat.in_review         IS 'Count of tickets currently under human review (status IN_REVIEW).';
    COMMENT ON COLUMN v_analytics_tickets_by_dept_status_cat.failed            IS 'Count of tickets that entered a FAILED terminal state due to processing errors or unresolvable conditions.';
    COMMENT ON COLUMN v_analytics_tickets_by_dept_status_cat.in_progress       IS 'Count of tickets in any active non-terminal status other than ANSWERED, RESOLVED, ESCALATED, IN_REVIEW, or FAILED.';
    COMMENT ON COLUMN v_analytics_tickets_by_dept_status_cat.pct_answered      IS 'Percentage of total_tickets that were properly answered or resolved; calculated as properly_answered / total_tickets * 100.';
    COMMENT ON COLUMN v_analytics_tickets_by_dept_status_cat.pct_escalated     IS 'Percentage of total_tickets that were escalated; calculated as escalated / total_tickets * 100.';
    COMMENT ON COLUMN v_analytics_tickets_by_dept_status_cat.pct_failed        IS 'Percentage of total_tickets that failed; calculated as failed / total_tickets * 100.';

    -- =============================================================================
    -- VIEW 2 : V_ANALYTICS_ACCURACY_BY_RESOLUTION_TYPE
    -- Purpose : Average LLM accuracy scores for tickets resolved autonomously by
    -- the agent (AUTO_ANSWERED) vs. tickets that required human review
    -- (ESCALATED). Includes all three scoring dimensions.
    -- Key KPIs: avg_composite_score, avg_relevance_score, avg_completeness_score,
    -- avg_faithfulness_score, scored_above_threshold.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_analytics_accuracy_by_resolution_type AS
        SELECT
            CASE
                WHEN t.status = 'ANSWERED'
            AND NOT EXISTS (
        SELECT 1 FROM escalations e WHERE e.ticket_id = t.ticket_id
            )                             THEN 'AUTO_ANSWERED'
                WHEN t.status IN ('ESCALATED', 'IN_REVIEW', 'RESOLVED')
            OR EXISTS (
        SELECT 1 FROM escalations e WHERE e.ticket_id = t.ticket_id
            )                             THEN 'ESCALATED'
                ELSE 'OTHER'
            END                                                         AS resolution_type,
            d.department_name,
            c.category_name,
            COUNT(DISTINCT t.ticket_id)                                 AS total_tickets,
            ROUND(AVG(t.accuracy_score),         4)                    AS avg_composite_score,
            ROUND(AVG(a.relevance_score),        4)                    AS avg_relevance_score,
            ROUND(AVG(a.completeness_score),     4)                    AS avg_completeness_score,
            ROUND(AVG(a.faithfulness_score),     4)                    AS avg_faithfulness_score,
            ROUND(MIN(t.accuracy_score),         4)                    AS min_composite_score,
            ROUND(MAX(t.accuracy_score),         4)                    AS max_composite_score,
            ROUND(STDDEV(a.composite_score),     4)                    AS stddev_composite_score,
            COUNT(CASE WHEN a.passed_threshold = 'Y' THEN 1 END)       AS scored_above_threshold,
            COUNT(CASE WHEN a.passed_threshold = 'N' THEN 1 END)       AS scored_below_threshold,
            ROUND(
            COUNT(CASE WHEN a.passed_threshold = 'Y' THEN 1 END)
            / NULLIF(COUNT(a.score_id), 0) * 100
            , 2)                                                        AS pct_above_threshold
        FROM tickets t
        LEFT JOIN categories      c ON c.category_id   = t.category_id
        LEFT JOIN departments     d ON d.department_id = t.department_id
        LEFT JOIN accuracy_scores a ON a.ticket_id     = t.ticket_id
        WHERE t.accuracy_score IS NOT NULL
        GROUP BY
            CASE
                WHEN t.status = 'ANSWERED'
            AND NOT EXISTS (SELECT 1 FROM escalations e WHERE e.ticket_id = t.ticket_id)
                THEN 'AUTO_ANSWERED'
                WHEN t.status IN ('ESCALATED', 'IN_REVIEW', 'RESOLVED')
            OR EXISTS (SELECT 1 FROM escalations e WHERE e.ticket_id = t.ticket_id)
                THEN 'ESCALATED'
                ELSE 'OTHER'
            END,
            d.department_name,
            c.category_name;

    COMMENT ON TABLE v_analytics_accuracy_by_resolution_type IS 'KPI view: average LLM accuracy scores (composite + all dimensions) split by resolution type (AUTO_ANSWERED vs ESCALATED) per department and category. Use to compare agent answer quality between autonomous and human-reviewed resolutions and to identify departments or categories where auto-answer quality is insufficient. Sources: tickets, categories, departments, accuracy_scores, escalations.';

    COMMENT ON COLUMN v_analytics_accuracy_by_resolution_type.resolution_type        IS 'Derived resolution classification: AUTO_ANSWERED (agent resolved without escalation), ESCALATED (ticket was or is escalated/in-review/resolved-after-escalation), or OTHER.';
    COMMENT ON COLUMN v_analytics_accuracy_by_resolution_type.department_name        IS 'Full name of the department associated with the tickets in this grouping.';
    COMMENT ON COLUMN v_analytics_accuracy_by_resolution_type.category_name          IS 'Full display name of the ticket category in this grouping.';
    COMMENT ON COLUMN v_analytics_accuracy_by_resolution_type.total_tickets          IS 'Count of distinct tickets in this resolution_type / department / category combination.';
    COMMENT ON COLUMN v_analytics_accuracy_by_resolution_type.avg_composite_score    IS 'Average composite LLM accuracy score (from TICKETS.ACCURACY_SCORE) for tickets in this group, rounded to 4 decimal places.';
    COMMENT ON COLUMN v_analytics_accuracy_by_resolution_type.avg_relevance_score    IS 'Average relevance dimension score from ACCURACY_SCORES; measures how closely the agent answer addresses the question asked.';
    COMMENT ON COLUMN v_analytics_accuracy_by_resolution_type.avg_completeness_score IS 'Average completeness dimension score from ACCURACY_SCORES; measures how fully the answer covers all aspects of the question.';
    COMMENT ON COLUMN v_analytics_accuracy_by_resolution_type.avg_faithfulness_score IS 'Average faithfulness dimension score from ACCURACY_SCORES; measures how factually grounded the answer is relative to retrieved KB content.';
    COMMENT ON COLUMN v_analytics_accuracy_by_resolution_type.min_composite_score    IS 'Minimum composite accuracy score observed in this group; useful for identifying worst-case answer quality.';
    COMMENT ON COLUMN v_analytics_accuracy_by_resolution_type.max_composite_score    IS 'Maximum composite accuracy score observed in this group.';
    COMMENT ON COLUMN v_analytics_accuracy_by_resolution_type.stddev_composite_score IS 'Standard deviation of composite accuracy scores in this group; high values indicate inconsistent answer quality.';
    COMMENT ON COLUMN v_analytics_accuracy_by_resolution_type.scored_above_threshold IS 'Count of scored tickets where ACCURACY_SCORES.PASSED_THRESHOLD = ''Y''.';
    COMMENT ON COLUMN v_analytics_accuracy_by_resolution_type.scored_below_threshold IS 'Count of scored tickets where ACCURACY_SCORES.PASSED_THRESHOLD = ''N''.';
    COMMENT ON COLUMN v_analytics_accuracy_by_resolution_type.pct_above_threshold    IS 'Percentage of scored tickets that passed the quality threshold; calculated as scored_above_threshold / total scored * 100.';

    -- =============================================================================
    -- VIEW 3 : V_ANALYTICS_RESOLUTION_TIMINGS
    -- Purpose : Resolution time statistics (avg, min, max, median) in minutes,
    -- segmented by resolution path, department, category and priority.
    -- Surfaces time-to-score, time-to-escalation and escalation-to-
    -- resolution durations derived from the status history.
    -- Key KPIs: avg_total_resolution_mins, median_resolution_mins,
    -- avg_mins_to_escalation, avg_mins_escalated_to_resolved.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_analytics_resolution_timings AS
            WITH ticket_path AS (
        SELECT
            t.ticket_id,
            t.department_id,
            t.category_id,
            t.priority,
            t.timestamp_received,
            t.timestamp_resolved,
            ROUND(
                    (CAST(t.timestamp_resolved AS DATE)
                    - CAST(t.timestamp_received AS DATE)) * 24 * 60
                    , 2)                                                            AS total_resolution_minutes,
            CASE
                WHEN t.status = 'ANSWERED'
            AND NOT EXISTS (
        SELECT 1 FROM escalations e WHERE e.ticket_id = t.ticket_id
            )                                                       THEN 'AUTO_ANSWERED'
                WHEN EXISTS (
        SELECT 1 FROM escalations e WHERE e.ticket_id = t.ticket_id
            )                                                       THEN 'ESCALATED_MANUAL'
                ELSE 'OTHER'
            END                                                             AS resolution_path,
    -- Minutes from ANSWERING stage start to SCORING stage start
            (SELECT ROUND(
                    (CAST(MIN(h2.created_at) AS DATE)
                    - CAST(MIN(h1.created_at) AS DATE)) * 24 * 60
                    , 2)
        FROM ticket_status_history h1
        JOIN ticket_status_history h2
                    ON h2.ticket_id  = h1.ticket_id
                    AND h2.to_status  = 'SCORING'
        WHERE h1.ticket_id = t.ticket_id
                    AND h1.to_status = 'ANSWERING')                              AS mins_to_score,
    -- Minutes from ingestion to first ESCALATED transition
            (SELECT ROUND(
                    (CAST(MIN(h.created_at) AS DATE)
                    - CAST(t.timestamp_received AS DATE)) * 24 * 60
                    , 2)
        FROM ticket_status_history h
        WHERE h.ticket_id = t.ticket_id
                    AND h.to_status = 'ESCALATED')                               AS mins_to_escalation,
    -- Minutes from ESCALATED transition to RESOLVED transition
            (SELECT ROUND(
                    (CAST(MAX(h2.created_at) AS DATE)
                    - CAST(MIN(h1.created_at) AS DATE)) * 24 * 60
                    , 2)
        FROM ticket_status_history h1
        JOIN ticket_status_history h2
                    ON h2.ticket_id  = h1.ticket_id
                    AND h2.to_status  = 'RESOLVED'
        WHERE h1.ticket_id = t.ticket_id
                    AND h1.to_status = 'ESCALATED')                              AS mins_escalated_to_resolved
        FROM tickets t
        WHERE t.timestamp_resolved IS NOT NULL
            )
        SELECT
            tp.resolution_path,
            d.department_name,
            c.category_name,
            tp.priority,
            COUNT(tp.ticket_id)                                         AS total_tickets,
            ROUND(AVG(tp.total_resolution_minutes),    2)              AS avg_total_resolution_mins,
            ROUND(MIN(tp.total_resolution_minutes),    2)              AS min_resolution_mins,
            ROUND(MAX(tp.total_resolution_minutes),    2)              AS max_resolution_mins,
            ROUND(MEDIAN(tp.total_resolution_minutes), 2)              AS median_resolution_mins,
            ROUND(STDDEV(tp.total_resolution_minutes), 2)              AS stddev_resolution_mins,
            ROUND(AVG(tp.mins_to_score),               2)              AS avg_mins_to_score,
            ROUND(AVG(tp.mins_to_escalation),          2)              AS avg_mins_to_escalation,
            ROUND(AVG(tp.mins_escalated_to_resolved),  2)              AS avg_mins_escalated_to_resolved
        FROM ticket_path tp
        LEFT JOIN categories  c ON c.category_id   = tp.category_id
        LEFT JOIN departments d ON d.department_id = tp.department_id
        GROUP BY
            tp.resolution_path,
            d.department_name,
            c.category_name,
            tp.priority;

    COMMENT ON TABLE v_analytics_resolution_timings IS 'KPI view: resolution time statistics (avg, min, max, median, stddev) in minutes, split by resolution path (AUTO_ANSWERED vs ESCALATED_MANUAL), department, category and priority. Also surfaces average time-to-score, time-to-escalation and escalation-to-resolution sub-timings. Only includes tickets where TIMESTAMP_RESOLVED IS NOT NULL. Use for SLA monitoring, bottleneck identification and performance benchmarking. Sources: tickets, categories, departments, escalations, ticket_status_history.';

    COMMENT ON COLUMN v_analytics_resolution_timings.resolution_path                IS 'How the ticket was ultimately resolved: AUTO_ANSWERED (no escalation), ESCALATED_MANUAL (had at least one escalation record), or OTHER.';
    COMMENT ON COLUMN v_analytics_resolution_timings.department_name                IS 'Full name of the department that owned the ticket.';
    COMMENT ON COLUMN v_analytics_resolution_timings.category_name                  IS 'Full display name of the ticket category.';
    COMMENT ON COLUMN v_analytics_resolution_timings.priority                       IS 'Priority level of the tickets in this grouping (e.g. LOW, MEDIUM, HIGH, CRITICAL).';
    COMMENT ON COLUMN v_analytics_resolution_timings.total_tickets                  IS 'Count of fully resolved tickets in this resolution_path / department / category / priority combination.';
    COMMENT ON COLUMN v_analytics_resolution_timings.avg_total_resolution_mins      IS 'Average end-to-end resolution time in minutes from TIMESTAMP_RECEIVED to TIMESTAMP_RESOLVED.';
    COMMENT ON COLUMN v_analytics_resolution_timings.min_resolution_mins            IS 'Minimum end-to-end resolution time in minutes observed in this group.';
    COMMENT ON COLUMN v_analytics_resolution_timings.max_resolution_mins            IS 'Maximum end-to-end resolution time in minutes observed in this group.';
    COMMENT ON COLUMN v_analytics_resolution_timings.median_resolution_mins         IS 'Median end-to-end resolution time in minutes; less sensitive to outliers than the average.';
    COMMENT ON COLUMN v_analytics_resolution_timings.stddev_resolution_mins         IS 'Standard deviation of resolution times in minutes; high values indicate high variability in throughput.';
    COMMENT ON COLUMN v_analytics_resolution_timings.avg_mins_to_score              IS 'Average minutes elapsed from the ANSWERING stage start to the SCORING stage start, derived from TICKET_STATUS_HISTORY.';
    COMMENT ON COLUMN v_analytics_resolution_timings.avg_mins_to_escalation         IS 'Average minutes from TIMESTAMP_RECEIVED to the first ESCALATED status transition, derived from TICKET_STATUS_HISTORY.';
    COMMENT ON COLUMN v_analytics_resolution_timings.avg_mins_escalated_to_resolved IS 'Average minutes from the first ESCALATED status transition to the RESOLVED status transition; measures human resolution turnaround time.';

    -- =============================================================================
    -- VIEW 4 : V_ANALYTICS_CATEGORISATION_QUALITY
    -- Purpose : Categorisation accuracy per category. Shows how many tickets were
    -- accepted as submitted, overridden by the agent, or further
    -- corrected by a human reviewer. Identifies categories with the
    -- lowest first-time correct-categorisation rates.
    -- Key KPIs: pct_correct_first_time, pct_agent_override, pct_human_override,
    -- avg_confidence_score.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_analytics_categorisation_quality AS
        SELECT
            c.category_name,
            c.category_code,
            d.department_name,
            COUNT(cl.log_id)                                                           AS total_categorisations,
            COUNT(CASE WHEN cl.was_overridden = 'N'
            AND t.category_source = 'SUBMITTER'              THEN 1 END)  AS accepted_as_submitted,
            COUNT(CASE WHEN cl.was_overridden = 'Y'
            AND t.category_source = 'AGENT_SUGGESTED'        THEN 1 END)  AS overridden_by_agent,
            COUNT(CASE WHEN t.category_source = 'HUMAN_OVERRIDE'        THEN 1 END)  AS overridden_by_human,
            COUNT(CASE WHEN cl.was_overridden = 'Y'
            OR  t.category_source = 'HUMAN_OVERRIDE'         THEN 1 END)  AS total_recategorised,
            ROUND(
            COUNT(CASE WHEN cl.was_overridden = 'N'
                    AND t.category_source = 'SUBMITTER' THEN 1 END)
            / NULLIF(COUNT(cl.log_id), 0) * 100
            , 2)                                                                       AS pct_correct_first_time,
            ROUND(
            COUNT(CASE WHEN cl.was_overridden = 'Y'
                    AND t.category_source = 'AGENT_SUGGESTED' THEN 1 END)
            / NULLIF(COUNT(cl.log_id), 0) * 100
            , 2)                                                                       AS pct_agent_override,
            ROUND(
            COUNT(CASE WHEN t.category_source = 'HUMAN_OVERRIDE' THEN 1 END)
            / NULLIF(COUNT(cl.log_id), 0) * 100
            , 2)                                                                       AS pct_human_override,
            ROUND(AVG(cl.confidence_score),  4)                                        AS avg_confidence_score,
            ROUND(MIN(cl.confidence_score),  4)                                        AS min_confidence_score,
            ROUND(MAX(cl.confidence_score),  4)                                        AS max_confidence_score,
            ROUND(STDDEV(cl.confidence_score), 4)                                      AS stddev_confidence_score
        FROM ticket_categorisation_log cl
        JOIN tickets      t  ON t.ticket_id    = cl.ticket_id
        LEFT JOIN categories  c ON c.category_id   = cl.suggested_category_id
        LEFT JOIN departments d ON d.department_id = c.department_id
        GROUP BY
            c.category_name,
            c.category_code,
            d.department_name;

    COMMENT ON TABLE v_analytics_categorisation_quality IS 'KPI view: categorisation accuracy per category and department. Shows accepted-as-submitted, agent-override, and human-override counts and percentage rates. Includes confidence score statistics (avg, min, max, stddev). Use to identify categories with the lowest first-time correct-categorisation rates and to guide model fine-tuning or category taxonomy improvements. Sources: ticket_categorisation_log, tickets, categories, departments.';

    COMMENT ON COLUMN v_analytics_categorisation_quality.category_name           IS 'Full display name of the ticket category being evaluated.';
    COMMENT ON COLUMN v_analytics_categorisation_quality.category_code           IS 'Short alphanumeric code for the category; matches CATEGORIES.CATEGORY_CODE.';
    COMMENT ON COLUMN v_analytics_categorisation_quality.department_name         IS 'Full name of the department that owns this category.';
    COMMENT ON COLUMN v_analytics_categorisation_quality.total_categorisations   IS 'Total number of categorisation log entries for this category.';
    COMMENT ON COLUMN v_analytics_categorisation_quality.accepted_as_submitted   IS 'Count of tickets where the submitter-provided category was accepted without override (WAS_OVERRIDDEN=N and CATEGORY_SOURCE=SUBMITTER).';
    COMMENT ON COLUMN v_analytics_categorisation_quality.overridden_by_agent     IS 'Count of tickets where the agent suggested a different category and the suggestion was accepted (WAS_OVERRIDDEN=Y and CATEGORY_SOURCE=AGENT_SUGGESTED).';
    COMMENT ON COLUMN v_analytics_categorisation_quality.overridden_by_human     IS 'Count of tickets where a human reviewer manually changed the final category (CATEGORY_SOURCE=HUMAN_OVERRIDE).';
    COMMENT ON COLUMN v_analytics_categorisation_quality.total_recategorised     IS 'Count of tickets that were recategorised at any stage by either the agent or a human reviewer.';
    COMMENT ON COLUMN v_analytics_categorisation_quality.pct_correct_first_time  IS 'Percentage of total categorisations accepted as originally submitted without any override; the primary quality KPI for categorisation accuracy.';
    COMMENT ON COLUMN v_analytics_categorisation_quality.pct_agent_override      IS 'Percentage of total categorisations where the agent overrode the submitter category.';
    COMMENT ON COLUMN v_analytics_categorisation_quality.pct_human_override      IS 'Percentage of total categorisations where a human reviewer further overrode the agent-suggested or submitter category.';
    COMMENT ON COLUMN v_analytics_categorisation_quality.avg_confidence_score    IS 'Average model confidence score for category predictions in this group, on a 0-1 scale.';
    COMMENT ON COLUMN v_analytics_categorisation_quality.min_confidence_score    IS 'Minimum confidence score observed; identifies the least certain categorisation in this group.';
    COMMENT ON COLUMN v_analytics_categorisation_quality.max_confidence_score    IS 'Maximum confidence score observed in this group.';
    COMMENT ON COLUMN v_analytics_categorisation_quality.stddev_confidence_score IS 'Standard deviation of confidence scores; high values indicate inconsistent model certainty for this category.';

    -- =============================================================================
    -- VIEW 5 : V_ANALYTICS_ESCALATION_BY_TEAM_CATEGORY
    -- Purpose : Volume and SLA metrics for escalations broken down by receiving
    -- team and ticket category. Surfaces workload concentration,
    -- acknowledgement lag and resolution duration per team.
    -- Key KPIs: total_escalations, pct_acknowledged, pct_resolved,
    -- avg_ack_minutes, avg_resolution_minutes,
    -- avg_accuracy_at_escalation.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_analytics_escalation_by_team_category AS
        SELECT
            ad.department_name                                          AS assigned_team,
            ad.department_code                                         AS assigned_team_code,
            c.category_name,
            c.category_code,
            t.priority,
            e.notification_method,
            COUNT(e.escalation_id)                                     AS total_escalations,
            COUNT(CASE WHEN e.acknowledged_at IS NOT NULL THEN 1 END)  AS acknowledged_count,
            COUNT(CASE WHEN e.resolved_at     IS NOT NULL THEN 1 END)  AS resolved_count,
            COUNT(CASE WHEN e.acknowledged_at IS NULL
            AND e.notified_at      IS NOT NULL THEN 1 END)  AS pending_ack_count,
            COUNT(CASE WHEN e.notified_at     IS NULL      THEN 1 END) AS not_yet_notified_count,
            ROUND(
            COUNT(CASE WHEN e.acknowledged_at IS NOT NULL THEN 1 END)
            / NULLIF(COUNT(e.escalation_id), 0) * 100
            , 2)                                                        AS pct_acknowledged,
            ROUND(
            COUNT(CASE WHEN e.resolved_at IS NOT NULL THEN 1 END)
            / NULLIF(COUNT(e.escalation_id), 0) * 100
            , 2)                                                        AS pct_resolved,
            ROUND(AVG(
                    CASE WHEN e.acknowledged_at IS NOT NULL
                THEN (CAST(e.acknowledged_at AS DATE)
                    - CAST(e.notified_at   AS DATE)) * 24 * 60
            END
            ), 2)                                                       AS avg_ack_minutes,
            ROUND(AVG(
                    CASE WHEN e.resolved_at IS NOT NULL
                THEN (CAST(e.resolved_at  AS DATE)
                    - CAST(e.created_at AS DATE)) * 24 * 60
            END
            ), 2)                                                       AS avg_resolution_minutes,
            ROUND(MIN(
                    CASE WHEN e.resolved_at IS NOT NULL
                THEN (CAST(e.resolved_at  AS DATE)
                    - CAST(e.created_at AS DATE)) * 24 * 60
            END
            ), 2)                                                       AS min_resolution_minutes,
            ROUND(MAX(
                    CASE WHEN e.resolved_at IS NOT NULL
                THEN (CAST(e.resolved_at  AS DATE)
                    - CAST(e.created_at AS DATE)) * 24 * 60
            END
            ), 2)                                                       AS max_resolution_minutes,
            ROUND(AVG(e.accuracy_score), 4)                            AS avg_accuracy_at_escalation,
            COUNT(DISTINCT t.submitter_email)                          AS unique_submitters
        FROM escalations  e
        JOIN tickets      t  ON t.ticket_id      = e.ticket_id
        JOIN departments  ad ON ad.department_id = e.department_id
        LEFT JOIN categories c ON c.category_id  = t.category_id
        GROUP BY
            ad.department_name,
            ad.department_code,
            c.category_name,
            c.category_code,
            t.priority,
            e.notification_method;

    COMMENT ON TABLE v_analytics_escalation_by_team_category IS 'KPI view: escalation volume and SLA metrics per receiving team, ticket category, priority and notification method. Tracks acknowledged, resolved and pending counts with percentage rates, average acknowledgement and resolution durations, and average agent accuracy score at escalation time. Use for team workload monitoring, escalation SLA dashboards and routing rule reviews. Sources: escalations, tickets, departments, categories.';

    COMMENT ON COLUMN v_analytics_escalation_by_team_category.assigned_team              IS 'Full name of the department (team) that received the escalation, from DEPARTMENTS.DEPARTMENT_NAME.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.assigned_team_code         IS 'Short code for the receiving team; matches DEPARTMENTS.DEPARTMENT_CODE.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.category_name              IS 'Full display name of the ticket category involved in the escalation.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.category_code              IS 'Short code for the ticket category; matches CATEGORIES.CATEGORY_CODE.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.priority                   IS 'Priority level of the escalated tickets in this grouping.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.notification_method        IS 'Method used to notify the team of the escalation (e.g. EMAIL, SLACK, WEBHOOK, SMS).';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.total_escalations          IS 'Total number of escalation records in this team / category / priority / notification_method combination.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.acknowledged_count         IS 'Count of escalations where the team has set an ACKNOWLEDGED_AT timestamp.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.resolved_count             IS 'Count of escalations where the team has set a RESOLVED_AT timestamp.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.pending_ack_count          IS 'Count of escalations that have been notified but not yet acknowledged (NOTIFIED_AT IS NOT NULL AND ACKNOWLEDGED_AT IS NULL).';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.not_yet_notified_count     IS 'Count of escalations where NOTIFIED_AT is still NULL; these have not yet triggered a team notification.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.pct_acknowledged           IS 'Percentage of total escalations that have been acknowledged by the receiving team.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.pct_resolved               IS 'Percentage of total escalations that have been fully resolved by the receiving team.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.avg_ack_minutes            IS 'Average minutes from NOTIFIED_AT to ACKNOWLEDGED_AT for acknowledged escalations; measures team response speed.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.avg_resolution_minutes     IS 'Average minutes from ESCALATIONS.CREATED_AT to RESOLVED_AT for resolved escalations.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.min_resolution_minutes     IS 'Minimum resolution time in minutes observed for resolved escalations in this group.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.max_resolution_minutes     IS 'Maximum resolution time in minutes observed for resolved escalations in this group.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.avg_accuracy_at_escalation IS 'Average agent accuracy score (ESCALATIONS.ACCURACY_SCORE) at the moment the ticket was escalated; lower values indicate the agent recognised its own uncertainty before escalating.';
    COMMENT ON COLUMN v_analytics_escalation_by_team_category.unique_submitters          IS 'Count of distinct submitter email addresses among escalated tickets in this group; indicates breadth of impact.';

    -- =============================================================================
    -- VIEW 6 : V_ANALYTICS_ACCURACY_BY_DEPT_CATEGORY
    -- Purpose : Comprehensive accuracy score analytics aggregated by department,
    -- category and judge model. Covers all scoring dimensions with full
    -- descriptive statistics to support model quality monitoring and
    -- threshold calibration.
    -- Key KPIs: avg/median/stddev composite_score, pct_passed_threshold,
    -- avg_relevance/completeness/faithfulness scores.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_analytics_accuracy_by_dept_category AS
        SELECT
            d.department_name,
            d.department_code,
            c.category_name,
            c.category_code,
            a.judge_model,
            COUNT(a.score_id)                                   AS total_scored_tickets,
            ROUND(AVG(a.composite_score),      4)               AS avg_composite_score,
            ROUND(MEDIAN(a.composite_score),   4)               AS median_composite_score,
            ROUND(STDDEV(a.composite_score),   4)               AS stddev_composite_score,
            ROUND(MIN(a.composite_score),      4)               AS min_composite_score,
            ROUND(MAX(a.composite_score),      4)               AS max_composite_score,
            ROUND(AVG(a.relevance_score),      4)               AS avg_relevance_score,
            ROUND(AVG(a.completeness_score),   4)               AS avg_completeness_score,
            ROUND(AVG(a.faithfulness_score),   4)               AS avg_faithfulness_score,
            COUNT(CASE WHEN a.passed_threshold = 'Y' THEN 1 END) AS passed_threshold_count,
            COUNT(CASE WHEN a.passed_threshold = 'N' THEN 1 END) AS failed_threshold_count,
            ROUND(
            COUNT(CASE WHEN a.passed_threshold = 'Y' THEN 1 END)
            / NULLIF(COUNT(a.score_id), 0) * 100
            , 2)                                                AS pct_passed_threshold,
            ROUND(AVG(a.threshold_applied),    4)               AS avg_threshold_applied
        FROM accuracy_scores a
        JOIN tickets      t ON t.ticket_id     = a.ticket_id
        LEFT JOIN categories  c ON c.category_id   = t.category_id
        LEFT JOIN departments d ON d.department_id = t.department_id
        GROUP BY
            d.department_name,
            d.department_code,
            c.category_name,
            c.category_code,
            a.judge_model;

    COMMENT ON TABLE v_analytics_accuracy_by_dept_category IS 'KPI view: full LLM accuracy score analytics aggregated by department, category and judge model. Includes avg/median/stddev/min/max for composite score and avg for each dimension score. Shows pass/fail threshold counts and pass rate percentage. Use for model performance monitoring, threshold calibration and identifying domains where the agent systematically underperforms. Sources: accuracy_scores, tickets, categories, departments.';

    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.department_name        IS 'Full name of the department associated with the scored tickets.';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.department_code        IS 'Short alphanumeric code for the department; matches DEPARTMENTS.DEPARTMENT_CODE.';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.category_name          IS 'Full display name of the ticket category.';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.category_code          IS 'Short code for the category; matches CATEGORIES.CATEGORY_CODE.';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.judge_model            IS 'Identifier of the LLM judge model that produced the accuracy scores (e.g. gpt-4o, claude-3-5-sonnet).';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.total_scored_tickets   IS 'Total number of ACCURACY_SCORES records in this department / category / judge_model combination.';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.avg_composite_score    IS 'Average composite accuracy score across all scored tickets in this group, rounded to 4 decimal places.';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.median_composite_score IS 'Median composite accuracy score; robust to outliers and useful alongside the average.';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.stddev_composite_score IS 'Standard deviation of composite accuracy scores; indicates consistency of agent answer quality in this domain.';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.min_composite_score    IS 'Lowest composite accuracy score in this group.';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.max_composite_score    IS 'Highest composite accuracy score in this group.';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.avg_relevance_score    IS 'Average relevance dimension score; measures how on-topic agent answers are for this department/category.';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.avg_completeness_score IS 'Average completeness dimension score; measures how fully agent answers address all sub-questions.';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.avg_faithfulness_score IS 'Average faithfulness dimension score; measures factual grounding of answers against retrieved Knowledge Base content.';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.passed_threshold_count IS 'Count of scored tickets where the composite score met or exceeded the configured quality threshold (PASSED_THRESHOLD=Y).';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.failed_threshold_count IS 'Count of scored tickets that fell below the quality threshold (PASSED_THRESHOLD=N).';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.pct_passed_threshold   IS 'Percentage of scored tickets that passed the quality threshold; the primary accuracy KPI for this view.';
    COMMENT ON COLUMN v_analytics_accuracy_by_dept_category.avg_threshold_applied  IS 'Average value of the quality threshold applied at scoring time; reflects any threshold changes over the period.';

    -- =============================================================================
    -- VIEW 7 : V_ANALYTICS_DAILY_THROUGHPUT
    -- Purpose : Daily operational throughput - tickets received, answered,
    -- escalated and failed per department. Tracks daily average accuracy
    -- score and unique submitter count for trend and capacity analysis.
    -- Key KPIs: tickets_received, tickets_answered, pct_auto_resolved,
    -- pct_escalated, avg_accuracy_score.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_analytics_daily_throughput AS
        SELECT
            TRUNC(t.timestamp_received)                                                AS ticket_date,
            d.department_name,
            COUNT(t.ticket_id)                                                         AS tickets_received,
            COUNT(CASE WHEN t.status IN ('ANSWERED','RESOLVED')        THEN 1 END)    AS tickets_answered,
            COUNT(CASE WHEN t.status IN ('ESCALATED', 'IN_REVIEW')
            OR EXISTS (SELECT 1 FROM escalations e
        WHERE e.ticket_id = t.ticket_id)     THEN 1 END)    AS tickets_escalated,
            COUNT(CASE WHEN t.status = 'FAILED'                        THEN 1 END)    AS tickets_failed,
            COUNT(CASE WHEN t.status NOT IN
            ('ANSWERED','RESOLVED','FAILED','ESCALATED','IN_REVIEW')
                THEN 1 END)    AS tickets_in_progress,
            ROUND(AVG(t.accuracy_score), 4)                                           AS avg_accuracy_score,
            ROUND(
            COUNT(CASE WHEN t.status IN ('ANSWERED','RESOLVED')
                    AND NOT EXISTS (SELECT 1 FROM escalations e
        WHERE e.ticket_id = t.ticket_id) THEN 1 END)
            / NULLIF(COUNT(t.ticket_id), 0) * 100
            , 2)                                                                       AS pct_auto_resolved,
            ROUND(
            COUNT(CASE WHEN EXISTS (SELECT 1 FROM escalations e
        WHERE e.ticket_id = t.ticket_id) THEN 1 END)
            / NULLIF(COUNT(t.ticket_id), 0) * 100
            , 2)                                                                       AS pct_escalated,
            ROUND(
            COUNT(CASE WHEN t.status = 'FAILED' THEN 1 END)
            / NULLIF(COUNT(t.ticket_id), 0) * 100
            , 2)                                                                       AS pct_failed,
            COUNT(DISTINCT t.submitter_email)                                         AS unique_submitters
        FROM tickets t
        LEFT JOIN departments d ON d.department_id = t.department_id
        GROUP BY
            TRUNC(t.timestamp_received),
            d.department_name
        ORDER BY
            ticket_date DESC,
            d.department_name;

    COMMENT ON TABLE v_analytics_daily_throughput IS 'KPI view: daily ticket volumes by department. Tracks received, answered, escalated, failed and in-progress counts alongside daily average accuracy score and unique submitter count. Granularity: one row per calendar day (TRUNC of TIMESTAMP_RECEIVED) per department. Use for trend analysis, capacity planning and day-over-day operational monitoring dashboards. Sources: tickets, departments, escalations.';

    COMMENT ON COLUMN v_analytics_daily_throughput.ticket_date         IS 'Calendar date (time-truncated) derived from TICKETS.TIMESTAMP_RECEIVED; the primary time dimension for daily trend analysis.';
    COMMENT ON COLUMN v_analytics_daily_throughput.department_name     IS 'Full name of the department that received the tickets on this date.';
    COMMENT ON COLUMN v_analytics_daily_throughput.tickets_received    IS 'Total number of tickets received by this department on this date.';
    COMMENT ON COLUMN v_analytics_daily_throughput.tickets_answered    IS 'Count of tickets received on this date that currently have status ANSWERED or RESOLVED.';
    COMMENT ON COLUMN v_analytics_daily_throughput.tickets_escalated   IS 'Count of tickets received on this date that are currently ESCALATED or IN_REVIEW, or have any escalation record.';
    COMMENT ON COLUMN v_analytics_daily_throughput.tickets_failed      IS 'Count of tickets received on this date that entered a FAILED terminal state.';
    COMMENT ON COLUMN v_analytics_daily_throughput.tickets_in_progress IS 'Count of tickets received on this date still in an active non-terminal status other than ANSWERED, RESOLVED, ESCALATED, IN_REVIEW, or FAILED.';
    COMMENT ON COLUMN v_analytics_daily_throughput.avg_accuracy_score  IS 'Average composite accuracy score (TICKETS.ACCURACY_SCORE) across all tickets received on this date for this department.';
    COMMENT ON COLUMN v_analytics_daily_throughput.pct_auto_resolved   IS 'Percentage of tickets received on this date fully resolved by the agent without any escalation.';
    COMMENT ON COLUMN v_analytics_daily_throughput.pct_escalated       IS 'Percentage of tickets received on this date that were or are escalated.';
    COMMENT ON COLUMN v_analytics_daily_throughput.pct_failed          IS 'Percentage of tickets received on this date that failed processing.';
    COMMENT ON COLUMN v_analytics_daily_throughput.unique_submitters   IS 'Count of distinct submitter email addresses among tickets received on this date for this department.';

    -- =============================================================================
    -- VIEW 8 : V_ANALYTICS_PIPELINE_HEALTH
    -- Purpose : Point-in-time snapshot of all tickets currently in non-terminal
    -- statuses. Shows age distribution (>1h, >4h, >24h) per pipeline
    -- stage, department and priority. Designed for real-time alerting
    -- and operational health dashboards.
    -- Key KPIs: ticket_count, avg_age_minutes, tickets_over_1h,
    -- tickets_over_4h, tickets_over_24h.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_analytics_pipeline_health AS
        SELECT
            t.status,
            d.department_name,
            t.priority,
            COUNT(t.ticket_id)                                                          AS ticket_count,
            ROUND(AVG(
                    (CAST(SYSTIMESTAMP AS DATE)
                    - CAST(t.timestamp_received AS DATE)) * 24 * 60
            ), 2)                                                                       AS avg_age_minutes,
            ROUND(MAX(
                    (CAST(SYSTIMESTAMP AS DATE)
                    - CAST(t.timestamp_received AS DATE)) * 24 * 60
            ), 2)                                                                       AS max_age_minutes,
            COUNT(CASE WHEN
            (CAST(SYSTIMESTAMP AS DATE)
                    - CAST(t.timestamp_received AS DATE)) * 24 * 60 > 60   THEN 1 END)   AS tickets_over_1h,
            COUNT(CASE WHEN
            (CAST(SYSTIMESTAMP AS DATE)
                    - CAST(t.timestamp_received AS DATE)) * 24 * 60 > 240  THEN 1 END)   AS tickets_over_4h,
            COUNT(CASE WHEN
            (CAST(SYSTIMESTAMP AS DATE)
                    - CAST(t.timestamp_received AS DATE)) * 24 * 60 > 1440 THEN 1 END)   AS tickets_over_24h,
            MIN(t.timestamp_received)                                                  AS oldest_ticket_received_at,
            MAX(t.timestamp_received)                                                  AS newest_ticket_received_at
        FROM tickets t
        LEFT JOIN departments d ON d.department_id = t.department_id
        WHERE t.status NOT IN ('ANSWERED', 'RESOLVED', 'FAILED')
        GROUP BY
            t.status,
            d.department_name,
            t.priority;

    COMMENT ON TABLE v_analytics_pipeline_health IS 'Operational view: live snapshot of tickets currently in non-terminal statuses. Shows count, average age and max age per pipeline stage, and how many tickets have been stuck for more than 1h, 4h or 24h per status, department and priority. Excludes terminal statuses ANSWERED, RESOLVED, FAILED. Ages are computed against SYSTIMESTAMP at query time. Use for real-time alerting, SLA breach detection and operations dashboards. Sources: tickets, departments.';

    COMMENT ON COLUMN v_analytics_pipeline_health.status                    IS 'Current non-terminal pipeline stage of the tickets in this row (e.g. RECEIVED, QUEUED, CATEGORISING, ANSWERING, SCORING, ESCALATED, IN_REVIEW).';
    COMMENT ON COLUMN v_analytics_pipeline_health.department_name           IS 'Full name of the department that owns the tickets currently in this pipeline stage.';
    COMMENT ON COLUMN v_analytics_pipeline_health.priority                  IS 'Priority level of the tickets in this grouping.';
    COMMENT ON COLUMN v_analytics_pipeline_health.ticket_count              IS 'Number of tickets currently in this status / department / priority grouping.';
    COMMENT ON COLUMN v_analytics_pipeline_health.avg_age_minutes           IS 'Average age in minutes of tickets in this grouping, measured from TIMESTAMP_RECEIVED to the current SYSTIMESTAMP at query time.';
    COMMENT ON COLUMN v_analytics_pipeline_health.max_age_minutes           IS 'Maximum age in minutes among tickets in this grouping; identifies the oldest stuck ticket.';
    COMMENT ON COLUMN v_analytics_pipeline_health.tickets_over_1h           IS 'Count of tickets in this grouping stuck in a non-terminal status for more than 60 minutes; yellow-alert threshold.';
    COMMENT ON COLUMN v_analytics_pipeline_health.tickets_over_4h           IS 'Count of tickets in this grouping stuck for more than 240 minutes (4 hours); orange-alert threshold.';
    COMMENT ON COLUMN v_analytics_pipeline_health.tickets_over_24h          IS 'Count of tickets in this grouping stuck for more than 1440 minutes (24 hours); red-alert threshold indicating a serious pipeline blockage.';
    COMMENT ON COLUMN v_analytics_pipeline_health.oldest_ticket_received_at IS 'TIMESTAMP_RECEIVED of the oldest ticket currently in this grouping; reference point for maximum age.';
    COMMENT ON COLUMN v_analytics_pipeline_health.newest_ticket_received_at IS 'TIMESTAMP_RECEIVED of the most recently received ticket currently in this grouping.';

    -- =============================================================================
    -- VIEW 8B : V_ANALYTICS_AGENT_DISPATCH_QUEUE
    -- Purpose : Live health of the worker queue. RECEIVED rows are waiting
    -- to be claimed by a fixed worker; QUEUED rows have been claimed by a worker
    -- and are waiting for validation to start.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_analytics_agent_dispatch_queue AS
        SELECT
            t.status,
            t.priority,
            d.department_name,
            COUNT(*) AS ticket_count,
            COUNT(CASE
                WHEN t.status = 'RECEIVED'
                AND  NVL(t.agent_next_retry_at, t.timestamp_received) <= SYSTIMESTAMP
                THEN 1
            END) AS eligible_received_tickets,
            COUNT(CASE
                WHEN t.status = 'RECEIVED'
                AND  t.agent_next_retry_at > SYSTIMESTAMP
                THEN 1
            END) AS delayed_retry_tickets,
            COUNT(CASE
                WHEN t.status = 'QUEUED'
                THEN 1
            END) AS dispatched_queued_tickets,
            MIN(t.timestamp_received) AS oldest_received_at,
            MIN(CASE
                WHEN t.status = 'RECEIVED'
                AND  NVL(t.agent_next_retry_at, t.timestamp_received) <= SYSTIMESTAMP
                THEN t.timestamp_received
            END) AS oldest_eligible_received_at,
            MIN(CASE
                WHEN t.status = 'RECEIVED'
                AND  t.agent_next_retry_at > SYSTIMESTAMP
                THEN t.agent_next_retry_at
            END) AS next_retry_at,
            MAX(t.agent_retry_count) AS max_retry_count,
            ROUND(AVG(
                (CAST(SYSTIMESTAMP AS DATE) - CAST(t.timestamp_received AS DATE)) * 24 * 60
            ), 2) AS avg_queue_age_minutes,
            ROUND(MAX(
                (CAST(SYSTIMESTAMP AS DATE) - CAST(t.timestamp_received AS DATE)) * 24 * 60
            ), 2) AS max_queue_age_minutes
        FROM tickets t
        LEFT JOIN departments d
            ON d.department_id = t.department_id
        WHERE t.status IN ('RECEIVED', 'QUEUED')
        GROUP BY
            t.status,
            t.priority,
            d.department_name;

    COMMENT ON TABLE v_analytics_agent_dispatch_queue IS 'Operational view for worker backlog and claimed work. RECEIVED rows are waiting or delayed for retry; QUEUED rows have been claimed by a fixed TICKET_RESPONSE_TEAM worker job.';
    COMMENT ON COLUMN v_analytics_agent_dispatch_queue.status                   IS 'Worker queue state: RECEIVED means waiting or retry-delayed; QUEUED means claimed by a worker job.';
    COMMENT ON COLUMN v_analytics_agent_dispatch_queue.priority                 IS 'Ticket priority for the queue grouping.';
    COMMENT ON COLUMN v_analytics_agent_dispatch_queue.department_name          IS 'Department that owns the queued tickets.';
    COMMENT ON COLUMN v_analytics_agent_dispatch_queue.ticket_count             IS 'Total tickets in this worker queue state / priority / department grouping.';
    COMMENT ON COLUMN v_analytics_agent_dispatch_queue.eligible_received_tickets IS 'RECEIVED tickets eligible for the next worker pickup based on AGENT_NEXT_RETRY_AT.';
    COMMENT ON COLUMN v_analytics_agent_dispatch_queue.delayed_retry_tickets    IS 'RECEIVED tickets held until a future retry eligibility timestamp.';
    COMMENT ON COLUMN v_analytics_agent_dispatch_queue.dispatched_queued_tickets IS 'QUEUED tickets already claimed by a fixed worker job.';
    COMMENT ON COLUMN v_analytics_agent_dispatch_queue.oldest_received_at       IS 'Oldest ticket received timestamp in this grouping.';
    COMMENT ON COLUMN v_analytics_agent_dispatch_queue.oldest_eligible_received_at IS 'Oldest currently eligible RECEIVED ticket in this grouping.';
    COMMENT ON COLUMN v_analytics_agent_dispatch_queue.next_retry_at            IS 'Soonest retry eligibility timestamp for delayed RECEIVED tickets in this grouping.';
    COMMENT ON COLUMN v_analytics_agent_dispatch_queue.max_retry_count          IS 'Highest transient timeout retry count in this grouping.';
    COMMENT ON COLUMN v_analytics_agent_dispatch_queue.avg_queue_age_minutes    IS 'Average age in minutes from ticket receipt for this grouping.';
    COMMENT ON COLUMN v_analytics_agent_dispatch_queue.max_queue_age_minutes    IS 'Maximum age in minutes from ticket receipt for this grouping.';

    -- =============================================================================
    -- VIEW 9 : V_ANALYTICS_CHANNEL_PERFORMANCE
    -- Purpose : Performance metrics broken down by ingestion channel
    -- (EMAIL, CHAT, API, TICKETING_SYSTEM) and department.
    -- Identifies which channels produce easier-to-resolve tickets
    -- and which generate higher escalation rates.
    -- Key KPIs: pct_answered, pct_escalated, avg_accuracy_score,
    -- avg_resolution_minutes.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_analytics_channel_performance AS
        SELECT
            t.source                                                        AS channel,
            d.department_name,
            COUNT(t.ticket_id)                                             AS total_tickets,
            COUNT(CASE WHEN t.status IN ('ANSWERED','RESOLVED')
            AND NOT EXISTS (SELECT 1 FROM escalations e
        WHERE e.ticket_id = t.ticket_id)   THEN 1 END) AS auto_answered,
            COUNT(CASE WHEN EXISTS (SELECT 1 FROM escalations e
        WHERE e.ticket_id = t.ticket_id)      THEN 1 END) AS escalated,
            COUNT(CASE WHEN t.status = 'FAILED'                           THEN 1 END) AS failed,
            ROUND(AVG(t.accuracy_score), 4)                               AS avg_accuracy_score,
            ROUND(
            COUNT(CASE WHEN t.status IN ('ANSWERED','RESOLVED')
                    AND NOT EXISTS (SELECT 1 FROM escalations e
        WHERE e.ticket_id = t.ticket_id) THEN 1 END)
            / NULLIF(COUNT(t.ticket_id), 0) * 100
            , 2)                                                           AS pct_auto_answered,
            ROUND(
            COUNT(CASE WHEN EXISTS (SELECT 1 FROM escalations e
        WHERE e.ticket_id = t.ticket_id) THEN 1 END)
            / NULLIF(COUNT(t.ticket_id), 0) * 100
            , 2)                                                           AS pct_escalated,
            ROUND(
            COUNT(CASE WHEN t.status = 'FAILED' THEN 1 END)
            / NULLIF(COUNT(t.ticket_id), 0) * 100
            , 2)                                                           AS pct_failed,
            ROUND(AVG(
                    CASE WHEN t.timestamp_resolved IS NOT NULL
                THEN (CAST(t.timestamp_resolved AS DATE)
                    - CAST(t.timestamp_received AS DATE)) * 24 * 60
            END
            ), 2)                                                          AS avg_resolution_minutes,
            COUNT(DISTINCT t.submitter_email)                              AS unique_submitters
        FROM tickets t
        LEFT JOIN departments d ON d.department_id = t.department_id
        GROUP BY
            t.source,
            d.department_name;

    COMMENT ON TABLE v_analytics_channel_performance IS 'KPI view: ticket volume, auto-answer rate, escalation rate, failure rate, average accuracy and average resolution time broken down by ingestion channel (EMAIL, CHAT, API, TICKETING_SYSTEM) and department. Use to identify which channels produce higher-quality, easier-to-resolve tickets and to benchmark agent performance across different input modalities. Sources: tickets, departments, escalations.';

    COMMENT ON COLUMN v_analytics_channel_performance.channel                IS 'Ingestion channel through which the ticket was received, from TICKETS.SOURCE (e.g. EMAIL, CHAT, API, TICKETING_SYSTEM).';
    COMMENT ON COLUMN v_analytics_channel_performance.department_name        IS 'Full name of the department that received tickets via this channel.';
    COMMENT ON COLUMN v_analytics_channel_performance.total_tickets          IS 'Total number of tickets received via this channel for this department.';
    COMMENT ON COLUMN v_analytics_channel_performance.auto_answered          IS 'Count of tickets fully answered or resolved by the agent without any escalation record.';
    COMMENT ON COLUMN v_analytics_channel_performance.escalated              IS 'Count of tickets that have at least one escalation record, regardless of current status.';
    COMMENT ON COLUMN v_analytics_channel_performance.failed                 IS 'Count of tickets that reached the FAILED terminal status.';
    COMMENT ON COLUMN v_analytics_channel_performance.avg_accuracy_score     IS 'Average composite accuracy score (TICKETS.ACCURACY_SCORE) for all tickets received via this channel and department.';
    COMMENT ON COLUMN v_analytics_channel_performance.pct_auto_answered      IS 'Percentage of total tickets fully resolved by the agent without escalation; the primary self-service rate KPI for channel comparison.';
    COMMENT ON COLUMN v_analytics_channel_performance.pct_escalated          IS 'Percentage of total tickets that were escalated; higher values may indicate channel-specific complexity or formatting issues.';
    COMMENT ON COLUMN v_analytics_channel_performance.pct_failed             IS 'Percentage of total tickets that failed processing; may indicate channel-specific ingestion or parsing issues.';
    COMMENT ON COLUMN v_analytics_channel_performance.avg_resolution_minutes IS 'Average end-to-end resolution time in minutes for resolved tickets received via this channel.';
    COMMENT ON COLUMN v_analytics_channel_performance.unique_submitters      IS 'Count of distinct submitter email addresses for tickets received via this channel and department.';

    -- =============================================================================
    -- VIEW 10 : V_ANALYTICS_ESCALATION_SLA
    -- Purpose : SLA compliance for escalations per receiving team, category and
    -- priority. Applies configurable SLA targets (adjust as required):
    -- - Acknowledgement SLA : 30 minutes from notification
    -- - Resolution SLA      : 240 minutes (4 hours) from escalation
    -- Key KPIs: pct_ack_within_sla, pct_resolved_within_sla,
    -- avg_ack_minutes, avg_resolution_minutes.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_analytics_escalation_sla AS
        SELECT
            ad.department_name                                          AS assigned_team,
            c.category_name,
            t.priority,
            COUNT(e.escalation_id)                                     AS total_escalations,
            COUNT(CASE WHEN e.acknowledged_at IS NOT NULL
            AND (CAST(e.acknowledged_at AS DATE)
                    - CAST(e.notified_at   AS DATE)) * 24 * 60 <= 30
                THEN 1 END)                                     AS ack_within_sla,
            COUNT(CASE WHEN e.acknowledged_at IS NOT NULL
            AND (CAST(e.acknowledged_at AS DATE)
                    - CAST(e.notified_at   AS DATE)) * 24 * 60 > 30
                THEN 1 END)                                     AS ack_sla_breached,
            COUNT(CASE WHEN e.acknowledged_at IS NULL  THEN 1 END)     AS ack_pending,
            COUNT(CASE WHEN e.resolved_at IS NOT NULL
            AND (CAST(e.resolved_at AS DATE)
                    - CAST(e.created_at AS DATE)) * 24 * 60 <= 240
                THEN 1 END)                                     AS resolved_within_sla,
            COUNT(CASE WHEN e.resolved_at IS NOT NULL
            AND (CAST(e.resolved_at AS DATE)
                    - CAST(e.created_at AS DATE)) * 24 * 60 > 240
                THEN 1 END)                                     AS resolution_sla_breached,
            COUNT(CASE WHEN e.resolved_at IS NULL      THEN 1 END)     AS resolution_pending,
            ROUND(
            COUNT(CASE WHEN e.acknowledged_at IS NOT NULL
                    AND (CAST(e.acknowledged_at AS DATE)
                    - CAST(e.notified_at   AS DATE)) * 24 * 60 <= 30 THEN 1 END)
            / NULLIF(COUNT(CASE WHEN e.acknowledged_at IS NOT NULL THEN 1 END), 0) * 100
            , 2)                                                        AS pct_ack_within_sla,
            ROUND(
            COUNT(CASE WHEN e.resolved_at IS NOT NULL
                    AND (CAST(e.resolved_at AS DATE)
                    - CAST(e.created_at AS DATE)) * 24 * 60 <= 240 THEN 1 END)
            / NULLIF(COUNT(CASE WHEN e.resolved_at IS NOT NULL THEN 1 END), 0) * 100
            , 2)                                                        AS pct_resolved_within_sla,
            ROUND(AVG(
                    CASE WHEN e.acknowledged_at IS NOT NULL
                THEN (CAST(e.acknowledged_at AS DATE)
                    - CAST(e.notified_at   AS DATE)) * 24 * 60
            END
            ), 2)                                                       AS avg_ack_minutes,
            ROUND(AVG(
                    CASE WHEN e.resolved_at IS NOT NULL
                THEN (CAST(e.resolved_at  AS DATE)
                    - CAST(e.created_at AS DATE)) * 24 * 60
            END
            ), 2)                                                       AS avg_resolution_minutes
        FROM escalations  e
        JOIN tickets      t  ON t.ticket_id      = e.ticket_id
        JOIN departments  ad ON ad.department_id = e.department_id
        LEFT JOIN categories c ON c.category_id  = t.category_id
        GROUP BY
            ad.department_name,
            c.category_name,
            t.priority;

    COMMENT ON TABLE v_analytics_escalation_sla IS 'SLA compliance view for escalations. Applies targets: 30 min for acknowledgement (from NOTIFIED_AT), 240 min (4h) for resolution (from CREATED_AT). Reports within-SLA, breached and pending counts plus compliance percentage rates per team, category and priority. Adjust the hardcoded minute thresholds in the view DDL to match your organisational SLAs. Sources: escalations, tickets, departments, categories.';

    COMMENT ON COLUMN v_analytics_escalation_sla.assigned_team           IS 'Full name of the department (team) that received the escalation.';
    COMMENT ON COLUMN v_analytics_escalation_sla.category_name           IS 'Full display name of the ticket category involved in the escalation.';
    COMMENT ON COLUMN v_analytics_escalation_sla.priority                IS 'Priority level of the escalated tickets; higher-priority tickets typically have tighter SLA targets.';
    COMMENT ON COLUMN v_analytics_escalation_sla.total_escalations       IS 'Total escalation records in this team / category / priority grouping.';
    COMMENT ON COLUMN v_analytics_escalation_sla.ack_within_sla          IS 'Count of escalations acknowledged within 30 minutes of NOTIFIED_AT (acknowledgement SLA met).';
    COMMENT ON COLUMN v_analytics_escalation_sla.ack_sla_breached        IS 'Count of escalations where acknowledgement took more than 30 minutes from NOTIFIED_AT (acknowledgement SLA breached).';
    COMMENT ON COLUMN v_analytics_escalation_sla.ack_pending             IS 'Count of escalations not yet acknowledged (ACKNOWLEDGED_AT IS NULL).';
    COMMENT ON COLUMN v_analytics_escalation_sla.resolved_within_sla     IS 'Count of escalations fully resolved within 240 minutes of ESCALATIONS.CREATED_AT (resolution SLA met).';
    COMMENT ON COLUMN v_analytics_escalation_sla.resolution_sla_breached IS 'Count of escalations that took more than 240 minutes to resolve from CREATED_AT (resolution SLA breached).';
    COMMENT ON COLUMN v_analytics_escalation_sla.resolution_pending      IS 'Count of escalations not yet resolved (RESOLVED_AT IS NULL).';
    COMMENT ON COLUMN v_analytics_escalation_sla.pct_ack_within_sla      IS 'Percentage of acknowledged escalations that met the 30-minute acknowledgement SLA; denominator excludes unacknowledged records.';
    COMMENT ON COLUMN v_analytics_escalation_sla.pct_resolved_within_sla IS 'Percentage of resolved escalations that met the 240-minute resolution SLA; denominator excludes unresolved records.';
    COMMENT ON COLUMN v_analytics_escalation_sla.avg_ack_minutes         IS 'Average minutes from NOTIFIED_AT to ACKNOWLEDGED_AT for acknowledged escalations.';
    COMMENT ON COLUMN v_analytics_escalation_sla.avg_resolution_minutes  IS 'Average minutes from ESCALATIONS.CREATED_AT to RESOLVED_AT for resolved escalations.';

    -- =============================================================================
    -- VIEW 11 : V_ANALYTICS_AGENT_KB_VERSION_QUALITY
    -- Purpose : Tracks answer quality per Knowledge Base (KB) version snapshot to
    -- detect score regressions after KB updates. Compares composite and
    -- dimension scores across KB versions, department and category.
    -- Key KPIs: avg_composite_score, pct_passed_threshold, stddev_composite_score,
    -- first_scored_at, last_scored_at (version activity window).
    -- =============================================================================
    CREATE OR REPLACE VIEW v_analytics_agent_kb_version_quality AS
        SELECT
            t.kb_version,
            d.department_name,
            c.category_name,
            a.judge_model,
            COUNT(a.score_id)                                   AS total_scored,
            ROUND(AVG(a.composite_score),     4)                AS avg_composite_score,
            ROUND(MEDIAN(a.composite_score),  4)                AS median_composite_score,
            ROUND(STDDEV(a.composite_score),  4)                AS stddev_composite_score,
            ROUND(MIN(a.composite_score),     4)                AS min_composite_score,
            ROUND(MAX(a.composite_score),     4)                AS max_composite_score,
            ROUND(AVG(a.relevance_score),     4)                AS avg_relevance_score,
            ROUND(AVG(a.completeness_score),  4)                AS avg_completeness_score,
            ROUND(AVG(a.faithfulness_score),  4)                AS avg_faithfulness_score,
            COUNT(CASE WHEN a.passed_threshold = 'Y' THEN 1 END) AS passed_threshold,
            COUNT(CASE WHEN a.passed_threshold = 'N' THEN 1 END) AS failed_threshold,
            ROUND(
            COUNT(CASE WHEN a.passed_threshold = 'Y' THEN 1 END)
            / NULLIF(COUNT(a.score_id), 0) * 100
            , 2)                                                AS pct_passed_threshold,
            MIN(a.created_at)                                   AS first_scored_at,
            MAX(a.created_at)                                   AS last_scored_at
        FROM accuracy_scores a
        JOIN tickets      t ON t.ticket_id     = a.ticket_id
        LEFT JOIN categories  c ON c.category_id   = t.category_id
        LEFT JOIN departments d ON d.department_id = t.department_id
        WHERE t.kb_version IS NOT NULL
        GROUP BY
            t.kb_version,
            d.department_name,
            c.category_name,
            a.judge_model;

    COMMENT ON TABLE v_analytics_agent_kb_version_quality IS 'Quality regression view: tracks composite and dimension accuracy scores per KB version, department, category and judge model. Only includes tickets where KB_VERSION IS NOT NULL. Use to detect answer quality degradation after KB updates and to compare performance across Knowledge Base snapshot versions. Requires kb_version to be populated on tickets. Sources: accuracy_scores, tickets, categories, departments.';

    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.kb_version             IS 'Knowledge Base snapshot version identifier from TICKETS.KB_VERSION; used to correlate answer quality with specific KB releases.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.department_name        IS 'Full name of the department associated with the scored tickets.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.category_name          IS 'Full display name of the ticket category.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.judge_model            IS 'LLM judge model identifier that produced the accuracy scores (e.g. gpt-4o, claude-3-5-sonnet).';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.total_scored           IS 'Total number of ACCURACY_SCORES records for this KB version / department / category / judge_model combination.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.avg_composite_score    IS 'Average composite accuracy score for this KB version grouping; compare across versions to detect regressions.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.median_composite_score IS 'Median composite accuracy score; use alongside the average for a more robust quality comparison between KB versions.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.stddev_composite_score IS 'Standard deviation of composite scores; an increase in stddev after a KB update may indicate the update introduced answer quality inconsistencies.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.min_composite_score    IS 'Lowest composite accuracy score observed for this KB version and domain.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.max_composite_score    IS 'Highest composite accuracy score observed for this KB version and domain.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.avg_relevance_score    IS 'Average relevance dimension score; relevant to detecting whether a KB update degraded topical coverage.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.avg_completeness_score IS 'Average completeness dimension score; relevant to detecting whether a KB update introduced knowledge gaps.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.avg_faithfulness_score IS 'Average faithfulness dimension score; relevant to detecting whether a KB update introduced hallucination risks.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.passed_threshold       IS 'Count of scored tickets that passed the quality threshold (PASSED_THRESHOLD=Y) for this KB version.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.failed_threshold       IS 'Count of scored tickets that failed the quality threshold (PASSED_THRESHOLD=N) for this KB version.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.pct_passed_threshold   IS 'Pass rate percentage for this KB version grouping; the primary KPI for KB version quality regression detection.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.first_scored_at        IS 'Timestamp of the earliest accuracy score record for this KB version grouping; marks the start of the version activity window.';
    COMMENT ON COLUMN v_analytics_agent_kb_version_quality.last_scored_at         IS 'Timestamp of the most recent accuracy score record for this KB version grouping; marks the end of the version activity window.';

    -- =============================================================================
    -- VIEW 12 : V_ANALYTICS_RECATEGORISATION_IMPACT
    -- Purpose : Measures the downstream impact of recategorisation on ticket
    -- outcomes. Compares accuracy scores, answer rates, escalation
    -- rates and resolution times across the three categorisation paths:
    -- SUBMITTER (accepted as-is), AGENT_SUGGESTED, HUMAN_OVERRIDE.
    -- Key KPIs: avg_accuracy_score, pct_answered, pct_escalated,
    -- avg_resolution_minutes by category_source.
    -- =============================================================================
    CREATE OR REPLACE VIEW v_analytics_recategorisation_impact AS
        SELECT
            t.category_source                                           AS final_category_source,
            d.department_name,
            c.category_name,
            COUNT(t.ticket_id)                                         AS total_tickets,
            ROUND(AVG(t.accuracy_score),  4)                          AS avg_accuracy_score,
            COUNT(CASE WHEN t.status IN ('ANSWERED','RESOLVED')
            AND NOT EXISTS (SELECT 1 FROM escalations e
        WHERE e.ticket_id = t.ticket_id) THEN 1 END) AS auto_answered,
            COUNT(CASE WHEN EXISTS (SELECT 1 FROM escalations e
        WHERE e.ticket_id = t.ticket_id)   THEN 1 END) AS escalated,
            COUNT(CASE WHEN t.status = 'FAILED'                        THEN 1 END) AS failed,
            ROUND(
            COUNT(CASE WHEN t.status IN ('ANSWERED','RESOLVED')
                    AND NOT EXISTS (SELECT 1 FROM escalations e
        WHERE e.ticket_id = t.ticket_id) THEN 1 END)
            / NULLIF(COUNT(t.ticket_id), 0) * 100
            , 2)                                                       AS pct_auto_answered,
            ROUND(
            COUNT(CASE WHEN EXISTS (SELECT 1 FROM escalations e
        WHERE e.ticket_id = t.ticket_id) THEN 1 END)
            / NULLIF(COUNT(t.ticket_id), 0) * 100
            , 2)                                                       AS pct_escalated,
            ROUND(AVG(
                    CASE WHEN t.timestamp_resolved IS NOT NULL
                THEN (CAST(t.timestamp_resolved AS DATE)
                    - CAST(t.timestamp_received AS DATE)) * 24 * 60
            END
            ), 2)                                                      AS avg_resolution_minutes
        FROM tickets t
        LEFT JOIN categories  c ON c.category_id   = t.category_id
        LEFT JOIN departments d ON d.department_id = t.department_id
        GROUP BY
            t.category_source,
            d.department_name,
            c.category_name;

    COMMENT ON TABLE v_analytics_recategorisation_impact IS 'Impact analysis view: compares ticket outcomes (accuracy score, auto-answer rate, escalation rate, resolution time) across the three categorisation paths: SUBMITTER (accepted as-is), AGENT_SUGGESTED (agent overrode original), HUMAN_OVERRIDE (human further corrected the agent). Use to quantify how miscategorisation affects downstream answer quality and throughput. Sources: tickets, categories, departments, escalations.';

    COMMENT ON COLUMN v_analytics_recategorisation_impact.final_category_source  IS 'Final categorisation path: SUBMITTER (original category accepted), AGENT_SUGGESTED (agent overrode submitter), or HUMAN_OVERRIDE (human reviewer further corrected the agent).';
    COMMENT ON COLUMN v_analytics_recategorisation_impact.department_name        IS 'Full name of the department that processed the tickets in this categorisation path grouping.';
    COMMENT ON COLUMN v_analytics_recategorisation_impact.category_name          IS 'Full display name of the final ticket category after any recategorisation.';
    COMMENT ON COLUMN v_analytics_recategorisation_impact.total_tickets          IS 'Total number of tickets in this final_category_source / department / category combination.';
    COMMENT ON COLUMN v_analytics_recategorisation_impact.avg_accuracy_score     IS 'Average composite accuracy score for tickets in this grouping; compare across categorisation paths to measure the impact of correct categorisation on answer quality.';
    COMMENT ON COLUMN v_analytics_recategorisation_impact.auto_answered          IS 'Count of tickets fully answered by the agent without escalation; use to compare self-service rates across categorisation paths.';
    COMMENT ON COLUMN v_analytics_recategorisation_impact.escalated              IS 'Count of tickets with at least one escalation record in this grouping.';
    COMMENT ON COLUMN v_analytics_recategorisation_impact.failed                 IS 'Count of tickets that reached the FAILED terminal status in this grouping.';
    COMMENT ON COLUMN v_analytics_recategorisation_impact.pct_auto_answered      IS 'Percentage of total tickets auto-answered without escalation; key metric for comparing outcome quality across categorisation paths.';
    COMMENT ON COLUMN v_analytics_recategorisation_impact.pct_escalated          IS 'Percentage of total tickets escalated; higher values for HUMAN_OVERRIDE may indicate systemic miscategorisation in certain categories.';
    COMMENT ON COLUMN v_analytics_recategorisation_impact.avg_resolution_minutes IS 'Average end-to-end resolution time in minutes for resolved tickets; compare across paths to quantify the time cost of miscategorisation.';

-- =============================================================================
-- TICKET RESPONSE AGENT — JSON RELATIONAL DUALITY VIEWS
-- Description : Views to support APIs
-- Version     : 1.0
-- Date        : April 2026
-- =============================================================================

    -- =============================================================================
    -- TICKET DETAIL — JSON RELATIONAL DUALITY VIEW
    -- Description : Oracle 26ai JSON Relational Duality View that exposes a
    -- single ticket and all four child collections as a native
    -- JSON document rooted on TICKETS.TICKET_ID.
    -- Root table  : TICKETS
    -- Child arrays : TICKET_STATUS_HISTORY, TICKET_CATEGORISATION_LOG,
    -- ACCURACY_SCORES, ESCALATIONS
    -- Design notes:
    -- • Every table exposes its PK (mandatory for duality views).
    -- • Child tables carry NOINSERT NOUPDATE NODELETE — the view is used
    -- for GET reads; writes go through the existing procedure API.
    -- • CLOB columns (body, generated_answer, suggested_answer,
    -- resolution_notes, suggested_answer on escalations,
    -- raw_judge_response on accuracy_scores) are included natively —
    -- 26ai duality views support CLOB.
    -- • additional_metadata on escalations is a JSON (OBJECT) flex column;
    -- its fields are merged into each escalation JSON object rather than
    -- rendered as an escaped JSON string.
    -- • suggested_category_id on TICKET_CATEGORISATION_LOG is a FK to
    -- CATEGORIES but is surfaced as a scalar; CATEGORIES is not nested
    -- as a child because it is a lookup table, not a child entity.
    -- • The JSON key names in the duality view match the groupings used by
    -- GET_TICKET_DETAIL: ticket / submitter / content / timestamps /
    -- status_history / categorisation_log / accuracy_scores / escalations.
    -- Because duality view keys map directly to column names, the logical
    -- groupings (ticket, submitter, content, timestamps) are flattened at
    -- the root — the GET_TICKET_DETAIL function re-shapes them into the
    -- hierarchical sub-objects for the API response.
    -- =============================================================================

    -- Drop if re-running
    DROP VIEW IF EXISTS ticket_detail_dv;
    /

    CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW ticket_detail_dv AS
        SELECT JSON {
            '_id'                : t.ticket_id,
            'source'             : t.source,
            'external_ref'       : t.external_ref,
            'status'             : t.status,
            'priority'           : t.priority,
            'category_source'    : t.category_source,
            'submitted_category' : t.submitted_category,
            'category_id'        : t.category_id,
            'department_id'      : t.department_id,
            'assigned_team_id'   : t.assigned_team_id,
            'kb_version'         : t.kb_version,
            'accuracy_score'     : t.accuracy_score,
            'accuracy_threshold' : t.accuracy_threshold,
            'auto_answer'        : t.auto_answer,
            'auto_route'         : t.auto_route,
            'auto_answer_auto_route' : t.auto_answer_auto_route,
            'process_attachments' : t.process_attachments,
            'submitter_name'     : t.submitter_name,
            'submitter_email'    : t.submitter_email,
            'subject'            : t.subject,
            'body'               : t.body,
            'generated_answer'   : t.generated_answer,
            'resolution_notes'   : t.resolution_notes,
            'timestamp_received' : t.timestamp_received,
            'timestamp_updated'  : t.timestamp_updated,
            'timestamp_resolved' : t.timestamp_resolved,
            'created_at'         : t.created_at,

            'attachments' :
            [ SELECT JSON {
                    'attachment_id'     : a.attachment_id,
                    'attachment_uri'    : a.attachment_uri,
                    'file_name'         : a.file_name,
                    'file_extension'    : a.file_extension,
                    'mime_type'         : a.mime_type,
                    'file_size_bytes'   : a.file_size_bytes,
                    'checksum_sha256'   : a.checksum_sha256,
                    'object_etag'       : a.etag,
                    'description'       : a.description,
                    'process_requested' : a.process_requested,
                    'processing_status' : a.processing_status,
                    'llm_profile_name'  : a.llm_profile_name,
                    'llm_model'         : a.llm_model,
                    'llm_output'        : a.llm_output,
                    'llm_raw_response'  : a.llm_raw_response,
                    'llm_error'         : a.llm_error,
                    'processed_at'      : a.processed_at,
                    a.metadata AS FLEX COLUMN,
                    'created_at'        : a.created_at,
                    'updated_at'        : a.updated_at
                }
            FROM ticket_attachments a WITH NOINSERT NOUPDATE NODELETE
            WHERE a.ticket_id = t.ticket_id ],

            'status_history' :
            [ SELECT JSON {
                    'history_id'        : h.history_id,
                    'from_status'       : h.from_status,
                    'to_status'         : h.to_status,
                    'transition_reason' : h.transition_reason,
                    'actor'             : h.actor,
                    'created_at'        : h.created_at
                }
            FROM ticket_status_history h WITH NOINSERT NOUPDATE NODELETE
            WHERE h.ticket_id = t.ticket_id ],

            'categorisation_log' :
            [ SELECT JSON {
                    'log_id'                : cl.log_id,
                    'original_category'     : cl.original_category,
                    'suggested_category_id' : cl.suggested_category_id,
                    'suggested_category'    : cl.suggested_category,
                    'confidence_score'      : cl.confidence_score,
                    'was_overridden'        : cl.was_overridden,
                    'override_reason'       : cl.override_reason,
                    'kb_cluster_matched'    : cl.kb_cluster_matched,
                    'created_at'            : cl.created_at
                }
            FROM ticket_categorisation_log cl WITH NOINSERT NOUPDATE NODELETE
            WHERE cl.ticket_id = t.ticket_id ],

            'accuracy_scores' :
            [ SELECT JSON {
                    'score_id'            : sc.score_id,
                    'judge_model'         : sc.judge_model,
                    'relevance_score'     : sc.relevance_score,
                    'completeness_score'  : sc.completeness_score,
                    'faithfulness_score'  : sc.faithfulness_score,
                    'composite_score'     : sc.composite_score,
                    'threshold_applied'   : sc.threshold_applied,
                    'passed_threshold'    : sc.passed_threshold,
                    'scoring_prompt_hash' : sc.scoring_prompt_hash,
                    'raw_judge_response'  : sc.raw_judge_response,
                    'created_at'          : sc.created_at
                }
            FROM accuracy_scores sc WITH NOINSERT NOUPDATE NODELETE
            WHERE sc.ticket_id = t.ticket_id ],

            'escalations' :
            [ SELECT JSON {
                    'escalation_id'       : e.escalation_id,
                    'department_id'       : e.department_id,
                    'category_id'         : e.category_id,
                    'accuracy_score'      : e.accuracy_score,
                    'suggested_answer'    : e.suggested_answer,
                    'notified_at'         : e.notified_at,
                    'notification_method' : e.notification_method,
                    'acknowledged_at'     : e.acknowledged_at,
                    'acknowledged_by'     : e.acknowledged_by,
                    'rule_name'           : e.rule_name,
                    'routing_rule_id'     : e.routing_rule_id,
                    'routing_rule_notes'  : e.routing_rule_notes,
                    'routing_rule_accuracy_score' : e.routing_rule_accuracy_score,
                    'escalation_reason'   : e.escalation_reason,
                    'escalation_email'    : e.escalation_email,
                    'escalation_slack'    : e.escalation_slack,
                    'escalation_teams'    : e.escalation_teams,
                    e.additional_metadata AS FLEX COLUMN,
                    'resolved_at'         : e.resolved_at,
                    'created_at'          : e.created_at
                }
            FROM escalations e WITH NOINSERT NOUPDATE NODELETE
            WHERE e.ticket_id = t.ticket_id ]
        }
        FROM tickets t
        WITH INSERT UPDATE DELETE;
    /


    -- =============================================================================
    -- TICKET ESCALATION ROUTING — JSON RELATIONAL DUALITY VIEW
    -- Description : Oracle 26ai JSON Relational Duality View that exposes a
    -- single ticket and the escalation-routing context needed by API and
    -- agent workflows as a native JSON document rooted on TICKETS.TICKET_ID.
    -- Root table  : TICKETS
    -- Child arrays : TICKET_ATTACHMENTS, ESCALATIONS
    -- Child objects: CATEGORIES, ROUTING_RULES
    -- Design notes:
    -- • Every table exposes its PK (mandatory for duality views).
    -- • Child tables carry NOINSERT NOUPDATE NODELETE — the view is used
    -- for GET reads; writes go through the existing procedure API.
    -- • CLOB columns (body, generated_answer, suggested_answer,
    -- llm_output, llm_raw_response, suggested_answer on escalations)
    -- are included natively — 26ai duality views support CLOB.
    -- • metadata on ticket_attachments, additional_metadata on categories,
    -- escalations and routing_rules are JSON (OBJECT) flex columns; their
    -- fields are merged into the related JSON object rather than rendered
    -- as escaped JSON strings.
    -- • CATEGORIES is surfaced as a nested lookup object for the ticket
    -- category because routing decisions depend on category policy fields:
    -- notification_method, auto_route, auto_answer and escalation targets.
    -- • ROUTING_RULES is nested under each escalation so consumers can inspect
    -- the exact matched rule, notification override fields, priority boost,
    -- effective dates and rule notes captured for routing/audit workflows.
    -- • The JSON key names in the duality view match the escalation-routing
    -- API payload shape: ticket fields at the root, attachments, category,
    -- escalations and routing_rule details.
    -- =============================================================================

    DROP VIEW IF EXISTS ticket_escalation_routing_dv;
    /

    CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW ticket_escalation_routing_dv AS
        SELECT JSON {
            '_id'                    : t.ticket_id,
            'source'                 : t.source,
            'external_ref'           : t.external_ref,

            'department' :
            ( SELECT JSON {
                    'department_id'   : d.department_id,
                    'department_name' : d.department_name
                }
            FROM departments d WITH NOINSERT NOUPDATE NODELETE
            WHERE d.department_id = t.department_id ),

            'subject'                : t.subject,
            'body'                   : t.body,
            'priority'               : t.priority,
            'submitter_email'        : t.submitter_email,
            'submitter_name'         : t.submitter_name,
            'generated_answer'       : t.generated_answer,
            'suggested_answer'       : t.suggested_answer,
            'resolution_notes'       : t.resolution_notes,
            'auto_answer'            : t.auto_answer,
            'auto_route'             : t.auto_route,
            'auto_answer_auto_route' : t.auto_answer_auto_route,
            'process_attachments'    : t.process_attachments,
            'origin_ticket_id'       : t.origin_ticket_id,
            'timestamp_received'     : t.timestamp_received,
            'timestamp_updated'      : t.timestamp_updated,
            'timestamp_resolved'     : t.timestamp_resolved,
            'created_at'             : t.created_at,

            'attachments' :
            [ SELECT JSON {
                    'attachment_uri' : a.attachment_uri,
                    'file_name'      : a.file_name
                }
            FROM ticket_attachments a WITH NOINSERT NOUPDATE NODELETE
            WHERE a.ticket_id = t.ticket_id ],

            'category' :
            ( SELECT JSON {
                    'category_id'         : c.category_id,
                    'category_code'       : c.category_code,
                    'category_name'       : c.category_name,

                    'parent_category' :
                    ( SELECT JSON {
                            'category_id'         : pc.category_id,
                            'category_code'       : pc.category_code,
                            'category_name'       : pc.category_name,
                            'notification_method' : pc.notification_method,
                            'escalation_email'    : pc.escalation_email
                        }
                    FROM categories pc WITH NOINSERT NOUPDATE NODELETE
                    WHERE pc.category_id = c.parent_category_id ),

                    'notification_method' : c.notification_method,
                    'escalation_email'    : c.escalation_email
                }
            FROM categories c WITH NOINSERT NOUPDATE NODELETE
            WHERE c.category_id = t.category_id ),

            'escalations' :
            [ SELECT JSON {
                    'escalation_id'       : e.escalation_id,
                    'accuracy_score'      : e.accuracy_score,
                    'suggested_answer'    : e.suggested_answer,
                    'rule_name'           : e.rule_name,
                    'routing_rule_accuracy_score' : e.routing_rule_accuracy_score,
                    'escalation_reason'   : e.escalation_reason,
                    'escalation_email'    : e.escalation_email
                }
            FROM escalations e WITH NOINSERT NOUPDATE NODELETE
            WHERE e.ticket_id = t.ticket_id ]
        }
        FROM tickets t
        WITH NOINSERT NOUPDATE NODELETE;
    /


    DROP VIEW IF EXISTS ticket_escalation_routing_middleware_dv;
    /

    CREATE OR REPLACE VIEW ticket_escalation_routing_middleware_dv AS
        SELECT JSON_OBJECT(
                'HeaderInput' VALUE JSON_OBJECT(
                    'Control' VALUE JSON_OBJECT(
                        'timeout'      VALUE 60,
                        'sourceSystem' VALUE 'TICKETAIHUB'
                        RETURNING CLOB
                    )
                    RETURNING CLOB
                ),
                'BodyIn' VALUE JSON_OBJECT(
                    'In' VALUE JSON_OBJECT(
                        'Ticket' VALUE JSON_SERIALIZE(
                            JSON_TRANSFORM(
                                d.data,
                                SET '$.workflow' =
                                    COALESCE(
                                        JSON_QUERY(
                                            esc.additional_metadata,
                                            '$.workflow'
                                            RETURNING CLOB
                                        ),
                                        JSON_QUERY(
                                            c.additional_metadata,
                                            '$.workflow'
                                            RETURNING CLOB
                                        ),
                                        JSON_OBJECT(RETURNING CLOB)
                                    )
                                    FORMAT JSON
                            )
                            RETURNING CLOB
                        ) FORMAT JSON
                        RETURNING CLOB
                    )
                    RETURNING CLOB
                )
                RETURNING CLOB
            ) AS data
        FROM ticket_escalation_routing_dv d
        JOIN tickets t
        ON t.ticket_id = JSON_VALUE(d.data, '$._id' RETURNING VARCHAR2(36))
        LEFT JOIN categories c
        ON c.category_id = t.category_id
        OUTER APPLY (
            SELECT e.additional_metadata
            FROM escalations e
            WHERE e.ticket_id = t.ticket_id
            AND e.additional_metadata IS NOT NULL
            AND JSON_EXISTS(e.additional_metadata, '$.workflow')
            ORDER BY e.created_at DESC, e.escalation_id DESC
            FETCH FIRST 1 ROW ONLY
        ) esc;
    /

-- =============================================================================
-- TICKET RESPONSE AGENT — AUXILIARY OBJECTS FOR DEMO PURPOSE
-- Description : Auxiliary tables, not needed for a production enviropnment,
-- used to support the end to end workload without external systems
-- Version     : 1.0
-- Date        : April 2026
-- =============================================================================

    -- =============================================================================
    -- ESCALATIONS_HITL Table
    -- Mirrors all columns from ESCALATIONS plus HITL-specific columns:
    -- resolution_notes  CLOB         (same type as TICKETS.RESOLUTION_NOTES)
    -- status            VARCHAR2(20)  DEFAULT 'IN_REVIEW' CHECK IN_REVIEW|RESOLVED
    -- hitl_created_at   TIMESTAMP     DEFAULT SYSTIMESTAMP
    -- No FK to ESCALATIONS — decoupled so HITL store operates independently.
    -- FKs to TICKETS, DEPARTMENTS, CATEGORIES and ROUTING_RULES preserved for
    -- referential integrity. ROUTING_RULES is nullable when category fallback is used.
    -- notification_method check matches v1.1: EMAIL | SLACK | TEAMS | API
    -- =============================================================================
    CREATE TABLE escalations_hitl (
        hitl_id                     NUMBER(18)    GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        escalation_id               NUMBER(18)    NOT NULL,
        ticket_id                   VARCHAR2(36)  NOT NULL,
        department_id               NUMBER(10)    NOT NULL,
        category_id                 NUMBER(10)    NOT NULL,
        accuracy_score              NUMBER(5,4)   NOT NULL,
        suggested_answer            CLOB,
        notified_at                 TIMESTAMP,
        notification_method         VARCHAR2(30),
        acknowledged_at             TIMESTAMP,
        acknowledged_by             VARCHAR2(200),
        rule_name                   VARCHAR2(255),
        routing_rule_id             NUMBER(10),
        routing_rule_notes          VARCHAR2(4000),
        routing_rule_accuracy_score NUMBER(5,4),
        escalation_reason           VARCHAR2(500),
        escalation_email            VARCHAR2(255),
        escalation_slack            VARCHAR2(255),
        escalation_teams            VARCHAR2(255),
        additional_metadata         JSON (OBJECT),
        api_payload                 JSON (OBJECT),
        resolved_at                 TIMESTAMP,
        created_at                  TIMESTAMP,
        -- ── HITL-specific columns ─────────────────────────────────────────────────
        resolution_notes            CLOB,
        status                      VARCHAR2(20)  DEFAULT 'IN_REVIEW' NOT NULL,
        hitl_created_at             TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
        -- ── Constraints ───────────────────────────────────────────────────────────
        CONSTRAINT fk_hitl_ticket      FOREIGN KEY (ticket_id)     REFERENCES tickets(ticket_id),
        CONSTRAINT fk_hitl_department  FOREIGN KEY (department_id) REFERENCES departments(department_id),
        CONSTRAINT fk_hitl_category    FOREIGN KEY (category_id)   REFERENCES categories(category_id),
        CONSTRAINT fk_hitl_routing_rule FOREIGN KEY (routing_rule_id) REFERENCES routing_rules(rule_id),
        CONSTRAINT ck_hitl_status      CHECK (status              IN ('IN_REVIEW', 'RESOLVED')),
        CONSTRAINT ck_hitl_notif_meth  CHECK (notification_method IN ('EMAIL', 'SLACK', 'TEAMS', 'API')),
        CONSTRAINT ck_hitl_score       CHECK (accuracy_score              BETWEEN 0 AND 1),
        CONSTRAINT ck_hitl_rr_accuracy CHECK (routing_rule_accuracy_score BETWEEN 0 AND 1)
    );

    COMMENT ON TABLE  escalations_hitl                             IS 'Human-in-the-loop store for escalations received from the AI agent pipeline. Each row represents an escalation queued for human review. Status: IN_REVIEW → RESOLVED.';
    COMMENT ON COLUMN escalations_hitl.hitl_id                     IS 'Surrogate primary key for the HITL record.';
    COMMENT ON COLUMN escalations_hitl.escalation_id               IS 'ID of the originating escalation from the ESCALATIONS table.';
    COMMENT ON COLUMN escalations_hitl.ticket_id                   IS 'FK to TICKETS. The ticket being escalated for human review.';
    COMMENT ON COLUMN escalations_hitl.department_id               IS 'FK to DEPARTMENTS. The team responsible for reviewing this escalation.';
    COMMENT ON COLUMN escalations_hitl.category_id                 IS 'FK to CATEGORIES. Snapshot of the ticket category at escalation time.';
    COMMENT ON COLUMN escalations_hitl.accuracy_score              IS 'Snapshot of the AI accuracy score at escalation time.';
    COMMENT ON COLUMN escalations_hitl.suggested_answer            IS 'Agent-generated answer snapshot provided to the reviewer as a starting point.';
    COMMENT ON COLUMN escalations_hitl.notified_at                 IS 'Timestamp when the notification was sent by the agent pipeline.';
    COMMENT ON COLUMN escalations_hitl.notification_method         IS 'Channel used. Values: EMAIL | SLACK | TEAMS | API.';
    COMMENT ON COLUMN escalations_hitl.acknowledged_at             IS 'Timestamp when a human reviewer acknowledged the escalation.';
    COMMENT ON COLUMN escalations_hitl.acknowledged_by             IS 'Username or email of the reviewer who acknowledged.';
    COMMENT ON COLUMN escalations_hitl.rule_name                   IS 'Snapshot of the routing rule name that triggered this escalation.';
    COMMENT ON COLUMN escalations_hitl.routing_rule_id             IS 'FK to ROUTING_RULES.rule_id for the rule selected by the routing engine. NULL when category fallback was used.';
    COMMENT ON COLUMN escalations_hitl.routing_rule_notes          IS 'Snapshot of ROUTING_RULES.rule_notes copied at escalation time for troubleshooting and audit.';
    COMMENT ON COLUMN escalations_hitl.routing_rule_accuracy_score IS 'Confidence score from the routing engine when selecting the routing rule.';
    COMMENT ON COLUMN escalations_hitl.escalation_email            IS 'Email address used to notify the team for this escalation.';
    COMMENT ON COLUMN escalations_hitl.escalation_slack            IS 'Slack channel or webhook URL used to notify the team.';
    COMMENT ON COLUMN escalations_hitl.escalation_teams            IS 'Microsoft Teams channel ID or webhook URL used to notify the team.';
    COMMENT ON COLUMN escalations_hitl.additional_metadata         IS 'Free-form JSON object payload snapshot from the routing rule or category.';
    COMMENT ON COLUMN escalations_hitl.api_payload                 IS 'Full JSON payload sent to the receive_escalation API and stored for debugging/audit.';
    COMMENT ON COLUMN escalations_hitl.resolved_at                 IS 'Timestamp when the escalation was resolved by the human reviewer.';
    COMMENT ON COLUMN escalations_hitl.created_at                  IS 'Timestamp of the original escalation record creation in the agent pipeline.';
    COMMENT ON COLUMN escalations_hitl.resolution_notes            IS 'Free-text notes added by the human reviewer. Same type as TICKETS.RESOLUTION_NOTES (CLOB).';
    COMMENT ON COLUMN escalations_hitl.status                      IS 'HITL review status. IN_REVIEW = awaiting human action; RESOLVED = review complete.';
    COMMENT ON COLUMN escalations_hitl.hitl_created_at             IS 'Timestamp when this HITL record was created via the receive_escalation API.';
    COMMENT ON COLUMN escalations_hitl.escalation_reason           IS 'Human-readable explanation of why the ticket was escalated. Copied from ESCALATIONS.escalation_reason at HITL record creation time. Values: low accuracy score below category threshold, or category configured for routing only (auto_answer=N) with no AI response generated.';

    CREATE INDEX idx_hitl_ticket_id       ON escalations_hitl (ticket_id);
    CREATE INDEX idx_hitl_escalation_id   ON escalations_hitl (escalation_id);
    CREATE INDEX idx_hitl_department_id   ON escalations_hitl (department_id);
    CREATE INDEX idx_hitl_category_id     ON escalations_hitl (category_id);
    CREATE INDEX idx_hitl_routing_rule_id ON escalations_hitl (routing_rule_id);
    CREATE INDEX idx_hitl_status          ON escalations_hitl (status);

    -- =============================================================================
    -- ANSWERS_DELIVERED TABLE
    -- Simulates the external CRM / customer-reply system that receives auto-answered
    -- tickets. Decoupled from TICKETS — no FK to TICKETS for flexibility, but
    -- ticket_id and category_id FKs preserved for joins.
    -- =============================================================================

    CREATE TABLE answers_delivered (
        answer_delivery_id  NUMBER(18)    GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        ticket_id           VARCHAR2(36)  NOT NULL,
        category_id         NUMBER(10),
        department_id       NUMBER(10),
        submitter_name      VARCHAR2(200),
        submitter_email     VARCHAR2(255),
        subject             VARCHAR2(500),
        generated_answer    CLOB          NOT NULL,
        accuracy_score      NUMBER(5,4),
        accuracy_threshold  NUMBER(5,4),
        kb_version          VARCHAR2(50),
        api_payload         JSON (OBJECT),
        delivery_channel    VARCHAR2(30)  DEFAULT 'API' NOT NULL,
        delivery_status     VARCHAR2(20)  DEFAULT 'DELIVERED' NOT NULL,
        acknowledged_at     TIMESTAMP,
        acknowledged_by     VARCHAR2(200),
        delivered_at        TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
        created_at          TIMESTAMP     DEFAULT SYSTIMESTAMP NOT NULL,
        CONSTRAINT fk_ad_ticket     FOREIGN KEY (ticket_id)     REFERENCES tickets(ticket_id),
        CONSTRAINT fk_ad_category   FOREIGN KEY (category_id)  REFERENCES categories(category_id),
        CONSTRAINT fk_ad_dept       FOREIGN KEY (department_id) REFERENCES departments(department_id),
        CONSTRAINT ck_ad_channel    CHECK (delivery_channel  IN ('API','EMAIL','CHAT')),
        CONSTRAINT ck_ad_status     CHECK (delivery_status   IN ('DELIVERED','ACKNOWLEDGED','FAILED')),
        CONSTRAINT ck_ad_score      CHECK (accuracy_score      BETWEEN 0 AND 1),
        CONSTRAINT ck_ad_threshold  CHECK (accuracy_threshold  BETWEEN 0 AND 1)
    );

    COMMENT ON TABLE  answers_delivered                    IS 'Records every auto-generated answer dispatched to the external customer-reply system. Acts as the demo HITL store for ANSWERED tickets — mirrors the ESCALATIONS_HITL pattern.';
    COMMENT ON COLUMN answers_delivered.answer_delivery_id IS 'Surrogate primary key.';
    COMMENT ON COLUMN answers_delivered.ticket_id          IS 'FK to TICKETS. The ticket whose generated answer was delivered.';
    COMMENT ON COLUMN answers_delivered.category_id        IS 'FK to CATEGORIES. Snapshot of the ticket category at delivery time.';
    COMMENT ON COLUMN answers_delivered.department_id      IS 'FK to DEPARTMENTS. Department that owns the category.';
    COMMENT ON COLUMN answers_delivered.submitter_name     IS 'Name of the ticket submitter — copied for the external system.';
    COMMENT ON COLUMN answers_delivered.submitter_email    IS 'Email of the ticket submitter — the reply-to address for the external system.';
    COMMENT ON COLUMN answers_delivered.subject            IS 'Ticket subject line at delivery time.';
    COMMENT ON COLUMN answers_delivered.generated_answer   IS 'Full KB-grounded answer text with inline citations, as delivered.';
    COMMENT ON COLUMN answers_delivered.accuracy_score     IS 'LLM-judge composite score at answer generation time.';
    COMMENT ON COLUMN answers_delivered.accuracy_threshold IS 'Category-specific threshold that the answer passed.';
    COMMENT ON COLUMN answers_delivered.kb_version         IS 'Version identifier of the Knowledge Base snapshot used.';
    COMMENT ON COLUMN answers_delivered.api_payload        IS 'Full JSON payload sent to the receive_answer API and stored for debugging/audit.';
    COMMENT ON COLUMN answers_delivered.delivery_channel   IS 'Channel used to deliver the answer. Values: API | EMAIL | CHAT.';
    COMMENT ON COLUMN answers_delivered.delivery_status    IS 'Delivery outcome. DELIVERED=sent; ACKNOWLEDGED=customer confirmed; FAILED=delivery error.';
    COMMENT ON COLUMN answers_delivered.acknowledged_at    IS 'Timestamp when the customer or external system acknowledged the answer.';
    COMMENT ON COLUMN answers_delivered.acknowledged_by    IS 'Username or email that acknowledged receipt.';
    COMMENT ON COLUMN answers_delivered.delivered_at       IS 'Timestamp when the answer was dispatched.';
    COMMENT ON COLUMN answers_delivered.created_at         IS 'Timestamp when this delivery record was inserted.';

    CREATE INDEX idx_ad_ticket_id     ON answers_delivered (ticket_id);
    CREATE INDEX idx_ad_category_id   ON answers_delivered (category_id);
    CREATE INDEX idx_ad_department_id ON answers_delivered (department_id);
    CREATE INDEX idx_ad_status        ON answers_delivered (delivery_status);
    CREATE INDEX idx_ad_delivered_at  ON answers_delivered (delivered_at);
