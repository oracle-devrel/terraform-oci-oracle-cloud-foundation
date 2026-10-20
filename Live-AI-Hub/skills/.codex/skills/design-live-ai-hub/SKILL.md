---
name: design-live-ai-hub
description: Helps design and implement governed AI workloads over live, distributed enterprise data using the Live AI Hub approach. Use when planning an AI-on-live-data architecture, selecting federation and performance patterns, designing security and semantics, building NL2SQL, RAG, or agent workflows, or operating a Live AI Hub workload.
---

# Design Live AI Hub

Use this skill to guide a solution from business use case through architecture, implementation planning, and operations. Treat Autonomous AI Database as the governed access and execution layer; keep source systems of record in place by default, and move or materialize only the data needed to meet freshness, performance, cost, or source-load requirements.

## Working method

1. Clarify the outcome. Identify users, example questions or actions, source systems, freshness needs, response-time targets, data sensitivity, locality or regulatory constraints, and success measures. Start with the smallest useful set of sources for a single use case; plan broader federation when several use cases will reuse the same data landscape.
2. Federate the data. Choose a connection method based on source type and how it is exposed. Consider database links, heterogeneous connectivity, external tables, catalog federation, APIs, and supported data-sharing protocols. Create and manage credentials, expose only required objects, and validate access with representative queries.
3. Meet performance and freshness needs. Set freshness requirements for each dataset. Query live where current values are essential. For repeated or latency-sensitive access, consider external-table caching, partitions, curated views, or materialized views with an explicit refresh schedule. Assess source-system load, cross-cloud latency, and egress cost.
4. Add business meaning. Create curated objects and document table, view, and column semantics with comments or annotations. Define business measures, statuses, join meaning, and allowed usage consistently so people and models interpret the data the same way.
5. Apply security before enabling AI. Use least privilege for users, applications, and agent identities. Grant access through approved curated objects. Add row-level controls such as Virtual Private Database policies where needed; redact or mask sensitive fields; and plan auditing and monitoring for generated SQL, retrieval, tool calls, API actions, and database access.
6. Build the AI workload. Select among NL2SQL for structured questions, RAG and vector search for unstructured content, and agents or agent teams for multi-step workflows. Scope profiles to approved objects and metadata. Give agents narrow responsibilities and explicit tools; route actions only through approved APIs or workflows. Select models by task complexity, latency, cost, and reasoning needs, using simpler models first and escalating when quality requires it.
7. Place and invoke the workload. Place the database execution layer and model service near the users and systems they serve when possible, subject to data locality and regulatory rules. Choose invocation through SQL, application code, REST, queues, streams, or scheduled jobs to fit the consuming system. Keep clients as entry points; execute through the governed workload layer.
8. Operate and improve. Monitor latency, errors, source impact, tool usage, retrieval quality, cost drivers, security events, and policy exceptions. Retain enough trace data to understand which identity, profile, model, objects, prompts, retrieved items, and tools contributed to an outcome. Revisit semantics, access policies, caching and refresh, model choice, locality, and tool approvals as schemas and usage change.

## Response expectations

- Give a short architecture recommendation, then explain the key choices and trade-offs.
- Separate confirmed requirements from assumptions and open decisions.
- Provide a staged implementation plan with validation and security checkpoints.
- For code or configuration, identify prerequisites and placeholders; do not invent credentials, endpoints, schema names, or tenancy details.
- Verify current Oracle product names, feature availability, limits, APIs, and implementation steps against current Oracle documentation before presenting them as current facts. The source guide is a June 2026 draft, version 0.1, and explicitly says its contents may change and are not a delivery commitment.
- Distinguish the guide's illustrative example choices from requirements. The Fashion Advisor example uses Autonomous AI Lakehouse as the AI control point, ATP for live commerce data, MongoDB and analytics sources, Object Storage for content, OCI Generative AI models, an application front end, and an API Gateway action path; adapt these roles to the actual environment.
- Do not promise zero data movement in every case. Federation is the default design posture, with caching or materialization as deliberate options.
- Do not enable an agent action until its authorization, input validation, audit trail, and failure behavior are defined.

## Source

Oracle, “Live AI Hub User Guide,” draft version 0.1, June 2026. The guide is organized around six design steps: federate data, augment performance, augment metadata, augment security, create the AI workload, and operate the workload. Source PDF: https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation/blob/main/Live-AI-Hub/documentation/Live%20AI%20Hub%20User%20Guide%20draft.pdf
