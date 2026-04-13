---
artifact: principles
scope: system
feature: {{PROJECT_NAME}}
stage: principles
iteration: 0
last_updated: {{TIMESTAMP}}
status: draft
parent: null
children: []
references: []
convergence:
  questions_stable_count: 0
  open_questions_count: 0
  high_confidence_ratio: 0.0
plugin_version: 1.0.0
---

# Principles: {{PROJECT_NAME}}

## 0. Prime Postulate

{Single, irreducible axiom that defines this system's reason for existence. Must be a statement, not a feature list. Should be true even if every implementation detail changes.}

**Corollary:** {Practical consequence that follows directly from the postulate.}

## 1. Core Concepts

| Concept | Definition | Owns | Governed By |
|---------|-----------|------|-------------|
| {Concept A} | {Precise definition} | {What this concept is responsible for} | {Higher-order concept or rule} |
| {Concept B} | ... | ... | ... |

### Concept Relationships

{Describe how concepts relate. Use diagrams or tables as needed. Example: "A B has many As; an A belongs to exactly one B."}

## 2. Lifecycle Model

For each concept that has state:

### {Concept Name} Lifecycle

**States:** {state1, state2, state3, ...}

| Transition | Trigger | Allowed | Forbidden |
|------------|---------|---------|-----------|
| state1 → state2 | {trigger} | Yes | — |
| state2 → state1 | — | No | Reverse not permitted |

**Authority:** {Who/what can effect transitions.}

## 3. Authority & Trust Model

### Trust Hierarchy (ranked, most-trusted first)

1. {Most trusted entity}
2. {Less trusted}
3. {Least trusted}
4. {Untrusted (network, user input, etc.)}

### Trust Boundaries

| Boundary | Inside (trusted) | Outside (untrusted) | Validation required |
|----------|------------------|---------------------|---------------------|
| {boundary name} | {what's inside} | {what's outside} | {validation policy} |

## 4. Core Principles

### P-001: {Principle title in imperative form}

**Statement:** {Axiomatic constraint. What must always be true.}
**Applies When:** {When this principle is in force.}
**Implies:** {Practical consequences for design.}
**Violation Looks Like:** {What would it mean to violate this? Concrete example.}
**Confidence:** High
**Source:** {Derivation from prime postulate or explicit user directive}

(Aim for 5–15 principles. Each must constrain the design space. If a principle could be violated and the system still work the same way, it's not a principle.)

### P-002: ...

## 5. Hard Invariants

### INV-001: {Invariant statement}

**Statement:** {Unconditional guarantee — no "if" clauses dependent on runtime state.}
**Violated By:** {What would cause violation.}
**Consequence:** {What goes wrong if violated.}
**Confidence:** High
**Source:** {Principle reference or explicit derivation}

### INV-002: ...

## 6. Separation of Concerns

For each strict separation:

### {Concern A} vs {Concern B}

| Dimension | {Concern A} | {Concern B} |
|-----------|-------------|-------------|
| {dim1} | ... | ... |
| {dim2} | ... | ... |

**Why separated:** {Reason}
**Crossing the boundary requires:** {Validation, transformation, etc.}

## 7. Data Authority

### Primary (source of truth)

| Data | Mutability | Durability | Authority |
|------|-----------|-----------|-----------|
| {data type} | {how it can change} | {persistence} | {who owns it} |

### Derived (recomputable)

| Data | Source | Staleness tolerance | Reconstruction cost |
|------|--------|---------------------|---------------------|
| {derived data} | {primary source} | {bounds} | {cost} |

## 8. Error & Uncertainty Doctrine

In order of preference (first viable wins):

1. **Reject** — refuse to proceed when {conditions}
2. **Retry** — with policy {policy} when {conditions}
3. **Degrade** — with explicit fallback {fallback} when {conditions}
4. **Last resort** — explicit, alarmed: {what triggers an alert}

## 9. Scope Boundaries

### In Scope

- {Item}
- {Item}

### Out of Scope

- {Item} — {Why excluded}
- {Item} — {Why excluded}

### Explicitly Forbidden

- {Item} — {Why forbidden}

## 10. Minimal Viable Starting State

The minimal set of elements and relationships that constitute a valid system instance:

- {Element} (with constraints)
- {Relationship} (with constraints)

## 11. Scaling Law

| Scale | What it looks like | Same rules apply? |
|-------|--------------------|--------------------|
| 1 user | ... | Yes |
| 100 users | ... | Yes |
| 10,000 users | ... | Yes / No (with explanation) |
| 1M users | ... | ... |

## Open Questions

| ID | Question | Type | Added | Status |
|----|----------|------|-------|--------|
| OQ-001 | {question} | RESEARCHABLE \| HUMAN_NEEDED \| DERIVABLE \| OUT_OF_SCOPE | {date} | OPEN |

## Iteration Log

### Iteration 0 — Initial draft ({date})
- **Created via:** advance --stage=principles
- **Source:** {seed idea text or input file path}
- **Initial state:** {N principles, N invariants, N open questions, ratio: N.NN}

## Changelog

| Date | Section | Change | Reason | Operation |
|------|---------|--------|--------|-----------|
| {date} | (created) | Initial draft | {idea source} | advance |
