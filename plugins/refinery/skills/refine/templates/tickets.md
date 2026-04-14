---
artifact: tickets
scope: {{PARENT_SCOPE}}
feature: {{PROJECT_NAME_OR_FEATURE}}
stage: tickets
iteration: 0
last_updated: {{TIMESTAMP}}
status: finalized
parent: {{PLAN_OR_SPEC_PATH}}
children: []
references: []
plugin_version: 1.2.0
format: waves                   # waves | sequence — see references/ticket-format.md §11
ticket_count: 0
wave_count: 0
flash_eligible_count: 0
core_required_count: 0
blocked_count: 0
recommended_starting_ticket: T-01
---

<!--
Template shows the waves-format skeleton. For linear ticket chains
(every non-blocked ticket has ≤1 predecessor and ≤1 successor), emit
the sequence format per references/ticket-format.md §11 instead:
drop the Dependency Graph section, replace per-wave headers with a
single `## 2. Steps` section, trim the Summary table.
-->

# Tickets: {{PROJECT_NAME_OR_FEATURE}}

## 1. Summary

| Metric | Value |
|--------|-------|
| Total tickets | N |
| Waves | N |
| Sizes | S: N, M: N, L: N, XL: N |
| Layers | frontend: N, backend: N, data: N, infra: N, docs: N, test: N |
| FLASH-eligible | N |
| CORE-required | N |
| Blocked | N |
| Recommended starting ticket | T-01 |

## 2. Dependency Graph

```
T-01 ──┐
T-02 ──┼──> T-04 ──> T-06
T-03 ──┘     │
             ↓
T-05 ─────> T-07
```

## 3. Wave 1: {Theme}

### T-01: {Action verb} {thing}

**Wave:** 1
**Size:** S | M | L | XL
**Layer:** frontend | backend | data | infra | docs | test
**Depends On:** None
**Blocks:** T-02
**Spec ref:** FR-001, AC-FR-001-1, AC-FR-001-2

#### Description

{2–3 sentences: what and why.}

#### Authorized Files

```
[NEW]    src/path/to/new-file.ts
[MODIFY] src/path/to/existing-file.ts
[EXISTS] src/path/to/dependency.ts (read-only context)
```

#### Acceptance Criteria

```gherkin
Given {precondition}
When {action}
Then {observable outcome}
```

(Each criterion is independently testable. Tests pass = criterion met.)

#### Convention Recipe

{Reference to project recipe number, or "follow pattern in src/path/to/exemplar.ts"}

#### Technical Notes

- Files: {create/modify summary}
- Pattern: {reference existing similar code}
- Watch out: {gotchas, edge cases}

#### Anti-Patterns

- ❌ {forbidden approach}: {why forbidden}
- ❌ {forbidden approach}: {what to do instead}

### T-02: ...

## 4. Wave 2: {Theme}

(Same structure)

## ...

## Appendix A: Ticket Index

| ID | Title | Wave | Size | Layer | Status |
|----|-------|------|------|-------|--------|
| T-01 | ... | 1 | S | test | pending |
| T-02 | ... | 1 | M | backend | pending |

## Appendix B: Blocked Tickets

(Tickets that cannot be fully specified due to open questions in the source artifact.)

### T-09: [BLOCKED] {Title}

**Blocked By:** OQ-NNN (in source artifact: {path}) — "{question summary}"
**Unblocks:** T-10, T-11

#### To Proceed

1. Resolve OQ-NNN via `/refine finalize {source-path}`
2. Re-run `/refine tickets {source-path}` to regenerate this ticket fully specified

## Open Questions

| ID | Question | Type | Added | Status |
|----|----------|------|-------|--------|
| OQ-001 | {question — typically XL-warning suggestions or BLOCKED-ticket pointers} | DERIVABLE \| OUT_OF_SCOPE | {date} | OPEN |

## Iteration Log

### Iteration 0 — Initial draft ({date})
- **Created via:** tickets {{PLAN_OR_SPEC_PATH}}
- **Source:** {{PLAN_OR_SPEC_PATH}}
- **Initial state:** {N tickets, N waves, sizes summary}

## Changelog

| Date | Section | Change | Reason | Operation |
|------|---------|--------|--------|-----------|
| {date} | (created) | Initial decomposition | from plan/spec | tickets |
