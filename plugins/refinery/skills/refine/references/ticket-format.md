# Reference: Ticket Format (Dispatch-Compatible)

Canonical schema for ticket entries in `tickets` artifacts. Designed to be **dual-audience**: human teams use them for sprint planning; agent dispatchers use them for work-queue ingest. The format is compatible with the Dispatch skill and any other agent-dispatcher reading the standard ticket schema.

## 1. Ticket Schema

Each ticket in a tickets artifact is structured as a markdown section with a YAML-extractable header. The schema:

```yaml
id: T-NN                                # T-NN sequential within artifact, never reused
title: "Add SSE reconnection tests"     # Action-verb + thing
wave: 1                                 # Dependency wave (1 = no dependencies)
size: S                                 # S | M | L | XL
layer: frontend                         # frontend | backend | data | infra | docs | test
depends_on: []                          # List of ticket IDs that must complete first (within this artifact)
blocks: [T-08]                          # List of ticket IDs blocked by this one
spec_ref:                               # Source artifact references (FRs, ACs, plan phases)
  - FR-007
  - AC-FR-007-1
  - AC-FR-007-2
files:                                  # Authorized files with status markers
  - path: tests/unit/hooks/sse-context.test.tsx
    status: NEW                         # NEW | MODIFY | EXISTS
  - path: src/hooks/sse-context.tsx
    status: EXISTS                      # Read-only context
acceptance:                             # Independently testable assertions
  - "Test 'reconnection_triggers_after_drop' passes"
  - "Test 'exponential_backoff_increases_delay' passes"
  - "All tests in tests/unit/hooks/ pass"
convention_recipe: 9                    # Optional reference to project convention recipe (or null)
technical_notes: |
  Use existing test pattern from tests/unit/hooks/auth.test.tsx as exemplar.
  Mock the SSE connection via existing test utility.
anti_patterns:
  - "Don't add new test runner config"
  - "Don't change SSE source code in this ticket"
status: pending                         # pending | in_progress | complete | blocked
```

Rendered as markdown for human readability:

```markdown
## T-07: Add SSE reconnection tests

**Wave:** 1
**Size:** S
**Layer:** test
**Depends On:** None
**Blocks:** T-08
**Spec ref:** FR-007, AC-FR-007-1, AC-FR-007-2

### Description

Add unit tests for SSE auto-reconnection behavior. The hook already exists at src/hooks/sse-context.tsx; this ticket verifies its behavior under network drop and backoff scenarios.

### Authorized Files

```
[NEW]    tests/unit/hooks/sse-context.test.tsx
[EXISTS] src/hooks/sse-context.tsx (read-only context)
```

### Acceptance Criteria

```gherkin
Given an SSE connection is established
When the network drops for >5 seconds
Then the hook attempts reconnection within the backoff window
  And exponential backoff doubles the delay between attempts
```

### Convention Recipe

Recipe 9 (test pattern; see tests/unit/hooks/auth.test.tsx as exemplar).

### Technical Notes

- Use existing test pattern from tests/unit/hooks/auth.test.tsx
- Mock the SSE connection via existing test utility

### Anti-Patterns

- ❌ Don't add new test runner config
- ❌ Don't change SSE source code in this ticket
```

## 2. Required Fields

Per FR-030 / FR-033 / FR-032:

- `id` — unique within tickets artifact
- `title` — action-verb verb + thing, ≤80 chars
- `wave` — integer ≥ 1
- `size` — one of S, M, L, XL
- `layer` — one of frontend, backend, data, infra, docs, test
- `depends_on` — list (may be empty)
- `blocks` — list (may be empty)
- `spec_ref` — list of source artifact references (must be non-empty)
- `files` — list of `{path, status}` (must be non-empty); `status` is one of NEW, MODIFY, EXISTS
- `acceptance` — list of independently testable assertions (must be non-empty)

## 3. Optional Fields

- `convention_recipe` — integer or string, references a project convention; null if N/A
- `technical_notes` — multi-line guidance for the implementer
- `anti_patterns` — list of forbidden approaches (with reason where useful)
- `status` — defaults to `pending`; updated by dispatchers as work progresses (Refinery does not track this)

## 4. Wave Organization

Tickets are grouped into **dependency waves**:

- **Wave 1** (Foundation): No `depends_on`. Can start immediately.
- **Wave N** (N>1): Depends on tickets in Wave N-1 or earlier. Can start when all dependencies complete.

Within a wave, tickets can run in **parallel**. Across waves, ordering is enforced by dependencies.

The tickets artifact MUST include a textual dependency graph in its body (per FR-031):

```
T-01 ──┐
T-02 ──┼──> T-04 ──> T-06
T-03 ──┘     │
             ↓
T-05 ─────> T-07
```

## 5. Size Classification

| Size | Estimated effort | Agent dispatch hint |
|------|------------------|---------------------|
| S | Hours | FLASH-eligible (ephemeral subagent, no team) |
| M | One day | FLASH-eligible if low risk and no convergence point; otherwise CORE |
| L | Multiple days | CORE-required (persistent worker, often part of a chain) |
| XL | Week+ | **Decompose further** (warning surfaced in Open Questions per FR-032) |

These hints align with Dispatch's classification cascade. Refinery does **not** enforce them — a dispatcher reads them as suggestions, not mandates.

## 6. Blocked Tickets

If a ticket cannot be fully specified due to an open question in the source artifact:

```markdown
## T-09: [BLOCKED] Implement payment reconciliation strategy

**Blocked By:** OQ-005 (in source artifact: billing-spec.md) — "Reconciliation window: real-time vs daily batch?"
**Unblocks:** T-10, T-11

### To Proceed

1. Resolve OQ-005 via `/refine finalize docs/refinery/billing-spec.md`
2. Re-run `/refine tickets docs/refinery/billing-spec.md` to regenerate this ticket fully specified
```

Blocked tickets:

- Appear in their own section (Appendix B of the tickets artifact)
- Do **not** count toward `flash_eligible_count` or `core_required_count`
- Have `status: blocked`

## 7. File-Authorization Markers

Each entry in a ticket's `files:` list has a status marker:

| Marker | Meaning |
|--------|---------|
| `NEW` | The implementer creates this file. The file does not exist yet. |
| `MODIFY` | The implementer modifies this existing file. |
| `EXISTS` | Read-only context. The implementer reads this file but does not modify it. |

The list is **exhaustive**: a ticket's implementer is authorized to touch only the listed files. No "and any other necessary files" wildcards. Per FR-034, no ticket should span more than ~3 files unless natural cohesion (e.g., a single component split across implementation + test files) requires more.

## 8. Cross-Artifact Compatibility

For Dispatch (or any compatible work-queue dispatcher), the following invariants hold:

- Ticket IDs are stable across regenerations (same source content + same ticket-architect prompt = same IDs)
- `depends_on` and `blocks` lists use ticket IDs from the **same artifact** (no cross-artifact ticket references)
- `files` list uses workspace-relative paths
- `acceptance` items are independently testable
- `size` aligns with Dispatch's S/M/L/XL convention
- Refinery does **not** write to any `.dispatch/` cache directory; the tickets artifact IS the source of truth

## 9. Validation (mode-tickets Phase 3)

Before writing the tickets artifact, `mode-tickets.md` validates:

- All `depends_on` references resolve (no dangling)
- No circular dependencies (DAG check)
- All requirements/items in the source artifact map to at least one ticket
- At least one ticket has empty `depends_on` (Wave 1 root)
- All tickets have `size` in {S, M, L, XL}; XL tickets emit a warning to Open Questions
- All tickets have non-empty `files` and `acceptance`

If any validation fails, ask the ticket-architect agent to revise and re-validate.

## 10. Front-of-Artifact Summary Block

The tickets artifact includes a summary table at the top of the body (after frontmatter, before §1):

```markdown
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
| Recommended starting ticket | T-NN |
```

These metrics also appear in the artifact's frontmatter:

```yaml
ticket_count: N
wave_count: N
flash_eligible_count: N
core_required_count: N
blocked_count: N
recommended_starting_ticket: T-NN
```

This enables dispatchers to read summary stats from frontmatter without parsing the full body.
