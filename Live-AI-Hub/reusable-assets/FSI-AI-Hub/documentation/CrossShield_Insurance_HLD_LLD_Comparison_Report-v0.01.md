# CrossShield Insurance — HLD and LLD Comparison Report

**Author:** Madhusudhan Rao  
**Version:** 0.01  
**Assessment date:** 2026-08-28  
**HLD source of truth:** `CrossShield_Insurance_HLD-v0.01.md`  
**Assessed implementation design:** `CrossShield_Insurance_LLD-v0.01.md`

## 1. Executive summary

The CrossShield Insurance Low-Level Design (LLD) is substantially consistent with the High-Level Design (HLD). It implements the intended Oracle APEX, Autonomous AI Database, Select AI and Select AI Agents architecture; the claim/fraud workflow; governed tools; the core data model; required integrations; and the APEX user experience.

The assessed HLD-to-LLD coverage is **91%**. There are no hard architecture or scope contradictions. The remaining gaps are implementation detail rather than a change to the HLD intent: explicit human-review gating for consequential actions, concrete authorization mapping, idempotency/correlation controls for finalization retries, and full delivery-roadmap traceability.

## 2. Assessment method

The HLD is the only source of truth for this assessment. Each HLD requirement area was mapped to the LLD and scored as follows:

| Score | Meaning |
|---:|---|
| 1.0 | Fully covered: the LLD defines an implementation approach and its relevant controls. |
| 0.5 | Partially covered: the LLD reflects the HLD intent but lacks a required implementation detail, control, or traceable acceptance evidence. |
| 0.0 | Not covered: the LLD has no corresponding implementation detail. |

The score uses 22 weighted HLD requirements. The calculation is:

```text
(18 fully covered × 1.0 + 4 partially covered × 0.5) / 22 × 100
= 20 / 22 × 100
= 90.9%, rounded to 91%
```

## 3. Coverage and consistency matrix

| # | HLD requirement | LLD evidence | Coverage | Consistency assessment |
|---:|---|---|---:|---|
| 1 | APEX application provides claims, fraud, reporting and AI-control experiences. | LLD sections 2, 3 and 6 define APEX areas, the control panel and report rendering. | 100% | Consistent. |
| 2 | Users can retrieve claim, policy, incident, party, payment, document and Customer 360 context. | LLD sections 3.1, 4.1 and 5.1 define profile, Customer 360, claim-view and data contracts. | 100% | Consistent. |
| 3 | Users can list claims by status and inspect high-risk claims. | LLD sections 3.1, 5.1 and 6 define Fraud Management and the list-by-status tool. | 100% | Consistent. |
| 4 | Maintenance is read-before-write and changes only `TOTAL_SETTLED` and `CLAIM_STATUS`. | LLD sections 3.2.2, 5.1 and 5.2 define the view-first and restricted update contract. | 100% | Consistent. |
| 5 | Fraud investigation follows four ordered stages. | LLD section 3.2.1 and 5.2 name all four tasks and define sequential execution. | 100% | Consistent. |
| 6 | Fraud probability includes risk level, reason codes and evidence. | LLD sections 4.1 and 5.1 define the rule-based scoring and output contract. | 100% | Consistent. |
| 7 | Multi-source validation uses contextual, weather, Google Sheets and Databricks repairer evidence where available. | LLD sections 2, 3.2.1, 4.1 and 5.1 define the aggregate validation flow and sources. | 100% | Consistent. |
| 8 | Similar historical fraud cases support the investigation. | LLD sections 3.2.1 and 5.1 define the similarity tool and result. | 100% | Consistent. |
| 9 | Reports are explainable, stored and linked through a report URI. | LLD sections 3.1, 3.2.1, 5.1 and 6 define finalization, report rendering and report URI. | 100% | Consistent. |
| 10 | SIU receives a threshold-based notification. | LLD sections 3.2.1, 5.1 and 7 document finalization and threshold-based escalation. | 100% | Consistent. |
| 11 | The PoV does not autonomously deny claims, authorize payments, alter coverage or assert fraud as fact. | LLD sections 2.1 and 7 state these exclusions and classify SIU notification as escalation. | 100% | Consistent. |
| 12 | Oracle APEX, Autonomous AI Database, Select AI and Select AI Agents form the target architecture. | LLD sections 2 and 2.1 provide the component diagram, boundaries and deployment order. | 100% | Consistent. |
| 13 | Bounded PL/SQL tools return structured JSON from authoritative data and approved services. | LLD sections 4.1, 5.1 and 5.2 define source and tool contracts. | 100% | Consistent. |
| 14 | Core data ownership remains in ADB; external enrichment remains source-owned. | LLD sections 2.1, 4.1 and 4.2 separate core relational tables from external services. | 100% | Consistent. |
| 15 | RAG retrieves knowledge-base content only and returns citations when available. | LLD sections 3.2.3, 4.3 and 5.2 define the RAG-only team and empty-index behavior. | 100% | Consistent. |
| 16 | Four specialized teams/agents have distinct responsibilities and write authority. | LLD section 5.2 defines fraud, maintenance, RAG and generic teams and their tool restrictions. | 100% | Consistent. |
| 17 | The UI distinguishes authoritative facts, derived scores, external evidence, missing data and AI narrative. | LLD sections 3.1, 3.2.1 and 6 require separation of claim facts and AI-derived output and safe empty/error rendering. | 100% | Consistent. |
| 18 | Security uses least privilege, externalized secrets, input/output controls and protected report artefacts. | LLD section 7 addresses least privilege, protected runtime configuration, prompt/tool control and data minimization. | 50% | Partially consistent: concrete APEX authorization schemes, database role mapping and report-URI access policy are not specified. |
| 19 | A human investigator reviews consequential actions; a fraud score is decision support only. | LLD sections 2.1 and 7 define non-autonomous operation and restricted writes. | 50% | Partially consistent: it lacks a named review/approval state, authorized approver role and recorded transition before the finalizer updates outcomes or sends SIU notification. |
| 20 | Reliability includes safe error states, audit, source observability and retry protection. | LLD sections 7 and 8.2 define structured errors, monitoring and audit evidence. | 50% | Partially consistent: the LLD does not define an idempotency key or correlation-ID contract for retried finalization/report/notification operations. |
| 21 | Delivery is phased through foundation, capabilities, APEX, integrations, knowledge/controls and PoV evaluation. | LLD sections 2.1 and 8.1 define deployment order and acceptance evidence. | 50% | Partially consistent: the six HLD roadmap phases are not individually traceable in the LLD. |
| 22 | HLD acceptance criteria are demonstrable. | LLD sections 7.1 and 8.1 define security tests and delivery acceptance evidence. | 100% | Consistent. |

## 4. Coverage result

| Assessment measure | Result |
|---|---:|
| HLD requirements assessed | 22 |
| Fully covered | 18 |
| Partially covered | 4 |
| Not covered | 0 |
| Weighted score | 20.0 / 22.0 |
| **HLD-to-LLD coverage** | **90.9%** |
| **Rounded coverage** | **91%** |

## 5. Consistency conclusion

The LLD is **consistent with the HLD**. Its architecture, data boundaries, agent workflow, tool restrictions, integrations, user experience and PoV exclusions align with the HLD. No hard contradiction was found.

The LLD is not yet complete enough to claim full HLD conformance because it does not turn several HLD governance expectations into explicit implementation controls. These are remediation items, not changes to the approved HLD direction.

## 6. Remediation items to reach full coverage

1. **Human-review gate:** Add a fraud-review state model, an authorized reviewer role, approval/rejection transitions, and an audit event before finalization performs fraud-outcome update or SIU notification.
2. **Authorization mapping:** Document the APEX authorization schemes, database roles, function grants, team invocation permissions and report-artefact access policy.
3. **Retry safety:** Add a correlation ID and idempotency key to `fsi_finalize_fraud_review`, report storage and notification delivery; define duplicate-request and partial-failure behavior.
4. **Roadmap traceability:** Add an LLD delivery table that maps each of the six HLD roadmap phases to deployment units, owners, verification steps and acceptance evidence.

## 7. Final assessment

**Overall result: 91% HLD coverage.** The LLD is a sound and largely traceable implementation design for the CrossShield HLD. Completion of the four remediation items above would close the remaining governance and operational-readiness gaps.
