# Mode: check

**Purpose:** Validate an artifact against the codebase. Detects drift in **both directions**: requirements without implementing code (spec → code drift) AND code behavior without spec coverage (code → spec drift, "undocumented behavior").

## Inputs

- Target artifact path (required first argument)

## Procedure

### Phase 1: Validate target

Read target. Confirm artifact type is one of: `spec`, `feature-spec`, `plan`, `tickets`. Refuse for `principles`, `design`, `stack` — these are not directly verifiable against code (they describe intent, not behavior).

### Phase 2: Extract verifiable items

For `spec` / `feature-spec`:

- Extract all FR-NNN, NFR-NNN with their EARS/RFC 2119 statements
- Extract all AC-* acceptance criteria with their Given/When/Then
- Extract data model definitions (entity names, fields, relationships)
- Extract API/interface contracts (endpoints, types, return values)
- **Skip items marked `[DELETED]`**

For `plan`:

- Extract all phases with file paths and components
- Extract acceptance criteria per phase
- Extract anti-patterns (used to detect violations)

For `tickets`:

- Extract all tickets with `files` lists and `acceptance` criteria

### Phase 3: Spawn code-archaeologist for coverage check

Spawn agent `refinery:code-archaeologist` (in **drift-detection mode** per §12.4 spec) with:

- Inventory of items to check
- Instruction to locate implementing code via Glob/Grep, classify each item, gather evidence

Classifications:

| Class | Meaning |
|-------|---------|
| `IMPLEMENTED` | Code exists and matches the requirement |
| `PARTIAL` | Code exists but doesn't fully satisfy (e.g., missing edge case) |
| `MISSING` | No implementing code found where expected |
| `DIVERGED` | Code exists but contradicts the spec (does X, spec says Y) |
| `SUPERSEDED` | Code implements a different (potentially better) approach not in the spec |

For each acceptance criterion, additionally check **test coverage** (per FR-025):

| Class | Meaning |
|-------|---------|
| `TESTED` | Corresponding test exists in `tests/`, `test/`, `*_test.go`, `*.test.ts`, etc. |
| `PARTIAL` | Partial test coverage (e.g., happy path tested, error case not) |
| `UNTESTED` | No test found |

### Phase 4: Detect undocumented behavior (reverse drift)

Spawn code-archaeologist (or extend the Phase 3 invocation) with:

- Code areas touched by the artifact's requirements (typically packages/modules/files referenced in requirements' Evidence fields)
- Instruction to identify behavior present in code but **absent from the spec**:
  - Undocumented public API endpoints/exports
  - Undocumented configuration options (env vars, config flags)
  - Undocumented error handling (exception types, error codes)
  - Undocumented dependencies (imports, services)
  - Undocumented side effects (file writes, network calls)

Per FR-026, this catches drift in the opposite direction — where code evolves faster than the spec.

### Phase 5: Generate drift report

Write to `<artifact-dir>/<artifact-basename>-check-<YYYY-MM-DD>.md` (per FR-028, AC-FR-019-1's pattern).

Frontmatter:

```yaml
---
artifact: check-report
scope: <inherited from target>
feature: <inherited>
parent: <target artifact path>
checker: code-archaeologist
last_updated: <now>
status: finalized
plugin_version: <version>
---
```

Body sections:

```markdown
# Drift Check: <target artifact title>

## Summary

| Category | Count |
|----------|-------|
| IMPLEMENTED | N |
| PARTIAL | N |
| MISSING | N |
| DIVERGED | N |
| SUPERSEDED | N |
| Undocumented behavior items | N |

**Drift status:** <NONE | DRIFTED ({M} findings)>

## Implementation Coverage

### Implemented (N)

| ID | Statement | Evidence |
|----|-----------|----------|
| FR-001 | The system shall... | src/auth.go:42-67 |

### Partial (N)

(Same table format; include "Missing aspects" column)

### Missing (N)

(Same table format; include "Where expected" column)

### Diverged (N)

(Same table format; include "Spec says" + "Code does" columns)

### Superseded (N)

(Same table format; include "Code's approach" + "Possible better" columns)

## Test Coverage

| AC ID | Status | Test File |
|-------|--------|-----------|
| AC-FR-001-1 | TESTED | tests/unit/auth.test.ts |
| AC-FR-001-2 | UNTESTED | — |

### Untested Acceptance Criteria

(Detail section listing each UNTESTED AC and a recommended test approach)

## Spec Drift (Undocumented Behavior)

For each undocumented item:

### <Item title>

**Found at:** <file:line>
**What it does:** <description>
**Why undocumented:** <missing from spec section X>
**Recommendation:** <add to spec / remove from code / explicit deferral>

## Structural Issues

- Orphan code (functions/files not referenced by any requirement)
- Contradictions between requirements (also detected during deep analysis)
- Stale evidence references (file:line citations that no longer exist)

## Recommendations (Prioritized)

1. **Address MISSING items first** (highest priority — spec promises behavior that doesn't exist)
2. **Address DIVERGED items** (spec and code disagree)
3. **Decide on SUPERSEDED items** (update spec to match code OR refactor code to match spec)
4. **Add tests for UNTESTED ACs**
5. **Add undocumented behavior to spec OR remove from code**
```

### Phase 6: Update target artifact's status

Each of the three cases below applies the status-transition procedure per `${CLAUDE_SKILL_DIR}/references/operation-bookkeeping.md §2` (case 3 only appends a Changelog row; no status change).

**Case A — drift found** (any PARTIAL, MISSING, DIVERGED, or undocumented behavior items, per FR-027):

- New status: `drifted`
- Changelog change: `Status → drifted (<N> findings)`
- Changelog reason: `Drift check found <breakdown>`
- Operation name: `check`

**Case B — no drift + target was `finalized`:**

- New status: `implemented` (optional — confirm if any user-facing ambiguity)
- Changelog change: `Status → implemented`
- Changelog reason: `Drift check confirmed full implementation`
- Operation name: `check`

> **Alternative path:** `mode-mark-implemented.md` provides a faster way to make this transition when you trust the implementation and don't need a drift check first. Use `check` when you want the archaeologist to verify; use `mark-implemented` when you just need the bookkeeping closed.

**Case C — target was already `implemented` and check is clean:**

No status change. Append a Changelog row per `${CLAUDE_SKILL_DIR}/references/document-format.md §2.3` with section `(verification)`, change `Re-checked: still implemented`, operation `check`. Atomic write per `operation-bookkeeping.md §1`.

### Phase 7: Report

```
[Refinery] check complete.
[Refinery] Wrote: <check-report-path>
[Refinery] Coverage: <I> IMPLEMENTED, <P> PARTIAL, <M> MISSING, <D> DIVERGED, <S> SUPERSEDED
[Refinery] Tests: <T> TESTED, <PT> PARTIAL, <U> UNTESTED
[Refinery] Undocumented behavior: <UB> items
[Refinery] Status transition: <prev> → <new>

Suggested next:
  /refine update <target-path> "address drift findings"   (if drifted)
  /refine review <check-report-path>                       (review the drift report itself)
  (no action needed)                                       (if clean)
```

Commit hint:

```
spec(<basename>): drift (<N> findings)    [if drift found]
spec(<basename>): check (clean)            [if no drift]
```

## Edge Cases

- **Greenfield project (no code yet):** Refuse with explanation: "Cannot check spec against codebase: no source files found. Use `/refine review` for content quality assessment instead."
- **Test infrastructure missing:** If no `tests/`, `test/`, or recognizable test files exist, skip the test-coverage section and note this in the report.
- **Multiple existing check reports for the same artifact:** Today's check overwrites only if filename collision (same date). Otherwise, multiple reports coexist as historical record.
- **Check on a `tickets` artifact whose tickets are partially complete:** Report each ticket's `status` (pending / in_progress / complete / blocked) as known from the ticket file; do not infer from code (Refinery doesn't track ticket execution state — that's the dispatcher's job).
- **Re-check after `update`:** If user runs `/refine check` immediately after `/refine update`, run normally; the previous drift report remains as historical record.

## Performance

The drift check can be expensive for large codebases. The code-archaeologist's search strategies should:

- Use Glob with specific patterns (per requirement's Evidence field as a starting point)
- Time-box each requirement (don't exhaustively search if first 3 strategies don't hit)
- Batch related searches into a single grep with multiple alternatives

In `--verbose`, log per-requirement search times to identify bottlenecks.
