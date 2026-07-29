whenever sqlerror exit sql.sqlcode
set define off
set serveroutput on

-- =============================================================================
-- TICKET RESPONSE AGENT
-- IDEMPOTENT TICKET SEED + ENGLISH TRANSLATION
-- SQL Developer Web compatible
--
-- Generated from the supplied TICKETS translation script.
--
-- Behaviour:
--   * If TICKET_ID exists: update the translated columns.
--   * If TICKET_ID does not exist: insert a minimal valid ticket row.
--   * Safe to run repeatedly; it does not create duplicates.
--
-- Important:
--   * The supplied translation file contains 199 ticket UPDATE statements,
--     not all 287 original CSV rows.
--   * For ticket 909AA483-EB7B-4A6B-A751-B4FC80867C03, the original German
--     subject/body were not included in the translation file. A concise
--     English reconstruction is used only so the mandatory columns can be
--     populated.
-- =============================================================================

DECLARE
    l_inserted NUMBER := 0;
    l_updated  NUMBER := 0;
BEGIN

    -- Ticket AD74CB7A-1996-4CDF-9C20-2F82EA4C9BE7
    UPDATE tickets
       SET subject = 'Wheelchair accessibility',
        body = 'Good morning, my mother uses a wheelchair. I would like to know whether all entrances at the Setúbal hospital are accessible and whether there is a lift to the upper floors.',
        submitted_category = 'Accessibility',
        generated_answer = 'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'AD74CB7A-1996-4CDF-9C20-2F82EA4C9BE7';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'AD74CB7A-1996-4CDF-9C20-2F82EA4C9BE7',
            'API',
            'SEED-AD74CB7A-1996-4CDF-9C20-2F82EA4C9BE7',
            'Wheelchair accessibility',
            'Good morning, my mother uses a wheelchair. I would like to know whether all entrances at the Setúbal hospital are accessible and whether there is a lift to the upper floors.',
            'Accessibility',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 2C791BCB-0E1D-4AD1-8A44-8A65819357AF
    UPDATE tickets
       SET subject = 'Booking a cardiology appointment',
        body = 'Good afternoon, I would like to book a cardiology appointment at Hospital de Santa Maria. What is the procedure? Do I need a GP referral or can I book directly?',
        submitted_category = 'Appointments',
        generated_answer = 'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00). A GP referral is not required for most specialties — except for NHS-subsidised cases. Cancellations must be made at least 24 hours in advance to avoid a cancellation fee (€15). Average waiting times for first appointments range from 3 to 15 working days depending on the specialty and unit. [KB: MARC-001, MARC-002, MARC-005]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '2C791BCB-0E1D-4AD1-8A44-8A65819357AF';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '2C791BCB-0E1D-4AD1-8A44-8A65819357AF',
            'API',
            'SEED-2C791BCB-0E1D-4AD1-8A44-8A65819357AF',
            'Booking a cardiology appointment',
            'Good afternoon, I would like to book a cardiology appointment at Hospital de Santa Maria. What is the procedure? Do I need a GP referral or can I book directly?',
            'Appointments',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00). A GP referral is not required for most specialties — except for NHS-subsidised cases. Cancellations must be made at least 24 hours in advance to avoid a cancellation fee (€15). Average waiting times for first appointments range from 3 to 15 working days depending on the specialty and unit. [KB: MARC-001, MARC-002, MARC-005]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 13819E49-A399-4D31-A403-D8C0A14C0DAE
    UPDATE tickets
       SET subject = 'Cancelling an orthopaedics appointment',
        body = 'Good morning, I have an orthopaedics appointment on 15 February and I cannot attend. How can I cancel? Is there a penalty for late cancellation?',
        submitted_category = 'Cancellation',
        generated_answer = 'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00). A GP referral is not required for most specialties — except for NHS-subsidised cases. Cancellations must be made at least 24 hours in advance to avoid a cancellation fee (€15). Average waiting times for first appointments range from 3 to 15 working days depending on the specialty and unit. [KB: MARC-001, MARC-002, MARC-005]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '13819E49-A399-4D31-A403-D8C0A14C0DAE';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '13819E49-A399-4D31-A403-D8C0A14C0DAE',
            'API',
            'SEED-13819E49-A399-4D31-A403-D8C0A14C0DAE',
            'Cancelling an orthopaedics appointment',
            'Good morning, I have an orthopaedics appointment on 15 February and I cannot attend. How can I cancel? Is there a penalty for late cancellation?',
            'Cancellation',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00). A GP referral is not required for most specialties — except for NHS-subsidised cases. Cancellations must be made at least 24 hours in advance to avoid a cancellation fee (€15). Average waiting times for first appointments range from 3 to 15 working days depending on the specialty and unit. [KB: MARC-001, MARC-002, MARC-005]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 2D902B3D-BD09-48AD-8D66-7C72A5F6DA92
    UPDATE tickets
       SET subject = 'Is there a taxi or transport service after surgery under anaesthesia?',
        body = 'Good morning,

I am having surgery under general anaesthesia and will not be able to drive afterwards. Is there a taxi or hospital-organised transport service to get home after surgery?

Kind regards,
Joana Ribeiro'
     WHERE ticket_id = '2D902B3D-BD09-48AD-8D66-7C72A5F6DA92';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '2D902B3D-BD09-48AD-8D66-7C72A5F6DA92',
            'API',
            'SEED-2D902B3D-BD09-48AD-8D66-7C72A5F6DA92',
            'Is there a taxi or transport service after surgery under anaesthesia?',
            'Good morning,

I am having surgery under general anaesthesia and will not be able to drive afterwards. Is there a taxi or hospital-organised transport service to get home after surgery?

Kind regards,
Joana Ribeiro',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 525E0E11-E5C8-4E48-BD9C-E064F7547790
    UPDATE tickets
       SET subject = 'Blood test results show abnormal values — should I go to A&E?',
        body = 'Good afternoon,

I received my blood test results and some values are flagged as abnormal (white blood cells and platelets). I cannot speak to my doctor for another 2 weeks. Should I go to A&E or wait?

Thank you,
Ricardo Vieira'
     WHERE ticket_id = '525E0E11-E5C8-4E48-BD9C-E064F7547790';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '525E0E11-E5C8-4E48-BD9C-E064F7547790',
            'API',
            'SEED-525E0E11-E5C8-4E48-BD9C-E064F7547790',
            'Blood test results show abnormal values — should I go to A&E?',
            'Good afternoon,

I received my blood test results and some values are flagged as abnormal (white blood cells and platelets). I cannot speak to my doctor for another 2 weeks. Should I go to A&E or wait?

Thank you,
Ricardo Vieira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 3644F1D7-A41A-486F-84CF-F7DD7D12FBA3
    UPDATE tickets
       SET subject = 'Received another patient''s test results by email — data breach',
        body = 'Hello,

I received another person''s test results by email. I have never had these tests done. Please correct this urgently as it constitutes a breach of personal health data.

Kind regards,
Marco Correia'
     WHERE ticket_id = '3644F1D7-A41A-486F-84CF-F7DD7D12FBA3';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '3644F1D7-A41A-486F-84CF-F7DD7D12FBA3',
            'API',
            'SEED-3644F1D7-A41A-486F-84CF-F7DD7D12FBA3',
            'Received another patient''s test results by email — data breach',
            'Hello,

I received another person''s test results by email. I have never had these tests done. Please correct this urgently as it constitutes a breach of personal health data.

Kind regards,
Marco Correia',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket A28380AA-5549-4ECD-86C9-119957A8C5C9
    UPDATE tickets
       SET subject = 'Echocardiogram report not received by cardiologist',
        body = 'Good morning,

I had an echocardiogram 3 weeks ago and my cardiologist said at the next appointment that they had not received the report. Could you check what happened and resend it?

Requisition number: ECO-2025-04521

Thank you,
Carlos Santos'
     WHERE ticket_id = 'A28380AA-5549-4ECD-86C9-119957A8C5C9';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'A28380AA-5549-4ECD-86C9-119957A8C5C9',
            'API',
            'SEED-A28380AA-5549-4ECD-86C9-119957A8C5C9',
            'Echocardiogram report not received by cardiologist',
            'Good morning,

I had an echocardiogram 3 weeks ago and my cardiologist said at the next appointment that they had not received the report. Could you check what happened and resend it?

Requisition number: ECO-2025-04521

Thank you,
Carlos Santos',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket C0699BBF-45F1-4495-B749-A669A3E8EC08
    UPDATE tickets
       SET subject = 'Processing time for genetic analysis',
        body = 'Good afternoon,

I have been requested to have a genetic study done and my doctor was unable to tell me the turnaround time. Could you tell me the average processing time for this type of analysis?

Kind regards,
Marco Correia'
     WHERE ticket_id = 'C0699BBF-45F1-4495-B749-A669A3E8EC08';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'C0699BBF-45F1-4495-B749-A669A3E8EC08',
            'API',
            'SEED-C0699BBF-45F1-4495-B749-A669A3E8EC08',
            'Processing time for genetic analysis',
            'Good afternoon,

I have been requested to have a genetic study done and my doctor was unable to tell me the turnaround time. Could you tell me the average processing time for this type of analysis?

Kind regards,
Marco Correia',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 5D2C8A1C-10BD-4202-B1DA-074F3384A17A
    UPDATE tickets
       SET subject = 'Full two-year analysis history for a new GP',
        body = 'Hello,

I would like to access the full history of tests carried out at your hospital over the past two years to share with a new GP. How can I obtain these documents?

Thank you,
Inês Carvalho'
     WHERE ticket_id = '5D2C8A1C-10BD-4202-B1DA-074F3384A17A';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '5D2C8A1C-10BD-4202-B1DA-074F3384A17A',
            'API',
            'SEED-5D2C8A1C-10BD-4202-B1DA-074F3384A17A',
            'Full two-year analysis history for a new GP',
            'Hello,

I would like to access the full history of tests carried out at your hospital over the past two years to share with a new GP. How can I obtain these documents?

Thank you,
Inês Carvalho',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket BF28CDB2-05DE-4E56-BC60-AC582C3C8172
    UPDATE tickets
       SET subject = 'Urgent PCR result needed for a flight tomorrow morning',
        body = 'Good morning,

I had a PCR test yesterday and I have a flight tomorrow morning. I urgently need the result with the certificate. How can I get it as quickly as possible?

Thank you,
Miguel Pereira'
     WHERE ticket_id = 'BF28CDB2-05DE-4E56-BC60-AC582C3C8172';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'BF28CDB2-05DE-4E56-BC60-AC582C3C8172',
            'API',
            'SEED-BF28CDB2-05DE-4E56-BC60-AC582C3C8172',
            'Urgent PCR result needed for a flight tomorrow morning',
            'Good morning,

I had a PCR test yesterday and I have a flight tomorrow morning. I urgently need the result with the certificate. How can I get it as quickly as possible?

Thank you,
Miguel Pereira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 6F4B2B67-AB83-4598-A430-0758C83AB396
    UPDATE tickets
       SET subject = 'Post-discharge medication prescriptions — electronic or paper?',
        body = 'Good afternoon,

I am being discharged after surgery and have been prescribed several new medications. How do I get the prescriptions? Are they sent electronically to the pharmacy or do I need to collect a paper copy?

Kind regards,
Patrícia Cunha'
     WHERE ticket_id = '6F4B2B67-AB83-4598-A430-0758C83AB396';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '6F4B2B67-AB83-4598-A430-0758C83AB396',
            'API',
            'SEED-6F4B2B67-AB83-4598-A430-0758C83AB396',
            'Post-discharge medication prescriptions — electronic or paper?',
            'Good afternoon,

I am being discharged after surgery and have been prescribed several new medications. How do I get the prescriptions? Are they sent electronically to the pharmacy or do I need to collect a paper copy?

Kind regards,
Patrícia Cunha',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket E49749F6-446F-4D0B-A26C-F199E5A42737
    UPDATE tickets
       SET subject = 'Home nursing care after discharge following a hip fracture',
        body = 'Hello,

My mother is being discharged after a hip fracture but still requires nursing care at home. Does the hospital have a home care service or can she be referred to a suitable facility?

Thank you,
Miguel Pereira',
        generated_answer = 'Hello Miguel,

We are sorry, but no specific information about home nursing care after discharge for a hip fracture was found. However, at discharge the patient receives a medical discharge report, medication prescription, follow-up instructions and next appointment date, and information about available support services. [KB: ALT-001, ALT-002]'
     WHERE ticket_id = 'E49749F6-446F-4D0B-A26C-F199E5A42737';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'E49749F6-446F-4D0B-A26C-F199E5A42737',
            'API',
            'SEED-E49749F6-446F-4D0B-A26C-F199E5A42737',
            'Home nursing care after discharge following a hip fracture',
            'Hello,

My mother is being discharged after a hip fracture but still requires nursing care at home. Does the hospital have a home care service or can she be referred to a suitable facility?

Thank you,
Miguel Pereira',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Hello Miguel,

We are sorry, but no specific information about home nursing care after discharge for a hip fracture was found. However, at discharge the patient receives a medical discharge report, medication prescription, follow-up instructions and next appointment date, and information about available support services. [KB: ALT-001, ALT-002]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 9048677E-2738-485D-9041-7CF7DBF8CBB0
    UPDATE tickets
       SET subject = 'Emergency department opening hours',
        body = 'Good morning, I would like to know the opening hours of the emergency department at Hospital de Cascais. I have a relative who may need to go at the weekend and I wanted to confirm whether it is open 24 hours.',
        submitted_category = 'Opening Hours',
        generated_answer = 'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
        suggested_answer = 'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = '9048677E-2738-485D-9041-7CF7DBF8CBB0';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '9048677E-2738-485D-9041-7CF7DBF8CBB0',
            'API',
            'SEED-9048677E-2738-485D-9041-7CF7DBF8CBB0',
            'Emergency department opening hours',
            'Good morning, I would like to know the opening hours of the emergency department at Hospital de Cascais. I have a relative who may need to go at the weekend and I wanted to confirm whether it is open 24 hours.',
            'Opening Hours',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
            'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 91AAC4DE-B5FA-4D5E-AE92-8D7A9862B454
    UPDATE tickets
       SET subject = 'Address of the Braga hospital',
        body = 'Good afternoon, could you give me the exact address of your Braga unit? I need to get there tomorrow morning for an appointment and I cannot find the address on the website.',
        submitted_category = 'Location',
        generated_answer = 'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
        suggested_answer = 'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances.'
     WHERE ticket_id = '91AAC4DE-B5FA-4D5E-AE92-8D7A9862B454';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '91AAC4DE-B5FA-4D5E-AE92-8D7A9862B454',
            'API',
            'SEED-91AAC4DE-B5FA-4D5E-AE92-8D7A9862B454',
            'Address of the Braga hospital',
            'Good afternoon, could you give me the exact address of your Braga unit? I need to get there tomorrow morning for an appointment and I cannot find the address on the website.',
            'Location',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
            'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances.',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 6638343F-4070-4318-A8D5-1990F842633C
    UPDATE tickets
       SET subject = 'How does the multidisciplinary oncology consultation work for a thyroid nodule?',
        body = 'Good afternoon,

A thyroid nodule has been detected and my endocrinologist mentioned that my case may require evaluation in a multidisciplinary consultation. How does this process work at your hospital?

Kind regards,
Sérgio Moreira'
     WHERE ticket_id = '6638343F-4070-4318-A8D5-1990F842633C';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '6638343F-4070-4318-A8D5-1990F842633C',
            'API',
            'SEED-6638343F-4070-4318-A8D5-1990F842633C',
            'How does the multidisciplinary oncology consultation work for a thyroid nodule?',
            'Good afternoon,

A thyroid nodule has been detected and my endocrinologist mentioned that my case may require evaluation in a multidisciplinary consultation. How does this process work at your hospital?

Kind regards,
Sérgio Moreira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket B3418A64-349B-46C2-B97C-1BF88858ECB9
    UPDATE tickets
       SET subject = 'How to request a second opinion in Neurosurgery',
        body = 'Hello,

I have been diagnosed with a herniated disc and surgery has been recommended. I would like to get a second opinion from another Neurosurgery specialist at your hospital. How can I arrange this?

Thank you,
Filipa Teixeira'
     WHERE ticket_id = 'B3418A64-349B-46C2-B97C-1BF88858ECB9';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'B3418A64-349B-46C2-B97C-1BF88858ECB9',
            'API',
            'SEED-B3418A64-349B-46C2-B97C-1BF88858ECB9',
            'How to request a second opinion in Neurosurgery',
            'Hello,

I have been diagnosed with a herniated disc and surgery has been recommended. I would like to get a second opinion from another Neurosurgery specialist at your hospital. How can I arrange this?

Thank you,
Filipa Teixeira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket C78DDC34-6487-4093-BA6D-1ED4A0114495
    UPDATE tickets
       SET subject = 'Elevated TSH — how to access Endocrinology without an available GP',
        body = 'Good afternoon,

My blood tests show elevated TSH. My health centre has no Endocrinologist available. Can you help me understand how to access this specialty at the hospital?

Kind regards,
Cristina Dias'
     WHERE ticket_id = 'C78DDC34-6487-4093-BA6D-1ED4A0114495';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'C78DDC34-6487-4093-BA6D-1ED4A0114495',
            'API',
            'SEED-C78DDC34-6487-4093-BA6D-1ED4A0114495',
            'Elevated TSH — how to access Endocrinology without an available GP',
            'Good afternoon,

My blood tests show elevated TSH. My health centre has no Endocrinologist available. Can you help me understand how to access this specialty at the hospital?

Kind regards,
Cristina Dias',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 849C8E5F-133C-4A2C-8127-66CE2B5DE7FA
    UPDATE tickets
       SET subject = 'Rehabilitation services after stroke — how does referral work?',
        body = 'Hello,

My father had a stroke three weeks ago and is starting his recovery. What rehabilitation services are available at the hospital and how does the referral process work?

Thank you,
Ana Ferreira'
     WHERE ticket_id = '849C8E5F-133C-4A2C-8127-66CE2B5DE7FA';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '849C8E5F-133C-4A2C-8127-66CE2B5DE7FA',
            'API',
            'SEED-849C8E5F-133C-4A2C-8127-66CE2B5DE7FA',
            'Rehabilitation services after stroke — how does referral work?',
            'Hello,

My father had a stroke three weeks ago and is starting his recovery. What rehabilitation services are available at the hospital and how does the referral process work?

Thank you,
Ana Ferreira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 187F3A9A-EE8F-43A6-9D6D-5A137DBEF2CC
    UPDATE tickets
       SET subject = 'Sleep Medicine consultation for sleep apnoea — how to access',
        body = 'Good morning,

I have been diagnosed with sleep apnoea by my GP. Does your hospital have a Sleep Medicine clinic? How can I be referred?

Thank you,
Tiago Valente'
     WHERE ticket_id = '187F3A9A-EE8F-43A6-9D6D-5A137DBEF2CC';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '187F3A9A-EE8F-43A6-9D6D-5A137DBEF2CC',
            'API',
            'SEED-187F3A9A-EE8F-43A6-9D6D-5A137DBEF2CC',
            'Sleep Medicine consultation for sleep apnoea — how to access',
            'Good morning,

I have been diagnosed with sleep apnoea by my GP. Does your hospital have a Sleep Medicine clinic? How can I be referred?

Thank you,
Tiago Valente',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 97BD7BC0-6472-49AC-BEB6-CD600BC76C78
    UPDATE tickets
       SET subject = 'Using Médis insurance at your hospital — agreement and prior authorisation',
        body = 'Good morning,

I have Médis health insurance and would like to know whether your hospital has an agreement with Médis and how the prior authorisation process works for planned surgery.

Kind regards,
João Silva'
     WHERE ticket_id = '97BD7BC0-6472-49AC-BEB6-CD600BC76C78';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '97BD7BC0-6472-49AC-BEB6-CD600BC76C78',
            'API',
            'SEED-97BD7BC0-6472-49AC-BEB6-CD600BC76C78',
            'Using Médis insurance at your hospital — agreement and prior authorisation',
            'Good morning,

I have Médis health insurance and would like to know whether your hospital has an agreement with Médis and how the prior authorisation process works for planned surgery.

Kind regards,
João Silva',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket AF478E51-FE44-426C-8AF1-7E98690C3835
    UPDATE tickets
       SET subject = 'ADSE — which procedures are covered for planned surgery?',
        body = 'Good afternoon,

I am a civil servant with ADSE. Could you send me information about the clinical procedures covered by ADSE at your hospital unit? I have planned surgery and would like to know what my co-payment will be.

Thank you,
Luís Pinto'
     WHERE ticket_id = 'AF478E51-FE44-426C-8AF1-7E98690C3835';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'AF478E51-FE44-426C-8AF1-7E98690C3835',
            'API',
            'SEED-AF478E51-FE44-426C-8AF1-7E98690C3835',
            'ADSE — which procedures are covered for planned surgery?',
            'Good afternoon,

I am a civil servant with ADSE. Could you send me information about the clinical procedures covered by ADSE at your hospital unit? I have planned surgery and would like to know what my co-payment will be.

Thank you,
Luís Pinto',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 69D6A63D-B1D2-4AE5-A7B2-AE83E36E355A
    UPDATE tickets
       SET subject = 'NHS referral timeline and process from GP',
        body = 'Hello,

My GP has issued a referral for a hospital consultation via the NHS. What is the average waiting time and how will I receive the appointment notice?

Thank you,
Fernanda Costa'
     WHERE ticket_id = '69D6A63D-B1D2-4AE5-A7B2-AE83E36E355A';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '69D6A63D-B1D2-4AE5-A7B2-AE83E36E355A',
            'API',
            'SEED-69D6A63D-B1D2-4AE5-A7B2-AE83E36E355A',
            'NHS referral timeline and process from GP',
            'Hello,

My GP has issued a referral for a hospital consultation via the NHS. What is the average waiting time and how will I receive the appointment notice?

Thank you,
Fernanda Costa',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 4EF97A94-D2B1-4AE9-98CE-0BE5A542D5A8
    UPDATE tickets
       SET subject = 'Service declaration for Zurich travel insurance reimbursement',
        body = 'Good morning,

I attended A&E during a trip and paid out of pocket. I have Zurich travel insurance. Can the hospital provide a detailed declaration of services rendered for submission to the insurer?

Kind regards,
Beatriz Alves'
     WHERE ticket_id = '4EF97A94-D2B1-4AE9-98CE-0BE5A542D5A8';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '4EF97A94-D2B1-4AE9-98CE-0BE5A542D5A8',
            'API',
            'SEED-4EF97A94-D2B1-4AE9-98CE-0BE5A542D5A8',
            'Service declaration for Zurich travel insurance reimbursement',
            'Good morning,

I attended A&E during a trip and paid out of pocket. I have Zurich travel insurance. Can the hospital provide a detailed declaration of services rendered for submission to the insurer?

Kind regards,
Beatriz Alves',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket F24A348C-53A0-471A-81BE-90F2C8B79C6C
    UPDATE tickets
       SET subject = 'How do I reschedule my appointment?',
        body = 'Hello, I booked a dermatology appointment for next month but need to change the date. What is the rescheduling process? Can I do it on your website or do I need to call?',
        submitted_category = 'Appointments',
        generated_answer = 'Hello Inês Costa,

To reschedule your appointment you have several options. You can do it through the Hospital Group Portal/App by accessing your appointments and selecting the reschedule option. Alternatively, you can contact the hospital by WhatsApp or phone with at least 24 hours'' notice [healthcare/hospital_group_kb_faq_pt.md - Appointments FAQ].',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'F24A348C-53A0-471A-81BE-90F2C8B79C6C';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'F24A348C-53A0-471A-81BE-90F2C8B79C6C',
            'API',
            'SEED-F24A348C-53A0-471A-81BE-90F2C8B79C6C',
            'How do I reschedule my appointment?',
            'Hello, I booked a dermatology appointment for next month but need to change the date. What is the rescheduling process? Can I do it on your website or do I need to call?',
            'Appointments',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Inês Costa,

To reschedule your appointment you have several options. You can do it through the Hospital Group Portal/App by accessing your appointments and selecting the reschedule option. Alternatively, you can contact the hospital by WhatsApp or phone with at least 24 hours'' notice [healthcare/hospital_group_kb_faq_pt.md - Appointments FAQ].',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket D61490AA-A201-4A7E-8232-34A0596A15F6
    UPDATE tickets
       SET subject = 'Waiting time for a neurology appointment',
        body = 'Good afternoon, I would like to know the average waiting time for a first neurology appointment. I have been experiencing persistent headaches and my GP suggested a specialist assessment.',
        submitted_category = 'Specialties',
        generated_answer = 'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00). A GP referral is not required for most specialties — except for NHS-subsidised cases. Cancellations must be made at least 24 hours in advance to avoid a cancellation fee (€15). Average waiting times for first appointments range from 3 to 15 working days depending on the specialty and unit. [KB: MARC-001, MARC-002, MARC-005]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'D61490AA-A201-4A7E-8232-34A0596A15F6';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'D61490AA-A201-4A7E-8232-34A0596A15F6',
            'API',
            'SEED-D61490AA-A201-4A7E-8232-34A0596A15F6',
            'Waiting time for a neurology appointment',
            'Good afternoon, I would like to know the average waiting time for a first neurology appointment. I have been experiencing persistent headaches and my GP suggested a specialist assessment.',
            'Specialties',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00). A GP referral is not required for most specialties — except for NHS-subsidised cases. Cancellations must be made at least 24 hours in advance to avoid a cancellation fee (€15). Average waiting times for first appointments range from 3 to 15 working days depending on the specialty and unit. [KB: MARC-001, MARC-002, MARC-005]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 20CC06EA-1026-4520-AC3D-E42A3DF3C07C
    UPDATE tickets
       SET subject = 'Query about inpatient bill',
        body = 'Good morning, I received an invoice for my January inpatient stay and there is a charge I cannot identify. What exactly does the item "TAXA ADM 2025" (value: €45) refer to?',
        submitted_category = 'Billing',
        generated_answer = 'Hello Teresa Nunes,

"TAXA ADM 2025" is an administrative fee charged by the hospital to cover the administrative costs associated with the admission and registration of the inpatient episode. This fee includes services such as patient registration, opening of the clinical record and other administrative procedures required for the hospital stay. [KB: FAT-001]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '20CC06EA-1026-4520-AC3D-E42A3DF3C07C';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '20CC06EA-1026-4520-AC3D-E42A3DF3C07C',
            'API',
            'SEED-20CC06EA-1026-4520-AC3D-E42A3DF3C07C',
            'Query about inpatient bill',
            'Good morning, I received an invoice for my January inpatient stay and there is a charge I cannot identify. What exactly does the item "TAXA ADM 2025" (value: €45) refer to?',
            'Billing',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Teresa Nunes,

"TAXA ADM 2025" is an administrative fee charged by the hospital to cover the administrative costs associated with the admission and registration of the inpatient episode. This fee includes services such as patient registration, opening of the clinical record and other administrative procedures required for the hospital stay. [KB: FAT-001]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 0F95BF08-476C-4072-945B-AF077A465BC5
    UPDATE tickets
       SET subject = 'Invoice with incorrect values',
        body = 'Good afternoon, the invoice I received states I had 3 clinical tests but I only had 2. Could you verify and issue a corrected invoice? The invoice number is FT2025/18742.',
        submitted_category = 'Billing',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '0F95BF08-476C-4072-945B-AF077A465BC5';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '0F95BF08-476C-4072-945B-AF077A465BC5',
            'API',
            'SEED-0F95BF08-476C-4072-945B-AF077A465BC5',
            'Invoice with incorrect values',
            'Good afternoon, the invoice I received states I had 3 clinical tests but I only had 2. Could you verify and issue a corrected invoice? The invoice number is FT2025/18742.',
            'Billing',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            NULL,
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 9D38310E-3A9F-4157-8441-516ECE1BD59A
    UPDATE tickets
       SET subject = 'Request for invoice in company name',
        body = 'Good morning, I had a diagnostic exam and need the invoice issued in my company name for tax purposes. How do I proceed? Is it possible to amend an already issued invoice?',
        submitted_category = 'Billing',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '9D38310E-3A9F-4157-8441-516ECE1BD59A';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '9D38310E-3A9F-4157-8441-516ECE1BD59A',
            'API',
            'SEED-9D38310E-3A9F-4157-8441-516ECE1BD59A',
            'Request for invoice in company name',
            'Good morning, I had a diagnostic exam and need the invoice issued in my company name for tax purposes. How do I proceed? Is it possible to amend an already issued invoice?',
            'Billing',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            NULL,
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 27217B02-B6AA-4128-8AB6-0A5961499B8C
    UPDATE tickets
       SET subject = 'Which specialty for back pain?',
        body = 'Hello, I have been suffering from lower back pain for about 3 months. Should I see an orthopaedic surgeon, a physiatrist or a neurologist? My GP is unavailable this week.',
        submitted_category = 'Medical Guidance',
        generated_answer = 'For back pain, the recommended specialties are Orthopaedics or Physical Medicine and Rehabilitation. You may therefore consult either an orthopaedic surgeon or a physiatrist.

Your GP is the ideal first point of contact for most health situations, but since they are unavailable and you have a persistent problem, you may book a specialist appointment directly. [KB: ESP-001, ESP-004]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '27217B02-B6AA-4128-8AB6-0A5961499B8C';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '27217B02-B6AA-4128-8AB6-0A5961499B8C',
            'API',
            'SEED-27217B02-B6AA-4128-8AB6-0A5961499B8C',
            'Which specialty for back pain?',
            'Hello, I have been suffering from lower back pain for about 3 months. Should I see an orthopaedic surgeon, a physiatrist or a neurologist? My GP is unavailable this week.',
            'Medical Guidance',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'For back pain, the recommended specialties are Orthopaedics or Physical Medicine and Rehabilitation. You may therefore consult either an orthopaedic surgeon or a physiatrist.

Your GP is the ideal first point of contact for most health situations, but since they are unavailable and you have a persistent problem, you may book a specialist appointment directly. [KB: ESP-001, ESP-004]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 1F669B52-0F73-40FC-868B-E19F5CF51910
    UPDATE tickets
       SET subject = 'Consultation for anxiety and insomnia',
        body = 'Good afternoon, I have been suffering from anxiety and sleep problems for several months. Should I see a psychiatrist or a psychologist? What is the difference in terms of available treatment?',
        submitted_category = 'Mental Health',
        generated_answer = 'For anxiety and sleep problems it may be useful to consult both a psychologist and a psychiatrist, depending on the severity of symptoms and specific needs.

A psychologist offers behavioural and emotional therapy, helping to manage anxiety and improve sleep quality through evidence-based techniques. A psychiatrist can prescribe medication and is more appropriate when pharmacological treatment is needed. [KB: ESP-007]'
     WHERE ticket_id = '1F669B52-0F73-40FC-868B-E19F5CF51910';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '1F669B52-0F73-40FC-868B-E19F5CF51910',
            'API',
            'SEED-1F669B52-0F73-40FC-868B-E19F5CF51910',
            'Consultation for anxiety and insomnia',
            'Good afternoon, I have been suffering from anxiety and sleep problems for several months. Should I see a psychiatrist or a psychologist? What is the difference in terms of available treatment?',
            'Mental Health',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'For anxiety and sleep problems it may be useful to consult both a psychologist and a psychiatrist, depending on the severity of symptoms and specific needs.

A psychologist offers behavioural and emotional therapy, helping to manage anxiety and improve sleep quality through evidence-based techniques. A psychiatrist can prescribe medication and is more appropriate when pharmacological treatment is needed. [KB: ESP-007]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket C29D51CD-8413-4C8B-9023-091ADF778CEE
    UPDATE tickets
       SET subject = 'Corporate email password reset',
        body = 'Hello, I forgot my corporate email password after the holidays. Can you reset it? My username is mferreira@hospitalgroup.pt.',
        submitted_category = 'Password',
        generated_answer = 'To reset a password for internal systems, submit a request via the Service Desk at helpdesk.hospitalgroup.pt or call extension 9000 (available 07:00–22:00). For urgent resets outside these hours, contact the on-call technician on extension 9999. The reset is completed within 30 minutes during normal hours. After the reset, the temporary password is sent to the personal email address registered with HR. [KB: IT-PASS-001, IT-PASS-002]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'C29D51CD-8413-4C8B-9023-091ADF778CEE';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'C29D51CD-8413-4C8B-9023-091ADF778CEE',
            'API',
            'SEED-C29D51CD-8413-4C8B-9023-091ADF778CEE',
            'Corporate email password reset',
            'Hello, I forgot my corporate email password after the holidays. Can you reset it? My username is mferreira@hospitalgroup.pt.',
            'Password',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'To reset a password for internal systems, submit a request via the Service Desk at helpdesk.hospitalgroup.pt or call extension 9000 (available 07:00–22:00). For urgent resets outside these hours, contact the on-call technician on extension 9999. The reset is completed within 30 minutes during normal hours. After the reset, the temporary password is sent to the personal email address registered with HR. [KB: IT-PASS-001, IT-PASS-002]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 9A678360-86EF-4678-9D06-2121CDD60E64
    UPDATE tickets
       SET subject = 'Workstation computer not powering on',
        body = 'Good afternoon, the computer at workstation 3C in the surgery wing has not powered on since this morning. I have checked the power supply and the cable is properly connected. It is urgent as it is a prescription terminal.',
        submitted_category = 'Hardware',
        generated_answer = 'For hardware faults, open a ticket in the Service Desk at helpdesk.hospitalgroup.pt with a photo of the equipment and a description of the problem. For critical situations (prescription terminals, emergency posts), call extension 9000 directly indicating urgency. A technician will be on site within 2 hours on working days. Replacement equipment is available from the IT store (floor 0, support building). [KB: IT-HW-001, IT-HW-002]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '9A678360-86EF-4678-9D06-2121CDD60E64';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '9A678360-86EF-4678-9D06-2121CDD60E64',
            'API',
            'SEED-9A678360-86EF-4678-9D06-2121CDD60E64',
            'Workstation computer not powering on',
            'Good afternoon, the computer at workstation 3C in the surgery wing has not powered on since this morning. I have checked the power supply and the cable is properly connected. It is urgent as it is a prescription terminal.',
            'Hardware',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'For hardware faults, open a ticket in the Service Desk at helpdesk.hospitalgroup.pt with a photo of the equipment and a description of the problem. For critical situations (prescription terminals, emergency posts), call extension 9000 directly indicating urgency. A technician will be on site within 2 hours on working days. Replacement equipment is available from the IT store (floor 0, support building). [KB: IT-HW-001, IT-HW-002]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 14B2A7B4-EDB1-4CD7-814D-5CC8F0F9FC65
    UPDATE tickets
       SET subject = 'Broken monitor screen',
        body = 'Hello, the monitor in consulting room 12 on floor 2 has a broken screen. It needs to be replaced urgently as the doctor has appointments this afternoon.',
        submitted_category = 'Hardware',
        generated_answer = 'For hardware faults, open a ticket in the Service Desk at helpdesk.hospitalgroup.pt with a photo of the equipment and a description of the problem. For critical situations (prescription terminals, emergency posts), call extension 9000 directly indicating urgency. A technician will be on site within 2 hours on working days. Replacement equipment is available from the IT store (floor 0, support building). [KB: IT-HW-001, IT-HW-002]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '14B2A7B4-EDB1-4CD7-814D-5CC8F0F9FC65';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '14B2A7B4-EDB1-4CD7-814D-5CC8F0F9FC65',
            'API',
            'SEED-14B2A7B4-EDB1-4CD7-814D-5CC8F0F9FC65',
            'Broken monitor screen',
            'Hello, the monitor in consulting room 12 on floor 2 has a broken screen. It needs to be replaced urgently as the doctor has appointments this afternoon.',
            'Hardware',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'For hardware faults, open a ticket in the Service Desk at helpdesk.hospitalgroup.pt with a photo of the equipment and a description of the problem. For critical situations (prescription terminals, emergency posts), call extension 9000 directly indicating urgency. A technician will be on site within 2 hours on working days. Replacement equipment is available from the IT store (floor 0, support building). [KB: IT-HW-001, IT-HW-002]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 6F3217C1-B6C6-4141-9081-6EEBB1A344FC
    UPDATE tickets
       SET subject = 'Which doctor for thyroid problems?',
        body = 'Hello, my blood tests show abnormal thyroid values. My GP suggested I see a specialist. Is Endocrinology the correct specialty?',
        submitted_category = 'Specialties',
        generated_answer = 'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '6F3217C1-B6C6-4141-9081-6EEBB1A344FC';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '6F3217C1-B6C6-4141-9081-6EEBB1A344FC',
            'API',
            'SEED-6F3217C1-B6C6-4141-9081-6EEBB1A344FC',
            'Which doctor for thyroid problems?',
            'Hello, my blood tests show abnormal thyroid values. My GP suggested I see a specialist. Is Endocrinology the correct specialty?',
            'Specialties',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 54426751-3C39-4B1C-B0A0-F82DE0C39AC5
    UPDATE tickets
       SET subject = 'Request for hospitalisation certificate',
        body = 'Good morning, I was admitted in November 2025 and need a hospitalisation certificate to give to my insurer. How can I request this document?',
        submitted_category = 'Documents',
        generated_answer = 'Hello Beatriz Mendes!

You can request a hospitalisation certificate for your insurer by email or in person. To request by email, send your request to arquivo@hospitalgroup.pt attaching a copy of your identity document. If you prefer in person, go to the Clinical Records office of the unit where you were admitted. [KB: DOC-001]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '54426751-3C39-4B1C-B0A0-F82DE0C39AC5';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '54426751-3C39-4B1C-B0A0-F82DE0C39AC5',
            'API',
            'SEED-54426751-3C39-4B1C-B0A0-F82DE0C39AC5',
            'Request for hospitalisation certificate',
            'Good morning, I was admitted in November 2025 and need a hospitalisation certificate to give to my insurer. How can I request this document?',
            'Documents',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Beatriz Mendes!

You can request a hospitalisation certificate for your insurer by email or in person. To request by email, send your request to arquivo@hospitalgroup.pt attaching a copy of your identity document. If you prefer in person, go to the Clinical Records office of the unit where you were admitted. [KB: DOC-001]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 615F61C6-ABAB-45EF-A081-DFA200EBC35C
    UPDATE tickets
       SET subject = 'Medical report for insurance company',
        body = 'Good afternoon, my insurance company is requesting a detailed medical report relating to the surgery I had in December. How can I obtain this report?',
        submitted_category = 'Reports',
        generated_answer = 'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days. For urgent documents (insurers, court), an express service with 48-hour delivery is available for an administrative fee of €20. [KB: DOC-001, DOC-002, DOC-005]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '615F61C6-ABAB-45EF-A081-DFA200EBC35C';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '615F61C6-ABAB-45EF-A081-DFA200EBC35C',
            'API',
            'SEED-615F61C6-ABAB-45EF-A081-DFA200EBC35C',
            'Medical report for insurance company',
            'Good afternoon, my insurance company is requesting a detailed medical report relating to the surgery I had in December. How can I obtain this report?',
            'Reports',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days. For urgent documents (insurers, court), an express service with 48-hour delivery is available for an administrative fee of €20. [KB: DOC-001, DOC-002, DOC-005]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 0C62CC41-6594-45A4-9616-12CCE0F7ED95
    UPDATE tickets
       SET subject = 'Copy of clinical analysis results',
        body = 'Hello, I had clinical tests in January and lost the printed results. Could you send me a copy by email? My patient number is 123456789.',
        submitted_category = 'Results',
        generated_answer = 'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days. For urgent documents (insurers, court), an express service with 48-hour delivery is available for an administrative fee of €20. [KB: DOC-001, DOC-002, DOC-005]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '0C62CC41-6594-45A4-9616-12CCE0F7ED95';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '0C62CC41-6594-45A4-9616-12CCE0F7ED95',
            'API',
            'SEED-0C62CC41-6594-45A4-9616-12CCE0F7ED95',
            'Copy of clinical analysis results',
            'Hello, I had clinical tests in January and lost the printed results. Could you send me a copy by email? My patient number is 123456789.',
            'Results',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days. For urgent documents (insurers, court), an express service with 48-hour delivery is available for an administrative fee of €20. [KB: DOC-001, DOC-002, DOC-005]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 83EB8F8B-E43B-4B3D-B835-43D0F70670CC
    UPDATE tickets
       SET subject = 'Discharge letter not sent to GP — please resend',
        body = 'Hello,

I was discharged from hospital 3 weeks ago and my GP told me they had not received the discharge letter. Could you check what happened and resend it?

Name: Luís Pinto | Discharge date: 28/02/2025

Kind regards,
Hugo Fernandes',
        suggested_answer = 'Hello,

I was discharged from hospital 3 weeks ago and my GP told me they had not received the discharge letter. Could you check what happened and resend it?

Name: Luís Pinto | Discharge date: 28/02/2025'
     WHERE ticket_id = '83EB8F8B-E43B-4B3D-B835-43D0F70670CC';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '83EB8F8B-E43B-4B3D-B835-43D0F70670CC',
            'API',
            'SEED-83EB8F8B-E43B-4B3D-B835-43D0F70670CC',
            'Discharge letter not sent to GP — please resend',
            'Hello,

I was discharged from hospital 3 weeks ago and my GP told me they had not received the discharge letter. Could you check what happened and resend it?

Name: Luís Pinto | Discharge date: 28/02/2025

Kind regards,
Hugo Fernandes',
            NULL,
            'SUBMITTER',
            'IN_REVIEW',
            'MEDIUM',
            NULL,
            'Hello,

I was discharged from hospital 3 weeks ago and my GP told me they had not received the discharge letter. Could you check what happened and resend it?

Name: Luís Pinto | Discharge date: 28/02/2025',
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 8804AF5A-D147-4AEB-AA72-B775529D3C50
    UPDATE tickets
       SET subject = 'Booking physiotherapy after knee surgery with Médis insurance',
        body = 'Good morning,

I had knee surgery 2 weeks ago and need to start physiotherapy. My doctor said the hospital has a rehabilitation service. How do I book and what is the cost with Médis health insurance?

Thank you,
Joana Ribeiro'
     WHERE ticket_id = '8804AF5A-D147-4AEB-AA72-B775529D3C50';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '8804AF5A-D147-4AEB-AA72-B775529D3C50',
            'API',
            'SEED-8804AF5A-D147-4AEB-AA72-B775529D3C50',
            'Booking physiotherapy after knee surgery with Médis insurance',
            'Good morning,

I had knee surgery 2 weeks ago and need to start physiotherapy. My doctor said the hospital has a rehabilitation service. How do I book and what is the cost with Médis health insurance?

Thank you,
Joana Ribeiro',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 95A0CE5E-4D3F-41C9-AFE8-EBB10F38C3FC
    UPDATE tickets
       SET subject = 'Post-surgical wound care — can I continue at the hospital?',
        body = 'Good afternoon,

I was discharged after surgery and need daily wound dressings. My doctor told me to go to the health centre, but it is very busy. Can I continue wound care at the hospital?

Kind regards,
João Silva'
     WHERE ticket_id = '95A0CE5E-4D3F-41C9-AFE8-EBB10F38C3FC';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '95A0CE5E-4D3F-41C9-AFE8-EBB10F38C3FC',
            'API',
            'SEED-95A0CE5E-4D3F-41C9-AFE8-EBB10F38C3FC',
            'Post-surgical wound care — can I continue at the hospital?',
            'Good afternoon,

I was discharged after surgery and need daily wound dressings. My doctor told me to go to the health centre, but it is very busy. Can I continue wound care at the hospital?

Kind regards,
João Silva',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 76B9785C-C211-4B95-B6AA-C9A97950701E
    UPDATE tickets
       SET subject = 'Documents and registrations to complete at maternity discharge',
        body = 'Hello,

My son was born today and we are being discharged tomorrow. What documents do we need to process while still in the hospital? Is the birth registration done here?

With best regards,
Catarina Nunes'
     WHERE ticket_id = '76B9785C-C211-4B95-B6AA-C9A97950701E';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '76B9785C-C211-4B95-B6AA-C9A97950701E',
            'API',
            'SEED-76B9785C-C211-4B95-B6AA-C9A97950701E',
            'Documents and registrations to complete at maternity discharge',
            'Hello,

My son was born today and we are being discharged tomorrow. What documents do we need to process while still in the hospital? Is the birth registration done here?

With best regards,
Catarina Nunes',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 308156A6-0025-4C23-AA52-DB41208612EF
    UPDATE tickets
       SET subject = 'Formal complaint about 9-hour wait in A&E with no information provided',
        body = 'Good morning,

I waited 9 hours in your hospital''s A&E last week and received no information whatsoever about the expected waiting time. I consider this time unacceptable and demand an explanation. How do I make a formal complaint?

Date: 10/03/2025

Kind regards,
Maria Oliveira'
     WHERE ticket_id = '308156A6-0025-4C23-AA52-DB41208612EF';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '308156A6-0025-4C23-AA52-DB41208612EF',
            'API',
            'SEED-308156A6-0025-4C23-AA52-DB41208612EF',
            'Formal complaint about 9-hour wait in A&E with no information provided',
            'Good morning,

I waited 9 hours in your hospital''s A&E last week and received no information whatsoever about the expected waiting time. I consider this time unacceptable and demand an explanation. How do I make a formal complaint?

Date: 10/03/2025

Kind regards,
Maria Oliveira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 3D736F8C-773D-4C0A-85A6-3236A9DC94C8
    UPDATE tickets
       SET subject = 'Suggestion to improve the online appointment booking system for mobile',
        body = 'Good afternoon,

Your online booking system is very unintuitive and does not work well on mobile phones. I would like to leave a suggestion: simplify the process and make it compatible with mobile devices.

With best regards,
Ricardo Vieira'
     WHERE ticket_id = '3D736F8C-773D-4C0A-85A6-3236A9DC94C8';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '3D736F8C-773D-4C0A-85A6-3236A9DC94C8',
            'API',
            'SEED-3D736F8C-773D-4C0A-85A6-3236A9DC94C8',
            'Suggestion to improve the online appointment booking system for mobile',
            'Good afternoon,

Your online booking system is very unintuitive and does not work well on mobile phones. I would like to leave a suggestion: simplify the process and make it compatible with mobile devices.

With best regards,
Ricardo Vieira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket B0BD8EF2-081D-4EC4-AD5E-FBE4C9574C60
    UPDATE tickets
       SET subject = 'Is there parking at the hospital?',
        body = 'Hello, I have an appointment next week at Hospital da Luz Lisboa. Is there a car park? What is the hourly rate? Are there spaces for people with reduced mobility?',
        submitted_category = 'Facilities',
        generated_answer = 'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
        suggested_answer = 'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances.'
     WHERE ticket_id = 'B0BD8EF2-081D-4EC4-AD5E-FBE4C9574C60';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'B0BD8EF2-081D-4EC4-AD5E-FBE4C9574C60',
            'API',
            'SEED-B0BD8EF2-081D-4EC4-AD5E-FBE4C9574C60',
            'Is there parking at the hospital?',
            'Hello, I have an appointment next week at Hospital da Luz Lisboa. Is there a car park? What is the hourly rate? Are there spaces for people with reduced mobility?',
            'Facilities',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
            'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances.',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket FF987CCE-A69D-4297-9CD6-6D9E9D073F8D
    UPDATE tickets
       SET subject = 'Wheelchair accessibility',
        body = 'Good morning, my mother uses a wheelchair. I would like to know whether all entrances at the Setúbal hospital are accessible and whether there is a lift to the upper floors.',
        submitted_category = 'Accessibility'
     WHERE ticket_id = 'FF987CCE-A69D-4297-9CD6-6D9E9D073F8D';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'FF987CCE-A69D-4297-9CD6-6D9E9D073F8D',
            'API',
            'SEED-FF987CCE-A69D-4297-9CD6-6D9E9D073F8D',
            'Wheelchair accessibility',
            'Good morning, my mother uses a wheelchair. I would like to know whether all entrances at the Setúbal hospital are accessible and whether there is a lift to the upper floors.',
            'Accessibility',
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 641D52C3-A944-4E4C-A67C-B6A9C3AA0E17
    UPDATE tickets
       SET subject = 'Does ADSE cover a nutrition consultation?',
        body = 'Good morning, I have ADSE as my health scheme. Does your unit have an agreement with ADSE for nutrition and dietetics consultations? What is the co-payment?',
        submitted_category = 'Insurance',
        generated_answer = 'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment with your beneficiary card. For ADSE, nutrition and dental consultations are not covered under direct access. [KB: SEG-001, SEG-003, SEG-006]',
        suggested_answer = 'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = '641D52C3-A944-4E4C-A67C-B6A9C3AA0E17';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '641D52C3-A944-4E4C-A67C-B6A9C3AA0E17',
            'API',
            'SEED-641D52C3-A944-4E4C-A67C-B6A9C3AA0E17',
            'Does ADSE cover a nutrition consultation?',
            'Good morning, I have ADSE as my health scheme. Does your unit have an agreement with ADSE for nutrition and dietetics consultations? What is the co-payment?',
            'Insurance',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment with your beneficiary card. For ADSE, nutrition and dental consultations are not covered under direct access. [KB: SEG-001, SEG-003, SEG-006]',
            'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 6D380F50-9F1C-4213-81AC-86CED34EC3E1
    UPDATE tickets
       SET subject = 'Médis insurance — which procedures are covered?',
        body = 'Good afternoon, I have Médis health insurance and would like to know which medical procedures and exams are covered at your clinic. I need to have an MRI scan.',
        submitted_category = 'Insurance',
        generated_answer = 'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment with your beneficiary card. For ADSE, nutrition and dental consultations are not covered under direct access. [KB: SEG-001, SEG-003, SEG-006]',
        suggested_answer = 'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = '6D380F50-9F1C-4213-81AC-86CED34EC3E1';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '6D380F50-9F1C-4213-81AC-86CED34EC3E1',
            'API',
            'SEED-6D380F50-9F1C-4213-81AC-86CED34EC3E1',
            'Médis insurance — which procedures are covered?',
            'Good afternoon, I have Médis health insurance and would like to know which medical procedures and exams are covered at your clinic. I need to have an MRI scan.',
            'Insurance',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment with your beneficiary card. For ADSE, nutrition and dental consultations are not covered under direct access. [KB: SEG-001, SEG-003, SEG-006]',
            'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 528B5666-464D-43AF-94C1-A0514DEC0021
    UPDATE tickets
       SET subject = 'Agreement with SAD GNR',
        body = 'Hello, I am a SAD GNR beneficiary. Does your Lisbon unit have an active agreement with this health scheme? Which specialties are included?',
        submitted_category = 'Health Subsystems',
        generated_answer = 'Hello Susana Pires! Hospital Group has an active agreement with SAD GNR. To find out which specialties are included, please visit www.hospitalgroup.pt/convenções or contact the appointments line on 808 200 300. You can also check the app or website of your health scheme for more details. [KB: SEG-003]',
        suggested_answer = 'Hello Susana Pires! Hospital Group has an active agreement with SAD GNR. To find out which specialties are included, please visit www.hospitalgroup.pt/convenções or contact the appointments line on 808 200 300.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = '528B5666-464D-43AF-94C1-A0514DEC0021';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '528B5666-464D-43AF-94C1-A0514DEC0021',
            'API',
            'SEED-528B5666-464D-43AF-94C1-A0514DEC0021',
            'Agreement with SAD GNR',
            'Hello, I am a SAD GNR beneficiary. Does your Lisbon unit have an active agreement with this health scheme? Which specialties are included?',
            'Health Subsystems',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Susana Pires! Hospital Group has an active agreement with SAD GNR. To find out which specialties are included, please visit www.hospitalgroup.pt/convenções or contact the appointments line on 808 200 300. You can also check the app or website of your health scheme for more details. [KB: SEG-003]',
            'Hello Susana Pires! Hospital Group has an active agreement with SAD GNR. To find out which specialties are included, please visit www.hospitalgroup.pt/convenções or contact the appointments line on 808 200 300.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 5C9629EA-048A-4C46-B01C-4F056EA461C9
    UPDATE tickets
       SET subject = 'Turnaround time for CT scan results',
        body = 'Good morning, I had a chest CT scan 5 days ago. Are the results already available? Can I collect them in person or can they be sent by email?',
        submitted_category = 'Results',
        generated_answer = 'Clinical analysis results are available within 24 to 72 hours. Imaging results (CT scan, MRI, ultrasound) are available within 3 to 5 working days. You can access results through the patient portal at www.hospitalgroup.pt/resultados using your patient number and date of birth. If you do not have portal access, you may collect them in person or request email delivery to the address registered in the system. [KB: EXA-001, EXA-003]',
        suggested_answer = 'Clinical analysis results are available within 24 to 72 hours. Imaging results (CT scan, MRI, ultrasound) are available within 3 to 5 working days. You can access results through the patient portal at www.hospitalgroup.pt/resultados using your patient number and date of birth.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = '5C9629EA-048A-4C46-B01C-4F056EA461C9';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '5C9629EA-048A-4C46-B01C-4F056EA461C9',
            'API',
            'SEED-5C9629EA-048A-4C46-B01C-4F056EA461C9',
            'Turnaround time for CT scan results',
            'Good morning, I had a chest CT scan 5 days ago. Are the results already available? Can I collect them in person or can they be sent by email?',
            'Results',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Clinical analysis results are available within 24 to 72 hours. Imaging results (CT scan, MRI, ultrasound) are available within 3 to 5 working days. You can access results through the patient portal at www.hospitalgroup.pt/resultados using your patient number and date of birth. If you do not have portal access, you may collect them in person or request email delivery to the address registered in the system. [KB: EXA-001, EXA-003]',
            'Clinical analysis results are available within 24 to 72 hours. Imaging results (CT scan, MRI, ultrasound) are available within 3 to 5 working days. You can access results through the patient portal at www.hospitalgroup.pt/resultados using your patient number and date of birth.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 4D2D97ED-BB6E-4FF4-AAD3-655C113CA363
    UPDATE tickets
       SET subject = 'Clinical analysis results not received',
        body = 'Good afternoon, I had clinical tests a week ago and have not received the results by email as usual. Could you check whether they were sent to the correct address?',
        submitted_category = 'Exams'
     WHERE ticket_id = '4D2D97ED-BB6E-4FF4-AAD3-655C113CA363';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '4D2D97ED-BB6E-4FF4-AAD3-655C113CA363',
            'API',
            'SEED-4D2D97ED-BB6E-4FF4-AAD3-655C113CA363',
            'Clinical analysis results not received',
            'Good afternoon, I had clinical tests a week ago and have not received the results by email as usual. Could you check whether they were sent to the correct address?',
            'Exams',
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket CC9E73EC-F183-4FB0-B6EC-B32B5E201F4C
    UPDATE tickets
       SET subject = 'Booking an Endocrinology appointment for diabetes management',
        body = 'Good afternoon,

I am a type 2 diabetic and my previous endocrinologist has retired. I need to book an Endocrinology appointment to continue treatment. I have ADSE as my health scheme.

Please advise on how to proceed.
Kind regards,
Joana Ribeiro'
     WHERE ticket_id = 'CC9E73EC-F183-4FB0-B6EC-B32B5E201F4C';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'CC9E73EC-F183-4FB0-B6EC-B32B5E201F4C',
            'API',
            'SEED-CC9E73EC-F183-4FB0-B6EC-B32B5E201F4C',
            'Booking an Endocrinology appointment for diabetes management',
            'Good afternoon,

I am a type 2 diabetic and my previous endocrinologist has retired. I need to book an Endocrinology appointment to continue treatment. I have ADSE as my health scheme.

Please advise on how to proceed.
Kind regards,
Joana Ribeiro',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket C4E001BE-8402-4776-AF4E-851E04F40740
    UPDATE tickets
       SET subject = 'Waiting time for a neurology appointment',
        body = 'Good afternoon, I would like to know the average waiting time for a first neurology appointment. I have been experiencing persistent headaches and my GP suggested a specialist assessment.',
        submitted_category = 'Specialties',
        generated_answer = 'Hello Margarida,

The average waiting time for a first Neurology appointment is 5 to 15 working days. We recommend checking availability and booking through the portal, mobile app, phone or WhatsApp. For urgent situations, call the Health Line on 21 770 41 16 for guidance. [KB: ESP-001]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'C4E001BE-8402-4776-AF4E-851E04F40740';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'C4E001BE-8402-4776-AF4E-851E04F40740',
            'API',
            'SEED-C4E001BE-8402-4776-AF4E-851E04F40740',
            'Waiting time for a neurology appointment',
            'Good afternoon, I would like to know the average waiting time for a first neurology appointment. I have been experiencing persistent headaches and my GP suggested a specialist assessment.',
            'Specialties',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Margarida,

The average waiting time for a first Neurology appointment is 5 to 15 working days. We recommend checking availability and booking through the portal, mobile app, phone or WhatsApp. For urgent situations, call the Health Line on 21 770 41 16 for guidance. [KB: ESP-001]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 76E4F1C1-F2B6-44DC-866A-D515E3498AEB
    UPDATE tickets
       SET subject = 'Query about inpatient bill',
        body = 'Good morning, I received an invoice for my January inpatient stay and there is a charge I cannot identify. What exactly does the item "TAXA ADM 2025" (value: €45) refer to?',
        submitted_category = 'Billing',
        generated_answer = 'Hello Diogo Pinto,

The administrative fee (TAXA ADM) is a charge levied by the hospital to cover the costs associated with admission and registration of the inpatient episode. This fee includes services such as patient registration, opening of the clinical record and other administrative procedures required for the hospital stay. [KB: FAT-001]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '76E4F1C1-F2B6-44DC-866A-D515E3498AEB';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '76E4F1C1-F2B6-44DC-866A-D515E3498AEB',
            'API',
            'SEED-76E4F1C1-F2B6-44DC-866A-D515E3498AEB',
            'Query about inpatient bill',
            'Good morning, I received an invoice for my January inpatient stay and there is a charge I cannot identify. What exactly does the item "TAXA ADM 2025" (value: €45) refer to?',
            'Billing',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Diogo Pinto,

The administrative fee (TAXA ADM) is a charge levied by the hospital to cover the costs associated with admission and registration of the inpatient episode. This fee includes services such as patient registration, opening of the clinical record and other administrative procedures required for the hospital stay. [KB: FAT-001]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket A0C1FE6C-757F-4DC1-AA35-D120D2A4106E
    UPDATE tickets
       SET subject = 'How to pay the invoice online?',
        body = 'Hello, I received my invoice by email but cannot find the online payment link. What payment methods are available? Do you accept Multibanco, MB Way and credit card?',
        submitted_category = 'Payments',
        generated_answer = 'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). We accept payment by Multibanco, MB Way, credit/debit card and bank transfer. To request a correction on an issued invoice, submit a rectification request with the invoice number at www.hospitalgroup.pt/faturacao. Company invoices can be issued when the tax number (NIF) is provided before the procedure or within 5 working days afterwards. [KB: FAT-001, FAT-003, FAT-007]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'A0C1FE6C-757F-4DC1-AA35-D120D2A4106E';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'A0C1FE6C-757F-4DC1-AA35-D120D2A4106E',
            'API',
            'SEED-A0C1FE6C-757F-4DC1-AA35-D120D2A4106E',
            'How to pay the invoice online?',
            'Hello, I received my invoice by email but cannot find the online payment link. What payment methods are available? Do you accept Multibanco, MB Way and credit card?',
            'Payments',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). We accept payment by Multibanco, MB Way, credit/debit card and bank transfer. To request a correction on an issued invoice, submit a rectification request with the invoice number at www.hospitalgroup.pt/faturacao. Company invoices can be issued when the tax number (NIF) is provided before the procedure or within 5 working days afterwards. [KB: FAT-001, FAT-003, FAT-007]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 7F47C9C8-8430-4A37-B566-9A1E0CE53041
    UPDATE tickets
       SET subject = 'Account creation for new nurse',
        body = 'Good morning, our unit has a new nurse starting tomorrow. I need to create an access account for HIS and corporate email. Name: Catarina Lemos, NIF: 234567890.',
        submitted_category = 'New Account',
        generated_answer = 'Hello Susana Pires!

To create an account for new nurse Catarina Lemos in HIS and corporate email you must follow the Hospital Group internal procedures. However, the specific steps for carrying out these procedures are not available in the information provided. Please contact the IT Service Desk for assistance. [KB: IT-ACC-002]',
        suggested_answer = 'Hello Susana Pires!

To create an account for new nurse Catarina Lemos in HIS and corporate email you must follow the Hospital Group internal procedures. However, the specific steps are not available in the current knowledge base. Please contact the IT Service Desk.',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '7F47C9C8-8430-4A37-B566-9A1E0CE53041';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '7F47C9C8-8430-4A37-B566-9A1E0CE53041',
            'API',
            'SEED-7F47C9C8-8430-4A37-B566-9A1E0CE53041',
            'Account creation for new nurse',
            'Good morning, our unit has a new nurse starting tomorrow. I need to create an access account for HIS and corporate email. Name: Catarina Lemos, NIF: 234567890.',
            'New Account',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Susana Pires!

To create an account for new nurse Catarina Lemos in HIS and corporate email you must follow the Hospital Group internal procedures. However, the specific steps for carrying out these procedures are not available in the information provided. Please contact the IT Service Desk for assistance. [KB: IT-ACC-002]',
            'Hello Susana Pires!

To create an account for new nurse Catarina Lemos in HIS and corporate email you must follow the Hospital Group internal procedures. However, the specific steps are not available in the current knowledge base. Please contact the IT Service Desk.',
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 442ECCC0-89DA-498D-B893-38F32D6B880B
    UPDATE tickets
       SET subject = 'Dermatology appointment with health insurance — how to proceed',
        body = 'Hello,

I have a skin patch that appeared a few months ago and would like to see a Dermatologist. I have Fidelidade health insurance. Could you tell me how to book and what documents I need?

Thank you,
Paulo Mendes'
     WHERE ticket_id = '442ECCC0-89DA-498D-B893-38F32D6B880B';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '442ECCC0-89DA-498D-B893-38F32D6B880B',
            'API',
            'SEED-442ECCC0-89DA-498D-B893-38F32D6B880B',
            'Dermatology appointment with health insurance — how to proceed',
            'Hello,

I have a skin patch that appeared a few months ago and would like to see a Dermatologist. I have Fidelidade health insurance. Could you tell me how to book and what documents I need?

Thank you,
Paulo Mendes',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 6EACE130-3CAA-4B1B-BA25-7CFF111E9B5A
    UPDATE tickets
       SET subject = 'Urgent Ophthalmology appointment',
        body = 'Good morning,

I have been experiencing sudden partial vision loss in my left eye since yesterday. My GP said to contact the hospital for an urgent Ophthalmology appointment. How should I proceed?

Thank you,
André Batista'
     WHERE ticket_id = '6EACE130-3CAA-4B1B-BA25-7CFF111E9B5A';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '6EACE130-3CAA-4B1B-BA25-7CFF111E9B5A',
            'API',
            'SEED-6EACE130-3CAA-4B1B-BA25-7CFF111E9B5A',
            'Urgent Ophthalmology appointment',
            'Good morning,

I have been experiencing sudden partial vision loss in my left eye since yesterday. My GP said to contact the hospital for an urgent Ophthalmology appointment. How should I proceed?

Thank you,
André Batista',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 308973D3-C533-44F8-A578-7E508D3D287A
    UPDATE tickets
       SET subject = 'Booking a Psychiatry appointment — is video consultation available?',
        body = 'Good morning,

I would like to book a Psychiatry appointment, recommended by my GP. I have some difficulty travelling; could you advise whether a telephone or video consultation is available?

Awaiting your reply,
Cristina Dias',
        generated_answer = 'Yes, it is possible to have a Psychiatry appointment by video call or telephone. Teleconsultation is an available option for specialties such as Psychiatry, allowing follow-up appointments, medication adjustment and non-acute illness situations. To book a teleconsultation, you can use the patient portal or the Hospital Group mobile app. [KB: MARC-005]'
     WHERE ticket_id = '308973D3-C533-44F8-A578-7E508D3D287A';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '308973D3-C533-44F8-A578-7E508D3D287A',
            'API',
            'SEED-308973D3-C533-44F8-A578-7E508D3D287A',
            'Booking a Psychiatry appointment — is video consultation available?',
            'Good morning,

I would like to book a Psychiatry appointment, recommended by my GP. I have some difficulty travelling; could you advise whether a telephone or video consultation is available?

Awaiting your reply,
Cristina Dias',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Yes, it is possible to have a Psychiatry appointment by video call or telephone. Teleconsultation is an available option for specialties such as Psychiatry, allowing follow-up appointments, medication adjustment and non-acute illness situations. To book a teleconsultation, you can use the patient portal or the Hospital Group mobile app. [KB: MARC-005]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 673A13F5-53AF-4CE8-A7C4-C78D5D33E0F9
    UPDATE tickets
       SET subject = 'Query about amount charged on Urology consultation invoice',
        body = 'Good morning,

I received an invoice for the Urology consultation I had last month, but the amount charged appears higher than what I was quoted at reception. Could you send me a detailed breakdown of the billed services?

Invoice number: FAT-2025-018432

Kind regards,
João Silva'
     WHERE ticket_id = '673A13F5-53AF-4CE8-A7C4-C78D5D33E0F9';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '673A13F5-53AF-4CE8-A7C4-C78D5D33E0F9',
            'API',
            'SEED-673A13F5-53AF-4CE8-A7C4-C78D5D33E0F9',
            'Query about amount charged on Urology consultation invoice',
            'Good morning,

I received an invoice for the Urology consultation I had last month, but the amount charged appears higher than what I was quoted at reception. Could you send me a detailed breakdown of the billed services?

Invoice number: FAT-2025-018432

Kind regards,
João Silva',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 19F7EED2-BABC-4C00-B4DC-B3EE27189566
    UPDATE tickets
       SET subject = 'Request for invoice with tax number (NIF) for tax deduction',
        body = 'Good afternoon,

I need an invoice with my tax number (NIF 123456789) for the consultations and exams carried out at your hospital during 2024, for income tax deduction purposes. How can I obtain this document?

Thank you,
Teresa Monteiro'
     WHERE ticket_id = '19F7EED2-BABC-4C00-B4DC-B3EE27189566';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '19F7EED2-BABC-4C00-B4DC-B3EE27189566',
            'API',
            'SEED-19F7EED2-BABC-4C00-B4DC-B3EE27189566',
            'Request for invoice with tax number (NIF) for tax deduction',
            'Good afternoon,

I need an invoice with my tax number (NIF 123456789) for the consultations and exams carried out at your hospital during 2024, for income tax deduction purposes. How can I obtain this document?

Thank you,
Teresa Monteiro',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 9094F8BB-EDA0-4FAB-AA54-F0A6B96CD392
    UPDATE tickets
       SET subject = 'Invoice includes exam I did not have — requesting correction',
        body = 'Hello,

My invoice includes a charge for a CT scan that I did not have. I was admitted in January and this charge does not correspond to any service provided to me. I am requesting an urgent correction.

Admission number: INT-2025-00234

Awaiting your reply,
Vera Henriques'
     WHERE ticket_id = '9094F8BB-EDA0-4FAB-AA54-F0A6B96CD392';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '9094F8BB-EDA0-4FAB-AA54-F0A6B96CD392',
            'API',
            'SEED-9094F8BB-EDA0-4FAB-AA54-F0A6B96CD392',
            'Invoice includes exam I did not have — requesting correction',
            'Hello,

My invoice includes a charge for a CT scan that I did not have. I was admitted in January and this charge does not correspond to any service provided to me. I am requesting an urgent correction.

Admission number: INT-2025-00234

Awaiting your reply,
Vera Henriques',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 8A052315-296C-4FD1-ACC9-1A87A3B678CD
    UPDATE tickets
       SET subject = 'Instalment payment plan for high-value inpatient invoice',
        body = 'Good morning,

I received the invoice for my 12-day admission in February totalling €8,420. I am not able to pay the full amount in one go. Is an instalment payment arrangement possible?

Thank you,
Maria Oliveira'
     WHERE ticket_id = '8A052315-296C-4FD1-ACC9-1A87A3B678CD';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '8A052315-296C-4FD1-ACC9-1A87A3B678CD',
            'API',
            'SEED-8A052315-296C-4FD1-ACC9-1A87A3B678CD',
            'Instalment payment plan for high-value inpatient invoice',
            'Good morning,

I received the invoice for my 12-day admission in February totalling €8,420. I am not able to pay the full amount in one go. Is an instalment payment arrangement possible?

Thank you,
Maria Oliveira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 909AA483-EB7B-4A6B-A751-B4FC80867C03
    UPDATE tickets
       SET suggested_answer = 'Mr Bauer''s questions regarding his upcoming surgery on 14 April 2026 can be answered as follows:

1. **Food and drink before surgery**: Generally, patients are advised to stop eating and drinking for a set period before surgery. The exact guidelines will be confirmed by the surgical team. [KB: INT-001]'
     WHERE ticket_id = '909AA483-EB7B-4A6B-A751-B4FC80867C03';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '909AA483-EB7B-4A6B-A751-B4FC80867C03',
            'API',
            'SEED-909AA483-EB7B-4A6B-A751-B4FC80867C03',
            'Questions before surgery on 14 April 2026',
            'Mr Bauer asks about food and drink requirements before his upcoming surgery on 14 April 2026.',
            NULL,
            'SUBMITTER',
            'IN_REVIEW',
            'MEDIUM',
            NULL,
            'Mr Bauer''s questions regarding his upcoming surgery on 14 April 2026 can be answered as follows:

1. **Food and drink before surgery**: Generally, patients are advised to stop eating and drinking for a set period before surgery. The exact guidelines will be confirmed by the surgical team. [KB: INT-001]',
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket BADCE4F1-B31C-488F-A1C2-D925B1746F71
    UPDATE tickets
       SET subject = 'Transfer to a convalescence unit after hospital discharge',
        body = 'Good afternoon,

My grandmother (84 years old) is being discharged from hospital but is not in a condition to go straight home. The doctor mentioned transfer to a convalescence unit. How does this process work?

Thank you,
Teresa Monteiro',
        generated_answer = 'Hello Teresa Monteiro,

The process of transfer to a convalescence unit after hospital discharge is generally initiated by the responsible doctor. The clinical team assesses the need for continued care after discharge and, if necessary, coordinates the transfer to a suitable unit. The social worker and discharge team are involved in finding the most appropriate placement. [KB: ALT-003]',
        suggested_answer = 'Hello Teresa Monteiro,

The process of transfer to a convalescence unit after hospital discharge is generally initiated by the responsible doctor. The clinical team assesses the need for continued care after discharge and coordinates the transfer accordingly.'
     WHERE ticket_id = 'BADCE4F1-B31C-488F-A1C2-D925B1746F71';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'BADCE4F1-B31C-488F-A1C2-D925B1746F71',
            'API',
            'SEED-BADCE4F1-B31C-488F-A1C2-D925B1746F71',
            'Transfer to a convalescence unit after hospital discharge',
            'Good afternoon,

My grandmother (84 years old) is being discharged from hospital but is not in a condition to go straight home. The doctor mentioned transfer to a convalescence unit. How does this process work?

Thank you,
Teresa Monteiro',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Hello Teresa Monteiro,

The process of transfer to a convalescence unit after hospital discharge is generally initiated by the responsible doctor. The clinical team assesses the need for continued care after discharge and, if necessary, coordinates the transfer to a suitable unit. The social worker and discharge team are involved in finding the most appropriate placement. [KB: ALT-003]',
            'Hello Teresa Monteiro,

The process of transfer to a convalescence unit after hospital discharge is generally initiated by the responsible doctor. The clinical team assesses the need for continued care after discharge and coordinates the transfer accordingly.',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket C668A2BD-68FE-49C1-AD9C-5C0FF0E3B12B
    UPDATE tickets
       SET subject = 'Scheduling application crashes on opening',
        body = 'Good morning, the appointment scheduling application crashes every time I try to open a patient record. The error shown is "Runtime Error 502". Windows 10, version 21H2.',
        submitted_category = 'Software',
        generated_answer = 'For errors in clinical applications, first check for pending updates (Help menu > Check for updates). Note the exact error code and time of occurrence and open a ticket in the Service Desk. For Runtime Error 502 in the scheduling application, there is a known patch — [KB: IT-SW-004].',
        suggested_answer = 'For errors in clinical applications, first check for pending updates (Help menu > Check for updates). Note the exact error code and time of occurrence and open a ticket in the Service Desk. For Runtime Error 502 in the scheduling application, there is a known patch.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = 'C668A2BD-68FE-49C1-AD9C-5C0FF0E3B12B';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'C668A2BD-68FE-49C1-AD9C-5C0FF0E3B12B',
            'API',
            'SEED-C668A2BD-68FE-49C1-AD9C-5C0FF0E3B12B',
            'Scheduling application crashes on opening',
            'Good morning, the appointment scheduling application crashes every time I try to open a patient record. The error shown is "Runtime Error 502". Windows 10, version 21H2.',
            'Software',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'For errors in clinical applications, first check for pending updates (Help menu > Check for updates). Note the exact error code and time of occurrence and open a ticket in the Service Desk. For Runtime Error 502 in the scheduling application, there is a known patch — [KB: IT-SW-004].',
            'For errors in clinical applications, first check for pending updates (Help menu > Check for updates). Note the exact error code and time of occurrence and open a ticket in the Service Desk. For Runtime Error 502 in the scheduling application, there is a known patch.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 4253FCBF-1004-4149-85C5-E9B7137FDB0D
    UPDATE tickets
       SET subject = 'No internet access on floor 4',
        body = 'Good morning, the entire floor 4 of building B has had no internet access since 08:30. Internal clinical systems are working but there is no external connection. This affects 12 workstations.',
        submitted_category = 'Network',
        generated_answer = 'For network problems, check the LEDs on the local switch/router. If the problem affects multiple workstations it is likely an infrastructure failure — contact IT immediately on extension 9000 giving the floor, building and number of affected workstations. For VPN problems when working remotely, verify your credentials and check the VPN configuration. [KB: IT-NET-001, IT-NET-003]',
        suggested_answer = 'For network problems, check the LEDs on the local switch/router. If the problem affects multiple workstations it is likely an infrastructure failure — contact IT immediately on extension 9000 giving the floor, building and number of affected workstations.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = '4253FCBF-1004-4149-85C5-E9B7137FDB0D';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '4253FCBF-1004-4149-85C5-E9B7137FDB0D',
            'API',
            'SEED-4253FCBF-1004-4149-85C5-E9B7137FDB0D',
            'No internet access on floor 4',
            'Good morning, the entire floor 4 of building B has had no internet access since 08:30. Internal clinical systems are working but there is no external connection. This affects 12 workstations.',
            'Network',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'For network problems, check the LEDs on the local switch/router. If the problem affects multiple workstations it is likely an infrastructure failure — contact IT immediately on extension 9000 giving the floor, building and number of affected workstations. For VPN problems when working remotely, verify your credentials and check the VPN configuration. [KB: IT-NET-001, IT-NET-003]',
            'For network problems, check the LEDs on the local switch/router. If the problem affects multiple workstations it is likely an infrastructure failure — contact IT immediately on extension 9000 giving the floor, building and number of affected workstations.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 6E85234C-852B-46EB-B8E5-B6C944F6A0CF
    UPDATE tickets
       SET subject = 'Psychological support available for cancer patients after mastectomy',
        body = 'Good morning,

I had a mastectomy two months ago and am experiencing emotional difficulties adapting. What type of psychological support does the hospital offer for oncology patients?

Thank you,
Marta Azevedo',
        generated_answer = 'Hospital Group offers psychological support for oncology patients, including those who have undergone mastectomy. The Psychology specialty provides this support. For anxiety, depression or other emotional difficulties, a referral through the oncology team is recommended. [KB: ESP-007]'
     WHERE ticket_id = '6E85234C-852B-46EB-B8E5-B6C944F6A0CF';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '6E85234C-852B-46EB-B8E5-B6C944F6A0CF',
            'API',
            'SEED-6E85234C-852B-46EB-B8E5-B6C944F6A0CF',
            'Psychological support available for cancer patients after mastectomy',
            'Good morning,

I had a mastectomy two months ago and am experiencing emotional difficulties adapting. What type of psychological support does the hospital offer for oncology patients?

Thank you,
Marta Azevedo',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Hospital Group offers psychological support for oncology patients, including those who have undergone mastectomy. The Psychology specialty provides this support. For anxiety, depression or other emotional difficulties, a referral through the oncology team is recommended. [KB: ESP-007]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket ADE8979B-79EA-4425-9E7E-615D9B98CF65
    UPDATE tickets
       SET subject = 'Multicare insurance refused surgery payment — missing documentation',
        body = 'Good afternoon,

My health insurance (Multicare) refused payment for the surgery performed in December, citing missing documentation. Does the hospital need to send any additional document to the insurer, or should I request something?

Policy number: 45678901

Thank you,
Tiago Valente',
        generated_answer = 'To resolve the reimbursement issue for the December surgery refused by Multicare due to missing documentation, please follow these steps:

1. **Check the required documentation**: Contact Multicare to understand exactly which documents are missing. [KB: SEG-006]'
     WHERE ticket_id = 'ADE8979B-79EA-4425-9E7E-615D9B98CF65';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'ADE8979B-79EA-4425-9E7E-615D9B98CF65',
            'API',
            'SEED-ADE8979B-79EA-4425-9E7E-615D9B98CF65',
            'Multicare insurance refused surgery payment — missing documentation',
            'Good afternoon,

My health insurance (Multicare) refused payment for the surgery performed in December, citing missing documentation. Does the hospital need to send any additional document to the insurer, or should I request something?

Policy number: 45678901

Thank you,
Tiago Valente',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'To resolve the reimbursement issue for the December surgery refused by Multicare due to missing documentation, please follow these steps:

1. **Check the required documentation**: Contact Multicare to understand exactly which documents are missing. [KB: SEG-006]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 909AA479-EB7B-4A6B-A751-B4FC80867C03
    UPDATE tickets
       SET subject = 'Urgent query about my appointment next week',
        body = 'Dear Sir/Madam,

I am writing most urgently to enquire whether it would be possible to bring my cat into the operating theatre to keep me company during surgery, given that he was present at my wedding and I firmly believe his presence has a proven calming effect.

I would also like to know whether the operating theatre offers a breakfast buffet service, as I am concerned about facing surgery on an empty stomach.',
        generated_answer = 'Hello Armindo Gomes!

It is unlikely that the hospital will permit the presence of pets such as cats in the operating theatre due to hygiene and safety requirements [KB: FAQ]. The operating theatre does not offer a breakfast buffet service, as patients must fast before surgery. [KB: INT-001]'
     WHERE ticket_id = '909AA479-EB7B-4A6B-A751-B4FC80867C03';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '909AA479-EB7B-4A6B-A751-B4FC80867C03',
            'API',
            'SEED-909AA479-EB7B-4A6B-A751-B4FC80867C03',
            'Urgent query about my appointment next week',
            'Dear Sir/Madam,

I am writing most urgently to enquire whether it would be possible to bring my cat into the operating theatre to keep me company during surgery, given that he was present at my wedding and I firmly believe his presence has a proven calming effect.

I would also like to know whether the operating theatre offers a breakfast buffet service, as I am concerned about facing surgery on an empty stomach.',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Hello Armindo Gomes!

It is unlikely that the hospital will permit the presence of pets such as cats in the operating theatre due to hygiene and safety requirements [KB: FAQ]. The operating theatre does not offer a breakfast buffet service, as patients must fast before surgery. [KB: INT-001]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket E04F2DB8-B31A-492B-833A-A1ACB2AD02FD
    UPDATE tickets
       SET subject = 'Complaint about administrative service',
        body = 'Good afternoon, I was treated rudely at the admissions desk of the Évora hospital. The member of staff was rude and provided no assistance whatsoever. I wish to formally register this situation.',
        submitted_category = 'Complaint',
        generated_answer = 'Hello Paulo Carvalho,

You can submit a formal complaint about the administrative service at the Évora hospital through the following channels:

1. **Online Complaints Book**: Visit www.hospitalgroup.pt/reclamacoes.
2. **Physical Complaints Book**: Available at reception at all units.
3. **Email**: qualidade@hospitalgroup.pt. [KB: REC-001]'
     WHERE ticket_id = 'E04F2DB8-B31A-492B-833A-A1ACB2AD02FD';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'E04F2DB8-B31A-492B-833A-A1ACB2AD02FD',
            'API',
            'SEED-E04F2DB8-B31A-492B-833A-A1ACB2AD02FD',
            'Complaint about administrative service',
            'Good afternoon, I was treated rudely at the admissions desk of the Évora hospital. The member of staff was rude and provided no assistance whatsoever. I wish to formally register this situation.',
            'Complaint',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Hello Paulo Carvalho,

You can submit a formal complaint about the administrative service at the Évora hospital through the following channels:

1. **Online Complaints Book**: Visit www.hospitalgroup.pt/reclamacoes.
2. **Physical Complaints Book**: Available at reception at all units.
3. **Email**: qualidade@hospitalgroup.pt. [KB: REC-001]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 6C9801F1-5B5F-4018-BA8F-F75F2E073E24
    UPDATE tickets
       SET subject = 'VPN not connecting when working remotely',
        body = 'Hello, I am working remotely and the corporate VPN will not connect. Error: "Authentication failed (Error 691)". I have checked my credentials and they are correct.',
        submitted_category = 'VPN',
        generated_answer = 'Hello Miguel Oliveira!

To resolve the VPN connection issue "Authentication failed (Error 691)" when working remotely, ensure your login credentials are correct. Then: 1. Check the VPN configuration (server address, protocol and authentication). 2. Restart the VPN client. 3. If the problem persists, contact the IT Service Desk on extension 9000. [KB: IT-NET-003]',
        suggested_answer = 'Hello Miguel Oliveira!

To resolve the VPN connection issue "Authentication failed (Error 691)" when working remotely, ensure your login credentials are correct. Then check the VPN configuration (server address, protocol and authentication) and restart the VPN client.',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '6C9801F1-5B5F-4018-BA8F-F75F2E073E24';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '6C9801F1-5B5F-4018-BA8F-F75F2E073E24',
            'API',
            'SEED-6C9801F1-5B5F-4018-BA8F-F75F2E073E24',
            'VPN not connecting when working remotely',
            'Hello, I am working remotely and the corporate VPN will not connect. Error: "Authentication failed (Error 691)". I have checked my credentials and they are correct.',
            'VPN',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Miguel Oliveira!

To resolve the VPN connection issue "Authentication failed (Error 691)" when working remotely, ensure your login credentials are correct. Then: 1. Check the VPN configuration (server address, protocol and authentication). 2. Restart the VPN client. 3. If the problem persists, contact the IT Service Desk on extension 9000. [KB: IT-NET-003]',
            'Hello Miguel Oliveira!

To resolve the VPN connection issue "Authentication failed (Error 691)" when working remotely, ensure your login credentials are correct. Then check the VPN configuration (server address, protocol and authentication) and restart the VPN client.',
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 76051AEB-39C0-4053-9C14-014A15B72AD1
    UPDATE tickets
       SET subject = 'Error registering episode in HIS',
        body = 'Good afternoon, when trying to register a new emergency episode in HIS the error "ORA-00001: unique constraint violated" appears. It has happened to 3 doctors in the last hour.',
        submitted_category = 'HIS',
        generated_answer = 'Hello Inês,

The error "ORA-00001: unique constraint violated" occurs when there is an attempt to insert a duplicate record in a column or set of columns with a uniqueness constraint defined in HIS. [KB: IT-SW-HIS-001]

Please check whether the episode already exists in the system before trying to create it again. If the problem persists, contact IT immediately on extension 9000.',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '76051AEB-39C0-4053-9C14-014A15B72AD1';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '76051AEB-39C0-4053-9C14-014A15B72AD1',
            'API',
            'SEED-76051AEB-39C0-4053-9C14-014A15B72AD1',
            'Error registering episode in HIS',
            'Good afternoon, when trying to register a new emergency episode in HIS the error "ORA-00001: unique constraint violated" appears. It has happened to 3 doctors in the last hour.',
            'HIS',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Inês,

The error "ORA-00001: unique constraint violated" occurs when there is an attempt to insert a duplicate record in a column or set of columns with a uniqueness constraint defined in HIS. [KB: IT-SW-HIS-001]

Please check whether the episode already exists in the system before trying to create it again. If the problem persists, contact IT immediately on extension 9000.',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 75FC4FCF-F989-4367-81BE-547144E54326
    UPDATE tickets
       SET subject = 'Emergency department opening hours',
        body = 'Good morning, I would like to know the opening hours of the emergency department at Hospital de Cascais. I have a relative who may need to go at the weekend and I wanted to confirm whether it is open 24 hours.',
        submitted_category = 'Opening Hours',
        generated_answer = 'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '75FC4FCF-F989-4367-81BE-547144E54326';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '75FC4FCF-F989-4367-81BE-547144E54326',
            'API',
            'SEED-75FC4FCF-F989-4367-81BE-547144E54326',
            'Emergency department opening hours',
            'Good morning, I would like to know the opening hours of the emergency department at Hospital de Cascais. I have a relative who may need to go at the weekend and I wanted to confirm whether it is open 24 hours.',
            'Opening Hours',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket FF7248A3-F7B3-4238-86C1-ED05147761B0
    UPDATE tickets
       SET subject = 'Clinical analysis results not received',
        body = 'Good afternoon, I had clinical tests a week ago and have not received the results by email as usual. Could you check whether they were sent to the correct address?',
        submitted_category = 'Exams',
        generated_answer = 'Hello Ana Ferreira!

If you had clinical tests a week ago and have not received the results by email, please follow these steps:

1. Check your spam/junk folder.
2. Confirm that your email address is correctly registered in the hospital system at www.hospitalgroup.pt/perfil. [KB: EXA-001]',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = 'FF7248A3-F7B3-4238-86C1-ED05147761B0';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'FF7248A3-F7B3-4238-86C1-ED05147761B0',
            'API',
            'SEED-FF7248A3-F7B3-4238-86C1-ED05147761B0',
            'Clinical analysis results not received',
            'Good afternoon, I had clinical tests a week ago and have not received the results by email as usual. Could you check whether they were sent to the correct address?',
            'Exams',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Ana Ferreira!

If you had clinical tests a week ago and have not received the results by email, please follow these steps:

1. Check your spam/junk folder.
2. Confirm that your email address is correctly registered in the hospital system at www.hospitalgroup.pt/perfil. [KB: EXA-001]',
            NULL,
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 6D3F9C41-27F7-4E79-8D85-3FD320180274
    UPDATE tickets
       SET subject = 'Complaint about waiting time in A&E',
        body = 'Good morning, I was in A&E yesterday for more than 4 hours with no information about the waiting time. The service was inadequate and I would like to submit a formal complaint.',
        submitted_category = 'Complaint',
        generated_answer = 'We regret the situation described. You can submit a formal complaint through the Online Complaints Book at www.hospitalgroup.pt/reclamacoes, in person at any unit, or by email to qualidade@hospitalgroup.pt. All complaints are reviewed by the Quality Directorate and you will receive a formal response within 15 working days. Our goal is to continuously improve the service we provide and we thank you for your feedback. [KB: REC-001, REC-002]',
        suggested_answer = 'We regret the situation described. You can submit a formal complaint through the Online Complaints Book at www.hospitalgroup.pt/reclamacoes, in person at any unit, or by email to qualidade@hospitalgroup.pt. All complaints are reviewed by the Quality Directorate and you will receive a formal response within 15 working days.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = '6D3F9C41-27F7-4E79-8D85-3FD320180274';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '6D3F9C41-27F7-4E79-8D85-3FD320180274',
            'API',
            'SEED-6D3F9C41-27F7-4E79-8D85-3FD320180274',
            'Complaint about waiting time in A&E',
            'Good morning, I was in A&E yesterday for more than 4 hours with no information about the waiting time. The service was inadequate and I would like to submit a formal complaint.',
            'Complaint',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'We regret the situation described. You can submit a formal complaint through the Online Complaints Book at www.hospitalgroup.pt/reclamacoes, in person at any unit, or by email to qualidade@hospitalgroup.pt. All complaints are reviewed by the Quality Directorate and you will receive a formal response within 15 working days. Our goal is to continuously improve the service we provide and we thank you for your feedback. [KB: REC-001, REC-002]',
            'We regret the situation described. You can submit a formal complaint through the Online Complaints Book at www.hospitalgroup.pt/reclamacoes, in person at any unit, or by email to qualidade@hospitalgroup.pt. All complaints are reviewed by the Quality Directorate and you will receive a formal response within 15 working days.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 40955425-B216-40C2-B9CF-210E8A1B64A3
    UPDATE tickets
       SET subject = 'Clinical analysis results not received',
        body = 'Good afternoon, I had clinical tests a week ago and have not received the results by email as usual. Could you check whether they were sent to the correct address?',
        submitted_category = 'Exams',
        generated_answer = 'Hello Luís Teixeira!

If you had clinical tests a week ago and have not received the results by email, please follow these steps:

1. Check your spam/junk folder.
2. Confirm that your email address is correctly registered in the hospital system at www.hospitalgroup.pt/perfil. [KB: EXA-001]',
        suggested_answer = 'Hello Luís Teixeira!

If you had clinical tests a week ago and have not received the results by email, please follow these steps:

1. Check your spam/junk folder.',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '40955425-B216-40C2-B9CF-210E8A1B64A3';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '40955425-B216-40C2-B9CF-210E8A1B64A3',
            'API',
            'SEED-40955425-B216-40C2-B9CF-210E8A1B64A3',
            'Clinical analysis results not received',
            'Good afternoon, I had clinical tests a week ago and have not received the results by email as usual. Could you check whether they were sent to the correct address?',
            'Exams',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Luís Teixeira!

If you had clinical tests a week ago and have not received the results by email, please follow these steps:

1. Check your spam/junk folder.
2. Confirm that your email address is correctly registered in the hospital system at www.hospitalgroup.pt/perfil. [KB: EXA-001]',
            'Hello Luís Teixeira!

If you had clinical tests a week ago and have not received the results by email, please follow these steps:

1. Check your spam/junk folder.',
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket A30222AF-EE36-49EE-A1DE-95C182B406AD
    UPDATE tickets
       SET subject = 'Emergency department opening hours',
        body = 'Good morning, I would like to know the opening hours of the emergency department at Hospital de Cascais. I have a relative who may need to go at the weekend and I wanted to confirm whether it is open 24 hours.',
        submitted_category = 'Opening Hours',
        generated_answer = 'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'A30222AF-EE36-49EE-A1DE-95C182B406AD';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'A30222AF-EE36-49EE-A1DE-95C182B406AD',
            'API',
            'SEED-A30222AF-EE36-49EE-A1DE-95C182B406AD',
            'Emergency department opening hours',
            'Good morning, I would like to know the opening hours of the emergency department at Hospital de Cascais. I have a relative who may need to go at the weekend and I wanted to confirm whether it is open 24 hours.',
            'Opening Hours',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket A2415266-E255-46A2-9D97-84B85D84C019
    UPDATE tickets
       SET subject = 'Paediatric A&E hours and location — child with high fever',
        body = 'Hello,

My son has a high fever and earache. What are the paediatric emergency department opening hours and where is it located?

Thank you,
Paulo Mendes'
     WHERE ticket_id = 'A2415266-E255-46A2-9D97-84B85D84C019';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'A2415266-E255-46A2-9D97-84B85D84C019',
            'API',
            'SEED-A2415266-E255-46A2-9D97-84B85D84C019',
            'Paediatric A&E hours and location — child with high fever',
            'Hello,

My son has a high fever and earache. What are the paediatric emergency department opening hours and where is it located?

Thank you,
Paulo Mendes',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 2DD6344E-EA66-4A90-9F42-0F5A87499D4D
    UPDATE tickets
       SET subject = 'Can I go to A&E with a companion — difficulty moving alone?',
        body = 'Good morning,

I am going to A&E but have difficulty moving on my own. Can I go with a companion? Is there any restriction on the number of companions?

Thank you,
Pedro Gomes'
     WHERE ticket_id = '2DD6344E-EA66-4A90-9F42-0F5A87499D4D';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '2DD6344E-EA66-4A90-9F42-0F5A87499D4D',
            'API',
            'SEED-2DD6344E-EA66-4A90-9F42-0F5A87499D4D',
            'Can I go to A&E with a companion — difficulty moving alone?',
            'Good morning,

I am going to A&E but have difficulty moving on my own. Can I go with a companion? Is there any restriction on the number of companions?

Thank you,
Pedro Gomes',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 00F7C5F5-BA57-46C8-8C86-E37690EA28FB
    UPDATE tickets
       SET subject = 'Does the hospital have a dental emergency service for toothache?',
        body = 'Good afternoon,

I have had unbearable toothache since this morning and cannot get an appointment with any dentist. Does the hospital have a dental/stomatology emergency service?

Kind regards,
Ricardo Vieira',
        generated_answer = 'Hello Ricardo Vieira,

Hospital Group does not have a specific Stomatology emergency department, but the Dentistry/Stomatology specialty is available to treat dental pain. We recommend contacting the hospital to check availability and the best procedure to follow. [KB: ESP-012]',
        suggested_answer = 'Hello Ricardo Vieira,

Hospital Group does not have a specific Stomatology emergency department, but the Dentistry/Stomatology specialty is available to treat dental pain. Please contact the hospital to check availability.'
     WHERE ticket_id = '00F7C5F5-BA57-46C8-8C86-E37690EA28FB';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '00F7C5F5-BA57-46C8-8C86-E37690EA28FB',
            'API',
            'SEED-00F7C5F5-BA57-46C8-8C86-E37690EA28FB',
            'Does the hospital have a dental emergency service for toothache?',
            'Good afternoon,

I have had unbearable toothache since this morning and cannot get an appointment with any dentist. Does the hospital have a dental/stomatology emergency service?

Kind regards,
Ricardo Vieira',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Hello Ricardo Vieira,

Hospital Group does not have a specific Stomatology emergency department, but the Dentistry/Stomatology specialty is available to treat dental pain. We recommend contacting the hospital to check availability and the best procedure to follow. [KB: ESP-012]',
            'Hello Ricardo Vieira,

Hospital Group does not have a specific Stomatology emergency department, but the Dentistry/Stomatology specialty is available to treat dental pain. Please contact the hospital to check availability.',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket BB5354C4-021C-41A8-A01E-12192F2C2123
    UPDATE tickets
       SET subject = 'Sudden vision loss in right eye — how does Ophthalmology A&E work?',
        body = 'Hello,

I feel I am losing vision in my right eye since this morning. Is this an emergency? Does your hospital have an Ophthalmology emergency service? Can I go directly or do I need to call first?

Thank you,
Paulo Mendes'
     WHERE ticket_id = 'BB5354C4-021C-41A8-A01E-12192F2C2123';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'BB5354C4-021C-41A8-A01E-12192F2C2123',
            'API',
            'SEED-BB5354C4-021C-41A8-A01E-12192F2C2123',
            'Sudden vision loss in right eye — how does Ophthalmology A&E work?',
            'Hello,

I feel I am losing vision in my right eye since this morning. Is this an emergency? Does your hospital have an Ophthalmology emergency service? Can I go directly or do I need to call first?

Thank you,
Paulo Mendes',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 47D0F03F-886E-4C82-A78D-53B4A78B7A27
    UPDATE tickets
       SET subject = '28 weeks pregnant with abdominal pain — obstetric A&E or wait for appointment?',
        body = 'Good morning,

I am 28 weeks pregnant and am experiencing regular abdominal pains. Should I go to the obstetric emergency department or wait for tomorrow''s appointment?

Kind regards,
Tiago Valente'
     WHERE ticket_id = '47D0F03F-886E-4C82-A78D-53B4A78B7A27';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '47D0F03F-886E-4C82-A78D-53B4A78B7A27',
            'API',
            'SEED-47D0F03F-886E-4C82-A78D-53B4A78B7A27',
            '28 weeks pregnant with abdominal pain — obstetric A&E or wait for appointment?',
            'Good morning,

I am 28 weeks pregnant and am experiencing regular abdominal pains. Should I go to the obstetric emergency department or wait for tomorrow''s appointment?

Kind regards,
Tiago Valente',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket CC91F0DF-DFD0-4B9E-AD7C-7719092A31C5
    UPDATE tickets
       SET subject = 'What documents to bring to A&E with Multicare health insurance?',
        body = 'Good afternoon,

I am going to A&E and want to know what documents I should bring. I have my citizen card, SNS card and Multicare health insurance.

Thank you,
Rui Marques'
     WHERE ticket_id = 'CC91F0DF-DFD0-4B9E-AD7C-7719092A31C5';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'CC91F0DF-DFD0-4B9E-AD7C-7719092A31C5',
            'API',
            'SEED-CC91F0DF-DFD0-4B9E-AD7C-7719092A31C5',
            'What documents to bring to A&E with Multicare health insurance?',
            'Good afternoon,

I am going to A&E and want to know what documents I should bring. I have my citizen card, SNS card and Multicare health insurance.

Thank you,
Rui Marques',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 909AA479-EB7B-4A6B-A751-B4FC80889C03
    UPDATE tickets
       SET subject = 'Surgical wound showing worrying signs 4 days after surgery — A&E?',
        body = 'Good morning,

I had surgery 4 days ago and since yesterday my surgical wound has been showing signs that concern me: redness and some fluid. Should I go to A&E or wait for the follow-up appointment?

Kind regards,
Sérgio Moreira'
     WHERE ticket_id = '909AA479-EB7B-4A6B-A751-B4FC80889C03';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '909AA479-EB7B-4A6B-A751-B4FC80889C03',
            'API',
            'SEED-909AA479-EB7B-4A6B-A751-B4FC80889C03',
            'Surgical wound showing worrying signs 4 days after surgery — A&E?',
            'Good morning,

I had surgery 4 days ago and since yesterday my surgical wound has been showing signs that concern me: redness and some fluid. Should I go to A&E or wait for the follow-up appointment?

Kind regards,
Sérgio Moreira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 280C04CE-70BE-4743-8CD2-497FA52725DC
    UPDATE tickets
       SET subject = 'Compliment for the surgical theatre nursing team',
        body = 'Good morning,

I would like to formally praise the nursing team that accompanied me during surgery and recovery. They were extremely professional, empathetic and attentive. The hospital is very fortunate to have these people.

Many thanks,
Miguel Pereira'
     WHERE ticket_id = '280C04CE-70BE-4743-8CD2-497FA52725DC';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '280C04CE-70BE-4743-8CD2-497FA52725DC',
            'API',
            'SEED-280C04CE-70BE-4743-8CD2-497FA52725DC',
            'Compliment for the surgical theatre nursing team',
            'Good morning,

I would like to formally praise the nursing team that accompanied me during surgery and recovery. They were extremely professional, empathetic and attentive. The hospital is very fortunate to have these people.

Many thanks,
Miguel Pereira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 15FA770C-FD8C-4908-8DD6-B75C5AFF2030
    UPDATE tickets
       SET subject = 'How to cancel a Rheumatology appointment without a penalty',
        body = 'Hello,

I need to cancel my Rheumatology appointment scheduled for the 22nd of this month due to an unavoidable professional commitment. How should I proceed and what is the minimum notice period to cancel without a penalty?

Thank you,
Pedro Gomes',
        generated_answer = 'To cancel your Rheumatology appointment without a penalty, you must do so at least 24 hours in advance [Hospital Group - FAQ - Appointment Cancellations].

You can cancel through the Hospital Group portal or app, or by contacting us via WhatsApp or phone. [KB: MARC-002]',
        suggested_answer = 'To cancel your Rheumatology appointment without a penalty, you must do so at least 24 hours in advance [Hospital Group - FAQ - Appointment Cancellations].

You can cancel through the Hospital Group portal or app, or by contacting us via WhatsApp or phone.'
     WHERE ticket_id = '15FA770C-FD8C-4908-8DD6-B75C5AFF2030';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '15FA770C-FD8C-4908-8DD6-B75C5AFF2030',
            'API',
            'SEED-15FA770C-FD8C-4908-8DD6-B75C5AFF2030',
            'How to cancel a Rheumatology appointment without a penalty',
            'Hello,

I need to cancel my Rheumatology appointment scheduled for the 22nd of this month due to an unavoidable professional commitment. How should I proceed and what is the minimum notice period to cancel without a penalty?

Thank you,
Pedro Gomes',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'To cancel your Rheumatology appointment without a penalty, you must do so at least 24 hours in advance [Hospital Group - FAQ - Appointment Cancellations].

You can cancel through the Hospital Group portal or app, or by contacting us via WhatsApp or phone. [KB: MARC-002]',
            'To cancel your Rheumatology appointment without a penalty, you must do so at least 24 hours in advance [Hospital Group - FAQ - Appointment Cancellations].

You can cancel through the Hospital Group portal or app, or by contacting us via WhatsApp or phone.',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket DFEB3405-E782-482F-946C-B1EED9347FEC
    UPDATE tickets
       SET subject = 'Complaint about waiting time in A&E',
        body = 'Good morning, I was in A&E yesterday for more than 4 hours with no information about the waiting time. The service was inadequate and I would like to submit a formal complaint.',
        submitted_category = 'Complaint',
        generated_answer = 'We regret the situation described. You can submit a formal complaint through the Online Complaints Book at www.hospitalgroup.pt/reclamacoes, in person at any unit, or by email to qualidade@hospitalgroup.pt. All complaints are reviewed by the Quality Directorate and you will receive a formal response within 15 working days. Our goal is to continuously improve the service we provide and we thank you for your feedback. [KB: REC-001, REC-002]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'DFEB3405-E782-482F-946C-B1EED9347FEC';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'DFEB3405-E782-482F-946C-B1EED9347FEC',
            'API',
            'SEED-DFEB3405-E782-482F-946C-B1EED9347FEC',
            'Complaint about waiting time in A&E',
            'Good morning, I was in A&E yesterday for more than 4 hours with no information about the waiting time. The service was inadequate and I would like to submit a formal complaint.',
            'Complaint',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'We regret the situation described. You can submit a formal complaint through the Online Complaints Book at www.hospitalgroup.pt/reclamacoes, in person at any unit, or by email to qualidade@hospitalgroup.pt. All complaints are reviewed by the Quality Directorate and you will receive a formal response within 15 working days. Our goal is to continuously improve the service we provide and we thank you for your feedback. [KB: REC-001, REC-002]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket A9E3CDDE-71AB-4F5D-A1F6-646CB39B2C3B
    UPDATE tickets
       SET subject = 'Complaint about administrative service',
        body = 'Good afternoon, I was treated rudely at the admissions desk of the Évora hospital. The member of staff was rude and provided no assistance whatsoever. I wish to formally register this situation.',
        submitted_category = 'Complaint',
        generated_answer = 'We regret the situation described. You can submit a formal complaint through the Online Complaints Book at www.hospitalgroup.pt/reclamacoes, in person at any unit, or by email to qualidade@hospitalgroup.pt. All complaints are reviewed by the Quality Directorate and you will receive a formal response within 15 working days. Our goal is to continuously improve the service we provide and we thank you for your feedback. [KB: REC-001, REC-002]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'A9E3CDDE-71AB-4F5D-A1F6-646CB39B2C3B';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'A9E3CDDE-71AB-4F5D-A1F6-646CB39B2C3B',
            'API',
            'SEED-A9E3CDDE-71AB-4F5D-A1F6-646CB39B2C3B',
            'Complaint about administrative service',
            'Good afternoon, I was treated rudely at the admissions desk of the Évora hospital. The member of staff was rude and provided no assistance whatsoever. I wish to formally register this situation.',
            'Complaint',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'We regret the situation described. You can submit a formal complaint through the Online Complaints Book at www.hospitalgroup.pt/reclamacoes, in person at any unit, or by email to qualidade@hospitalgroup.pt. All complaints are reviewed by the Quality Directorate and you will receive a formal response within 15 working days. Our goal is to continuously improve the service we provide and we thank you for your feedback. [KB: REC-001, REC-002]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket E96E4673-F1BD-4AE0-A7BF-F7447744EED4
    UPDATE tickets
       SET subject = 'Cannot access the HIS system',
        body = 'Good morning, when trying to log in to HIS this morning I receive the message "Invalid credentials". I have changed my password twice without success. Employee number: C-4821.',
        submitted_category = 'Access',
        generated_answer = 'To reset a password for internal systems, submit a request via the Service Desk at helpdesk.hospitalgroup.pt or call extension 9000 (available 07:00–22:00). For urgent resets outside these hours, contact the on-call technician on extension 9999. The reset is completed within 30 minutes during normal hours. After the reset, the temporary password is sent to the personal email address registered with HR. [KB: IT-PASS-001, IT-PASS-002]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'E96E4673-F1BD-4AE0-A7BF-F7447744EED4';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'E96E4673-F1BD-4AE0-A7BF-F7447744EED4',
            'API',
            'SEED-E96E4673-F1BD-4AE0-A7BF-F7447744EED4',
            'Cannot access the HIS system',
            'Good morning, when trying to log in to HIS this morning I receive the message "Invalid credentials". I have changed my password twice without success. Employee number: C-4821.',
            'Access',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'To reset a password for internal systems, submit a request via the Service Desk at helpdesk.hospitalgroup.pt or call extension 9000 (available 07:00–22:00). For urgent resets outside these hours, contact the on-call technician on extension 9999. The reset is completed within 30 minutes during normal hours. After the reset, the temporary password is sent to the personal email address registered with HR. [KB: IT-PASS-001, IT-PASS-002]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 68E002E3-933A-4193-9970-E2D14FE8A602
    UPDATE tickets
       SET subject = 'Medical report for insurance company',
        body = 'Good afternoon, my insurance company is requesting a detailed medical report relating to the surgery I had in December. How can I obtain this report?',
        submitted_category = 'Reports',
        generated_answer = 'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days. For urgent documents (insurers, court), an express service with 48-hour delivery is available for an administrative fee of €20. [KB: DOC-001, DOC-002, DOC-005]'
     WHERE ticket_id = '68E002E3-933A-4193-9970-E2D14FE8A602';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '68E002E3-933A-4193-9970-E2D14FE8A602',
            'API',
            'SEED-68E002E3-933A-4193-9970-E2D14FE8A602',
            'Medical report for insurance company',
            'Good afternoon, my insurance company is requesting a detailed medical report relating to the surgery I had in December. How can I obtain this report?',
            'Reports',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days. For urgent documents (insurers, court), an express service with 48-hour delivery is available for an administrative fee of €20. [KB: DOC-001, DOC-002, DOC-005]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 8939F8AE-DFB4-41D6-B06F-9B5D0954279C
    UPDATE tickets
       SET subject = 'Copy of clinical analysis results',
        body = 'Hello, I had clinical tests in January and lost the printed results. Could you send me a copy by email? My patient number is 123456789.',
        submitted_category = 'Results',
        generated_answer = 'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days. For urgent documents (insurers, court), an express service with 48-hour delivery is available for an administrative fee of €20. [KB: DOC-001, DOC-002, DOC-005]'
     WHERE ticket_id = '8939F8AE-DFB4-41D6-B06F-9B5D0954279C';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '8939F8AE-DFB4-41D6-B06F-9B5D0954279C',
            'API',
            'SEED-8939F8AE-DFB4-41D6-B06F-9B5D0954279C',
            'Copy of clinical analysis results',
            'Hello, I had clinical tests in January and lost the printed results. Could you send me a copy by email? My patient number is 123456789.',
            'Results',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days. For urgent documents (insurers, court), an express service with 48-hour delivery is available for an administrative fee of €20. [KB: DOC-001, DOC-002, DOC-005]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket BCAEC36F-9C3D-471C-AF40-40826FB72BD3
    UPDATE tickets
       SET subject = 'Does ADSE cover a nutrition consultation?',
        body = 'Good morning, I have ADSE as my health scheme. Does your unit have an agreement with ADSE for nutrition and dietetics consultations? What is the co-payment?',
        submitted_category = 'Insurance',
        generated_answer = 'Hello Carlos Rodrigues,

ADSE does not cover Nutrition consultations under direct access. However, Hospital Group has an active agreement with ADSE at several units. We recommend checking the specific conditions of your policy with ADSE or contacting the Hospital Group appointments line. [KB: SEG-001]',
        suggested_answer = 'Hello Carlos Rodrigues,

ADSE does not cover Nutrition consultations under direct access. However, Hospital Group has an active agreement with ADSE at several units. We recommend checking the specific conditions with ADSE.'
     WHERE ticket_id = 'BCAEC36F-9C3D-471C-AF40-40826FB72BD3';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'BCAEC36F-9C3D-471C-AF40-40826FB72BD3',
            'API',
            'SEED-BCAEC36F-9C3D-471C-AF40-40826FB72BD3',
            'Does ADSE cover a nutrition consultation?',
            'Good morning, I have ADSE as my health scheme. Does your unit have an agreement with ADSE for nutrition and dietetics consultations? What is the co-payment?',
            'Insurance',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Hello Carlos Rodrigues,

ADSE does not cover Nutrition consultations under direct access. However, Hospital Group has an active agreement with ADSE at several units. We recommend checking the specific conditions of your policy with ADSE or contacting the Hospital Group appointments line. [KB: SEG-001]',
            'Hello Carlos Rodrigues,

ADSE does not cover Nutrition consultations under direct access. However, Hospital Group has an active agreement with ADSE at several units. We recommend checking the specific conditions with ADSE.',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 2EF51F41-449F-41FD-B6E3-5B8178E11BBD
    UPDATE tickets
       SET subject = 'Médis insurance — which procedures are covered?',
        body = 'Good afternoon, I have Médis health insurance and would like to know which medical procedures and exams are covered at your clinic. I need to have an MRI scan.',
        submitted_category = 'Insurance',
        generated_answer = 'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment with your beneficiary card. For ADSE, nutrition and dental consultations are not covered under direct access. [KB: SEG-001, SEG-003, SEG-006]'
     WHERE ticket_id = '2EF51F41-449F-41FD-B6E3-5B8178E11BBD';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '2EF51F41-449F-41FD-B6E3-5B8178E11BBD',
            'API',
            'SEED-2EF51F41-449F-41FD-B6E3-5B8178E11BBD',
            'Médis insurance — which procedures are covered?',
            'Good afternoon, I have Médis health insurance and would like to know which medical procedures and exams are covered at your clinic. I need to have an MRI scan.',
            'Insurance',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment with your beneficiary card. For ADSE, nutrition and dental consultations are not covered under direct access. [KB: SEG-001, SEG-003, SEG-006]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket AF39D412-D1A0-42D5-8A6B-9D89F09B08B5
    UPDATE tickets
       SET subject = 'Request for hospitalisation certificate',
        body = 'Good morning, I was admitted in November 2025 and need a hospitalisation certificate to give to my insurer. How can I request this document?',
        submitted_category = 'Documents',
        generated_answer = 'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days. For urgent documents (insurers, court), an express service with 48-hour delivery is available for an administrative fee of €20. [KB: DOC-001, DOC-002, DOC-005]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'AF39D412-D1A0-42D5-8A6B-9D89F09B08B5';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'AF39D412-D1A0-42D5-8A6B-9D89F09B08B5',
            'API',
            'SEED-AF39D412-D1A0-42D5-8A6B-9D89F09B08B5',
            'Request for hospitalisation certificate',
            'Good morning, I was admitted in November 2025 and need a hospitalisation certificate to give to my insurer. How can I request this document?',
            'Documents',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days. For urgent documents (insurers, court), an express service with 48-hour delivery is available for an administrative fee of €20. [KB: DOC-001, DOC-002, DOC-005]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 05D3F9B7-23AE-4414-BF1D-6D0825FED751
    UPDATE tickets
       SET subject = 'Medical report for insurance company',
        body = 'Good afternoon, my insurance company is requesting a detailed medical report relating to the surgery I had in December. How can I obtain this report?',
        submitted_category = 'Reports',
        generated_answer = 'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days. For urgent documents (insurers, court), an express service with 48-hour delivery is available for an administrative fee of €20. [KB: DOC-001, DOC-002, DOC-005]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '05D3F9B7-23AE-4414-BF1D-6D0825FED751';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '05D3F9B7-23AE-4414-BF1D-6D0825FED751',
            'API',
            'SEED-05D3F9B7-23AE-4414-BF1D-6D0825FED751',
            'Medical report for insurance company',
            'Good afternoon, my insurance company is requesting a detailed medical report relating to the surgery I had in December. How can I obtain this report?',
            'Reports',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days. For urgent documents (insurers, court), an express service with 48-hour delivery is available for an administrative fee of €20. [KB: DOC-001, DOC-002, DOC-005]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket C3C4DB29-D691-44B2-83E9-0240FC9EEEAE
    UPDATE tickets
       SET subject = 'Copy of clinical analysis results',
        body = 'Hello, I had clinical tests in January and lost the printed results. Could you send me a copy by email? My patient number is 123456789.',
        submitted_category = 'Results',
        generated_answer = 'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days. For urgent documents (insurers, court), an express service with 48-hour delivery is available for an administrative fee of €20. [KB: DOC-001, DOC-002, DOC-005]',
        suggested_answer = 'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = 'C3C4DB29-D691-44B2-83E9-0240FC9EEEAE';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'C3C4DB29-D691-44B2-83E9-0240FC9EEEAE',
            'API',
            'SEED-C3C4DB29-D691-44B2-83E9-0240FC9EEEAE',
            'Copy of clinical analysis results',
            'Hello, I had clinical tests in January and lost the printed results. Could you send me a copy by email? My patient number is 123456789.',
            'Results',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days. For urgent documents (insurers, court), an express service with 48-hour delivery is available for an administrative fee of €20. [KB: DOC-001, DOC-002, DOC-005]',
            'Clinical documents (hospitalisation certificates, medical reports, copies of results) can be requested from the Clinical Records office of the unit where the procedure was carried out, in person with a valid ID, or by email at arquivo@hospitalgroup.pt. Processing time is 5 to 10 working days.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket D19277B2-AC57-4EBA-A56F-8C81744A644E
    UPDATE tickets
       SET subject = 'Request to book a Cardiology appointment',
        body = 'Good morning,

I would like to book a Cardiology appointment as soon as possible. My GP referred me following an abnormal ECG result. I am available on Tuesday and Thursday afternoons.

Thank you for your help.
Kind regards,
Marta Azevedo'
     WHERE ticket_id = 'D19277B2-AC57-4EBA-A56F-8C81744A644E';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'D19277B2-AC57-4EBA-A56F-8C81744A644E',
            'API',
            'SEED-D19277B2-AC57-4EBA-A56F-8C81744A644E',
            'Request to book a Cardiology appointment',
            'Good morning,

I would like to book a Cardiology appointment as soon as possible. My GP referred me following an abnormal ECG result. I am available on Tuesday and Thursday afternoons.

Thank you for your help.
Kind regards,
Marta Azevedo',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 4E98411E-5E89-4DBF-963C-743ACD9C8A36
    UPDATE tickets
       SET subject = 'Scheduling application crashes on opening',
        body = 'Good morning, the appointment scheduling application crashes every time I try to open a patient record. The error shown is "Runtime Error 502". Windows 10, version 21H2.',
        submitted_category = 'Software',
        generated_answer = 'Hello Carlos Rodrigues,

The "Runtime Error 502" in the appointment scheduling application may be related to compatibility issues or the application''s specific behaviour with Windows 10 version 21H2. To resolve this, it is recommended to check for updates and reinstall if necessary. [KB: IT-SW-004]',
        suggested_answer = 'Hello Carlos Rodrigues,

The "Runtime Error 502" in the appointment scheduling application may be related to compatibility issues with Windows 10 version 21H2. Please check for updates and contact the Service Desk if the problem persists.',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '4E98411E-5E89-4DBF-963C-743ACD9C8A36';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '4E98411E-5E89-4DBF-963C-743ACD9C8A36',
            'API',
            'SEED-4E98411E-5E89-4DBF-963C-743ACD9C8A36',
            'Scheduling application crashes on opening',
            'Good morning, the appointment scheduling application crashes every time I try to open a patient record. The error shown is "Runtime Error 502". Windows 10, version 21H2.',
            'Software',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Carlos Rodrigues,

The "Runtime Error 502" in the appointment scheduling application may be related to compatibility issues or the application''s specific behaviour with Windows 10 version 21H2. To resolve this, it is recommended to check for updates and reinstall if necessary. [KB: IT-SW-004]',
            'Hello Carlos Rodrigues,

The "Runtime Error 502" in the appointment scheduling application may be related to compatibility issues with Windows 10 version 21H2. Please check for updates and contact the Service Desk if the problem persists.',
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 24B82B9F-B0ED-4323-A92B-782F9499C6F6
    UPDATE tickets
       SET subject = 'How to pay the invoice online?',
        body = 'Hello, I received my invoice by email but cannot find the online payment link. What payment methods are available? Do you accept Multibanco, MB Way and credit card?',
        submitted_category = 'Payments',
        generated_answer = 'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). We accept payment by Multibanco, MB Way, credit/debit card and bank transfer. To request a correction on an issued invoice, submit a rectification request with the invoice number at www.hospitalgroup.pt/faturacao. Company invoices can be issued when the tax number (NIF) is provided before the procedure or within 5 working days afterwards. [KB: FAT-001, FAT-003, FAT-007]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '24B82B9F-B0ED-4323-A92B-782F9499C6F6';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '24B82B9F-B0ED-4323-A92B-782F9499C6F6',
            'API',
            'SEED-24B82B9F-B0ED-4323-A92B-782F9499C6F6',
            'How to pay the invoice online?',
            'Hello, I received my invoice by email but cannot find the online payment link. What payment methods are available? Do you accept Multibanco, MB Way and credit card?',
            'Payments',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). We accept payment by Multibanco, MB Way, credit/debit card and bank transfer. To request a correction on an issued invoice, submit a rectification request with the invoice number at www.hospitalgroup.pt/faturacao. Company invoices can be issued when the tax number (NIF) is provided before the procedure or within 5 working days afterwards. [KB: FAT-001, FAT-003, FAT-007]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 208AC1C2-0BD1-4420-ABBB-09832BF09602
    UPDATE tickets
       SET subject = 'Invoice with incorrect values',
        body = 'Good afternoon, the invoice I received states I had 3 clinical tests but I only had 2. Could you verify and issue a corrected invoice? The invoice number is FT2025/18742.',
        submitted_category = 'Billing',
        generated_answer = 'To resolve the invoice discrepancy, please contact the Hospital Group billing team. Quote invoice number FT2025/18742 and describe the error — 3 clinical tests billed when only 2 were performed.

Contact details: faturacao@hospitalgroup.pt or 210 000 100. [KB: FAT-003]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '208AC1C2-0BD1-4420-ABBB-09832BF09602';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '208AC1C2-0BD1-4420-ABBB-09832BF09602',
            'API',
            'SEED-208AC1C2-0BD1-4420-ABBB-09832BF09602',
            'Invoice with incorrect values',
            'Good afternoon, the invoice I received states I had 3 clinical tests but I only had 2. Could you verify and issue a corrected invoice? The invoice number is FT2025/18742.',
            'Billing',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'To resolve the invoice discrepancy, please contact the Hospital Group billing team. Quote invoice number FT2025/18742 and describe the error — 3 clinical tests billed when only 2 were performed.

Contact details: faturacao@hospitalgroup.pt or 210 000 100. [KB: FAT-003]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket D5E25D0E-D583-4E25-A715-615932BBBB71
    UPDATE tickets
       SET subject = 'Request for invoice in company name',
        body = 'Good morning, I had a diagnostic exam and need the invoice issued in my company name for tax purposes. How do I proceed? Is it possible to amend an already issued invoice?',
        submitted_category = 'Billing',
        generated_answer = 'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). We accept payment by Multibanco, MB Way, credit/debit card and bank transfer. To request a correction on an issued invoice, submit a rectification request with the invoice number at www.hospitalgroup.pt/faturacao. Company invoices can be issued when the tax number (NIF) is provided before the procedure or within 5 working days afterwards. [KB: FAT-001, FAT-003, FAT-007]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'D5E25D0E-D583-4E25-A715-615932BBBB71';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'D5E25D0E-D583-4E25-A715-615932BBBB71',
            'API',
            'SEED-D5E25D0E-D583-4E25-A715-615932BBBB71',
            'Request for invoice in company name',
            'Good morning, I had a diagnostic exam and need the invoice issued in my company name for tax purposes. How do I proceed? Is it possible to amend an already issued invoice?',
            'Billing',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). We accept payment by Multibanco, MB Way, credit/debit card and bank transfer. To request a correction on an issued invoice, submit a rectification request with the invoice number at www.hospitalgroup.pt/faturacao. Company invoices can be issued when the tax number (NIF) is provided before the procedure or within 5 working days afterwards. [KB: FAT-001, FAT-003, FAT-007]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 91C795DC-A088-45AC-9870-E6A3EE52AD94
    UPDATE tickets
       SET subject = 'Address of the Braga hospital',
        body = 'Good afternoon, could you give me the exact address of your Braga unit? I need to get there tomorrow morning for an appointment and I cannot find the address on the website.',
        submitted_category = 'Location',
        generated_answer = 'Hello Teresa Nunes,

The exact address of the Braga unit can be found on the unit''s page at www.hospitalgroup.pt/hospitais-clinicas. Each unit page contains the full address and postcode, direct phone number, interactive map with directions, and public transport options. [KB: LOC-001]',
        suggested_answer = 'Hello Teresa Nunes,

The exact address of the Braga unit can be found on the unit''s page at www.hospitalgroup.pt/hospitais-clinicas. Each unit page contains the full address and postcode, direct phone number and interactive map.',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '91C795DC-A088-45AC-9870-E6A3EE52AD94';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '91C795DC-A088-45AC-9870-E6A3EE52AD94',
            'API',
            'SEED-91C795DC-A088-45AC-9870-E6A3EE52AD94',
            'Address of the Braga hospital',
            'Good afternoon, could you give me the exact address of your Braga unit? I need to get there tomorrow morning for an appointment and I cannot find the address on the website.',
            'Location',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Teresa Nunes,

The exact address of the Braga unit can be found on the unit''s page at www.hospitalgroup.pt/hospitais-clinicas. Each unit page contains the full address and postcode, direct phone number, interactive map with directions, and public transport options. [KB: LOC-001]',
            'Hello Teresa Nunes,

The exact address of the Braga unit can be found on the unit''s page at www.hospitalgroup.pt/hospitais-clinicas. Each unit page contains the full address and postcode, direct phone number and interactive map.',
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 9C332D7B-53B5-4852-BE7C-5CF2AC42EA6D
    UPDATE tickets
       SET subject = 'Which specialty for back pain?',
        body = 'Hello, I have been suffering from lower back pain for about 3 months. Should I see an orthopaedic surgeon, a physiatrist or a neurologist? My GP is unavailable this week.',
        submitted_category = 'Medical Guidance',
        generated_answer = 'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
        suggested_answer = 'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry or Psychology. For thyroid abnormalities, Endocrinology.'
     WHERE ticket_id = '9C332D7B-53B5-4852-BE7C-5CF2AC42EA6D';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '9C332D7B-53B5-4852-BE7C-5CF2AC42EA6D',
            'API',
            'SEED-9C332D7B-53B5-4852-BE7C-5CF2AC42EA6D',
            'Which specialty for back pain?',
            'Hello, I have been suffering from lower back pain for about 3 months. Should I see an orthopaedic surgeon, a physiatrist or a neurologist? My GP is unavailable this week.',
            'Medical Guidance',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
            'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry or Psychology. For thyroid abnormalities, Endocrinology.',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 11176D61-59CB-4681-89DB-367B24AA4305
    UPDATE tickets
       SET subject = 'Specialty for vision problems in a child',
        body = 'Good morning, my 7-year-old son has been having vision difficulties. Should I see a paediatrician or go directly to an ophthalmologist? What is your recommendation?',
        submitted_category = 'Paediatrics',
        generated_answer = 'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
        suggested_answer = 'The choice of specialty depends on the symptoms presented. For vision problems in children, Paediatric Ophthalmology is the recommended specialty.'
     WHERE ticket_id = '11176D61-59CB-4681-89DB-367B24AA4305';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '11176D61-59CB-4681-89DB-367B24AA4305',
            'API',
            'SEED-11176D61-59CB-4681-89DB-367B24AA4305',
            'Specialty for vision problems in a child',
            'Good morning, my 7-year-old son has been having vision difficulties. Should I see a paediatrician or go directly to an ophthalmologist? What is your recommendation?',
            'Paediatrics',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
            'The choice of specialty depends on the symptoms presented. For vision problems in children, Paediatric Ophthalmology is the recommended specialty.',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 6F21D324-DB84-4DB0-A41D-A5FF6AC6E605
    UPDATE tickets
       SET subject = 'Which specialty for back pain?',
        body = 'Hello, I have been suffering from lower back pain for about 3 months. Should I see an orthopaedic surgeon, a physiatrist or a neurologist? My GP is unavailable this week.',
        submitted_category = 'Medical Guidance',
        generated_answer = 'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '6F21D324-DB84-4DB0-A41D-A5FF6AC6E605';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '6F21D324-DB84-4DB0-A41D-A5FF6AC6E605',
            'API',
            'SEED-6F21D324-DB84-4DB0-A41D-A5FF6AC6E605',
            'Which specialty for back pain?',
            'Hello, I have been suffering from lower back pain for about 3 months. Should I see an orthopaedic surgeon, a physiatrist or a neurologist? My GP is unavailable this week.',
            'Medical Guidance',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 47408C2B-FF3B-485D-A9C4-11BBF551655A
    UPDATE tickets
       SET subject = 'Specialty for vision problems in a child',
        body = 'Good morning, my 7-year-old son has been having vision difficulties. Should I see a paediatrician or go directly to an ophthalmologist? What is your recommendation?',
        submitted_category = 'Paediatrics',
        generated_answer = 'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '47408C2B-FF3B-485D-A9C4-11BBF551655A';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '47408C2B-FF3B-485D-A9C4-11BBF551655A',
            'API',
            'SEED-47408C2B-FF3B-485D-A9C4-11BBF551655A',
            'Specialty for vision problems in a child',
            'Good morning, my 7-year-old son has been having vision difficulties. Should I see a paediatrician or go directly to an ophthalmologist? What is your recommendation?',
            'Paediatrics',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 9684615E-FCBC-46BF-9B8B-C0A2D3BE7B57
    UPDATE tickets
       SET subject = 'Consultation for anxiety and insomnia',
        body = 'Good afternoon, I have been suffering from anxiety and sleep problems for several months. Should I see a psychiatrist or a psychologist? What is the difference in terms of available treatment?',
        submitted_category = 'Mental Health',
        generated_answer = 'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '9684615E-FCBC-46BF-9B8B-C0A2D3BE7B57';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '9684615E-FCBC-46BF-9B8B-C0A2D3BE7B57',
            'API',
            'SEED-9684615E-FCBC-46BF-9B8B-C0A2D3BE7B57',
            'Consultation for anxiety and insomnia',
            'Good afternoon, I have been suffering from anxiety and sleep problems for several months. Should I see a psychiatrist or a psychologist? What is the difference in terms of available treatment?',
            'Mental Health',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket AA29AD92-685F-4F0F-9104-798DBB981218
    UPDATE tickets
       SET subject = 'Booking a cardiology appointment',
        body = 'Good afternoon, I would like to book a cardiology appointment at Hospital de Santa Maria. What is the procedure? Do I need a GP referral or can I book directly?',
        submitted_category = 'Appointments',
        generated_answer = 'Hello Bruno Fernandes!

You can book a cardiology appointment at Hospital de Santa Maria through several available channels: Patient Portal (www.hospitalgroup.pt/marcacoes), Hospital Group Mobile App, WhatsApp (965 965 301), Phone (808 200 300) or in person at the reception of any unit. [KB: MARC-001]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'AA29AD92-685F-4F0F-9104-798DBB981218';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'AA29AD92-685F-4F0F-9104-798DBB981218',
            'API',
            'SEED-AA29AD92-685F-4F0F-9104-798DBB981218',
            'Booking a cardiology appointment',
            'Good afternoon, I would like to book a cardiology appointment at Hospital de Santa Maria. What is the procedure? Do I need a GP referral or can I book directly?',
            'Appointments',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Bruno Fernandes!

You can book a cardiology appointment at Hospital de Santa Maria through several available channels: Patient Portal (www.hospitalgroup.pt/marcacoes), Hospital Group Mobile App, WhatsApp (965 965 301), Phone (808 200 300) or in person at the reception of any unit. [KB: MARC-001]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 694FA883-824C-4D86-9D0F-B6C80F602A7C
    UPDATE tickets
       SET subject = 'Organisation of follow-up and next chemotherapy cycles after discharge',
        body = 'Good morning,

I have finished my inpatient chemotherapy cycle. How is the follow-up and scheduling of next cycles organised? Is the booking done automatically or should I contact the hospital?

Thank you,
Tiago Valente',
        generated_answer = 'After discharge from a chemotherapy cycle, follow-up and scheduling of subsequent cycles are organised by the hospital. At discharge, the patient receives follow-up instructions and the date of the next appointment. It is likely that the next cycle booking is made automatically by the clinical team. [KB: ALT-001]',
        suggested_answer = 'After discharge from a chemotherapy cycle, follow-up and scheduling of subsequent cycles are organised by the hospital. At discharge, the patient receives follow-up instructions and the date of the next appointment.'
     WHERE ticket_id = '694FA883-824C-4D86-9D0F-B6C80F602A7C';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '694FA883-824C-4D86-9D0F-B6C80F602A7C',
            'API',
            'SEED-694FA883-824C-4D86-9D0F-B6C80F602A7C',
            'Organisation of follow-up and next chemotherapy cycles after discharge',
            'Good morning,

I have finished my inpatient chemotherapy cycle. How is the follow-up and scheduling of next cycles organised? Is the booking done automatically or should I contact the hospital?

Thank you,
Tiago Valente',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'After discharge from a chemotherapy cycle, follow-up and scheduling of subsequent cycles are organised by the hospital. At discharge, the patient receives follow-up instructions and the date of the next appointment. It is likely that the next cycle booking is made automatically by the clinical team. [KB: ALT-001]',
            'After discharge from a chemotherapy cycle, follow-up and scheduling of subsequent cycles are organised by the hospital. At discharge, the patient receives follow-up instructions and the date of the next appointment.',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket D0F48C5D-4733-46CC-98F2-95B54DFBBB18
    UPDATE tickets
       SET subject = 'Label printer not printing',
        body = 'Good morning, the label printer in the laboratory has stopped working. The green light is on but it does not print. I have restarted the equipment without success.',
        submitted_category = 'Printer',
        generated_answer = 'For printer problems, restart the equipment and the print spooler (Services > Print Spooler > Restart). If the problem persists, open a ticket in the Service Desk with the model, serial number and location. For installing printers on new equipment, a technician can carry out the remote configuration. [KB: IT-HW-003]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'D0F48C5D-4733-46CC-98F2-95B54DFBBB18';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'D0F48C5D-4733-46CC-98F2-95B54DFBBB18',
            'API',
            'SEED-D0F48C5D-4733-46CC-98F2-95B54DFBBB18',
            'Label printer not printing',
            'Good morning, the label printer in the laboratory has stopped working. The green light is on but it does not print. I have restarted the equipment without success.',
            'Printer',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'For printer problems, restart the equipment and the print spooler (Services > Print Spooler > Restart). If the problem persists, open a ticket in the Service Desk with the model, serial number and location. For installing printers on new equipment, a technician can carry out the remote configuration. [KB: IT-HW-003]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket E993CE04-829B-4406-B400-E5886CA80FE3
    UPDATE tickets
       SET subject = 'Configure printer on new computer',
        body = 'Good afternoon, I received a new computer and need to install the HP LaserJet printer in the meeting room on floor 3. Can you carry out the configuration remotely?',
        submitted_category = 'Printer',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'E993CE04-829B-4406-B400-E5886CA80FE3';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'E993CE04-829B-4406-B400-E5886CA80FE3',
            'API',
            'SEED-E993CE04-829B-4406-B400-E5886CA80FE3',
            'Configure printer on new computer',
            'Good afternoon, I received a new computer and need to install the HP LaserJet printer in the meeting room on floor 3. Can you carry out the configuration remotely?',
            'Printer',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            NULL,
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 0A979E86-E6EE-4BD4-AF74-5BB7FF28991F
    UPDATE tickets
       SET subject = 'No internet access on floor 4',
        body = 'Good morning, the entire floor 4 of building B has had no internet access since 08:30. Internal clinical systems are working but there is no external connection. This affects 12 workstations.',
        submitted_category = 'Network',
        generated_answer = 'For network problems, check the LEDs on the local switch/router. If the problem affects multiple workstations it is likely an infrastructure failure — contact IT immediately on extension 9000 giving the floor, building and number of affected workstations. For VPN problems when working remotely, verify your credentials and check the VPN configuration. [KB: IT-NET-001, IT-NET-003]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '0A979E86-E6EE-4BD4-AF74-5BB7FF28991F';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '0A979E86-E6EE-4BD4-AF74-5BB7FF28991F',
            'API',
            'SEED-0A979E86-E6EE-4BD4-AF74-5BB7FF28991F',
            'No internet access on floor 4',
            'Good morning, the entire floor 4 of building B has had no internet access since 08:30. Internal clinical systems are working but there is no external connection. This affects 12 workstations.',
            'Network',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'For network problems, check the LEDs on the local switch/router. If the problem affects multiple workstations it is likely an infrastructure failure — contact IT immediately on extension 9000 giving the floor, building and number of affected workstations. For VPN problems when working remotely, verify your credentials and check the VPN configuration. [KB: IT-NET-001, IT-NET-003]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 1FCDA8CE-125E-47CF-86AC-0E37A885E4BC
    UPDATE tickets
       SET subject = 'No payment receipt received for consultation paid in cash',
        body = 'Good afternoon,

I had a private consultation two weeks ago and paid in cash at reception, but did not receive a receipt. I need the document to submit to my health insurer. How can I obtain it?

Kind regards,
Maria Oliveira'
     WHERE ticket_id = '1FCDA8CE-125E-47CF-86AC-0E37A885E4BC';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '1FCDA8CE-125E-47CF-86AC-0E37A885E4BC',
            'API',
            'SEED-1FCDA8CE-125E-47CF-86AC-0E37A885E4BC',
            'No payment receipt received for consultation paid in cash',
            'Good afternoon,

I had a private consultation two weeks ago and paid in cash at reception, but did not receive a receipt. I need the document to submit to my health insurer. How can I obtain it?

Kind regards,
Maria Oliveira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 29AC3A4C-8031-4A32-8B7C-E29ED48B26AB
    UPDATE tickets
       SET subject = 'Clinical analysis values do not match the NHS price list',
        body = 'Good morning,

I had clinical tests on a GP referral and received an invoice with values that do not match the NHS price list. Could you verify and correct?

Requisition number: REQ-2025-045612

Awaiting your reply,
Pedro Gomes',
        generated_answer = 'To resolve the discrepancy in clinical analysis values versus the NHS price list, please contact the billing team at faturacao@hospitalgroup.pt or on 210 000 100. Quote the invoice number, describe the error (values do not match NHS price list) and provide the requisition number REQ-2025-045612. [KB: FAT-003]'
     WHERE ticket_id = '29AC3A4C-8031-4A32-8B7C-E29ED48B26AB';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '29AC3A4C-8031-4A32-8B7C-E29ED48B26AB',
            'API',
            'SEED-29AC3A4C-8031-4A32-8B7C-E29ED48B26AB',
            'Clinical analysis values do not match the NHS price list',
            'Good morning,

I had clinical tests on a GP referral and received an invoice with values that do not match the NHS price list. Could you verify and correct?

Requisition number: REQ-2025-045612

Awaiting your reply,
Pedro Gomes',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'To resolve the discrepancy in clinical analysis values versus the NHS price list, please contact the billing team at faturacao@hospitalgroup.pt or on 210 000 100. Quote the invoice number, describe the error (values do not match NHS price list) and provide the requisition number REQ-2025-045612. [KB: FAT-003]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket FFA32CF2-1970-4B40-A1FA-55A1509EED85
    UPDATE tickets
       SET subject = 'Request for credit note — appointment cancelled by hospital',
        body = 'Hello,

My Gynaecology appointment was cancelled by the hospital with less than 24 hours'' notice and I had already made the advance payment online. I am requesting the issue of a credit note and refund.

Kind regards,
Rui Marques',
        generated_answer = 'Hello Rui Marques,

To request a credit note and refund for the Gynaecology appointment cancelled by the hospital with less than 24 hours'' notice, please follow the steps below [hospital_group_kb_faq_pt - Refund procedure]:

1. Check whether the hospital has a specific procedure for refunds. Contact the billing team at faturacao@hospitalgroup.pt. [KB: FAT-007]'
     WHERE ticket_id = 'FFA32CF2-1970-4B40-A1FA-55A1509EED85';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'FFA32CF2-1970-4B40-A1FA-55A1509EED85',
            'API',
            'SEED-FFA32CF2-1970-4B40-A1FA-55A1509EED85',
            'Request for credit note — appointment cancelled by hospital',
            'Hello,

My Gynaecology appointment was cancelled by the hospital with less than 24 hours'' notice and I had already made the advance payment online. I am requesting the issue of a credit note and refund.

Kind regards,
Rui Marques',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Hello Rui Marques,

To request a credit note and refund for the Gynaecology appointment cancelled by the hospital with less than 24 hours'' notice, please follow the steps below [hospital_group_kb_faq_pt - Refund procedure]:

1. Check whether the hospital has a specific procedure for refunds. Contact the billing team at faturacao@hospitalgroup.pt. [KB: FAT-007]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 18E4B990-0E5A-4B8F-A4AE-B46E2DC23A0D
    UPDATE tickets
       SET subject = 'Difference between quoted price at booking and billed amount',
        body = 'Good morning,

When I booked a colonoscopy I was quoted a price of €280. The invoice I received is for €340. Could you explain this difference?

Appointment number: 2025-COL-00892

Awaiting clarification,
Teresa Monteiro'
     WHERE ticket_id = '18E4B990-0E5A-4B8F-A4AE-B46E2DC23A0D';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '18E4B990-0E5A-4B8F-A4AE-B46E2DC23A0D',
            'API',
            'SEED-18E4B990-0E5A-4B8F-A4AE-B46E2DC23A0D',
            'Difference between quoted price at booking and billed amount',
            'Good morning,

When I booked a colonoscopy I was quoted a price of €280. The invoice I received is for €340. Could you explain this difference?

Appointment number: 2025-COL-00892

Awaiting clarification,
Teresa Monteiro',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket E77F069E-E383-4404-9E47-30205921292B
    UPDATE tickets
       SET subject = 'How to get to the hospital by public transport from Barreiro?',
        body = 'Good morning,

I have an appointment next week and do not have a car. Could you advise me on the best public transport options to reach the hospital from Barreiro?

Thank you,
Ricardo Vieira'
     WHERE ticket_id = 'E77F069E-E383-4404-9E47-30205921292B';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'E77F069E-E383-4404-9E47-30205921292B',
            'API',
            'SEED-E77F069E-E383-4404-9E47-30205921292B',
            'How to get to the hospital by public transport from Barreiro?',
            'Good morning,

I have an appointment next week and do not have a car. Could you advise me on the best public transport options to reach the hospital from Barreiro?

Thank you,
Ricardo Vieira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket DA3C37D0-DC79-462E-A490-3252CAC25B68
    UPDATE tickets
       SET subject = 'Reserved parking for people with reduced mobility',
        body = 'Good afternoon,

My mother is 78 years old and has very limited mobility. She has an Orthopaedics appointment. Is there reserved parking near the hospital entrance? We need to know in advance to plan the journey.

Kind regards,
Miguel Pereira'
     WHERE ticket_id = 'DA3C37D0-DC79-462E-A490-3252CAC25B68';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'DA3C37D0-DC79-462E-A490-3252CAC25B68',
            'API',
            'SEED-DA3C37D0-DC79-462E-A490-3252CAC25B68',
            'Reserved parking for people with reduced mobility',
            'Good afternoon,

My mother is 78 years old and has very limited mobility. She has an Orthopaedics appointment. Is there reserved parking near the hospital entrance? We need to know in advance to plan the journey.

Kind regards,
Miguel Pereira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket D18A99C0-DCB4-4292-B8A7-8EB7065A6D6F
    UPDATE tickets
       SET subject = 'Specialty for vision problems in a child',
        body = 'Good morning, my 7-year-old son has been having vision difficulties. Should I see a paediatrician or go directly to an ophthalmologist? What is your recommendation?',
        submitted_category = 'Paediatrics',
        generated_answer = 'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'D18A99C0-DCB4-4292-B8A7-8EB7065A6D6F';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'D18A99C0-DCB4-4292-B8A7-8EB7065A6D6F',
            'API',
            'SEED-D18A99C0-DCB4-4292-B8A7-8EB7065A6D6F',
            'Specialty for vision problems in a child',
            'Good morning, my 7-year-old son has been having vision difficulties. Should I see a paediatrician or go directly to an ophthalmologist? What is your recommendation?',
            'Paediatrics',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 5A12B392-EF33-4CE6-9DF5-C31615B5F190
    UPDATE tickets
       SET subject = 'Consultation for anxiety and insomnia',
        body = 'Good afternoon, I have been suffering from anxiety and sleep problems for several months. Should I see a psychiatrist or a psychologist? What is the difference in terms of available treatment?',
        submitted_category = 'Mental Health',
        generated_answer = 'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '5A12B392-EF33-4CE6-9DF5-C31615B5F190';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '5A12B392-EF33-4CE6-9DF5-C31615B5F190',
            'API',
            'SEED-5A12B392-EF33-4CE6-9DF5-C31615B5F190',
            'Consultation for anxiety and insomnia',
            'Good afternoon, I have been suffering from anxiety and sleep problems for several months. Should I see a psychiatrist or a psychologist? What is the difference in terms of available treatment?',
            'Mental Health',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket E681D9A6-0B2C-48B8-8681-98AFF9337FBA
    UPDATE tickets
       SET subject = 'Which doctor for thyroid problems?',
        body = 'Hello, my blood tests show abnormal thyroid values. My GP suggested I see a specialist. Is Endocrinology the correct specialty?',
        submitted_category = 'Specialties',
        generated_answer = 'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'E681D9A6-0B2C-48B8-8681-98AFF9337FBA';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'E681D9A6-0B2C-48B8-8681-98AFF9337FBA',
            'API',
            'SEED-E681D9A6-0B2C-48B8-8681-98AFF9337FBA',
            'Which doctor for thyroid problems?',
            'Hello, my blood tests show abnormal thyroid values. My GP suggested I see a specialist. Is Endocrinology the correct specialty?',
            'Specialties',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'The choice of specialty depends on the symptoms presented. For lower back pain we recommend Orthopaedics or Physical Medicine and Rehabilitation. For vision problems in children, Paediatric Ophthalmology. For anxiety and insomnia, Psychiatry (pharmacological treatment) or Psychology (therapy). For thyroid abnormalities, Endocrinology. If in doubt, our clinical guidance line 808 100 200 can help direct you to the most appropriate specialty without the need for a prior appointment. [KB: ESP-001, ESP-004, ESP-007, ESP-010]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket DA4B9191-AFD5-4CC4-B59A-B714387DFA2C
    UPDATE tickets
       SET subject = 'Label printer not printing',
        body = 'Good morning, the label printer in the laboratory has stopped working. The green light is on but it does not print. I have restarted the equipment without success.',
        submitted_category = 'Printer',
        generated_answer = 'For printer problems, restart the equipment and the print spooler (Services > Print Spooler > Restart). If the problem persists, open a ticket in the Service Desk with the model, serial number and location. For installing printers on new equipment, a technician can carry out the remote configuration. [KB: IT-HW-003]',
        suggested_answer = 'For printer problems, restart the equipment and the print spooler (Services > Print Spooler > Restart). If the problem persists, open a ticket in the Service Desk with the model, serial number and location.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = 'DA4B9191-AFD5-4CC4-B59A-B714387DFA2C';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'DA4B9191-AFD5-4CC4-B59A-B714387DFA2C',
            'API',
            'SEED-DA4B9191-AFD5-4CC4-B59A-B714387DFA2C',
            'Label printer not printing',
            'Good morning, the label printer in the laboratory has stopped working. The green light is on but it does not print. I have restarted the equipment without success.',
            'Printer',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'For printer problems, restart the equipment and the print spooler (Services > Print Spooler > Restart). If the problem persists, open a ticket in the Service Desk with the model, serial number and location. For installing printers on new equipment, a technician can carry out the remote configuration. [KB: IT-HW-003]',
            'For printer problems, restart the equipment and the print spooler (Services > Print Spooler > Restart). If the problem persists, open a ticket in the Service Desk with the model, serial number and location.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket B488E590-7EFC-480E-AEFA-B3912DC21C2B
    UPDATE tickets
       SET subject = 'Rights of a patient involuntarily admitted to psychiatry',
        body = 'Good afternoon,

My relative has been involuntarily admitted to a psychiatric unit. What are the patient''s rights in this situation? How can I stay informed about their condition?

Kind regards,
Marta Azevedo',
        generated_answer = 'Your relative who has been involuntarily admitted to a psychiatric unit has rights guaranteed by Law No. 15/2014 and other applicable legislation. These rights include: access to healthcare within the guaranteed maximum response times (TMRG), clear information about their health status and diagnosis, and the right to have a legal representative. [KB: INT-003]',
        suggested_answer = 'Your relative who has been involuntarily admitted to a psychiatric unit has rights guaranteed by Law No. 15/2014. These include: access to healthcare, clear information about their health status and the right to a legal representative.'
     WHERE ticket_id = 'B488E590-7EFC-480E-AEFA-B3912DC21C2B';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'B488E590-7EFC-480E-AEFA-B3912DC21C2B',
            'API',
            'SEED-B488E590-7EFC-480E-AEFA-B3912DC21C2B',
            'Rights of a patient involuntarily admitted to psychiatry',
            'Good afternoon,

My relative has been involuntarily admitted to a psychiatric unit. What are the patient''s rights in this situation? How can I stay informed about their condition?

Kind regards,
Marta Azevedo',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Your relative who has been involuntarily admitted to a psychiatric unit has rights guaranteed by Law No. 15/2014 and other applicable legislation. These rights include: access to healthcare within the guaranteed maximum response times (TMRG), clear information about their health status and diagnosis, and the right to have a legal representative. [KB: INT-003]',
            'Your relative who has been involuntarily admitted to a psychiatric unit has rights guaranteed by Law No. 15/2014. These include: access to healthcare, clear information about their health status and the right to a legal representative.',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket AE6B0339-F4D2-45A5-8FE5-7FAB13A57DD9
    UPDATE tickets
       SET subject = 'Documents received at discharge and transition to GP',
        body = 'Good morning,

My father is being discharged tomorrow after a week in hospital. What documents should he receive and what should he do with the discharge note? How is the handover to the GP managed?

Thank you,
Marco Correia',
        generated_answer = 'Good morning,

At hospital discharge, your father should receive several important documents. These include the discharge note (or medical report) detailing the admission, diagnosis, treatment and recommendations. He may also receive prescriptions for medication, exam results and information about available support services. The discharge note should be shared with the GP at the earliest opportunity. [KB: ALT-001, ALT-002]'
     WHERE ticket_id = 'AE6B0339-F4D2-45A5-8FE5-7FAB13A57DD9';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'AE6B0339-F4D2-45A5-8FE5-7FAB13A57DD9',
            'API',
            'SEED-AE6B0339-F4D2-45A5-8FE5-7FAB13A57DD9',
            'Documents received at discharge and transition to GP',
            'Good morning,

My father is being discharged tomorrow after a week in hospital. What documents should he receive and what should he do with the discharge note? How is the handover to the GP managed?

Thank you,
Marco Correia',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Good morning,

At hospital discharge, your father should receive several important documents. These include the discharge note (or medical report) detailing the admission, diagnosis, treatment and recommendations. He may also receive prescriptions for medication, exam results and information about available support services. The discharge note should be shared with the GP at the earliest opportunity. [KB: ALT-001, ALT-002]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket B6A069E7-1DF1-4A9F-9629-D55B62C8F26C
    UPDATE tickets
       SET subject = 'Incorrect moderating fee charged — exempt due to chronic illness',
        body = 'Hello,

I was charged a moderating fee at A&E, but I am exempt because I am a type 1 diabetic on insulin therapy. I am requesting a refund of the €14.00 incorrectly charged.

NIF: 234567891 | Date: 15/03/2025

Kind regards,
Beatriz Alves',
        generated_answer = 'Hello Beatriz,

We apologise for the incorrect charge. To request a refund of the moderating fee, please follow the steps below as outlined in our procedures guide.

1. **Gather the documentation**: Have proof of your exemption for chronic illness (type 1 diabetes with insulin therapy) and your payment receipt. Contact the billing team at faturacao@hospitalgroup.pt. [KB: FAT-007]'
     WHERE ticket_id = 'B6A069E7-1DF1-4A9F-9629-D55B62C8F26C';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'B6A069E7-1DF1-4A9F-9629-D55B62C8F26C',
            'API',
            'SEED-B6A069E7-1DF1-4A9F-9629-D55B62C8F26C',
            'Incorrect moderating fee charged — exempt due to chronic illness',
            'Hello,

I was charged a moderating fee at A&E, but I am exempt because I am a type 1 diabetic on insulin therapy. I am requesting a refund of the €14.00 incorrectly charged.

NIF: 234567891 | Date: 15/03/2025

Kind regards,
Beatriz Alves',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Hello Beatriz,

We apologise for the incorrect charge. To request a refund of the moderating fee, please follow the steps below as outlined in our procedures guide.

1. **Gather the documentation**: Have proof of your exemption for chronic illness (type 1 diabetes with insulin therapy) and your payment receipt. Contact the billing team at faturacao@hospitalgroup.pt. [KB: FAT-007]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 444B5079-A49E-4514-9BF9-5CE29CFEFFB4
    UPDATE tickets
       SET subject = 'What to bring for a 3 to 5-day admission after abdominal surgery?',
        body = 'Good afternoon,

I am being admitted tomorrow for planned abdominal surgery with an expected stay of 3 to 5 days. What should I bring? Can I bring my mobile phone and charger?

Thank you,
António Sousa'
     WHERE ticket_id = '444B5079-A49E-4514-9BF9-5CE29CFEFFB4';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '444B5079-A49E-4514-9BF9-5CE29CFEFFB4',
            'API',
            'SEED-444B5079-A49E-4514-9BF9-5CE29CFEFFB4',
            'What to bring for a 3 to 5-day admission after abdominal surgery?',
            'Good afternoon,

I am being admitted tomorrow for planned abdominal surgery with an expected stay of 3 to 5 days. What should I bring? Can I bring my mobile phone and charger?

Thank you,
António Sousa',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket F16D1CD4-BD69-43E6-A540-45A790334A87
    UPDATE tickets
       SET subject = 'Admission of a 6-year-old child — can a parent stay overnight?',
        body = 'Hello,

My 6-year-old daughter is being admitted. Can I stay with her overnight? Is there a bed for parents? Does the hospital provide meals for accompanying family members?

Thank you,
Ricardo Vieira'
     WHERE ticket_id = 'F16D1CD4-BD69-43E6-A540-45A790334A87';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'F16D1CD4-BD69-43E6-A540-45A790334A87',
            'API',
            'SEED-F16D1CD4-BD69-43E6-A540-45A790334A87',
            'Admission of a 6-year-old child — can a parent stay overnight?',
            'Hello,

My 6-year-old daughter is being admitted. Can I stay with her overnight? Is there a bed for parents? Does the hospital provide meals for accompanying family members?

Thank you,
Ricardo Vieira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 0E36778B-83DF-4E29-9210-567257F68BA8
    UPDATE tickets
       SET subject = 'Adapted meals during admission for a diabetic patient',
        body = 'Good morning,

I am being admitted and I am diabetic. Are the hospital meals adapted for diabetics? Can I bring food from home?

Kind regards,
Vera Henriques'
     WHERE ticket_id = '0E36778B-83DF-4E29-9210-567257F68BA8';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '0E36778B-83DF-4E29-9210-567257F68BA8',
            'API',
            'SEED-0E36778B-83DF-4E29-9210-567257F68BA8',
            'Adapted meals during admission for a diabetic patient',
            'Good morning,

I am being admitted and I am diabetic. Are the hospital meals adapted for diabetics? Can I bring food from home?

Kind regards,
Vera Henriques',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 5250CAFD-F529-498E-89A8-C00007ADD517
    UPDATE tickets
       SET subject = 'Wi-Fi access for inpatients — conditions of use',
        body = 'Good afternoon,

I will probably be admitted for 5 days. Is Wi-Fi available for patients? What are the conditions of access?

Thank you,
Paulo Mendes'
     WHERE ticket_id = '5250CAFD-F529-498E-89A8-C00007ADD517';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '5250CAFD-F529-498E-89A8-C00007ADD517',
            'API',
            'SEED-5250CAFD-F529-498E-89A8-C00007ADD517',
            'Wi-Fi access for inpatients — conditions of use',
            'Good afternoon,

I will probably be admitted for 5 days. Is Wi-Fi available for patients? What are the conditions of access?

Thank you,
Paulo Mendes',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 2290A1EF-4AF2-4FE6-9C1E-D572AF166015
    UPDATE tickets
       SET subject = 'Admission process for planned surgery — when to arrive and what documents to bring',
        body = 'Hello,

I have planned surgery next week. When and where should I present myself? What documents should I bring? Should I be fasting?

Kind regards,
Joana Ribeiro'
     WHERE ticket_id = '2290A1EF-4AF2-4FE6-9C1E-D572AF166015';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '2290A1EF-4AF2-4FE6-9C1E-D572AF166015',
            'API',
            'SEED-2290A1EF-4AF2-4FE6-9C1E-D572AF166015',
            'Admission process for planned surgery — when to arrive and what documents to bring',
            'Hello,

I have planned surgery next week. When and where should I present myself? What documents should I bring? Should I be fasting?

Kind regards,
Joana Ribeiro',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 3FFFA420-0D56-4581-AA4C-5D5B7035258D
    UPDATE tickets
       SET subject = 'Single room during admission — availability and additional cost',
        body = 'Good morning,

I will need to be admitted and would prefer a single room for privacy and rest. Is this possible? What is the additional cost?

Thank you,
Beatriz Alves'
     WHERE ticket_id = '3FFFA420-0D56-4581-AA4C-5D5B7035258D';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '3FFFA420-0D56-4581-AA4C-5D5B7035258D',
            'API',
            'SEED-3FFFA420-0D56-4581-AA4C-5D5B7035258D',
            'Single room during admission — availability and additional cost',
            'Good morning,

I will need to be admitted and would prefer a single room for privacy and rest. Is this possible? What is the additional cost?

Thank you,
Beatriz Alves',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket A78AE2C5-069C-4DD6-8D5F-E3630C8EC4B8
    UPDATE tickets
       SET subject = 'Authorisation for a temporary leave during prolonged admission',
        body = 'Hello,

I have been admitted for 10 days and have an important commitment. Is it possible to request authorisation for a temporary leave? How does the process work?

Thank you,
Catarina Nunes'
     WHERE ticket_id = 'A78AE2C5-069C-4DD6-8D5F-E3630C8EC4B8';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'A78AE2C5-069C-4DD6-8D5F-E3630C8EC4B8',
            'API',
            'SEED-A78AE2C5-069C-4DD6-8D5F-E3630C8EC4B8',
            'Authorisation for a temporary leave during prolonged admission',
            'Hello,

I have been admitted for 10 days and have an important commitment. Is it possible to request authorisation for a temporary leave? How does the process work?

Thank you,
Catarina Nunes',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket CE3DFC56-7D0E-44A5-89A7-EA993712D98C
    UPDATE tickets
       SET subject = 'Questions about informed consent before surgery — can I refuse?',
        body = 'Good morning,

I have been asked to sign an informed consent form for surgery but have questions about some points. Can I speak to the doctor before signing? Do I have the right to refuse any procedure?

Kind regards,
Sérgio Moreira'
     WHERE ticket_id = 'CE3DFC56-7D0E-44A5-89A7-EA993712D98C';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'CE3DFC56-7D0E-44A5-89A7-EA993712D98C',
            'API',
            'SEED-CE3DFC56-7D0E-44A5-89A7-EA993712D98C',
            'Questions about informed consent before surgery — can I refuse?',
            'Good morning,

I have been asked to sign an informed consent form for surgery but have questions about some points. Can I speak to the doctor before signing? Do I have the right to refuse any procedure?

Kind regards,
Sérgio Moreira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket A579F553-7D87-49AC-8E31-F1259BDE83CF
    UPDATE tickets
       SET subject = '38.5°C fever for two days — should I go to A&E or is there another option?',
        body = 'Good morning,

I have had a fever of 38.5°C for two days, a cough and muscle aches. I cannot get an appointment at my health centre. Should I go to the hospital A&E or is there another option?

Thank you,
Ana Ferreira'
     WHERE ticket_id = 'A579F553-7D87-49AC-8E31-F1259BDE83CF';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'A579F553-7D87-49AC-8E31-F1259BDE83CF',
            'API',
            'SEED-A579F553-7D87-49AC-8E31-F1259BDE83CF',
            '38.5°C fever for two days — should I go to A&E or is there another option?',
            'Good morning,

I have had a fever of 38.5°C for two days, a cough and muscle aches. I cannot get an appointment at my health centre. Should I go to the hospital A&E or is there another option?

Thank you,
Ana Ferreira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 17EE56FD-8374-43C4-84E1-55FDD15C7E65
    UPDATE tickets
       SET subject = 'What does a yellow wristband mean in the Manchester triage?',
        body = 'Good afternoon,

I went to A&E and waited 30 minutes at triage. The nurse gave me a yellow wristband. What does it mean? How is the priority of care determined?

Kind regards,
Fernanda Costa'
     WHERE ticket_id = '17EE56FD-8374-43C4-84E1-55FDD15C7E65';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '17EE56FD-8374-43C4-84E1-55FDD15C7E65',
            'API',
            'SEED-17EE56FD-8374-43C4-84E1-55FDD15C7E65',
            'What does a yellow wristband mean in the Manchester triage?',
            'Good afternoon,

I went to A&E and waited 30 minutes at triage. The nurse gave me a yellow wristband. What does it mean? How is the priority of care determined?

Kind regards,
Fernanda Costa',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket DD660DF1-F842-47FB-9CF7-1EE59ADD0F6F
    UPDATE tickets
       SET subject = 'Invoice with incorrect values',
        body = 'Good afternoon, the invoice I received states I had 3 clinical tests but I only had 2. Could you verify and issue a corrected invoice? The invoice number is FT2025/18742.',
        submitted_category = 'Billing',
        generated_answer = 'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). We accept payment by Multibanco, MB Way, credit/debit card and bank transfer. To request a correction on an issued invoice, submit a rectification request with the invoice number at www.hospitalgroup.pt/faturacao. Company invoices can be issued when the tax number (NIF) is provided before the procedure or within 5 working days afterwards. [KB: FAT-001, FAT-003, FAT-007]',
        suggested_answer = 'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). To request a correction, submit a rectification request at www.hospitalgroup.pt/faturacao.'
     WHERE ticket_id = 'DD660DF1-F842-47FB-9CF7-1EE59ADD0F6F';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'DD660DF1-F842-47FB-9CF7-1EE59ADD0F6F',
            'API',
            'SEED-DD660DF1-F842-47FB-9CF7-1EE59ADD0F6F',
            'Invoice with incorrect values',
            'Good afternoon, the invoice I received states I had 3 clinical tests but I only had 2. Could you verify and issue a corrected invoice? The invoice number is FT2025/18742.',
            'Billing',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). We accept payment by Multibanco, MB Way, credit/debit card and bank transfer. To request a correction on an issued invoice, submit a rectification request with the invoice number at www.hospitalgroup.pt/faturacao. Company invoices can be issued when the tax number (NIF) is provided before the procedure or within 5 working days afterwards. [KB: FAT-001, FAT-003, FAT-007]',
            'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). To request a correction, submit a rectification request at www.hospitalgroup.pt/faturacao.',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 8B3FDF33-AE42-4A08-8FB9-C5F877D718C0
    UPDATE tickets
       SET subject = 'Request for invoice in company name',
        body = 'Good morning, I had a diagnostic exam and need the invoice issued in my company name for tax purposes. How do I proceed? Is it possible to amend an already issued invoice?',
        submitted_category = 'Billing',
        generated_answer = 'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). We accept payment by Multibanco, MB Way, credit/debit card and bank transfer. To request a correction on an issued invoice, submit a rectification request with the invoice number at www.hospitalgroup.pt/faturacao. Company invoices can be issued when the tax number (NIF) is provided before the procedure or within 5 working days afterwards. [KB: FAT-001, FAT-003, FAT-007]',
        suggested_answer = 'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). Company invoices can be issued when the NIF is provided before the procedure or within 5 working days afterwards.'
     WHERE ticket_id = '8B3FDF33-AE42-4A08-8FB9-C5F877D718C0';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '8B3FDF33-AE42-4A08-8FB9-C5F877D718C0',
            'API',
            'SEED-8B3FDF33-AE42-4A08-8FB9-C5F877D718C0',
            'Request for invoice in company name',
            'Good morning, I had a diagnostic exam and need the invoice issued in my company name for tax purposes. How do I proceed? Is it possible to amend an already issued invoice?',
            'Billing',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). We accept payment by Multibanco, MB Way, credit/debit card and bank transfer. To request a correction on an issued invoice, submit a rectification request with the invoice number at www.hospitalgroup.pt/faturacao. Company invoices can be issued when the tax number (NIF) is provided before the procedure or within 5 working days afterwards. [KB: FAT-001, FAT-003, FAT-007]',
            'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). Company invoices can be issued when the NIF is provided before the procedure or within 5 working days afterwards.',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 50B0AF15-F65A-460A-8E40-229065A2A58F
    UPDATE tickets
       SET subject = 'Request for hospitalisation certificate',
        body = 'Good morning, I was admitted in November 2025 and need a hospitalisation certificate to give to my insurer. How can I request this document?',
        submitted_category = 'Documents'
     WHERE ticket_id = '50B0AF15-F65A-460A-8E40-229065A2A58F';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '50B0AF15-F65A-460A-8E40-229065A2A58F',
            'API',
            'SEED-50B0AF15-F65A-460A-8E40-229065A2A58F',
            'Request for hospitalisation certificate',
            'Good morning, I was admitted in November 2025 and need a hospitalisation certificate to give to my insurer. How can I request this document?',
            'Documents',
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket AC3196F7-E6E0-4CA8-A68A-99A0E391FD1E
    UPDATE tickets
       SET subject = 'Query about inpatient bill',
        body = 'Good morning, I received an invoice for my January inpatient stay and there is a charge I cannot identify. What exactly does the item "TAXA ADM 2025" (value: €45) refer to?',
        submitted_category = 'Billing',
        generated_answer = 'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). We accept payment by Multibanco, MB Way, credit/debit card and bank transfer. To request a correction on an issued invoice, submit a rectification request with the invoice number at www.hospitalgroup.pt/faturacao. [KB: FAT-001, FAT-003, FAT-007]',
        suggested_answer = 'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). To request a correction, submit a rectification request at www.hospitalgroup.pt/faturacao.'
     WHERE ticket_id = 'AC3196F7-E6E0-4CA8-A68A-99A0E391FD1E';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'AC3196F7-E6E0-4CA8-A68A-99A0E391FD1E',
            'API',
            'SEED-AC3196F7-E6E0-4CA8-A68A-99A0E391FD1E',
            'Query about inpatient bill',
            'Good morning, I received an invoice for my January inpatient stay and there is a charge I cannot identify. What exactly does the item "TAXA ADM 2025" (value: €45) refer to?',
            'Billing',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). We accept payment by Multibanco, MB Way, credit/debit card and bank transfer. To request a correction on an issued invoice, submit a rectification request with the invoice number at www.hospitalgroup.pt/faturacao. [KB: FAT-001, FAT-003, FAT-007]',
            'For invoice enquiries, our billing team can be reached at faturacao@hospitalgroup.pt or on 210 000 100 (weekdays 09:00–17:00). To request a correction, submit a rectification request at www.hospitalgroup.pt/faturacao.',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 76724119-97CA-45A5-8F4E-839907FA4C7F
    UPDATE tickets
       SET subject = 'Address of the Braga hospital',
        body = 'Good afternoon, could you give me the exact address of your Braga unit? I need to get there tomorrow morning for an appointment and I cannot find the address on the website.',
        submitted_category = 'Location',
        generated_answer = 'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '76724119-97CA-45A5-8F4E-839907FA4C7F';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '76724119-97CA-45A5-8F4E-839907FA4C7F',
            'API',
            'SEED-76724119-97CA-45A5-8F4E-839907FA4C7F',
            'Address of the Braga hospital',
            'Good afternoon, could you give me the exact address of your Braga unit? I need to get there tomorrow morning for an appointment and I cannot find the address on the website.',
            'Location',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 2004B0D9-A193-40BD-984F-DEF86A9E4D52
    UPDATE tickets
       SET subject = 'Is there parking at the hospital?',
        body = 'Hello, I have an appointment next week at Hospital da Luz Lisboa. Is there a car park? What is the hourly rate? Are there spaces for people with reduced mobility?',
        submitted_category = 'Facilities',
        generated_answer = 'Hello Maria Santos,

Yes, Hospital da Luz Lisboa, part of Hospital Group, has a car park. The approximate cost is €1.50 per hour. There are reserved spaces for people with reduced mobility near the main entrances, clearly signposted. All units of Hospital Group are equipped with accessibility features including ramps, automatic doors and lifts. [KB: LOC-002]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '2004B0D9-A193-40BD-984F-DEF86A9E4D52';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '2004B0D9-A193-40BD-984F-DEF86A9E4D52',
            'API',
            'SEED-2004B0D9-A193-40BD-984F-DEF86A9E4D52',
            'Is there parking at the hospital?',
            'Hello, I have an appointment next week at Hospital da Luz Lisboa. Is there a car park? What is the hourly rate? Are there spaces for people with reduced mobility?',
            'Facilities',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Maria Santos,

Yes, Hospital da Luz Lisboa, part of Hospital Group, has a car park. The approximate cost is €1.50 per hour. There are reserved spaces for people with reduced mobility near the main entrances, clearly signposted. All units of Hospital Group are equipped with accessibility features including ramps, automatic doors and lifts. [KB: LOC-002]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket ABFBAB43-A84F-474F-9220-98FEAA95B943
    UPDATE tickets
       SET subject = 'Hospital pharmacy opening hours on Saturdays',
        body = 'Good afternoon,

I need to collect medication from the hospital pharmacy after my appointment. What are the opening hours? Is it also open on Saturdays?

Thank you,
Vera Henriques'
     WHERE ticket_id = 'ABFBAB43-A84F-474F-9220-98FEAA95B943';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'ABFBAB43-A84F-474F-9220-98FEAA95B943',
            'API',
            'SEED-ABFBAB43-A84F-474F-9220-98FEAA95B943',
            'Hospital pharmacy opening hours on Saturdays',
            'Good afternoon,

I need to collect medication from the hospital pharmacy after my appointment. What are the opening hours? Is it also open on Saturdays?

Thank you,
Vera Henriques',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 70B9B102-5A3A-4372-A1CE-691FA0B2232E
    UPDATE tickets
       SET subject = 'Wheelchair accessibility and internal support',
        body = 'Hello,

My father is in a wheelchair and has a Neurology appointment. What are the accessible entrances and is there any support service to assist patients with reduced mobility inside the hospital?

Kind regards,
Miguel Pereira'
     WHERE ticket_id = '70B9B102-5A3A-4372-A1CE-691FA0B2232E';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '70B9B102-5A3A-4372-A1CE-691FA0B2232E',
            'API',
            'SEED-70B9B102-5A3A-4372-A1CE-691FA0B2232E',
            'Wheelchair accessibility and internal support',
            'Hello,

My father is in a wheelchair and has a Neurology appointment. What are the accessible entrances and is there any support service to assist patients with reduced mobility inside the hospital?

Kind regards,
Miguel Pereira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket FB6C0836-3E95-47E7-8AB4-7CE39390F24B
    UPDATE tickets
       SET subject = 'Car park rates and hours',
        body = 'Good morning,

What are the car park rates at the hospital and for how long is it free for patients? I have a consultation and tests on the same day.

Thank you,
Sandra Lopes'
     WHERE ticket_id = 'FB6C0836-3E95-47E7-8AB4-7CE39390F24B';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'FB6C0836-3E95-47E7-8AB4-7CE39390F24B',
            'API',
            'SEED-FB6C0836-3E95-47E7-8AB4-7CE39390F24B',
            'Car park rates and hours',
            'Good morning,

What are the car park rates at the hospital and for how long is it free for patients? I have a consultation and tests on the same day.

Thank you,
Sandra Lopes',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 77A8CE8E-9072-4446-8C43-84C9D34744CA
    UPDATE tickets
       SET subject = 'Correct entrance for the Maternity unit and obstetric emergency',
        body = 'Good afternoon,

My wife is approaching her due date. Which is the correct entrance for the Maternity unit? Is there a dedicated obstetric emergency entrance?

Thank you,
Fernanda Costa'
     WHERE ticket_id = '77A8CE8E-9072-4446-8C43-84C9D34744CA';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '77A8CE8E-9072-4446-8C43-84C9D34744CA',
            'API',
            'SEED-77A8CE8E-9072-4446-8C43-84C9D34744CA',
            'Correct entrance for the Maternity unit and obstetric emergency',
            'Good afternoon,

My wife is approaching her due date. Which is the correct entrance for the Maternity unit? Is there a dedicated obstetric emergency entrance?

Thank you,
Fernanda Costa',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket C73A9608-E6E8-48C4-B0BE-F37955015138
    UPDATE tickets
       SET subject = 'Location and hours of the fasting blood test laboratory',
        body = 'Hello,

I need to have fasting blood tests and would like to know: exactly where is the laboratory, what time do they stop accepting fasting patients, and whether I need a medical requisition?

Thank you,
Marco Correia'
     WHERE ticket_id = 'C73A9608-E6E8-48C4-B0BE-F37955015138';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'C73A9608-E6E8-48C4-B0BE-F37955015138',
            'API',
            'SEED-C73A9608-E6E8-48C4-B0BE-F37955015138',
            'Location and hours of the fasting blood test laboratory',
            'Hello,

I need to have fasting blood tests and would like to know: exactly where is the laboratory, what time do they stop accepting fasting patients, and whether I need a medical requisition?

Thank you,
Marco Correia',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 1C06AA73-22B5-4DE0-85D4-E197007B1714
    UPDATE tickets
       SET subject = 'Is there a cafeteria or restaurant open to the public at the hospital?',
        body = 'Good morning,

I will be at the hospital for most of the day with my admitted relative. Is there a cafeteria or restaurant open to the public? What are the opening hours?

Kind regards,
Ricardo Vieira'
     WHERE ticket_id = '1C06AA73-22B5-4DE0-85D4-E197007B1714';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '1C06AA73-22B5-4DE0-85D4-E197007B1714',
            'API',
            'SEED-1C06AA73-22B5-4DE0-85D4-E197007B1714',
            'Is there a cafeteria or restaurant open to the public at the hospital?',
            'Good morning,

I will be at the hospital for most of the day with my admitted relative. Is there a cafeteria or restaurant open to the public? What are the opening hours?

Kind regards,
Ricardo Vieira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 59E21527-CB6F-441F-B2F7-A1CE70233020
    UPDATE tickets
       SET subject = 'Orthopaedics or Rheumatology for chronic joint pain?',
        body = 'Good afternoon,

I have chronic pain in the joints of my fingers and knees. One doctor told me to go to Orthopaedics, another to Rheumatology. Could you guide me towards the most appropriate specialty?

Kind regards,
Ana Ferreira'
     WHERE ticket_id = '59E21527-CB6F-441F-B2F7-A1CE70233020';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '59E21527-CB6F-441F-B2F7-A1CE70233020',
            'API',
            'SEED-59E21527-CB6F-441F-B2F7-A1CE70233020',
            'Orthopaedics or Rheumatology for chronic joint pain?',
            'Good afternoon,

I have chronic pain in the joints of my fingers and knees. One doctor told me to go to Orthopaedics, another to Rheumatology. Could you guide me towards the most appropriate specialty?

Kind regards,
Ana Ferreira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 2319E9E5-DACB-46F0-9A41-C135B248B6EC
    UPDATE tickets
       SET subject = 'Assessment process for bariatric surgery',
        body = 'Hello,

I have a BMI of 42 and associated diabetes and hypertension. I would like to know how the assessment and referral process for bariatric surgery works at your hospital.

Thank you,
Paulo Mendes'
     WHERE ticket_id = '2319E9E5-DACB-46F0-9A41-C135B248B6EC';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '2319E9E5-DACB-46F0-9A41-C135B248B6EC',
            'API',
            'SEED-2319E9E5-DACB-46F0-9A41-C135B248B6EC',
            'Assessment process for bariatric surgery',
            'Hello,

I have a BMI of 42 and associated diabetes and hypertension. I would like to know how the assessment and referral process for bariatric surgery works at your hospital.

Thank you,
Paulo Mendes',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket EF8AA709-69EE-41D3-A7FD-A2B62DEA7CAC
    UPDATE tickets
       SET subject = 'Child with language development delay — which specialty?',
        body = 'Good morning,

My 4-year-old son has been followed at the health centre for suspected language development delay. The paediatrician recommended a hospital referral. Which specialties should I look for?

Thank you,
Carlos Santos'
     WHERE ticket_id = 'EF8AA709-69EE-41D3-A7FD-A2B62DEA7CAC';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'EF8AA709-69EE-41D3-A7FD-A2B62DEA7CAC',
            'API',
            'SEED-EF8AA709-69EE-41D3-A7FD-A2B62DEA7CAC',
            'Child with language development delay — which specialty?',
            'Good morning,

My 4-year-old son has been followed at the health centre for suspected language development delay. The paediatrician recommended a hospital referral. Which specialties should I look for?

Thank you,
Carlos Santos',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 5562B551-3421-4168-B9FD-8AA125149E8C
    UPDATE tickets
       SET subject = 'VPN not connecting when working remotely',
        body = 'Hello, I am working remotely and the corporate VPN will not connect. Error: "Authentication failed (Error 691)". I have checked my credentials and they are correct.',
        submitted_category = 'VPN',
        generated_answer = 'Hello Catarina! To resolve the VPN connection issue "Authentication failed (Error 691)" when working remotely, ensure your login credentials are correct. Then: 1. Check the VPN configuration (server address, protocol, authentication). 2. Restart the VPN client. 3. If the problem persists, contact the IT Service Desk. [KB: IT-NET-003]',
        suggested_answer = 'Hello Catarina! To resolve the VPN connection issue "Authentication failed (Error 691)", ensure your credentials are correct, then check the VPN configuration and restart the client.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = '5562B551-3421-4168-B9FD-8AA125149E8C';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '5562B551-3421-4168-B9FD-8AA125149E8C',
            'API',
            'SEED-5562B551-3421-4168-B9FD-8AA125149E8C',
            'VPN not connecting when working remotely',
            'Hello, I am working remotely and the corporate VPN will not connect. Error: "Authentication failed (Error 691)". I have checked my credentials and they are correct.',
            'VPN',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Catarina! To resolve the VPN connection issue "Authentication failed (Error 691)" when working remotely, ensure your login credentials are correct. Then: 1. Check the VPN configuration (server address, protocol, authentication). 2. Restart the VPN client. 3. If the problem persists, contact the IT Service Desk. [KB: IT-NET-003]',
            'Hello Catarina! To resolve the VPN connection issue "Authentication failed (Error 691)", ensure your credentials are correct, then check the VPN configuration and restart the client.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket AD7E67B2-3531-4AEB-8647-6EF1C9C1394F
    UPDATE tickets
       SET subject = 'Error registering episode in HIS',
        body = 'Good afternoon, when trying to register a new emergency episode in HIS the error "ORA-00001: unique constraint violated" appears. It has happened to 3 doctors in the last hour.',
        submitted_category = 'HIS',
        generated_answer = 'The ORA-00001 error in HIS indicates a primary key violation, typically caused by sequence synchronisation problems. This is a critical incident — IT has been immediately notified. As a temporary measure, please wait 5 minutes and try again with a new episode number. If the problem persists contact IT on extension 9000. [KB: IT-SW-HIS-001]',
        suggested_answer = 'The ORA-00001 error in HIS indicates a primary key violation, typically caused by sequence synchronisation problems. This is a critical incident — IT has been immediately notified. Please wait 5 minutes and try again with a new episode number.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = 'AD7E67B2-3531-4AEB-8647-6EF1C9C1394F';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'AD7E67B2-3531-4AEB-8647-6EF1C9C1394F',
            'API',
            'SEED-AD7E67B2-3531-4AEB-8647-6EF1C9C1394F',
            'Error registering episode in HIS',
            'Good afternoon, when trying to register a new emergency episode in HIS the error "ORA-00001: unique constraint violated" appears. It has happened to 3 doctors in the last hour.',
            'HIS',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'The ORA-00001 error in HIS indicates a primary key violation, typically caused by sequence synchronisation problems. This is a critical incident — IT has been immediately notified. As a temporary measure, please wait 5 minutes and try again with a new episode number. If the problem persists contact IT on extension 9000. [KB: IT-SW-HIS-001]',
            'The ORA-00001 error in HIS indicates a primary key violation, typically caused by sequence synchronisation problems. This is a critical incident — IT has been immediately notified. Please wait 5 minutes and try again with a new episode number.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket EA17DB87-E6A8-4EB7-BD15-6552BE0E7CC7
    UPDATE tickets
       SET subject = 'Agreement with SAD GNR',
        body = 'Hello, I am a SAD GNR beneficiary. Does your Lisbon unit have an active agreement with this health scheme? Which specialties are included?',
        submitted_category = 'Health Subsystems',
        generated_answer = 'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment with your beneficiary card. For ADSE, nutrition and dental consultations are not covered under direct access. [KB: SEG-001, SEG-003, SEG-006]'
     WHERE ticket_id = 'EA17DB87-E6A8-4EB7-BD15-6552BE0E7CC7';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'EA17DB87-E6A8-4EB7-BD15-6552BE0E7CC7',
            'API',
            'SEED-EA17DB87-E6A8-4EB7-BD15-6552BE0E7CC7',
            'Agreement with SAD GNR',
            'Hello, I am a SAD GNR beneficiary. Does your Lisbon unit have an active agreement with this health scheme? Which specialties are included?',
            'Health Subsystems',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment with your beneficiary card. For ADSE, nutrition and dental consultations are not covered under direct access. [KB: SEG-001, SEG-003, SEG-006]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 18D3A69C-BF71-4C53-A4F7-5DE20998B328
    UPDATE tickets
       SET subject = 'Turnaround time for CT scan results',
        body = 'Good morning, I had a chest CT scan 5 days ago. Are the results already available? Can I collect them in person or can they be sent by email?',
        submitted_category = 'Results',
        generated_answer = 'Clinical analysis results are available within 24 to 72 hours. Imaging results (CT scan, MRI, ultrasound) are available within 3 to 5 working days. You can access results through the patient portal at www.hospitalgroup.pt/resultados using your patient number and date of birth. If you do not have portal access, you may collect them in person or request email delivery to the address registered in the system. [KB: EXA-001, EXA-003]'
     WHERE ticket_id = '18D3A69C-BF71-4C53-A4F7-5DE20998B328';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '18D3A69C-BF71-4C53-A4F7-5DE20998B328',
            'API',
            'SEED-18D3A69C-BF71-4C53-A4F7-5DE20998B328',
            'Turnaround time for CT scan results',
            'Good morning, I had a chest CT scan 5 days ago. Are the results already available? Can I collect them in person or can they be sent by email?',
            'Results',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Clinical analysis results are available within 24 to 72 hours. Imaging results (CT scan, MRI, ultrasound) are available within 3 to 5 working days. You can access results through the patient portal at www.hospitalgroup.pt/resultados using your patient number and date of birth. If you do not have portal access, you may collect them in person or request email delivery to the address registered in the system. [KB: EXA-001, EXA-003]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 59E9798A-CA0E-4273-A1DD-776C94864145
    UPDATE tickets
       SET subject = 'Complaint about waiting time in A&E',
        body = 'Good morning, I was in A&E yesterday for more than 4 hours with no information about the waiting time. The service was inadequate and I would like to submit a formal complaint.',
        submitted_category = 'Complaint'
     WHERE ticket_id = '59E9798A-CA0E-4273-A1DD-776C94864145';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '59E9798A-CA0E-4273-A1DD-776C94864145',
            'API',
            'SEED-59E9798A-CA0E-4273-A1DD-776C94864145',
            'Complaint about waiting time in A&E',
            'Good morning, I was in A&E yesterday for more than 4 hours with no information about the waiting time. The service was inadequate and I would like to submit a formal complaint.',
            'Complaint',
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket F7876C65-99C8-4BDA-874D-53EB02FF56D2
    UPDATE tickets
       SET subject = 'How to book a first Paediatrics appointment for my daughter',
        body = 'Good afternoon,

My daughter is 3 years old and needs a first Paediatrics appointment for developmental assessment. I am not familiar with the booking process at your hospital. Could you advise on the steps required and what documents to bring?

Thank you,
Miguel Pereira'
     WHERE ticket_id = 'F7876C65-99C8-4BDA-874D-53EB02FF56D2';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'F7876C65-99C8-4BDA-874D-53EB02FF56D2',
            'API',
            'SEED-F7876C65-99C8-4BDA-874D-53EB02FF56D2',
            'How to book a first Paediatrics appointment for my daughter',
            'Good afternoon,

My daughter is 3 years old and needs a first Paediatrics appointment for developmental assessment. I am not familiar with the booking process at your hospital. Could you advise on the steps required and what documents to bring?

Thank you,
Miguel Pereira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 2D1A9925-3BE8-48BB-98E9-CAA24CFF4580
    UPDATE tickets
       SET subject = 'Rescheduling a cancelled Orthopaedics appointment',
        body = 'Hello,

My Orthopaedics appointment scheduled for next week was cancelled without prior notice. I urgently need to reschedule as I have chronic knee pain that is worsening. What is the process for rebooking?

Awaiting your reply,
Vera Henriques'
     WHERE ticket_id = '2D1A9925-3BE8-48BB-98E9-CAA24CFF4580';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '2D1A9925-3BE8-48BB-98E9-CAA24CFF4580',
            'API',
            'SEED-2D1A9925-3BE8-48BB-98E9-CAA24CFF4580',
            'Rescheduling a cancelled Orthopaedics appointment',
            'Hello,

My Orthopaedics appointment scheduled for next week was cancelled without prior notice. I urgently need to reschedule as I have chronic knee pain that is worsening. What is the process for rebooking?

Awaiting your reply,
Vera Henriques',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 43ADBB30-5393-4AA9-AEF2-698B14D77538
    UPDATE tickets
       SET subject = 'How do I reschedule my appointment?',
        body = 'Hello, I booked a dermatology appointment for next month but need to change the date. What is the rescheduling process? Can I do it on your website or do I need to call?',
        submitted_category = 'Appointments',
        generated_answer = 'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00). A GP referral is not required for most specialties — except for NHS-subsidised cases. Cancellations must be made at least 24 hours in advance to avoid a cancellation fee (€15). Average waiting times for first appointments range from 3 to 15 working days depending on the specialty and unit. [KB: MARC-001, MARC-002, MARC-005]',
        suggested_answer = 'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00).'
     WHERE ticket_id = '43ADBB30-5393-4AA9-AEF2-698B14D77538';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '43ADBB30-5393-4AA9-AEF2-698B14D77538',
            'API',
            'SEED-43ADBB30-5393-4AA9-AEF2-698B14D77538',
            'How do I reschedule my appointment?',
            'Hello, I booked a dermatology appointment for next month but need to change the date. What is the rescheduling process? Can I do it on your website or do I need to call?',
            'Appointments',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00). A GP referral is not required for most specialties — except for NHS-subsidised cases. Cancellations must be made at least 24 hours in advance to avoid a cancellation fee (€15). Average waiting times for first appointments range from 3 to 15 working days depending on the specialty and unit. [KB: MARC-001, MARC-002, MARC-005]',
            'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00).',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 48DC54DF-A726-4A8C-B185-84B8898C3009
    UPDATE tickets
       SET subject = 'Confirmation of active agreement with SAMS Quadros',
        body = 'Good afternoon,

I am a SAMS Quadros beneficiary. I would like to confirm whether your hospital has an active agreement with SAMS and what the conditions and co-payment are for specialist consultations.

Thank you,
Tiago Valente'
     WHERE ticket_id = '48DC54DF-A726-4A8C-B185-84B8898C3009';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '48DC54DF-A726-4A8C-B185-84B8898C3009',
            'API',
            'SEED-48DC54DF-A726-4A8C-B185-84B8898C3009',
            'Confirmation of active agreement with SAMS Quadros',
            'Good afternoon,

I am a SAMS Quadros beneficiary. I would like to confirm whether your hospital has an active agreement with SAMS and what the conditions and co-payment are for specialist consultations.

Thank you,
Tiago Valente',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket A45DD054-99E8-4956-9BBF-70ABB3792896
    UPDATE tickets
       SET subject = 'Prior authorisation from Tranquilidade insurance for knee MRI',
        body = 'Hello,

My doctor has prescribed a knee MRI. My insurance (Tranquilidade) requires prior authorisation. Could you help me with the process and advise which documents are needed?

Kind regards,
Joana Ribeiro'
     WHERE ticket_id = 'A45DD054-99E8-4956-9BBF-70ABB3792896';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'A45DD054-99E8-4956-9BBF-70ABB3792896',
            'API',
            'SEED-A45DD054-99E8-4956-9BBF-70ABB3792896',
            'Prior authorisation from Tranquilidade insurance for knee MRI',
            'Hello,

My doctor has prescribed a knee MRI. My insurance (Tranquilidade) requires prior authorisation. Could you help me with the process and advise which documents are needed?

Kind regards,
Joana Ribeiro',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 58C4DE83-A7C9-44C6-BDDC-F001529035D2
    UPDATE tickets
       SET subject = 'GNR health plan — coverage available at your hospital',
        body = 'Good morning,

I am a GNR military officer and a beneficiary of the GNR health plan. What services are covered by my plan at your hospital? Do I need to pay any amount upfront?

Thank you,
Inês Carvalho'
     WHERE ticket_id = '58C4DE83-A7C9-44C6-BDDC-F001529035D2';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '58C4DE83-A7C9-44C6-BDDC-F001529035D2',
            'API',
            'SEED-58C4DE83-A7C9-44C6-BDDC-F001529035D2',
            'GNR health plan — coverage available at your hospital',
            'Good morning,

I am a GNR military officer and a beneficiary of the GNR health plan. What services are covered by my plan at your hospital? Do I need to pay any amount upfront?

Thank you,
Inês Carvalho',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 0B77A25E-2CA3-4E33-9D20-197193996647
    UPDATE tickets
       SET subject = 'Documents for reimbursement of private consultation from AdvanceCare insurance',
        body = 'Good afternoon,

I had a private consultation and paid in full. My insurance (AdvanceCare) partially covers this. What documents do I need to request from the hospital for the reimbursement claim?

Thank you,
Maria Oliveira'
     WHERE ticket_id = '0B77A25E-2CA3-4E33-9D20-197193996647';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '0B77A25E-2CA3-4E33-9D20-197193996647',
            'API',
            'SEED-0B77A25E-2CA3-4E33-9D20-197193996647',
            'Documents for reimbursement of private consultation from AdvanceCare insurance',
            'Good afternoon,

I had a private consultation and paid in full. My insurance (AdvanceCare) partially covers this. What documents do I need to request from the hospital for the reimbursement claim?

Thank you,
Maria Oliveira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 57004D5C-D07A-468D-A7F8-1ACDD8ED216E
    UPDATE tickets
       SET subject = 'Road traffic accident — how does direct billing to car insurance work?',
        body = 'Hello,

I was involved in a road traffic accident and received emergency treatment. The treatment will be covered by the at-fault driver''s car insurance. How does the direct billing process to the insurer work?

Kind regards,
Sandra Lopes'
     WHERE ticket_id = '57004D5C-D07A-468D-A7F8-1ACDD8ED216E';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '57004D5C-D07A-468D-A7F8-1ACDD8ED216E',
            'API',
            'SEED-57004D5C-D07A-468D-A7F8-1ACDD8ED216E',
            'Road traffic accident — how does direct billing to car insurance work?',
            'Hello,

I was involved in a road traffic accident and received emergency treatment. The treatment will be covered by the at-fault driver''s car insurance. How does the direct billing process to the insurer work?

Kind regards,
Sandra Lopes',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket E5E99268-9A5F-43CE-A354-05BB54D39FDB
    UPDATE tickets
       SET subject = 'Agreement with CTT Saúde — confirmation and how to use it',
        body = 'Good morning,

I am a CTT employee with access to the CTT Saúde plan. Is there an agreement with your hospital? If so, how does the usage process work?

Thank you,
João Silva'
     WHERE ticket_id = 'E5E99268-9A5F-43CE-A354-05BB54D39FDB';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'E5E99268-9A5F-43CE-A354-05BB54D39FDB',
            'API',
            'SEED-E5E99268-9A5F-43CE-A354-05BB54D39FDB',
            'Agreement with CTT Saúde — confirmation and how to use it',
            'Good morning,

I am a CTT employee with access to the CTT Saúde plan. Is there an agreement with your hospital? If so, how does the usage process work?

Thank you,
João Silva',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 37216F6E-96F5-486D-959F-BEE371175D33
    UPDATE tickets
       SET subject = 'How to access clinical analysis results online',
        body = 'Good morning,

I had clinical tests 5 days ago and have still not received the results. How can I access the results online? Is there a patient portal?

Thank you,
Catarina Nunes'
     WHERE ticket_id = '37216F6E-96F5-486D-959F-BEE371175D33';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '37216F6E-96F5-486D-959F-BEE371175D33',
            'API',
            'SEED-37216F6E-96F5-486D-959F-BEE371175D33',
            'How to access clinical analysis results online',
            'Good morning,

I had clinical tests 5 days ago and have still not received the results. How can I access the results online? Is there a patient portal?

Thank you,
Catarina Nunes',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket C1DDA96E-6160-4353-B471-C337B3E9A102
    UPDATE tickets
       SET subject = 'Biopsy result overdue — 10 days have passed',
        body = 'Good afternoon,

I had a biopsy 10 days ago and the doctor said the results would take a week. It has now been 10 days and I still have no response. When can I expect the results?

Kind regards,
Luís Pinto'
     WHERE ticket_id = 'C1DDA96E-6160-4353-B471-C337B3E9A102';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'C1DDA96E-6160-4353-B471-C337B3E9A102',
            'API',
            'SEED-C1DDA96E-6160-4353-B471-C337B3E9A102',
            'Biopsy result overdue — 10 days have passed',
            'Good afternoon,

I had a biopsy 10 days ago and the doctor said the results would take a week. It has now been 10 days and I still have no response. When can I expect the results?

Kind regards,
Luís Pinto',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket B49A69C8-819D-4FA9-8B73-594D44009317
    UPDATE tickets
       SET subject = 'Request for copy of abdominal CT report for another hospital',
        body = 'Hello,

I need a copy of the abdominal CT report from the scan I had in February. I need it for a specialist appointment at another hospital unit. How can I request the document?

Thank you,
Vera Henriques'
     WHERE ticket_id = 'B49A69C8-819D-4FA9-8B73-594D44009317';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'B49A69C8-819D-4FA9-8B73-594D44009317',
            'API',
            'SEED-B49A69C8-819D-4FA9-8B73-594D44009317',
            'Request for copy of abdominal CT report for another hospital',
            'Hello,

I need a copy of the abdominal CT report from the scan I had in February. I need it for a specialist appointment at another hospital unit. How can I request the document?

Thank you,
Vera Henriques',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 3447DBDF-F0C7-4150-9E7C-2BA5F0113304
    UPDATE tickets
       SET subject = 'Obtain spinal MRI in digital format',
        body = 'Good morning,

I had a spinal MRI and would like to obtain the exam in digital format (CD or file transfer). What is the procedure and is there a cost?

Kind regards,
Luís Pinto'
     WHERE ticket_id = '3447DBDF-F0C7-4150-9E7C-2BA5F0113304';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '3447DBDF-F0C7-4150-9E7C-2BA5F0113304',
            'API',
            'SEED-3447DBDF-F0C7-4150-9E7C-2BA5F0113304',
            'Obtain spinal MRI in digital format',
            'Good morning,

I had a spinal MRI and would like to obtain the exam in digital format (CD or file transfer). What is the procedure and is there a cost?

Kind regards,
Luís Pinto',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket FD6B2830-D722-4823-932B-DF0942D613FE
    UPDATE tickets
       SET subject = 'Current location of the Haematology department within the hospital',
        body = 'Hello,

I have a Haematology appointment and it is my first time at the hospital. The website shows it is in Building B, Floor 3, but when I call reception they say it has moved. What is the current location?

Thank you,
Beatriz Alves',
        generated_answer = 'I am sorry, but I do not have access to real-time information about the specific location of departments within Hospital Group units, including the Haematology department. However, I can suggest some options to find the information you need.

1. Check the official Hospital Group website. 2. Call reception directly for the most up-to-date location. [KB: LOC-001]',
        suggested_answer = 'I am sorry, but I do not have real-time information about the specific location of departments within Hospital Group units, including Haematology. Please call reception directly for the most up-to-date location.'
     WHERE ticket_id = 'FD6B2830-D722-4823-932B-DF0942D613FE';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'FD6B2830-D722-4823-932B-DF0942D613FE',
            'API',
            'SEED-FD6B2830-D722-4823-932B-DF0942D613FE',
            'Current location of the Haematology department within the hospital',
            'Hello,

I have a Haematology appointment and it is my first time at the hospital. The website shows it is in Building B, Floor 3, but when I call reception they say it has moved. What is the current location?

Thank you,
Beatriz Alves',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'I am sorry, but I do not have access to real-time information about the specific location of departments within Hospital Group units, including the Haematology department. However, I can suggest some options to find the information you need.

1. Check the official Hospital Group website. 2. Call reception directly for the most up-to-date location. [KB: LOC-001]',
            'I am sorry, but I do not have real-time information about the specific location of departments within Hospital Group units, including Haematology. Please call reception directly for the most up-to-date location.',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 1E3ADC93-8F6A-4273-9766-66FEDBDBB702
    UPDATE tickets
       SET subject = 'Is there parking at the hospital?',
        body = 'Hello, I have an appointment next week at Hospital da Luz Lisboa. Is there a car park? What is the hourly rate? Are there spaces for people with reduced mobility?',
        submitted_category = 'Facilities',
        generated_answer = 'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '1E3ADC93-8F6A-4273-9766-66FEDBDBB702';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '1E3ADC93-8F6A-4273-9766-66FEDBDBB702',
            'API',
            'SEED-1E3ADC93-8F6A-4273-9766-66FEDBDBB702',
            'Is there parking at the hospital?',
            'Hello, I have an appointment next week at Hospital da Luz Lisboa. Is there a car park? What is the hourly rate? Are there spaces for people with reduced mobility?',
            'Facilities',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Our hospital network operates 24 hours a day, 7 days a week, across the emergency departments of all units. Outpatient services run Monday to Friday 08:00–20:00 and Saturday 08:00–13:00. For the exact address and access map, visit www.hospitalgroup.pt/unidades. All units have paid car parks (approximately €1.50/hour) with reserved spaces for people with reduced mobility near main entrances. All buildings have access ramps, automatic doors and wheelchair-accessible lifts. [KB: LOC-001, LOC-002, LOC-003]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket A392AE5D-D5AA-4C7A-B71B-44B230B7182B
    UPDATE tickets
       SET subject = 'Wheelchair accessibility',
        body = 'Good morning, my mother uses a wheelchair. I would like to know whether all entrances at the Setúbal hospital are accessible and whether there is a lift to the upper floors.',
        submitted_category = 'Accessibility',
        generated_answer = 'Good morning Filipa Almeida!

Yes, all Hospital Group units, including the Setúbal hospital, are equipped with accessibility features for people with reduced mobility. These include access ramps at all main entrances, automatic doors of adapted width, lifts accessible by wheelchair, and reserved parking spaces near the main entrances. [KB: LOC-003]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'A392AE5D-D5AA-4C7A-B71B-44B230B7182B';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'A392AE5D-D5AA-4C7A-B71B-44B230B7182B',
            'API',
            'SEED-A392AE5D-D5AA-4C7A-B71B-44B230B7182B',
            'Wheelchair accessibility',
            'Good morning, my mother uses a wheelchair. I would like to know whether all entrances at the Setúbal hospital are accessible and whether there is a lift to the upper floors.',
            'Accessibility',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Good morning Filipa Almeida!

Yes, all Hospital Group units, including the Setúbal hospital, are equipped with accessibility features for people with reduced mobility. These include access ramps at all main entrances, automatic doors of adapted width, lifts accessible by wheelchair, and reserved parking spaces near the main entrances. [KB: LOC-003]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 4DB97A99-D685-4105-915D-F1B94FCE26EF
    UPDATE tickets
       SET subject = 'Waiting time for a Neurology appointment',
        body = 'Good morning,

I have been referred by my GP for a Neurology appointment. I would like to know the current average waiting time and whether there is a cancellation list I can join to get an earlier appointment.

Kind regards,
Ana Ferreira'
     WHERE ticket_id = '4DB97A99-D685-4105-915D-F1B94FCE26EF';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '4DB97A99-D685-4105-915D-F1B94FCE26EF',
            'API',
            'SEED-4DB97A99-D685-4105-915D-F1B94FCE26EF',
            'Waiting time for a Neurology appointment',
            'Good morning,

I have been referred by my GP for a Neurology appointment. I would like to know the current average waiting time and whether there is a cancellation list I can join to get an earlier appointment.

Kind regards,
Ana Ferreira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket EC2E9CFD-0F41-411C-951C-9586294D2418
    UPDATE tickets
       SET subject = 'Which doctor for thyroid problems?',
        body = 'Hello, my blood tests show abnormal thyroid values. My GP suggested I see a specialist. Is Endocrinology the correct specialty?',
        submitted_category = 'Specialties',
        generated_answer = 'Hello Pedro Castro,

Yes, for problems related to the thyroid, the recommended medical specialty is Endocrinology. Endocrinology is the specialty that deals with the diagnosis and treatment of diseases related to the hormonal system, including thyroid problems, diabetes and other hormonal disorders. [KB: ESP-010]'
     WHERE ticket_id = 'EC2E9CFD-0F41-411C-951C-9586294D2418';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'EC2E9CFD-0F41-411C-951C-9586294D2418',
            'API',
            'SEED-EC2E9CFD-0F41-411C-951C-9586294D2418',
            'Which doctor for thyroid problems?',
            'Hello, my blood tests show abnormal thyroid values. My GP suggested I see a specialist. Is Endocrinology the correct specialty?',
            'Specialties',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Hello Pedro Castro,

Yes, for problems related to the thyroid, the recommended medical specialty is Endocrinology. Endocrinology is the specialty that deals with the diagnosis and treatment of diseases related to the hormonal system, including thyroid problems, diabetes and other hormonal disorders. [KB: ESP-010]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 9B134D54-CAA6-480C-B2FA-BBA2178360C0
    UPDATE tickets
       SET subject = 'Is there a way to check current A&E waiting time before travelling?',
        body = 'Hello,

I am thinking of going to A&E but I am concerned about waiting times. Is there a way to check the current waiting time before travelling? Is there an app or website?

Thank you,
Catarina Nunes',
        generated_answer = 'Hello Catarina,

We understand your concern about waiting times. At present, there is no app or website that allows you to check the current A&E waiting time before travelling. [Hospital Group FAQ - Emergency and Triage]

Please note that care in A&E is based on clinical priority according to the Manchester Triage System, not arrival order. [KB: URG-001]'
     WHERE ticket_id = '9B134D54-CAA6-480C-B2FA-BBA2178360C0';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '9B134D54-CAA6-480C-B2FA-BBA2178360C0',
            'API',
            'SEED-9B134D54-CAA6-480C-B2FA-BBA2178360C0',
            'Is there a way to check current A&E waiting time before travelling?',
            'Hello,

I am thinking of going to A&E but I am concerned about waiting times. Is there a way to check the current waiting time before travelling? Is there an app or website?

Thank you,
Catarina Nunes',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'Hello Catarina,

We understand your concern about waiting times. At present, there is no app or website that allows you to check the current A&E waiting time before travelling. [Hospital Group FAQ - Emergency and Triage]

Please note that care in A&E is based on clinical priority according to the Manchester Triage System, not arrival order. [KB: URG-001]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket D516E659-7481-49F8-8592-3B70AF6954C9
    UPDATE tickets
       SET subject = 'Which specialty for chest pain during physical exertion?',
        body = 'Good morning,

I have been experiencing chest pain regularly, especially during physical effort. My GP is on holiday. Which hospital specialty should I seek and how urgent is it?

Thank you,
Nuno Figueiredo',
        generated_answer = 'For chest pain during physical exertion, the recommended specialty is Cardiology. Chest pain, particularly during effort, may be related to cardiac problems.

If your GP is unavailable and you are experiencing this symptom, it is advisable to go to A&E or call the clinical guidance line 808 100 200. [KB: ESP-001, URG-002]'
     WHERE ticket_id = 'D516E659-7481-49F8-8592-3B70AF6954C9';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'D516E659-7481-49F8-8592-3B70AF6954C9',
            'API',
            'SEED-D516E659-7481-49F8-8592-3B70AF6954C9',
            'Which specialty for chest pain during physical exertion?',
            'Good morning,

I have been experiencing chest pain regularly, especially during physical effort. My GP is on holiday. Which hospital specialty should I seek and how urgent is it?

Thank you,
Nuno Figueiredo',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'For chest pain during physical exertion, the recommended specialty is Cardiology. Chest pain, particularly during effort, may be related to cardiac problems.

If your GP is unavailable and you are experiencing this symptom, it is advisable to go to A&E or call the clinical guidance line 808 100 200. [KB: ESP-001, URG-002]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 97FBAC26-7582-436E-8184-E4FEFD578FC9
    UPDATE tickets
       SET subject = 'Complaint about lack of clinical information during admission',
        body = 'Hello,

During my father''s admission nobody informed us of his clinical status for 2 days. We were completely ignored. I want to submit a formal complaint about the lack of communication from the medical team.

Kind regards,
Sandra Lopes',
        generated_answer = 'To submit a formal complaint about the lack of communication from the medical team during your father''s admission, you can use the channels provided by Hospital Group.

1. **Online Complaints Book**: Visit www.hospitalgroup.pt/reclamacoes to submit your complaint online.
2. **Email**: qualidade@hospitalgroup.pt. [KB: REC-001]'
     WHERE ticket_id = '97FBAC26-7582-436E-8184-E4FEFD578FC9';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '97FBAC26-7582-436E-8184-E4FEFD578FC9',
            'API',
            'SEED-97FBAC26-7582-436E-8184-E4FEFD578FC9',
            'Complaint about lack of clinical information during admission',
            'Hello,

During my father''s admission nobody informed us of his clinical status for 2 days. We were completely ignored. I want to submit a formal complaint about the lack of communication from the medical team.

Kind regards,
Sandra Lopes',
            NULL,
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'To submit a formal complaint about the lack of communication from the medical team during your father''s admission, you can use the channels provided by Hospital Group.

1. **Online Complaints Book**: Visit www.hospitalgroup.pt/reclamacoes to submit your complaint online.
2. **Email**: qualidade@hospitalgroup.pt. [KB: REC-001]',
            NULL,
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket EAEE06C6-027A-45E4-915C-DE3CAAD62399
    UPDATE tickets
       SET subject = 'Cancelling an orthopaedics appointment',
        body = 'Good morning, I have an orthopaedics appointment on 15 February and I cannot attend. How can I cancel? Is there a penalty for late cancellation?',
        submitted_category = 'Cancellation',
        generated_answer = 'Hello Catarina,

To cancel your orthopaedics appointment on 15 February, you can use the Portal/App by accessing your appointments and selecting the cancel option, or contact us via WhatsApp or phone with at least 24 hours'' notice [KB: MARC-002].',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'EAEE06C6-027A-45E4-915C-DE3CAAD62399';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'EAEE06C6-027A-45E4-915C-DE3CAAD62399',
            'API',
            'SEED-EAEE06C6-027A-45E4-915C-DE3CAAD62399',
            'Cancelling an orthopaedics appointment',
            'Good morning, I have an orthopaedics appointment on 15 February and I cannot attend. How can I cancel? Is there a penalty for late cancellation?',
            'Cancellation',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Hello Catarina,

To cancel your orthopaedics appointment on 15 February, you can use the Portal/App by accessing your appointments and selecting the cancel option, or contact us via WhatsApp or phone with at least 24 hours'' notice [KB: MARC-002].',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket DCAEDFDC-36E3-42FB-9A33-F039A2BF7199
    UPDATE tickets
       SET subject = 'How do I reschedule my appointment?',
        body = 'Hello, I booked a dermatology appointment for next month but need to change the date. What is the rescheduling process? Can I do it on your website or do I need to call?',
        submitted_category = 'Appointments',
        generated_answer = 'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00). A GP referral is not required for most specialties — except for NHS-subsidised cases. Cancellations must be made at least 24 hours in advance to avoid a cancellation fee (€15). Average waiting times for first appointments range from 3 to 15 working days depending on the specialty and unit. [KB: MARC-001, MARC-002, MARC-005]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'DCAEDFDC-36E3-42FB-9A33-F039A2BF7199';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'DCAEDFDC-36E3-42FB-9A33-F039A2BF7199',
            'API',
            'SEED-DCAEDFDC-36E3-42FB-9A33-F039A2BF7199',
            'How do I reschedule my appointment?',
            'Hello, I booked a dermatology appointment for next month but need to change the date. What is the rescheduling process? Can I do it on your website or do I need to call?',
            'Appointments',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00). A GP referral is not required for most specialties — except for NHS-subsidised cases. Cancellations must be made at least 24 hours in advance to avoid a cancellation fee (€15). Average waiting times for first appointments range from 3 to 15 working days depending on the specialty and unit. [KB: MARC-001, MARC-002, MARC-005]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 7C670E07-F12F-433C-A34E-A782B7CAA883
    UPDATE tickets
       SET subject = 'Booking a post-surgery follow-up appointment',
        body = 'Good afternoon,

I had surgery at your hospital three weeks ago and need to book the post-operative follow-up appointment with the surgeon. My episode number is 2025/87543.

Thank you,
Ana Ferreira'
     WHERE ticket_id = '7C670E07-F12F-433C-A34E-A782B7CAA883';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '7C670E07-F12F-433C-A34E-A782B7CAA883',
            'API',
            'SEED-7C670E07-F12F-433C-A34E-A782B7CAA883',
            'Booking a post-surgery follow-up appointment',
            'Good afternoon,

I had surgery at your hospital three weeks ago and need to book the post-operative follow-up appointment with the surgeon. My episode number is 2025/87543.

Thank you,
Ana Ferreira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket AF8AD7C7-A8E7-41E1-ADD6-C76CAF0660D6
    UPDATE tickets
       SET subject = 'Waiting time for a neurology appointment',
        body = 'Good afternoon, I would like to know the average waiting time for a first neurology appointment. I have been experiencing persistent headaches and my GP suggested a specialist assessment.',
        submitted_category = 'Specialties',
        generated_answer = 'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00). A GP referral is not required for most specialties — except for NHS-subsidised cases. Average waiting times for first appointments range from 3 to 15 working days depending on the specialty and unit. [KB: MARC-001, MARC-002, MARC-005]',
        suggested_answer = 'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00).'
     WHERE ticket_id = 'AF8AD7C7-A8E7-41E1-ADD6-C76CAF0660D6';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'AF8AD7C7-A8E7-41E1-ADD6-C76CAF0660D6',
            'API',
            'SEED-AF8AD7C7-A8E7-41E1-ADD6-C76CAF0660D6',
            'Waiting time for a neurology appointment',
            'Good afternoon, I would like to know the average waiting time for a first neurology appointment. I have been experiencing persistent headaches and my GP suggested a specialist assessment.',
            'Specialties',
            'SUBMITTER',
            'ANSWERED',
            'MEDIUM',
            'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00). A GP referral is not required for most specialties — except for NHS-subsidised cases. Average waiting times for first appointments range from 3 to 15 working days depending on the specialty and unit. [KB: MARC-001, MARC-002, MARC-005]',
            'To book, reschedule or cancel an appointment you can use the patient portal at www.hospitalgroup.pt/marcacoes, the Hospital Group mobile app, or call the appointments line on 808 200 300 (weekdays 07:30–21:00).',
            NULL,
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 713A6559-B31A-431D-90D7-ED4DED26B40A
    UPDATE tickets
       SET subject = 'Request early discharge before the date planned by the doctor',
        body = 'Good morning,

I am admitted and feeling well. The doctor expects to discharge me in 3 days, but for family reasons I would like to go home sooner. How can I speak to the responsible doctor about the possibility of early discharge?

Kind regards,
Marco Correia'
     WHERE ticket_id = '713A6559-B31A-431D-90D7-ED4DED26B40A';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '713A6559-B31A-431D-90D7-ED4DED26B40A',
            'API',
            'SEED-713A6559-B31A-431D-90D7-ED4DED26B40A',
            'Request early discharge before the date planned by the doctor',
            'Good morning,

I am admitted and feeling well. The doctor expects to discharge me in 3 days, but for family reasons I would like to go home sooner. How can I speak to the responsible doctor about the possibility of early discharge?

Kind regards,
Marco Correia',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket E896FD08-EDE2-46F5-9421-67404AF4E888
    UPDATE tickets
       SET subject = 'Where is the Complaints Book — is there an electronic version?',
        body = 'Good morning,

I would like to register a complaint in the Complaints Book. Where is it available in the hospital? Is there also an electronic version?

Thank you,
Maria Oliveira'
     WHERE ticket_id = 'E896FD08-EDE2-46F5-9421-67404AF4E888';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'E896FD08-EDE2-46F5-9421-67404AF4E888',
            'API',
            'SEED-E896FD08-EDE2-46F5-9421-67404AF4E888',
            'Where is the Complaints Book — is there an electronic version?',
            'Good morning,

I would like to register a complaint in the Complaints Book. Where is it available in the hospital? Is there also an electronic version?

Thank you,
Maria Oliveira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket F97DF4AB-D27E-4BA9-808E-EDC41DF51552
    UPDATE tickets
       SET subject = 'Complaint about poor hygiene conditions on floor 4, North Wing',
        body = 'Good afternoon,

During a visit to my admitted relative I found poor hygiene conditions in the toilets and corridor on floor 4. I request that this situation be urgently checked and corrected.

Date: 12/03/2025 | Floor 4 - North Wing

Kind regards,
Catarina Nunes'
     WHERE ticket_id = 'F97DF4AB-D27E-4BA9-808E-EDC41DF51552';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'F97DF4AB-D27E-4BA9-808E-EDC41DF51552',
            'API',
            'SEED-F97DF4AB-D27E-4BA9-808E-EDC41DF51552',
            'Complaint about poor hygiene conditions on floor 4, North Wing',
            'Good afternoon,

During a visit to my admitted relative I found poor hygiene conditions in the toilets and corridor on floor 4. I request that this situation be urgently checked and corrected.

Date: 12/03/2025 | Floor 4 - North Wing

Kind regards,
Catarina Nunes',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket CE01740B-BC68-409C-A6D8-A3D63B428CEF
    UPDATE tickets
       SET subject = 'Complaint about inability to reach the hospital by telephone',
        body = 'Hello,

I tried to contact the hospital by telephone for 3 consecutive days and nobody answered. It is unacceptable that a healthcare institution is so difficult to contact. How do I formally report this situation?

Kind regards,
António Sousa'
     WHERE ticket_id = 'CE01740B-BC68-409C-A6D8-A3D63B428CEF';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'CE01740B-BC68-409C-A6D8-A3D63B428CEF',
            'API',
            'SEED-CE01740B-BC68-409C-A6D8-A3D63B428CEF',
            'Complaint about inability to reach the hospital by telephone',
            'Hello,

I tried to contact the hospital by telephone for 3 consecutive days and nobody answered. It is unacceptable that a healthcare institution is so difficult to contact. How do I formally report this situation?

Kind regards,
António Sousa',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket A59D9F17-5BE0-4C4C-9FE4-D4DB72CDE47B
    UPDATE tickets
       SET subject = 'Suggestion to create a telephone support line for Alzheimer''s carers',
        body = 'Good morning,

I am a carer for a relative with Alzheimer''s and feel the lack of specialist support. I suggest setting up a telephone support line for carers. Does a service like this already exist?

Thank you,
Maria Oliveira'
     WHERE ticket_id = 'A59D9F17-5BE0-4C4C-9FE4-D4DB72CDE47B';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'A59D9F17-5BE0-4C4C-9FE4-D4DB72CDE47B',
            'API',
            'SEED-A59D9F17-5BE0-4C4C-9FE4-D4DB72CDE47B',
            'Suggestion to create a telephone support line for Alzheimer''s carers',
            'Good morning,

I am a carer for a relative with Alzheimer''s and feel the lack of specialist support. I suggest setting up a telephone support line for carers. Does a service like this already exist?

Thank you,
Maria Oliveira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket B91ACAD6-CA5F-4E9B-9D29-8FCD9E90D062
    UPDATE tickets
       SET subject = 'Complaint about disrespectful behaviour by A&E doctor',
        body = 'Good afternoon,

During the emergency consultation the doctor was extremely rude and dismissive of my complaint. I feel I was not adequately examined. I would like to submit a formal complaint and to know whether it is possible to request to be seen by another doctor.

Kind regards,
Maria Oliveira'
     WHERE ticket_id = 'B91ACAD6-CA5F-4E9B-9D29-8FCD9E90D062';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'B91ACAD6-CA5F-4E9B-9D29-8FCD9E90D062',
            'API',
            'SEED-B91ACAD6-CA5F-4E9B-9D29-8FCD9E90D062',
            'Complaint about disrespectful behaviour by A&E doctor',
            'Good afternoon,

During the emergency consultation the doctor was extremely rude and dismissive of my complaint. I feel I was not adequately examined. I would like to submit a formal complaint and to know whether it is possible to request to be seen by another doctor.

Kind regards,
Maria Oliveira',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 45D6EF5B-BF25-463A-8AE9-0DC473E59C53
    UPDATE tickets
       SET subject = 'Complaint about disappearance of personal item during admission',
        body = 'Hello,

During my admission my watch, which was on the bedside table, disappeared. I have informed the nursing staff but nobody has responded. How can I submit a formal report?

Admission number: INT-2025-00891

Kind regards,
Tiago Valente'
     WHERE ticket_id = '45D6EF5B-BF25-463A-8AE9-0DC473E59C53';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '45D6EF5B-BF25-463A-8AE9-0DC473E59C53',
            'API',
            'SEED-45D6EF5B-BF25-463A-8AE9-0DC473E59C53',
            'Complaint about disappearance of personal item during admission',
            'Hello,

During my admission my watch, which was on the bedside table, disappeared. I have informed the nursing staff but nobody has responded. How can I submit a formal report?

Admission number: INT-2025-00891

Kind regards,
Tiago Valente',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 61E483D2-AAFC-4745-ABA4-430BAF7AD000
    UPDATE tickets
       SET subject = 'Visiting hours and visitor limit during admission',
        body = 'Good morning,

My husband is being admitted for planned surgery. What are the visiting hours? Is there a limit on the number of simultaneous visitors? Can children visit?

Kind regards,
António Sousa'
     WHERE ticket_id = '61E483D2-AAFC-4745-ABA4-430BAF7AD000';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '61E483D2-AAFC-4745-ABA4-430BAF7AD000',
            'API',
            'SEED-61E483D2-AAFC-4745-ABA4-430BAF7AD000',
            'Visiting hours and visitor limit during admission',
            'Good morning,

My husband is being admitted for planned surgery. What are the visiting hours? Is there a limit on the number of simultaneous visitors? Can children visit?

Kind regards,
António Sousa',
            NULL,
            'SUBMITTER',
            'RECEIVED',
            'MEDIUM',
            NULL,
            NULL,
            NULL,
            SYSTIMESTAMP,
            NULL
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket F89AF00F-2949-4DD5-93C3-A935321BE05B
    UPDATE tickets
       SET subject = 'Complaint about administrative service',
        body = 'Good afternoon, I was treated rudely at the admissions desk of the Évora hospital. The member of staff was rude and provided no assistance whatsoever. I wish to formally register this situation.',
        submitted_category = 'Complaint',
        generated_answer = 'We regret the situation described. You can submit a formal complaint through the Online Complaints Book at www.hospitalgroup.pt/reclamacoes, in person at any unit, or by email to qualidade@hospitalgroup.pt. All complaints are reviewed by the Quality Directorate and you will receive a formal response within 15 working days. Our goal is to continuously improve the service we provide and we thank you for your feedback. [KB: REC-001, REC-002]',
        suggested_answer = 'We regret the situation described. You can submit a formal complaint through the Online Complaints Book at www.hospitalgroup.pt/reclamacoes, in person at any unit, or by email to qualidade@hospitalgroup.pt.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = 'F89AF00F-2949-4DD5-93C3-A935321BE05B';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'F89AF00F-2949-4DD5-93C3-A935321BE05B',
            'API',
            'SEED-F89AF00F-2949-4DD5-93C3-A935321BE05B',
            'Complaint about administrative service',
            'Good afternoon, I was treated rudely at the admissions desk of the Évora hospital. The member of staff was rude and provided no assistance whatsoever. I wish to formally register this situation.',
            'Complaint',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'We regret the situation described. You can submit a formal complaint through the Online Complaints Book at www.hospitalgroup.pt/reclamacoes, in person at any unit, or by email to qualidade@hospitalgroup.pt. All complaints are reviewed by the Quality Directorate and you will receive a formal response within 15 working days. Our goal is to continuously improve the service we provide and we thank you for your feedback. [KB: REC-001, REC-002]',
            'We regret the situation described. You can submit a formal complaint through the Online Complaints Book at www.hospitalgroup.pt/reclamacoes, in person at any unit, or by email to qualidade@hospitalgroup.pt.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 8DB6E686-4093-4440-ABF7-9D4E114B794E
    UPDATE tickets
       SET subject = 'Cannot access the HIS system',
        body = 'Good morning, when trying to log in to HIS this morning I receive the message "Invalid credentials". I have changed my password twice without success. Employee number: C-4821.',
        submitted_category = 'Access',
        generated_answer = 'Good morning Carlos Rodrigues,

To resolve the HIS access issue with the message "Invalid credentials" after changing the password twice, it is recommended to follow these steps:

1. Verify that the employee number is correct. 2. Contact the IT Service Desk on extension 9000. [KB: IT-PASS-002]',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = '8DB6E686-4093-4440-ABF7-9D4E114B794E';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '8DB6E686-4093-4440-ABF7-9D4E114B794E',
            'API',
            'SEED-8DB6E686-4093-4440-ABF7-9D4E114B794E',
            'Cannot access the HIS system',
            'Good morning, when trying to log in to HIS this morning I receive the message "Invalid credentials". I have changed my password twice without success. Employee number: C-4821.',
            'Access',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Good morning Carlos Rodrigues,

To resolve the HIS access issue with the message "Invalid credentials" after changing the password twice, it is recommended to follow these steps:

1. Verify that the employee number is correct. 2. Contact the IT Service Desk on extension 9000. [KB: IT-PASS-002]',
            NULL,
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 8D2ECC5A-94F2-4FB9-B906-28280E219674
    UPDATE tickets
       SET subject = 'Configure printer on new computer',
        body = 'Good afternoon, I received a new computer and need to install the HP LaserJet printer in the meeting room on floor 3. Can you carry out the configuration remotely?',
        submitted_category = 'Printer',
        generated_answer = 'For printer problems, restart the equipment and the print spooler (Services > Print Spooler > Restart). If the problem persists, open a ticket in the Service Desk with the model, serial number and location. For installing printers on new equipment, a technician can carry out the remote configuration. [KB: IT-HW-003]',
        suggested_answer = 'For printer problems, restart the equipment and the print spooler (Services > Print Spooler > Restart). If the problem persists, open a ticket in the Service Desk with the model, serial number and location.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = '8D2ECC5A-94F2-4FB9-B906-28280E219674';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '8D2ECC5A-94F2-4FB9-B906-28280E219674',
            'API',
            'SEED-8D2ECC5A-94F2-4FB9-B906-28280E219674',
            'Configure printer on new computer',
            'Good afternoon, I received a new computer and need to install the HP LaserJet printer in the meeting room on floor 3. Can you carry out the configuration remotely?',
            'Printer',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'For printer problems, restart the equipment and the print spooler (Services > Print Spooler > Restart). If the problem persists, open a ticket in the Service Desk with the model, serial number and location. For installing printers on new equipment, a technician can carry out the remote configuration. [KB: IT-HW-003]',
            'For printer problems, restart the equipment and the print spooler (Services > Print Spooler > Restart). If the problem persists, open a ticket in the Service Desk with the model, serial number and location.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 4356322E-A150-414A-9A9F-EE7F3373713A
    UPDATE tickets
       SET subject = 'Workstation computer not powering on',
        body = 'Good afternoon, the computer at workstation 3C in the surgery wing has not powered on since this morning. I have checked the power supply and the cable is properly connected. It is urgent as it is a prescription terminal.',
        submitted_category = 'Hardware',
        generated_answer = 'For hardware faults, open a ticket in the Service Desk at helpdesk.hospitalgroup.pt with a photo of the equipment and a description of the problem. For critical situations (prescription terminals, emergency posts), call extension 9000 directly indicating urgency. A technician will be on site within 2 hours on working days. Replacement equipment is available from the IT store (floor 0, support building). [KB: IT-HW-001, IT-HW-002]',
        suggested_answer = 'For hardware faults, open a ticket in the Service Desk at helpdesk.hospitalgroup.pt with a photo of the equipment and a description of the problem. For critical situations, call extension 9000 directly indicating urgency.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = '4356322E-A150-414A-9A9F-EE7F3373713A';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '4356322E-A150-414A-9A9F-EE7F3373713A',
            'API',
            'SEED-4356322E-A150-414A-9A9F-EE7F3373713A',
            'Workstation computer not powering on',
            'Good afternoon, the computer at workstation 3C in the surgery wing has not powered on since this morning. I have checked the power supply and the cable is properly connected. It is urgent as it is a prescription terminal.',
            'Hardware',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'For hardware faults, open a ticket in the Service Desk at helpdesk.hospitalgroup.pt with a photo of the equipment and a description of the problem. For critical situations (prescription terminals, emergency posts), call extension 9000 directly indicating urgency. A technician will be on site within 2 hours on working days. Replacement equipment is available from the IT store (floor 0, support building). [KB: IT-HW-001, IT-HW-002]',
            'For hardware faults, open a ticket in the Service Desk at helpdesk.hospitalgroup.pt with a photo of the equipment and a description of the problem. For critical situations, call extension 9000 directly indicating urgency.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket D4070F53-C819-4FDF-97A1-19ED5937829E
    UPDATE tickets
       SET subject = 'Broken monitor screen',
        body = 'Hello, the monitor in consulting room 12 on floor 2 has a broken screen. It needs to be replaced urgently as the doctor has appointments this afternoon.',
        submitted_category = 'Hardware',
        generated_answer = 'For hardware faults, open a ticket in the Service Desk at helpdesk.hospitalgroup.pt with a photo of the equipment and a description of the problem. For critical situations (prescription terminals, emergency posts), call extension 9000 directly indicating urgency. A technician will be on site within 2 hours on working days. Replacement equipment is available from the IT store (floor 0, support building). [KB: IT-HW-001, IT-HW-002]',
        suggested_answer = 'For hardware faults, open a ticket in the Service Desk at helpdesk.hospitalgroup.pt with a photo of the equipment and a description of the problem. For critical situations, call extension 9000 directly indicating urgency.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = 'D4070F53-C819-4FDF-97A1-19ED5937829E';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'D4070F53-C819-4FDF-97A1-19ED5937829E',
            'API',
            'SEED-D4070F53-C819-4FDF-97A1-19ED5937829E',
            'Broken monitor screen',
            'Hello, the monitor in consulting room 12 on floor 2 has a broken screen. It needs to be replaced urgently as the doctor has appointments this afternoon.',
            'Hardware',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'For hardware faults, open a ticket in the Service Desk at helpdesk.hospitalgroup.pt with a photo of the equipment and a description of the problem. For critical situations (prescription terminals, emergency posts), call extension 9000 directly indicating urgency. A technician will be on site within 2 hours on working days. Replacement equipment is available from the IT store (floor 0, support building). [KB: IT-HW-001, IT-HW-002]',
            'For hardware faults, open a ticket in the Service Desk at helpdesk.hospitalgroup.pt with a photo of the equipment and a description of the problem. For critical situations, call extension 9000 directly indicating urgency.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 1B9CE3FB-69B9-41A7-A46D-4931B20C055F
    UPDATE tickets
       SET subject = 'Corporate email password reset',
        body = 'Hello, I forgot my corporate email password after the holidays. Can you reset it? My username is mferreira@hospitalgroup.pt.',
        submitted_category = 'Password',
        generated_answer = 'To reset a password for internal systems, submit a request via the Service Desk at helpdesk.hospitalgroup.pt or call extension 9000 (available 07:00–22:00). For urgent resets outside these hours, contact the on-call technician on extension 9999. The reset is completed within 30 minutes during normal hours. After the reset, the temporary password is sent to the personal email address registered with HR. [KB: IT-PASS-001, IT-PASS-002]',
        suggested_answer = 'To reset a password for internal systems, submit a request via the Service Desk at helpdesk.hospitalgroup.pt or call extension 9000 (available 07:00–22:00). After the reset, the temporary password is sent to the personal email registered with HR.',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = '1B9CE3FB-69B9-41A7-A46D-4931B20C055F';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '1B9CE3FB-69B9-41A7-A46D-4931B20C055F',
            'API',
            'SEED-1B9CE3FB-69B9-41A7-A46D-4931B20C055F',
            'Corporate email password reset',
            'Hello, I forgot my corporate email password after the holidays. Can you reset it? My username is mferreira@hospitalgroup.pt.',
            'Password',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'To reset a password for internal systems, submit a request via the Service Desk at helpdesk.hospitalgroup.pt or call extension 9000 (available 07:00–22:00). For urgent resets outside these hours, contact the on-call technician on extension 9999. The reset is completed within 30 minutes during normal hours. After the reset, the temporary password is sent to the personal email address registered with HR. [KB: IT-PASS-001, IT-PASS-002]',
            'To reset a password for internal systems, submit a request via the Service Desk at helpdesk.hospitalgroup.pt or call extension 9000 (available 07:00–22:00). After the reset, the temporary password is sent to the personal email registered with HR.',
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket B884EE3E-3CC6-4315-8E00-9F8FC5D7D785
    UPDATE tickets
       SET subject = 'Account creation for new nurse',
        body = 'Good morning, our unit has a new nurse starting tomorrow. I need to create an access account for HIS and corporate email. Name: Catarina Lemos, NIF: 234567890.',
        submitted_category = 'New Account',
        resolution_notes = 'Resolved by the team after human review.'
     WHERE ticket_id = 'B884EE3E-3CC6-4315-8E00-9F8FC5D7D785';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'B884EE3E-3CC6-4315-8E00-9F8FC5D7D785',
            'API',
            'SEED-B884EE3E-3CC6-4315-8E00-9F8FC5D7D785',
            'Account creation for new nurse',
            'Good morning, our unit has a new nurse starting tomorrow. I need to create an access account for HIS and corporate email. Name: Catarina Lemos, NIF: 234567890.',
            'New Account',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            NULL,
            NULL,
            'Resolved by the team after human review.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 7BFC9DF2-3F5E-4886-8A46-BB80BCB284FA
    UPDATE tickets
       SET subject = 'Does ADSE cover a nutrition consultation?',
        body = 'Good morning, I have ADSE as my health scheme. Does your unit have an agreement with ADSE for nutrition and dietetics consultations? What is the co-payment?',
        submitted_category = 'Insurance',
        generated_answer = 'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment with your beneficiary card. For ADSE, nutrition and dental consultations are not covered under direct access. [KB: SEG-001, SEG-003, SEG-006]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '7BFC9DF2-3F5E-4886-8A46-BB80BCB284FA';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '7BFC9DF2-3F5E-4886-8A46-BB80BCB284FA',
            'API',
            'SEED-7BFC9DF2-3F5E-4886-8A46-BB80BCB284FA',
            'Does ADSE cover a nutrition consultation?',
            'Good morning, I have ADSE as my health scheme. Does your unit have an agreement with ADSE for nutrition and dietetics consultations? What is the co-payment?',
            'Insurance',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment with your beneficiary card. For ADSE, nutrition and dental consultations are not covered under direct access. [KB: SEG-001, SEG-003, SEG-006]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 5F1AB0CE-1BC3-40B9-9003-492D66F60E4F
    UPDATE tickets
       SET subject = 'Médis insurance — which procedures are covered?',
        body = 'Good afternoon, I have Médis health insurance and would like to know which medical procedures and exams are covered at your clinic. I need to have an MRI scan.',
        submitted_category = 'Insurance',
        generated_answer = 'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment with your beneficiary card. For ADSE, nutrition and dental consultations are not covered under direct access. [KB: SEG-001, SEG-003, SEG-006]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '5F1AB0CE-1BC3-40B9-9003-492D66F60E4F';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '5F1AB0CE-1BC3-40B9-9003-492D66F60E4F',
            'API',
            'SEED-5F1AB0CE-1BC3-40B9-9003-492D66F60E4F',
            'Médis insurance — which procedures are covered?',
            'Good afternoon, I have Médis health insurance and would like to know which medical procedures and exams are covered at your clinic. I need to have an MRI scan.',
            'Insurance',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment with your beneficiary card. For ADSE, nutrition and dental consultations are not covered under direct access. [KB: SEG-001, SEG-003, SEG-006]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket 2982E846-2A6B-4CD1-A2AB-E4E2A6882E20
    UPDATE tickets
       SET subject = 'Agreement with SAD GNR',
        body = 'Hello, I am a SAD GNR beneficiary. Does your Lisbon unit have an active agreement with this health scheme? Which specialties are included?',
        submitted_category = 'Health Subsystems',
        generated_answer = 'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment with your beneficiary card. For ADSE, nutrition and dental consultations are not covered under direct access. [KB: SEG-001, SEG-003, SEG-006]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = '2982E846-2A6B-4CD1-A2AB-E4E2A6882E20';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            '2982E846-2A6B-4CD1-A2AB-E4E2A6882E20',
            'API',
            'SEED-2982E846-2A6B-4CD1-A2AB-E4E2A6882E20',
            'Agreement with SAD GNR',
            'Hello, I am a SAD GNR beneficiary. Does your Lisbon unit have an active agreement with this health scheme? Which specialties are included?',
            'Health Subsystems',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Our network has active agreements with ADSE, SAMS, SAD GNR, SAD PSP, AdvanceCare, Médis, Fidelidade Saúde and Multicare, among others. Co-payment amounts vary by procedure and health scheme. We recommend checking the updated table at www.hospitalgroup.pt/convenções or contacting the admissions desk before your appointment with your beneficiary card. For ADSE, nutrition and dental consultations are not covered under direct access. [KB: SEG-001, SEG-003, SEG-006]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    -- Ticket B0303803-3F7E-4A6F-86B3-6386B1F54423
    UPDATE tickets
       SET subject = 'Turnaround time for CT scan results',
        body = 'Good morning, I had a chest CT scan 5 days ago. Are the results already available? Can I collect them in person or can they be sent by email?',
        submitted_category = 'Results',
        generated_answer = 'Clinical analysis results are available within 24 to 72 hours. Imaging results (CT scan, MRI, ultrasound) are available within 3 to 5 working days. You can access results through the patient portal at www.hospitalgroup.pt/resultados using your patient number and date of birth. If you do not have portal access, you may collect them in person or request email delivery to the address registered in the system. [KB: EXA-001, EXA-003]',
        resolution_notes = 'Resolved by the agent based on the knowledge base.'
     WHERE ticket_id = 'B0303803-3F7E-4A6F-86B3-6386B1F54423';

    IF SQL%ROWCOUNT = 0 THEN
        INSERT INTO tickets (
            ticket_id,
            source,
            external_ref,
            subject,
            body,
            submitted_category,
            category_source,
            status,
            priority,
            generated_answer,
            suggested_answer,
            resolution_notes,
            timestamp_received,
            timestamp_resolved
        ) VALUES (
            'B0303803-3F7E-4A6F-86B3-6386B1F54423',
            'API',
            'SEED-B0303803-3F7E-4A6F-86B3-6386B1F54423',
            'Turnaround time for CT scan results',
            'Good morning, I had a chest CT scan 5 days ago. Are the results already available? Can I collect them in person or can they be sent by email?',
            'Results',
            'SUBMITTER',
            'RESOLVED',
            'MEDIUM',
            'Clinical analysis results are available within 24 to 72 hours. Imaging results (CT scan, MRI, ultrasound) are available within 3 to 5 working days. You can access results through the patient portal at www.hospitalgroup.pt/resultados using your patient number and date of birth. If you do not have portal access, you may collect them in person or request email delivery to the address registered in the system. [KB: EXA-001, EXA-003]',
            NULL,
            'Resolved by the agent based on the knowledge base.',
            SYSTIMESTAMP,
            SYSTIMESTAMP
        );

        l_inserted := l_inserted + 1;
    ELSE
        l_updated := l_updated + 1;
    END IF;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Tickets inserted: ' || l_inserted);
    DBMS_OUTPUT.PUT_LINE('Tickets updated : ' || l_updated);
    DBMS_OUTPUT.PUT_LINE('Total processed : ' || (l_inserted + l_updated));
END;
/

-- =============================================================================
-- VERIFICATION
-- =============================================================================

SELECT COUNT(*) AS total_tickets
FROM tickets;

SELECT
    status,
    COUNT(*) AS ticket_count
FROM tickets
GROUP BY status
ORDER BY status;

SELECT
    ticket_id,
    subject,
    status
FROM tickets
FETCH FIRST 10 ROWS ONLY;
