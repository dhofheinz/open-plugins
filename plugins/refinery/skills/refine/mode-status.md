# Mode: status

**Purpose:** Read-only report of the current pipeline state with a suggested next action. Produces no file changes (per FR-040).

## Inputs

- None (operates on the working directory; respects `--output-dir` and `${user_config.working_directory}`)

## Procedure

### Phase 1: Scan working directory

Per the algorithm in `${CLAUDE_SKILL_DIR}/references/state-detection.md` (frontmatter-only reads, no body parsing).

Build the artifact graph: every `*.md` in the working directory (recursively) whose frontmatter contains an `artifact:` field becomes a graph node.

If the working directory does not exist, report "no working directory" and suggest `/refine init`.

### Phase 2: Detect pipeline gaps

Define the **expected pipeline** based on which artifacts exist:

- If any artifact has `scope: system` → expected = `[principles, design, stack, spec, plan, tickets]` plus any feature-specs as siblings
- If only feature-spec artifacts exist → expected per-feature = `[feature-spec, plan?, tickets?]`
- If working dir is empty → no pipeline (user has not started)

For each stage in the expected pipeline:

- If the stage's artifact is missing → flag `missing_stage(stage)`
- If the artifact exists but `status in {draft, iterating}` → flag `incomplete_stage(stage, status)`
- If `status == drifted` → flag `drifted_stage(stage)`

For nested feature-specs (per OQ-010), traverse `children:` recursively and apply the same checks per-feature.

### Phase 3: Detect drift and staleness

For each artifact:

- If `status == drifted` → collect for the Drift section
- If `last_updated < parent.last_updated` → mark "potentially stale" (suggest re-iteration)
- If `status in {archived, superseded}` but children exist with non-terminal status → flag inconsistency

### Phase 4: Detect open work

For artifacts with `status == iterating` or `reviewed` and `open_questions_count > 0`:

- List as "in progress, has open questions"
- Show the count

### Phase 5: Format report

Print a structured report:

```
REFINERY STATUS
===============

Working directory: <path>
Artifacts: <N> total (<breakdown by type>)

Pipeline:
  Stage 1: principles    [✓ finalized]    docs/refinery/<project>-principles.md
  Stage 2: design        [✓ finalized]    docs/refinery/<project>-design.md
  Stage 3: stack         [⚠ iterating]    docs/refinery/<project>-stack.md (3 OQ, ratio 0.71)
  Stage 4: spec          [✗ missing]
  Stage 5: plan          [✗ missing]

Features:
  user-auth              [✓ finalized]    docs/refinery/features/user-auth-spec.md
                         └─ user-auth-mfa [⚠ draft]   docs/refinery/features/user-auth/mfa-spec.md
  records                [⚠ drifted]      docs/refinery/features/records-spec.md
                                          (last check: 2026-04-10, 4 MISSING + 2 DIVERGED)

Drift:
  records                Last check found 4 MISSING + 2 DIVERGED items.

Open Work:
  <project>-stack         3 open questions, high_confidence_ratio: 0.71

Suggested next:
  /refine iterate docs/refinery/<project>-stack.md   (3 open questions, ready to converge)
  /refine update docs/refinery/features/records-spec.md "address drift"
  /refine --stage=spec                                (advance pipeline)
```

Status indicators:

| Symbol | Meaning |
|--------|---------|
| `✓` | finalized or implemented |
| `⚠` | draft, iterating, reviewed, drifted, or stale |
| `✗` | missing |
| `■` | archived or superseded (terminal) |

### Phase 6: Suggested next action

Apply the priority order in `${CLAUDE_SKILL_DIR}/references/state-detection.md §4`:

1. Validation errors → suggest fix
2. Terminal artifacts with active children → suggest retargeting
3. Drifted artifacts → suggest update
4. Incomplete stages → suggest iterate/review/finalize as appropriate
5. Missing stages → suggest advance
6. Finalized plan/spec without tickets → suggest tickets generation
7. Implemented without recent check → suggest check
8. Otherwise → "pipeline is healthy; no action suggested"

Print the highest-priority suggestion(s) at the bottom of the report (1–3 suggestions).

### Phase 7: Exit

**No file changes.** Status mode is read-only (per FR-040 and AC-FR-040-1).

## Verbose Mode

In `--verbose`, additionally print:

- Per-artifact convergence metrics (`stable_count`, `open_questions_count`, `high_confidence_ratio`)
- Per-artifact `last_updated` and time-since-update
- Validation warnings (frontmatter parse errors, dangling references, INV-001 violations)
- Discovered nested feature hierarchies as a tree
- Suggested-next-action priority ranking (which rule fired)

## Performance

Per NFR-P-002, `/refine status` invocation must stay under 600 lines of total context. The orchestrator is ~170 lines; this mode file is ~110 lines; per-artifact frontmatter reads are ~30 lines each. Comfortable for projects with up to ~10 artifacts; larger projects may approach the limit but remain functional.
