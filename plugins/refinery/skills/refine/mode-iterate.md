# Mode: iterate

**Purpose:** Run a convergence research loop on an artifact. For each iteration: identify ambiguities, research them in the codebase, integrate findings, and re-evaluate. Stops when convergence reached or max iterations hit.

## Inputs

- Target artifact path (required first argument)
- Optional `--max-iterations=<N>` (default 5; minimum 2)
- Optional `--converge-on=<criterion>` (default `any`; values: `any`, `stable_count`, `low_count`, `high_confidence`)

## Procedure

### Phase 1: Validate target

Read target artifact's frontmatter.

- Validate the artifact exists and is parseable
- Validate `status` is in `{draft, iterating, reviewed}` per §10.2
- If status is invalid for `iterate`, refuse and explain (e.g., "cannot iterate on `archived` artifact")

If status was `draft` or `reviewed`, transition it to `iterating` and write the frontmatter update.

### Phase 2: Iteration loop

Iteration counter starts at the artifact's current `iteration` field + 1 (per §11.2.3 implicit-resume semantics — see `references/convergence.md §8`).

```
WHILE iteration_count < max_iterations:
```

#### Phase 2a: Analyze ambiguities (spec-critic)

Spawn agent `refinery:spec-critic` via the `Agent` tool with:

- Full target artifact content
- Instruction to identify gaps, ambiguities, unclear items
- Output mode: **Mode A (Ambiguity Report)** — categorized as RESEARCHABLE / HUMAN_NEEDED / DERIVABLE / OUT_OF_SCOPE (see agent prompt for the full schema)

Receive the ambiguity report. Parse the four categories.

#### Phase 2b: Research codebase (code-archaeologist)

If any RESEARCHABLE items in the report:

- Spawn agent `refinery:code-archaeologist` via the `Agent` tool with:
  - The RESEARCHABLE items and their suggested search strategies
  - Project root path
  - Instruction to research and report findings with confidence levels (HIGH/MEDIUM/LOW per the agent's standard format)

- Receive findings report.

If the project has **no relevant code** (greenfield, archaeologist returns "no relevant files found"):

- Reclassify all RESEARCHABLE items in this iteration to HUMAN_NEEDED (they'll surface in the Open Questions section for the human-review phase)
- Continue to Phase 2c with an empty findings report

If no RESEARCHABLE items, skip this phase entirely.

#### Phase 2c: Integrate findings (spec-scribe)

Spawn agent `refinery:spec-scribe` via the `Agent` tool with:

- Current target artifact content
- Findings report from the archaeologist (may be empty)
- Original ambiguity report (for HUMAN_NEEDED items to remain in Open Questions)
- Instruction to update the artifact preserving structure, tracking changes via Changelog, recalculating convergence

Receive the updated artifact + change summary.

Write the updated artifact (atomic write per NFR-R-004).

Append an Iteration Log entry (per `references/convergence.md §6` format):

```markdown
### Iteration N (YYYY-MM-DD)
- **Operation:** iterate
- **Researched:** <topics from archaeologist>
- **Resolved:** <N questions → High Confidence: FR-X, FR-Y, ...>
- **Added:** <N High, N Medium confidence items>
- **New questions:** <N discovered>
- **Still open:** <N questions remain>
- **Convergence:** stable_count=N, open=N, ratio=N.NN
```

#### Phase 2d: Recompute convergence

Recalculate from the new artifact (per `references/convergence.md §2`):

- `open_questions_count` = count of OPEN entries in Open Questions table (NEW status counted as OPEN per §2.2)
- `high_confidence_ratio` = `high_count / (high_count + medium_count + open_questions_count)`
- `questions_stable_count`:
  - If `open_questions_count` unchanged from previous iteration → `previous_stable_count + 1`
  - Otherwise → `0`

Update the frontmatter `convergence` block. Atomic write.

#### Phase 2e: Check stop conditions

- If `iteration_count < 2` → continue (minimum-iterations floor)
- If `iteration_count == max_iterations` → stop with reason `max_iterations`
- Otherwise check stop conditions per `--converge-on`:
  - `--converge-on=any` (default): stop if **any** of the three conditions hold
  - `--converge-on=stable_count`: stop only if `questions_stable_count >= 2`
  - `--converge-on=low_count`: stop only if `open_questions_count <= 3`
  - `--converge-on=high_confidence`: stop only if `high_confidence_ratio > 0.80`
- If a stop condition met → stop with the matching reason

If continuing, increment `iteration_count` and loop.

### Phase 3: Transition status

After the loop terminates, transition status `iterating` → `reviewed` (per §10.2).

Update `last_updated` and `iteration` in frontmatter. Atomic write.

### Phase 4: Report

Report (terse):

```
[Refinery] iterate complete.
[Refinery] Iterations run: <N> (stop reason: <reason>)
[Refinery] Items resolved: <count>  (<H_delta> new High, <M_delta> new Medium)
[Refinery] Items still open: <N>  (high_confidence_ratio: <R>)
[Refinery] Status: iterating → reviewed

Suggested next:
  /refine finalize <path>             (close <N> open questions via research + AskUserQuestion)
  /refine review <path>               (formal quality assessment)
  /refine --stage=<next>              (advance pipeline; will warn if questions remain)
```

Commit hint:

```
spec(<basename>): iterate (i<N>)
```

## Verbose Mode

In `--verbose`, after each iteration print the per-iteration diagnostics from `references/convergence.md §10`.

## Edge Cases

- **No critic ambiguities found** (artifact is already crisp): integrate empty findings; convergence ratio jumps to 1.0; stop after iteration 2 (minimum).
- **All ambiguities are HUMAN_NEEDED** (nothing researchable): skip Phase 2b; integrate empty findings + add to Open Questions; convergence stable_count likely reaches 2 within 2-3 iterations as the same items persist.
- **Archaeologist discovers contradictory evidence**: scribe records it in the artifact body with `Confidence: Low` and adds an Open Question; do not auto-resolve.
- **Scribe refuses an integration** (e.g., the change would violate INV-004 by reusing a deleted ID): log the refusal in the iteration log; surface as an Open Question for the human; continue.
- **Interrupted loop** (per OQ-006 implicit resume): next `/refine iterate <path>` invocation reads the current `iteration: N` and continues from `N+1`. No special "resume" mode needed.
- **Already at status `finalized`**: refuse with message "Cannot iterate on a finalized artifact. Use `/refine update` for traceable changes."

## Performance

This mode loads: orchestrator (~170) + this mode file (~140) + spec-critic agent + code-archaeologist agent + spec-scribe agent. Each agent forks its own context (per the Agent tool semantics) and returns only the structured result, keeping the orchestrator's context clean across iterations.
