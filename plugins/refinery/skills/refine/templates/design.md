---
artifact: design
scope: system
feature: {{PROJECT_NAME}}
stage: design
iteration: 0
last_updated: {{TIMESTAMP}}
status: draft
parent: {{PRINCIPLES_PATH}}
children: []
references: []
convergence:
  questions_stable_count: 0
  open_questions_count: 0
  high_confidence_ratio: 0.0
plugin_version: 1.0.0
---

# Design: {{PROJECT_NAME}}

## 0. Thesis

{Reframe what kind of engineering problem this actually is. Look past the obvious domain to the underlying technical challenge. Should surprise someone who only knows the domain surface. Example: "On the surface this is a customer-management UI; underneath, it's a distributed-consensus problem because multiple devices write the same record concurrently."}

## 1. System Decomposition

### Subsystems

| Subsystem | Responsibility | Characteristics | Key Constraint |
|-----------|---------------|-----------------|----------------|
| {Subsystem A} | {what it does} | {properties: stateless / stateful / sync / async / etc.} | {invariant or principle it satisfies} |

### Boundary Rules

- {Rule about inter-subsystem communication, e.g., "Subsystem A may only call Subsystem B via the event bus, never directly."}

### Change Pipeline

- **Disallowed:** {patterns or paths that violate the design}
- **Allowed:** {patterns or paths that respect the design}

## 2. Data Model & Authority

### Source of Truth

{Single, unambiguous source of truth for each data type. Reference the principles' Data Authority section.}

### Data Flow

{Diagram or stepwise description of how data moves between subsystems.}

### Consistency & Conflict Resolution

{When and how conflicts arise; resolution policy. Reference principles' Trust Hierarchy.}

## 3. External Integrations

### Integration Inventory

| Integration | Type | Purpose |
|-------------|------|---------|
| {name} | {sync API / async webhook / batch / etc.} | {what it provides} |

For each integration:

### {Integration Name}

- **Contract:** {Interface or API expected}
- **Abstraction:** {How wrapped — port/adapter pattern, anti-corruption layer, etc.}
- **Testing:** {How verified — mocked, contract test, recorded fixtures, etc.}
- **Fallback:** {What happens when unavailable; reference Error Doctrine}
- **Confidence:** {High / Medium / Low}
- **Source:** {Principle or codebase reference}

## 4. Security Model

### Threat Boundaries

| Boundary | Threats | Mitigation |
|----------|---------|-----------|
| {boundary} | {threat list} | {mitigation strategy} |

### Authentication & Authorization

{Strategy. Reference Trust Hierarchy.}

### Input Validation Strategy

{Where validated, by what, against what schema. Reference the principle about untrusted inputs.}

## 5. Scalability & Performance

### Performance-Critical Paths

| Path | Latency target (p95) | Throughput target | Notes |
|------|----------------------|-------------------|-------|
| {path} | {ms} | {req/sec} | {context} |

### Scaling Strategy

{Vertical, horizontal, sharding, etc. Reference principles' Scaling Law.}

### Caching Strategy

{What, where, invalidation policy.}

## 6. Reliability & Failure Modes

### Failure Classification

| Failure Mode | Detection | Recovery |
|--------------|-----------|----------|
| FM-001: {description} | {how detected — health check, alert, user report} | {how recovered — retry, failover, manual intervention} |
| FM-002: ... | ... | ... |

### Degradation Strategy

- **First to cut:** {feature that degrades first under load}
- **Never degrade:** {feature that must remain available}

### Recovery Procedures

{Steps. Reference operational runbooks if they exist.}

## 7. Observability

### Logging Strategy

{What gets logged at what level. Structured? Sampled?}

### Key Metrics

| Metric | Type | Description |
|--------|------|-------------|
| {metric_name} | counter / gauge / histogram | {what it measures} |

### Alerting

| Alert | Trigger | Action |
|-------|---------|--------|
| {alert_name} | {threshold or condition} | {who is paged, what runbook} |

## 8. Operational Concerns

### Configuration

{How configured, what's static vs runtime, where secrets live (defer to stack for the specific store).}

### Deployment Model

{Topology — how does this run? Where? With what dependencies?}

### Data Migration

{Strategy for schema/data evolution.}

## 9. Second-Order Failure Scenarios

(At least 3.)

### {Scenario name}

- **How it emerges:** {Description — what conditions interact?}
- **Detection:** {How spotted}
- **Mitigation:** {Response}

### {Scenario 2}
...

### {Scenario 3}
...

## 10. Open Questions & Deferred Decisions

(See the Open Questions section below for the full table; this section provides additional context for the most complex questions.)

## 11. Pre-Implementation Validation

Assumptions to test before building:

- {Assumption} — verify by {experiment / spike / consultation}
- {Assumption}

## Open Questions

| ID | Question | Type | Added | Status |
|----|----------|------|-------|--------|
| OQ-001 | {question} | RESEARCHABLE \| HUMAN_NEEDED \| DERIVABLE \| OUT_OF_SCOPE | {date} | OPEN |

## Iteration Log

### Iteration 0 — Initial draft ({date})
- **Created via:** advance --stage=design
- **Source:** {{PRINCIPLES_PATH}}
- **Initial state:** {N subsystems, N integrations, N failure modes, N open questions, ratio: N.NN}

## Changelog

| Date | Section | Change | Reason | Operation |
|------|---------|--------|--------|-----------|
| {date} | (created) | Initial draft | derived from principles | advance |
