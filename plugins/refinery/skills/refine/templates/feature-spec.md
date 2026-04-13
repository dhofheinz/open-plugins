---
artifact: feature-spec
scope: feature
feature: {{FEATURE_NAME}}
stage: feature-spec
iteration: 0
last_updated: {{TIMESTAMP}}
status: draft
parent: {{PARENT_PATH_OR_NULL}}
children: []
references: []
convergence:
  questions_stable_count: 0
  open_questions_count: 0
  high_confidence_ratio: 0.0
plugin_version: 1.0.0
---

# Feature Spec: {{FEATURE_NAME}}

## 1. Overview

{One paragraph: what this feature does, who it serves, what problem it solves. Use the user's words from intake.}

## 2. Context

### 2.1 Current State

{What exists today. Reference codebase findings: file:line citations for similar features or patterns to extend.}

### 2.2 Problem Statement

{The pain or gap this feature addresses. Specific.}

### 2.3 Scope

**In scope:**
- {capability}
- {capability}

**Out of scope:**
- {capability} — {why excluded}

**Non-goals (explicit):**
- {item} — {why explicitly not pursued}

## 3. Requirements

### 3.1 Functional Requirements

#### FR-001: {Title using verb-object pattern}

When {trigger}, the system shall {action}.

**Priority:** Must
**Confidence:** High
**Evidence:** {file:line citations OR "user decision in intake"}
**Source:** {Feature intake batch N answer / parent system spec FR-XX / design constraint}
**Status:** Verified
**Notes:** {optional}

#### AC-FR-001-1: {Scenario name}

```gherkin
Given {precondition}
When {action}
Then {observable outcome}
```

(Repeat per FR. Use the six EARS patterns; prefer atomic FRs.)

### 3.2 Non-Functional Requirements

#### NFR-P-001: {Title} (Performance)

The system shall {action} within {threshold} {units}.

**Priority:** Must
**Acceptance:** {how measured}
**Confidence:** Medium
**Evidence:** {single example or inference}

(Other categories: NFR-S security, NFR-SC scalability, NFR-R reliability, NFR-A availability, NFR-U usability, NFR-M maintainability, NFR-C compatibility.)

### 3.3 Constraints

| ID | Constraint | Source |
|----|-----------|--------|
| C-001 | {hard constraint} | {derivation} |

## 4. Acceptance Criteria

(Detailed AC per FR are listed in §3.1. This section provides feature-level integration acceptance criteria — the "feature is done" tests.)

### Feature-level AC-1: {Title}

```gherkin
Given the feature is fully implemented
When {integration scenario}
Then {observable feature-level outcome}
```

## 5. Data Model

| Entity | Fields | Relationships | Lifecycle |
|--------|--------|---------------|-----------|
| {entity} | {field: type, ...} | {related entities} | {states} |

(Reference parent system spec's Domain Model where applicable.)

## 6. API / Interface Contracts

### {Endpoint or interface name}

```
{method} {path}

Request:
{
  "field": type
}

Response (200):
{
  "field": type
}

Error responses:
- 400: {when}
- 404: {when}
- 500: {when}
```

(For non-HTTP interfaces: function signatures, event schemas, message formats.)

## 7. Error Handling

| Error | Detection | Response | Recovery |
|-------|-----------|----------|----------|
| {error type} | {how detected} | {what user/caller sees} | {retry / failover / abort} |

(Reference parent's Error Doctrine / Error Handling appendix; don't duplicate.)

## 8. Dependencies

### Internal

- {existing feature or module} — {how this feature depends on it}

### External

- {external service or library} — {what it provides}

## 9. Migration / Rollout

(If the feature requires data migration, schema changes, or staged rollout.)

| Step | Description | Risk | Rollback |
|------|-------------|------|----------|
| 1 | {migration step} | {risk level} | {rollback procedure} |

## Open Questions

| ID | Question | Type | Added | Status |
|----|----------|------|-------|--------|
| OQ-001 | {question} | RESEARCHABLE \| HUMAN_NEEDED \| DERIVABLE \| OUT_OF_SCOPE | {date} | OPEN |

## Iteration Log

### Iteration 0 — Initial draft ({date})
- **Created via:** advance --stage=feature-spec
- **Source:** Intake (requirements-interviewer) + {parent path or "standalone"}
- **Initial state:** {N FRs, N NFRs, N ACs, N open questions, ratio: N.NN}

## Changelog

| Date | Section | Change | Reason | Operation |
|------|---------|--------|--------|-----------|
| {date} | (created) | Initial draft | feature intake + synthesis | advance |
