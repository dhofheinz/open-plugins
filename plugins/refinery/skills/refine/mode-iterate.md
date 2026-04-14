# Mode: iterate

**Purpose:** Run a convergence research loop on an artifact. For each iteration: identify ambiguities, research them in the codebase, integrate findings, and re-evaluate. Stops when convergence reached or max iterations hit.

## Inputs

- Target artifact path (required first argument)
- Optional `--max-iterations=<N>` (default 5; minimum 2)
- Optional `--converge-on=<criterion>` (default `any`; values: `any`, `stable_count`, `low_count`, `high_confidence`, `no_new_findings`)

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

Structured handoffs are the backbone of this phase. Each agent emits a YAML block keyed by stable item IDs (`Q-N`, `F-N`, `C-N`); the orchestrator forwards those blocks **verbatim** to downstream agents. See `references/agent-handoffs.md` for full schemas and invariants.

#### Phase 2a: Analyze ambiguities (spec-critic)

Spawn agent `refinery:spec-critic` via the `Agent` tool with:

- Full target artifact content
- Instruction to identify gaps, ambiguities, unclear items
- Output mode: **Mode A (Ambiguity Report)** — categorized as RESEARCHABLE / HUMAN_NEEDED / DERIVABLE / OUT_OF_SCOPE (see agent prompt for the full schema)

Receive the response. The agent emits prose tables **plus** a YAML handoff block (per `references/agent-handoffs.md §3`) at the end of its output. Extract the block; do not paraphrase.

Read `handoff.no_new_findings` directly from the block for the Phase 2e stop-condition check. `no_new_findings == true` iff `handoff.items` is empty — this is the critic's explicit "nothing new to add" signal and is independent of `open_questions_count`.

Extract `handoff.items[*]` where `category: RESEARCHABLE` as input to Phase 2b. Preserve each item's `id` exactly (`Q-1`, `Q-2`, …) — downstream agents reference them by string match.

#### Phase 2b: Research codebase (code-archaeologist)

If `handoff.items` contains any `category: RESEARCHABLE` entries:

- Spawn agent `refinery:code-archaeologist` via the `Agent` tool with:
  - The **verbatim** critic Mode A handoff block (YAML). Do not reformat, reorder, or summarize.
  - Project root path
  - Instruction to research each RESEARCHABLE `Q-N` and emit a Mode A handoff block per `references/agent-handoffs.md §4`

- Receive the response. Extract the archaeologist's YAML handoff block.

- **Validate the coverage invariant:** every critic `Q-N` with `category: RESEARCHABLE` must appear **exactly once** across `handoff.findings[].answers` and `handoff.unresolved[].id`. If violated, refuse — do not continue to Phase 2c. Surface the discrepancy to the user with the specific `Q-N` IDs that were dropped or double-counted.

If the project has **no relevant code** (greenfield, archaeologist returns `findings: []` and an `unresolved` entry for every RESEARCHABLE `Q-N` with `reason: no_evidence_found`):

- The scribe will reclassify these to HUMAN_NEEDED in Phase 2c (no orchestrator-side reclassification needed — the handoff carries the information).
- Continue to Phase 2c with the greenfield handoff block as-is.

If `handoff.items` contained no RESEARCHABLE entries, skip this phase entirely. In that case, Phase 2c receives only the critic's block (no archaeologist block).

#### Phase 2c: Integrate findings (spec-scribe)

Spawn agent `refinery:spec-scribe` via the `Agent` tool with:

- Current target artifact content
- **Verbatim** critic Mode A handoff block (from Phase 2a)
- **Verbatim** archaeologist Mode A handoff block (from Phase 2b; or the sentinel `findings: []` block if Phase 2b was skipped)
- Instruction to integrate per `references/agent-handoffs.md §5`: consume every `F-N` and every `Q-N` exactly once (via `changes[].consumed_from` or `refusals[].consumed_from`), preserve structure, track changes via Changelog, recompute convergence

Receive the response. Extract the scribe's integrate handoff block (YAML).

The scribe has already written the artifact. **Validate the consumption invariant:** every `F-N` from Phase 2b and every `Q-N` from Phase 2a must appear in exactly one of `changes[].consumed_from` or `refusals[].consumed_from`. If violated, log the discrepancy, surface to user, but do not un-do the scribe's write — the artifact is the source of truth; the handoff block is a receipt.

Build the Iteration Log entry directly from the scribe's handoff block (no re-read of the artifact needed):

- **Researched:** derived from `handoff.changes[]` where `consumed_from` contains `F-N` IDs → join the archaeologist findings' `statement` fields
- **Resolved:** count of `changes[].kind == resolve_open_question` plus the resolved OQ IDs
- **Added:** count of `changes[].kind == add_requirement` split by `confidence` (High vs Medium)
- **New questions:** count of `changes[].kind == move_to_oq` plus `refusals[].surfaced_as`
- **Still open:** `convergence_after.open_questions_count`
- **Convergence:** `stable_count=<convergence_after.questions_stable_count>, open=<convergence_after.open_questions_count>, ratio=<convergence_after.high_confidence_ratio>`

Append the entry (per `references/convergence.md §6` format):

```markdown
### Iteration N (YYYY-MM-DD)
- **Operation:** iterate
- **Researched:** <from scribe handoff changes[] + archaeologist F-N statements>
- **Resolved:** <N questions → High Confidence: FR-X, FR-Y, ...>
- **Added:** <N High, N Medium confidence items>
- **New questions:** <N discovered>
- **Still open:** <N questions remain>
- **Convergence:** stable_count=N, open=N, ratio=N.NN
```

#### Phase 2d: Recompute convergence

The scribe's integrate handoff block already carries `convergence_after` (computed by the scribe from the artifact body it just wrote). Use those values directly rather than re-reading the artifact:

- `open_questions_count` ← `handoff.convergence_after.open_questions_count`
- `high_confidence_ratio` ← `handoff.convergence_after.high_confidence_ratio`
- `questions_stable_count` ← `handoff.convergence_after.questions_stable_count`

The scribe is responsible for applying the §2.1 rule (`stable_count` increments when `open_questions_count` is unchanged from the previous iteration; resets to 0 otherwise) — it has access to the previous frontmatter and the new count.

If you disagree with the scribe's values (e.g., they appear inconsistent with the critic/archaeologist blocks), do **not** silently overwrite — log the discrepancy and surface to the user. The scribe's write is authoritative; this check is a sanity layer, not a correction mechanism.

#### Phase 2e: Check stop conditions

- If `iteration_count < 2` → continue (minimum-iterations floor)
- If `iteration_count == max_iterations` → stop with reason `max_iterations`
- Otherwise check stop conditions per `--converge-on`:
  - `--converge-on=any` (default): stop if **any** of the four conditions hold
  - `--converge-on=stable_count`: stop only if `questions_stable_count >= 2`
  - `--converge-on=low_count`: stop only if `open_questions_count <= 3`
  - `--converge-on=high_confidence`: stop only if `high_confidence_ratio > 0.80`
  - `--converge-on=no_new_findings`: stop only if the critic reported zero new items this iteration (`no_new_findings == true` from Phase 2a)
- If a stop condition met → stop with the matching reason (`stable_count`, `low_count`, `high_confidence`, or `no_new_findings`)

If continuing, increment `iteration_count` and loop.

**Why `no_new_findings` is a first-class stop condition:** the three numeric conditions (`stable_count`, `low_count`, `high_confidence`) can all fail simultaneously when a prior iteration queued HUMAN_NEEDED items in Open Questions — those items keep `open_questions_count` above the low-count threshold and keep the ratio denominator non-zero, even though the critic has nothing new to add. The critic's own "zero new findings" signal captures that situation directly.

### Phase 3: Transition status

Apply the status-transition procedure per `${CLAUDE_SKILL_DIR}/references/operation-bookkeeping.md §2`, with these parameters:

- **New status:** `reviewed`
- **Additional frontmatter:** `iteration` = latest iteration count (the final N after the loop); `convergence` reflects the scribe's last `convergence_after` block
- **Changelog change:** `Status → reviewed (i<N>)`
- **Changelog reason:** `Iterate loop converged: stop reason <stop_reason>`
- **Operation name:** `iterate (i<N>)`

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

Commit hint per `${CLAUDE_SKILL_DIR}/references/commit-protocol.md` (see §9 on commit granularity for when to bundle):

```
spec(<basename>): iterate (i<N>)
```

## Verbose Mode

In `--verbose`, after each iteration print the per-iteration diagnostics from `references/convergence.md §10`.

## Edge Cases

- **No critic ambiguities found** (artifact is already crisp): integrate empty findings. If `open_questions_count == 0`, convergence ratio jumps to 1.0 (triggers `high_confidence`). If `open_questions_count > 0` because of carried-over HUMAN_NEEDED items, the `no_new_findings` condition triggers instead. Either way the loop stops after the iteration-2 minimum under `--converge-on=any`.
- **All ambiguities are HUMAN_NEEDED** (nothing researchable): skip Phase 2b; integrate empty findings + add to Open Questions; convergence stable_count likely reaches 2 within 2-3 iterations as the same items persist.
- **Archaeologist discovers contradictory evidence**: scribe records it in the artifact body with `Confidence: Low` and adds an Open Question; do not auto-resolve.
- **Scribe refuses an integration** (e.g., the change would violate INV-004 by reusing a deleted ID): log the refusal in the iteration log; surface as an Open Question for the human; continue.
- **Interrupted loop** (per OQ-006 implicit resume): next `/refine iterate <path>` invocation reads the current `iteration: N` and continues from `N+1`. No special "resume" mode needed.
- **Already at status `finalized`**: refuse with message "Cannot iterate on a finalized artifact. Use `/refine update` for traceable changes."

## Performance

This mode loads: orchestrator (~200) + this mode file (~180) + spec-critic agent + code-archaeologist agent + spec-scribe agent. Each agent forks its own context (per the Agent tool semantics) and returns structured YAML handoff blocks plus prose.

The structured-handoff protocol (per `references/agent-handoffs.md`) keeps the orchestrator's context footprint approximately constant across iterations: the orchestrator forwards YAML blocks verbatim to downstream agents rather than re-paraphrasing the prose. The prose remains available for human review in `--verbose` mode but is not carried forward through the pipeline.
