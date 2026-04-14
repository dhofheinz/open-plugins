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
format: waves               # waves | sequence — see §11
ticket_count: N
wave_count: N
flash_eligible_count: N
core_required_count: N
blocked_count: N
recommended_starting_ticket: T-NN
```

This enables dispatchers to read summary stats from frontmatter without parsing the full body.

## 11. Sequence Format Variant

When the ticket dependency graph is a **linear chain**, the tickets artifact uses the **sequence format** instead of the default waves format. The wave machinery (Dependency Graph ASCII, per-wave section headers, wave-count metrics) only conveys information when the graph has parallelism; for a linear chain, it adds ceremony without content.

The content of each ticket is identical across formats; only the artifact-level scaffolding differs. Dispatchers parsing individual tickets see the same schema either way.

### 11.1 Detection

A ticket set is a linear chain iff, considering only non-blocked tickets:

- every ticket has `len(depends_on) ≤ 1`
- every ticket is in `len(blocks) ≤ 1` of other tickets
- exactly one ticket has `depends_on: []` (the root)
- exactly one ticket has no successor (the tail — no other ticket lists it in `depends_on`)
- the tickets form a single connected path from root to tail

Blocked tickets (per §6) are excluded from the linearity check — they sit in Appendix B regardless of format.

### 11.2 Frontmatter

Sequence-format frontmatter sets:

```yaml
format: sequence
wave_count: 1                           # the entire chain is one implicit wave
recommended_starting_ticket: T-01       # trivially the root for a linear chain
```

All other frontmatter fields (`ticket_count`, `flash_eligible_count`, `core_required_count`, `blocked_count`) carry the same meaning as in the waves format.

If `format:` is absent, consumers default to `waves` (backward compatibility).

### 11.3 Body

```markdown
# Tickets: <Feature/System Name>

## 1. Summary

| Metric | Value |
|--------|-------|
| Total tickets | N |
| Format | sequence (linear chain) |
| Sizes | S: N, M: N, L: N, XL: N |
| Layers | frontend: N, backend: N, ... |
| FLASH-eligible | N |
| CORE-required | N |
| Blocked | N |

## 2. Steps

### T-01: <title>

**Size:** S
**Layer:** test
**Depends On:** None
**Blocks:** T-02
**Spec ref:** FR-007

... (full ticket body per §1)

### T-02: <title>

...

## Appendix A: Ticket Index
## Appendix B: Blocked Tickets
## Open Questions
## Iteration Log
## Changelog
```

What differs from the waves format:

| Aspect | Waves format | Sequence format |
|--------|--------------|-----------------|
| §2 | `Dependency Graph` (ASCII diagram) | **Omitted** — linearity is implicit in ticket order + `depends_on` |
| §3+ | `Wave 1: <theme>`, `Wave 2: <theme>`, … | Single `## 2. Steps` section containing all tickets in dependency order |
| Summary row | `Waves: N` | `Format: sequence (linear chain)` |
| Summary row | `Recommended starting ticket: T-NN` | Omitted — trivially T-01 |
| Per-ticket rendered header | `**Wave:** N` line | Omitted — implicit single wave |

### 11.4 When waves format is used even on small chains

Waves format applies whenever the graph has any parallelism. Specifically, waves is used when **any** of the following hold:

- Some ticket has `len(depends_on) > 1` (fan-in: multiple predecessors converge).
- Some ticket has `len(blocks) > 1` (fan-out: multiple successors diverge).
- The non-blocked tickets form multiple disconnected subgraphs.

These structures carry parallelism information that sequence format would erase. For long linear chains (15+ tickets) the sequence format still applies — linearity is the load-bearing property, not chain length.

### 11.5 Stability under regeneration

A ticket set that was originally linear may become branched after a `/refine update` adds a parallel ticket, or vice versa. Re-running `/refine tickets` after the source change produces the appropriate format automatically. The `format:` field in frontmatter records which variant was written; downstream tooling (Dispatch, human readers) reads it rather than inferring.
