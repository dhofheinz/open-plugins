# Mode: review

**Purpose:** Read-only quality assessment of an artifact. Produces a structured review report at a sibling path. Does **not** modify the target artifact (per FR-017, AC-FR-017-1).

## Inputs

- Target artifact path (required first argument)

## Procedure

### Phase 1: Validate target

Read the target artifact. Validate:

- File exists and is a valid Refinery artifact (frontmatter parses, `artifact:` field present)
- Artifact type is one of: `principles`, `design`, `stack`, `spec`, `feature-spec`, `plan`, `tickets`

If validation fails, report and exit (no review report written).

### Phase 2: Spawn spec-critic for assessment

Spawn agent `refinery:spec-critic` via the `Agent` tool with:

- Full target artifact content
- Output mode: **Mode B (Review Report)** — structured quality assessment per §8.4 / FR-018
- Reference: the agent should consult `${CLAUDE_SKILL_DIR}/references/requirement-syntax.md` for the quality checklist

The review report covers:

1. **Structural completeness** — required sections present? frontmatter complete? universal sections (Open Questions, Iteration Log, Changelog) present?
2. **Requirement quality scoring** — each tracked requirement scored on 5 dimensions:
   - Atomicity (one requirement per item)
   - EARS compliance (uses one of the six patterns)
   - Specificity (no weasel words; concrete thresholds)
   - Testability (could a test verify this?)
   - Necessity (traces to a stated need)
3. **Acceptance criteria coverage** — each AC scored on:
   - Structure (Given/When/Then form)
   - Preconditions (atomic, listed)
   - Single action (one When per AC)
   - Determinism (same Given+When → same Then)
   - Coverage (positive, negative, boundary, error cases)
4. **Codebase alignment** — does the artifact respect actual architecture? (the critic does NOT research; alignment is assessed against any cited evidence)
5. **Risk assessment** — categorized as Critical / High / Medium / Low

### Phase 3: Write report

Write the report to `<artifact-dir>/<artifact-basename>-review-<YYYY-MM-DD>.md` (per FR-019, AC-FR-019-1).

Frontmatter:

```yaml
---
artifact: review-report
scope: <inherited from target>
feature: <inherited>
parent: <target artifact path>
reviewer: spec-critic
last_updated: <now>
status: finalized
plugin_version: <version>
---
```

Body sections (per FR-018):

```markdown
# Review: <target artifact title>

## Overall Assessment

| Dimension | Score (1-5) | Notes |
|-----------|-------------|-------|
| Structural completeness | 5 | All required sections present |
| Requirement quality (avg) | 4 | 12 requirements, mean atomicity 4.5 |
| Acceptance criteria coverage | 3 | Some FRs have only happy-path ACs |
| Codebase alignment | 4 | Most evidence cites valid file:line; 2 stale references |
| Risk profile | Medium | 1 High finding, 4 Medium |

**Overall:** <one-line summary>

## Strengths

- <thing the artifact does well>
- ...

## Critical Findings

(C-1, C-2, ... — each Critical finding blocks finalization until addressed)

### C-1: <Title>

**Where:** <section / FR-NNN reference>
**What:** <description>
**Why critical:** <reason>
**Recommendation:** <what to do>

## High-Priority Findings

(H-1, H-2, ...)

## Medium-Priority Findings

(M-1, M-2, ...)

## Low-Priority Findings

(L-1, L-2, ...)

## Requirement-Level Detail

| ID | Atomicity | EARS | Specificity | Testability | Necessity | Notes |
|----|-----------|------|-------------|-------------|-----------|-------|
| FR-001 | 5 | 5 | 4 | 5 | 5 | "Within 200ms" is concrete |
| FR-002 | 3 | 4 | 2 | 3 | 5 | Compound: split "validate AND store" |
| ... |

## Acceptance Criteria Coverage

| AC ID | Structure | Preconditions | Single Action | Determinism | Coverage | Notes |
|-------|-----------|--------------|---------------|-------------|----------|-------|
| AC-FR-001-1 | 5 | 5 | 5 | 5 | 4 | No negative case |
| ... |

## Recommendations (Prioritized)

1. **Address Critical finding C-1 before finalize** — <description>
2. ...

## Open Questions
(empty — review reports don't accumulate questions)

## Iteration Log
### Iteration 0 — Initial review (YYYY-MM-DD)
- **Created via:** review
- **Source:** <target artifact path>

## Changelog
| Date | Section | Change | Reason | Operation |
|------|---------|--------|--------|-----------|
| YYYY-MM-DD | (created) | Initial review | <target> reviewed | review |
```

### Phase 4: Optionally suggest target status update

If the target's current status is `draft` or `iterating` AND the review found **no Critical findings**:

- AskUserQuestion: "Review found no Critical findings. Transition target's status from `<current>` to `reviewed`?"
- Options: "Yes (update status)" / "No (keep current status)"

If user accepts, update the target's frontmatter `status` to `reviewed`, append a Changelog entry, and write atomically.

This is the **only** target modification this mode performs, and it is gated on user confirmation.

### Phase 5: Report

Report (terse):

```
[Refinery] review complete.
[Refinery] Wrote: <review-report-path>
[Refinery] Overall assessment: <score>/5
[Refinery] Findings: <C> Critical, <H> High, <M> Medium, <L> Low
[Refinery] Top recommendations:
[Refinery]   1. <top recommendation>
[Refinery]   2. <next>
[Refinery]   3. <next>

Suggested next:
  /refine update <target-path> "<change>"   (address findings; see review for prioritized list)
  /refine finalize <target-path>            (close open questions; recommended after addressing Critical/High)
  /refine iterate <target-path>             (more research before finalize, if convergence not reached)
```

Commit hint:

```
spec(<basename>): review report <YYYY-MM-DD>
```

## Edge Cases

- **Artifact has Critical findings but user wants to finalize anyway:** `mode-finalize.md` will independently re-check and refuse if critical issues remain. The review's recommendation is advisory; the finalize gate is enforced.
- **Re-review of an already-reviewed artifact:** Generates a new report with today's date in the filename (no overwrite). Multiple review reports can coexist.
- **Review on a `tickets` artifact:** Same flow, but the quality checklist focuses on ticket integrity (per `references/ticket-format.md §9`): no dangling depends_on, no circular deps, all spec items mapped, sizes assigned, files exhaustive.

## Performance

Loads: orchestrator + this mode (~110) + spec-critic agent (which forks its own context). Output is the review report file; this mode's context stays clean.
