---
artifact: spec
scope: system
feature: {{PROJECT_NAME}}
stage: spec
iteration: 0
last_updated: {{TIMESTAMP}}
status: draft
parent: {{DESIGN_PATH}}
children: []
references: [{{STACK_PATH_IF_EXISTS}}]
convergence:
  questions_stable_count: 0
  open_questions_count: 0
  high_confidence_ratio: 0.0
plugin_version: 1.0.0
---

# Specification: {{PROJECT_NAME}}

## 1. Introduction

### 1.1 Purpose & Scope

{What this spec specifies. What it does not.}

### 1.2 Intended Audience

{Implementers, reviewers, operators, dispatchers.}

### 1.3 Conventions & Terminology

- Requirements use **RFC 2119** keywords (MUST, SHALL, SHOULD, MAY).
- Acceptance criteria use **Given/When/Then** (Gherkin) format.
- Numbering per `_conventions.md` and `references/document-format.md §5`.
- Domain terms defined in Appendix B (Glossary) and `_glossary.md`.

## 2. System Overview

### 2.1 System Context

{Brief overview. Reference design §0 thesis and §1 decomposition. Don't restate; cite.}

### 2.2 Key Actors & External Systems

| Actor | Role | Interaction |
|-------|------|-------------|
| {actor} | {role} | {how they interact with the system} |

## 3. Domain Model

### 3.1 Entities and Relationships

{Entity-relationship description. Reference principles' Core Concepts.}

### 3.2 Lifecycle States and Transitions

{Per entity that has state. Reference principles' Lifecycle Model.}

### 3.3 Invariants and Business Rules

(References to principles INV-NNN; this section may add spec-level invariants beyond principles.)

| ID | Invariant | Source | Confidence |
|----|-----------|--------|------------|
| INV-001 | {statement} | {derivation} | High |

## 4. Functional Requirements

### FR-001: {Title using verb-object pattern}

The system SHALL {action} when {trigger}.

**Priority:** Must
**Confidence:** High
**Evidence:** {file:line citations or upstream artifact reference, e.g., "design.md §3.2"}
**Source:** {provenance}
**Status:** Verified
**Last validated:** {date}
**Notes:** {optional implementation hints, edge cases}

#### AC-FR-001-1: {Brief scenario name}

```gherkin
Given {precondition}
  And {additional precondition}
When {action}
Then {observable outcome}
  And {additional outcome}
```

#### AC-FR-001-2: ...

(Repeat per FR. Aim for atomic FRs; prefer multiple FRs over compound ones.)

### FR-002: ...

## 5. Non-Functional Requirements

### Performance (NFR-P-NNN)

#### NFR-P-001: {Title}

The system SHALL {action with concrete threshold and units}.

**Priority:** Must
**Confidence:** High
**Acceptance:** {How verified — load test, benchmark, etc.}
**Evidence:** {source}

### Security (NFR-S-NNN)

### Scalability (NFR-SC-NNN)

### Reliability (NFR-R-NNN)

### Availability (NFR-A-NNN)

### Usability (NFR-U-NNN)

### Maintainability (NFR-M-NNN)

### Compatibility (NFR-C-NNN)

(Each follows the same per-requirement format above.)

## 6. System Interfaces

### 6.1 External Interfaces

| Interface | Direction | Protocol | Format |
|-----------|-----------|----------|--------|
| {name} | inbound / outbound | HTTP / gRPC / event / etc. | JSON / Proto / etc. |

### 6.2 Internal Subsystem Interfaces

(Per design §1 boundary rules.)

## 7. Architectural Constraints

| ID | Constraint | Source |
|----|-----------|--------|
| C-001 | {hard constraint that limits implementation choices} | {principle / design / external regulation} |

## 8. Resolved Design Decisions

### RD-001: {Decision title}

**Decision:** {what was chosen}
**Alternatives considered:** {what else was on the table}
**Rationale:** {why this won}
**Trade-offs accepted:** {what we gave up}
**Confidence:** High
**Source:** {who decided, when, and via what process}

## 9. Risk Register

### R-001: {Risk title}

**Description:** {what could go wrong}
**Likelihood:** Low / Medium / High
**Impact:** Low / Medium / High
**Mitigation:** {planned response}
**Owner:** {who tracks this}

## Appendix A: Traceability Matrix

| Requirement | Source | Priority | Test strategy |
|-------------|--------|----------|---------------|
| FR-001 | design.md §X.Y | Must | Integration: {scenario} |
| FR-002 | principles.md §Z | Must | Unit: {scenario} |
| NFR-P-001 | design.md §5 | Must | Benchmark: {scenario} |

## Appendix B: Glossary

(See also `_glossary.md`.)

| Term | Definition |
|------|------------|
| {term} | {definition} |

## Open Questions

| ID | Question | Type | Added | Status |
|----|----------|------|-------|--------|
| OQ-001 | {question} | RESEARCHABLE \| HUMAN_NEEDED \| DERIVABLE \| OUT_OF_SCOPE | {date} | OPEN |

## Iteration Log

### Iteration 0 — Initial draft ({date})
- **Created via:** advance --stage=spec
- **Source:** {{DESIGN_PATH}}
- **Initial state:** {N FRs, N NFRs, N invariants, N RDs, N risks, N open questions, ratio: N.NN}

## Changelog

| Date | Section | Change | Reason | Operation |
|------|---------|--------|--------|-----------|
| {date} | (created) | Initial draft | derived from design | advance |
