---
artifact: plan
scope: system
feature: {{PROJECT_NAME}}
stage: plan
iteration: 0
last_updated: {{TIMESTAMP}}
status: draft
parent: {{SPEC_PATH}}
children: []
references: [{{STACK_PATH_IF_EXISTS}}, {{DESIGN_PATH_IF_EXISTS}}]
convergence:
  questions_stable_count: 0
  open_questions_count: 0
  high_confidence_ratio: 0.0
plugin_version: 1.0.0
---

# Implementation Plan: {{PROJECT_NAME}}

## 0. Document Conventions

- Each phase has: Objective, Prerequisites, Module Scope, Components, Acceptance Criteria, Anti-Patterns, Confidence
- Components carry status markers: `[NEW]` (will be created), `[MODIFY]` (existing, will be modified), `[EXISTS]` (read-only context)
- Type signatures are pseudocode unless the stack mandates language-specific notation
- All FRs from the parent spec are mapped to phases in Appendix E (File Manifest)

## 1. System Architecture Overview

(Brief summary; reference parent spec §2 and design §0-1 if applicable. Don't restate; cite.)

## 2. Current Implementation State

(Greenfield: "no existing implementation". Brownfield: summary of what exists, with file:line citations.)

## 3. Phase Dependency Graph

```
Phase 1: Foundation ──┐
Phase 2: Core ────────┼──> Phase 4: Integration
Phase 3: Models ──────┘
                          │
                          ↓
                      Phase 5: Polish
```

(Textual graph; ASCII art if helpful. Phases must form a DAG.)

## 4. Phase 1 — {Phase Name}

**Objective:** {What this phase delivers — observable, end-of-phase state}

**Prerequisites:** {Other phases that must complete first; or "None" for Phase 1 root}

**Module Scope:**
- `internal/<subsystem>/` — {what's touched here}
- `pkg/<package>/` — {what's touched}

**Components:**

### Component: {Name}

**Status:** [NEW] / [MODIFY] / [EXISTS]
**Type signature:**

```
{language-agnostic or stack-specific signature, e.g.:
  func ProcessRequest(ctx Context, req Request) (Response, error)
  type Request struct { ... }
  type Response struct { ... }
}
```

**Responsibility:** {What this component does — one paragraph}

**Implements:** FR-NNN (cite parent spec)

**Confidence:** High / Medium / Low
**Source:** Parent spec FR-NNN

### Component: {Name 2}
...

**Acceptance Criteria for Phase:**

```gherkin
Given Phase 1 is complete
When the system starts up
Then the following components are functional: {list}
  And the following tests pass: {list}
```

**Anti-Patterns:**

- ❌ {forbidden approach}: {why}
- ❌ {forbidden approach}: {what to do instead}

**Confidence:** High

## 5. Phase 2 — {Phase Name}

(Same structure)

## ...

## Appendix A: Cross-Cutting — Error Handling

{Strategy across phases. Reference parent spec / design Error Doctrine.}

| Error class | Where handled | Recovery policy |
|-------------|---------------|-----------------|
| {class} | {component / layer} | {policy} |

## Appendix B: Cross-Cutting — Observability

{Logging, metrics, tracing strategy across phases.}

## Appendix C: Cross-Cutting — Testing Strategy

| Layer | Tool | Phase coverage |
|-------|------|-----------------|
| Unit | {tool} | All phases |
| Integration | {tool} | Phases 2, 4, 5 |
| End-to-end | {tool} | Phase 5 |

## Appendix D: Reference — Decision Index

(Trade-offs and decisions made during plan authoring.)

| RD-001 | {decision} | {rationale} | {date} |

## Appendix E: File Manifest

| FR / NFR | Phase | Component | File path |
|----------|-------|-----------|-----------|
| FR-001 | 2 | {component name} | {file path or "[NEW]"} |
| FR-002 | 2 | {component name} | {file path} |
| NFR-P-001 | 4 | {component} | {file path} |

(Every FR/NFR in the source spec maps to at least one row.)

## Open Questions

| ID | Question | Type | Added | Status |
|----|----------|------|-------|--------|
| OQ-001 | {question} | RESEARCHABLE \| HUMAN_NEEDED \| DERIVABLE \| OUT_OF_SCOPE | {date} | OPEN |

## Iteration Log

### Iteration 0 — Initial draft ({date})
- **Created via:** advance --stage=plan
- **Source:** {{SPEC_PATH}}
- **Initial state:** {N phases, N components total, N FRs mapped, N open questions, ratio: N.NN}

## Changelog

| Date | Section | Change | Reason | Operation |
|------|---------|--------|--------|-----------|
| {date} | (created) | Initial draft | derived from spec | advance |
