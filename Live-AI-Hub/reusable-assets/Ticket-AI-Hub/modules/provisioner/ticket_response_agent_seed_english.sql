whenever sqlerror exit sql.sqlcode
set define off
set serveroutput on

-- =============================================================================
-- TICKET RESPONSE AGENT - ENGLISH REFERENCE DATA SEED / UPSERT
-- Purpose:
--   * Works with GENERATED ALWAYS AS IDENTITY columns
--   * Does not insert or depend on hardcoded IDs
--   * Can be run repeatedly (idempotent MERGE)
--   * Creates/updates departments, categories and routing rules
-- =============================================================================


-- ================================================================
-- 1. UPSERT DEPARTMENTS
-- ================================================================

MERGE INTO departments d
USING (
    SELECT 'IT_INTERNAL' AS department_code,
           'Internal IT' AS department_name,
           'Support for internal systems, access and technology infrastructure of the hospital group.' AS description,
           'it.support@hospitalgroup.com' AS escalation_email,
           '#it-support' AS escalation_slack
      FROM dual
    UNION ALL SELECT 'CUST_SVC' AS department_code,
           'Customer Service' AS department_name,
           'Support for patients and users on billing, appointments, directions and services.' AS description,
           'customer.service@hospitalgroup.com' AS escalation_email,
           '#customer-service' AS escalation_slack
      FROM dual
) s
ON (d.department_code = s.department_code)
WHEN MATCHED THEN
    UPDATE SET
        d.department_name  = s.department_name,
        d.description      = s.description,
        d.escalation_email = s.escalation_email,
        d.escalation_slack = s.escalation_slack,
        d.is_active        = 'Y'
WHEN NOT MATCHED THEN
    INSERT (
        department_code,
        department_name,
        description,
        escalation_email,
        escalation_slack,
        is_active
    )
    VALUES (
        s.department_code,
        s.department_name,
        s.description,
        s.escalation_email,
        s.escalation_slack,
        'Y'
    );

-- ================================================================
-- 2. UPSERT CATEGORIES
-- ================================================================

MERGE INTO categories c
USING (
    SELECT
        d.department_id,
        x.category_code,
        x.category_name,
        x.description,
        x.kb_cluster_tag
    FROM departments d
    JOIN (
        SELECT 'IT_INTERNAL' AS department_code,
               'IT_ACCESS' AS category_code,
               'Access and Credentials' AS category_name,
               'Requests related to the creation, reset or lockout of access credentials for internal systems.' AS description,
               'it_access' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'IT_INTERNAL' AS department_code,
               'IT_HARDWARE' AS category_code,
               'Hardware and Equipment' AS category_name,
               'Faults, replacement requests or configuration of IT equipment.' AS description,
               'it_hardware' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'IT_INTERNAL' AS department_code,
               'IT_SOFTWARE' AS category_code,
               'Software and Applications' AS category_name,
               'Installation, update or errors in clinical and administrative applications.' AS description,
               'it_software' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'IT_INTERNAL' AS department_code,
               'IT_NETWORK' AS category_code,
               'Networks and Connectivity' AS category_name,
               'Network connection issues, VPN, Wi-Fi or remote access.' AS description,
               'it_network' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'IT_INTERNAL' AS department_code,
               'IT_PWD_RESET' AS category_code,
               'Password Reset' AS category_name,
               'Password reset for user accounts in Active Directory or clinical systems.' AS description,
               'it_access' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'IT_INTERNAL' AS department_code,
               'IT_NEW_ACCOUNT' AS category_code,
               'New Account Creation' AS category_name,
               'Creation of access accounts for new employees or service providers.' AS description,
               'it_access' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'IT_INTERNAL' AS department_code,
               'IT_PRINTER' AS category_code,
               'Printers and Peripherals' AS category_name,
               'Faults or configuration of printers, scanners and card readers.' AS description,
               'it_hardware' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'IT_INTERNAL' AS department_code,
               'IT_HIS_ERROR' AS category_code,
               'HIS System Error' AS category_name,
               'Errors and failures in the hospital information system (HIS/EMR).' AS description,
               'it_software' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'CUST_SVC' AS department_code,
               'CS_BILLING' AS category_code,
               'Billing and Payments' AS category_name,
               'Queries about invoices, charges, health insurance and payment methods.' AS description,
               'cs_billing' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'CUST_SVC' AS department_code,
               'CS_APPOINTMENTS' AS category_code,
               'Appointments and Consultations' AS category_name,
               'Scheduling, amending or cancelling appointments and exams.' AS description,
               'cs_appointments' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'CUST_SVC' AS department_code,
               'CS_LOCATION' AS category_code,
               'Location and Facilities' AS category_name,
               'Addresses, opening hours, parking and accessibility of hospital units.' AS description,
               'cs_location' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'CUST_SVC' AS department_code,
               'CS_SPECIALTY' AS category_code,
               'Specialty Recommendation' AS category_name,
               'Guidance on which medical specialty to consult for a given non-urgent health problem.' AS description,
               'cs_specialty' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'CUST_SVC' AS department_code,
               'CS_DOCUMENTS' AS category_code,
               'Documents and Reports' AS category_name,
               'Requests for declarations, medical reports, certificates and clinical records for administrative purposes.' AS description,
               'cs_documents' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'CUST_SVC' AS department_code,
               'CS_INSURANCE' AS category_code,
               'Insurance and Health Schemes' AS category_name,
               'Information on agreements with insurers, ADSE, SAD and other health subsystems.' AS description,
               'cs_billing' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'CUST_SVC' AS department_code,
               'CS_EXAM_RESULTS' AS category_code,
               'Exam Results' AS category_name,
               'Requests for delivery or clarification of clinical analysis and imaging results.' AS description,
               'cs_appointments' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'CUST_SVC' AS department_code,
               'CS_COMPLAINTS' AS category_code,
               'Complaints and Suggestions' AS category_name,
               'Formal complaints about service quality, care or facilities.' AS description,
               'cs_complaints' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'CUST_SVC' AS department_code,
               'CS_APPT_BOOKING' AS category_code,
               'Appointment Booking' AS category_name,
               'Booking, rescheduling and cancellation of specialist appointments, post-operative follow-up and first consultations.' AS description,
               'appt_booking' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'CUST_SVC' AS department_code,
               'CS_LAB_RESULTS' AS category_code,
               'Lab and Exam Results' AS category_name,
               'Delivery of clinical analysis results, imaging reports, processing times and access to exam history.' AS description,
               'exam_results' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'CUST_SVC' AS department_code,
               'CS_DISCHARGE' AS category_code,
               'Discharge and Continuity of Care' AS category_name,
               'Discharge notes, post-discharge medication, home care, transfers to convalescence units and continuity of care.' AS description,
               'discharge_continuity' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'CUST_SVC' AS department_code,
               'CS_INPATIENT' AS category_code,
               'Inpatient Information' AS category_name,
               'Visiting rules, admission, what to bring for a hospital stay, companions, meals, Wi-Fi and inpatient rights.' AS description,
               'inpatient_info' AS kb_cluster_tag
          FROM dual
        UNION ALL SELECT 'CUST_SVC' AS department_code,
               'CS_EMERGENCY' AS category_code,
               'Emergency and Triage' AS category_name,
               'Criteria for emergency care, Manchester triage system, paediatric, gynaecological and specialty emergencies, waiting times.' AS description,
               'emergency_triage' AS kb_cluster_tag
          FROM dual
    ) x
      ON x.department_code = d.department_code
) s
ON (c.category_code = s.category_code)
WHEN MATCHED THEN
    UPDATE SET
        c.department_id  = s.department_id,
        c.category_name  = s.category_name,
        c.description    = s.description,
        c.kb_cluster_tag = s.kb_cluster_tag,
        c.is_active      = 'Y'
WHEN NOT MATCHED THEN
    INSERT (
        department_id,
        category_code,
        category_name,
        description,
        kb_cluster_tag,
        is_active
    )
    VALUES (
        s.department_id,
        s.category_code,
        s.category_name,
        s.description,
        s.kb_cluster_tag,
        'Y'
    );

-- ================================================================
-- 3. UPSERT ROUTING RULES
-- ================================================================

MERGE INTO routing_rules rr
USING (
    SELECT
        c.category_id,
        d.department_id,
        x.rule_name,
        x.priority_boost,
        x.rule_notes
    FROM (
        SELECT 'IT_ACCESS' AS category_code,
               'IT_INTERNAL' AS department_code,
               'ROUTE_IT_ACCESS_TO_IT_INTERNAL' AS rule_name,
               0 AS priority_boost,
               'Access and credentials managed by Internal IT.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'IT_HARDWARE' AS category_code,
               'IT_INTERNAL' AS department_code,
               'ROUTE_IT_HARDWARE_TO_IT_INTERNAL' AS rule_name,
               0 AS priority_boost,
               'Hardware managed by Internal IT.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'IT_SOFTWARE' AS category_code,
               'IT_INTERNAL' AS department_code,
               'ROUTE_IT_SOFTWARE_TO_IT_INTERNAL' AS rule_name,
               0 AS priority_boost,
               'Software and applications managed by Internal IT.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'IT_NETWORK' AS category_code,
               'IT_INTERNAL' AS department_code,
               'ROUTE_IT_NETWORK_TO_IT_INTERNAL' AS rule_name,
               2 AS priority_boost,
               'Network issues have a priority boost.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'IT_PWD_RESET' AS category_code,
               'IT_INTERNAL' AS department_code,
               'ROUTE_IT_PWD_RESET_TO_IT_INTERNAL' AS rule_name,
               0 AS priority_boost,
               'Password reset handled by Internal IT.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'IT_NEW_ACCOUNT' AS category_code,
               'IT_INTERNAL' AS department_code,
               'ROUTE_IT_NEW_ACCOUNT_TO_IT_INTERNAL' AS rule_name,
               0 AS priority_boost,
               'Account creation handled by Internal IT.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'IT_PRINTER' AS category_code,
               'IT_INTERNAL' AS department_code,
               'ROUTE_IT_PRINTER_TO_IT_INTERNAL' AS rule_name,
               0 AS priority_boost,
               'Printers managed by Internal IT.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'IT_HIS_ERROR' AS category_code,
               'IT_INTERNAL' AS department_code,
               'ROUTE_IT_HIS_ERROR_TO_IT_INTERNAL' AS rule_name,
               5 AS priority_boost,
               'HIS errors have high priority - clinical impact.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'CS_BILLING' AS category_code,
               'CUST_SVC' AS department_code,
               'ROUTE_CS_BILLING_TO_CUST_SVC' AS rule_name,
               0 AS priority_boost,
               'Billing managed by Customer Service.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'CS_APPOINTMENTS' AS category_code,
               'CUST_SVC' AS department_code,
               'ROUTE_CS_APPOINTMENTS_TO_CUST_SVC' AS rule_name,
               0 AS priority_boost,
               'Appointments managed by Customer Service.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'CS_LOCATION' AS category_code,
               'CUST_SVC' AS department_code,
               'ROUTE_CS_LOCATION_TO_CUST_SVC' AS rule_name,
               0 AS priority_boost,
               'Location enquiries managed by Customer Service.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'CS_SPECIALTY' AS category_code,
               'CUST_SVC' AS department_code,
               'ROUTE_CS_SPECIALTY_TO_CUST_SVC' AS rule_name,
               0 AS priority_boost,
               'Specialty recommendation handled by Customer Service.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'CS_DOCUMENTS' AS category_code,
               'CUST_SVC' AS department_code,
               'ROUTE_CS_DOCUMENTS_TO_CUST_SVC' AS rule_name,
               0 AS priority_boost,
               'Documents managed by Customer Service.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'CS_INSURANCE' AS category_code,
               'CUST_SVC' AS department_code,
               'ROUTE_CS_INSURANCE_TO_CUST_SVC' AS rule_name,
               2 AS priority_boost,
               'Insurance has a priority boost because it affects access to care.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'CS_EXAM_RESULTS' AS category_code,
               'CUST_SVC' AS department_code,
               'ROUTE_CS_EXAM_RESULTS_TO_CUST_SVC' AS rule_name,
               0 AS priority_boost,
               'Exam results handled by Customer Service.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'CS_COMPLAINTS' AS category_code,
               'CUST_SVC' AS department_code,
               'ROUTE_CS_COMPLAINTS_TO_CUST_SVC' AS rule_name,
               5 AS priority_boost,
               'Complaints have high priority.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'CS_APPT_BOOKING' AS category_code,
               'CUST_SVC' AS department_code,
               'ROUTE_CS_APPT_BOOKING_TO_CUST_SVC' AS rule_name,
               0 AS priority_boost,
               'Automatic routing to Customer Service.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'CS_LAB_RESULTS' AS category_code,
               'CUST_SVC' AS department_code,
               'ROUTE_CS_LAB_RESULTS_TO_CUST_SVC' AS rule_name,
               0 AS priority_boost,
               'Automatic routing to Customer Service.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'CS_DISCHARGE' AS category_code,
               'CUST_SVC' AS department_code,
               'ROUTE_CS_DISCHARGE_TO_CUST_SVC' AS rule_name,
               0 AS priority_boost,
               'Automatic routing to Customer Service.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'CS_INPATIENT' AS category_code,
               'CUST_SVC' AS department_code,
               'ROUTE_CS_INPATIENT_TO_CUST_SVC' AS rule_name,
               0 AS priority_boost,
               'Automatic routing to Customer Service.' AS rule_notes
          FROM dual
        UNION ALL SELECT 'CS_EMERGENCY' AS category_code,
               'CUST_SVC' AS department_code,
               'ROUTE_CS_EMERGENCY_TO_CUST_SVC' AS rule_name,
               0 AS priority_boost,
               'Automatic routing to Customer Service.' AS rule_notes
          FROM dual
    ) x
    JOIN categories c
      ON c.category_code = x.category_code
    JOIN departments d
      ON d.department_code = x.department_code
     AND d.department_id = c.department_id
) s
ON (
       rr.category_id   = s.category_id
   AND rr.department_id = s.department_id
   AND rr.rule_name     = s.rule_name
)
WHEN MATCHED THEN
    UPDATE SET
        rr.priority_boost = s.priority_boost,
        rr.rule_notes     = s.rule_notes,
        rr.is_active      = 'Y',
        rr.effective_to   = NULL
WHEN NOT MATCHED THEN
    INSERT (
        rule_name,
        category_id,
        department_id,
        priority_boost,
        rule_notes,
        is_active,
        effective_from
    )
    VALUES (
        s.rule_name,
        s.category_id,
        s.department_id,
        s.priority_boost,
        s.rule_notes,
        'Y',
        TRUNC(SYSDATE)
    );

COMMIT;

-- ================================================================
-- 4. VALIDATION
-- ================================================================

SELECT department_id,
       department_code,
       department_name,
       is_active
FROM departments
WHERE department_code IN ('IT_INTERNAL', 'CUST_SVC')
ORDER BY department_code;

SELECT c.category_id,
       d.department_code,
       c.category_code,
       c.category_name,
       c.kb_cluster_tag,
       c.is_active
FROM categories c
JOIN departments d
  ON d.department_id = c.department_id
WHERE c.category_code IN (
    'IT_ACCESS', 'IT_HARDWARE', 'IT_SOFTWARE', 'IT_NETWORK',
    'IT_PWD_RESET', 'IT_NEW_ACCOUNT', 'IT_PRINTER', 'IT_HIS_ERROR',
    'CS_BILLING', 'CS_APPOINTMENTS', 'CS_LOCATION', 'CS_SPECIALTY',
    'CS_DOCUMENTS', 'CS_INSURANCE', 'CS_EXAM_RESULTS', 'CS_COMPLAINTS',
    'CS_APPT_BOOKING', 'CS_LAB_RESULTS', 'CS_DISCHARGE',
    'CS_INPATIENT', 'CS_EMERGENCY'
)
ORDER BY d.department_code, c.category_code;

SELECT rr.rule_id,
       rr.rule_name,
       c.category_code,
       d.department_code,
       rr.priority_boost,
       rr.rule_notes,
       rr.is_active
FROM routing_rules rr
JOIN categories c
  ON c.category_id = rr.category_id
JOIN departments d
  ON d.department_id = rr.department_id
WHERE rr.rule_name LIKE 'ROUTE\_%' ESCAPE '\'
ORDER BY d.department_code, c.category_code;

SELECT
    (SELECT COUNT(*)
       FROM departments
      WHERE department_code IN ('IT_INTERNAL', 'CUST_SVC')) AS departments_loaded,
    (SELECT COUNT(*)
       FROM categories
      WHERE category_code IN (
          'IT_ACCESS', 'IT_HARDWARE', 'IT_SOFTWARE', 'IT_NETWORK',
          'IT_PWD_RESET', 'IT_NEW_ACCOUNT', 'IT_PRINTER', 'IT_HIS_ERROR',
          'CS_BILLING', 'CS_APPOINTMENTS', 'CS_LOCATION', 'CS_SPECIALTY',
          'CS_DOCUMENTS', 'CS_INSURANCE', 'CS_EXAM_RESULTS', 'CS_COMPLAINTS',
          'CS_APPT_BOOKING', 'CS_LAB_RESULTS', 'CS_DISCHARGE',
          'CS_INPATIENT', 'CS_EMERGENCY'
      )) AS categories_loaded,
    (SELECT COUNT(*)
       FROM routing_rules
      WHERE rule_name LIKE 'ROUTE\_%' ESCAPE '\') AS routing_rules_loaded
FROM dual;

-- Expected reference-data counts: 2 departments, 21 categories, 21 routing rules.
-- Seed/upsert completed successfully.
