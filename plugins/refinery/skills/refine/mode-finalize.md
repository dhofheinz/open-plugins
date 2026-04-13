# Mode: finalize

**Purpose:** Close all open questions in an artifact via a two-phase resolution: research what can be researched (never asks the user about RESEARCHABLE items per FR-021), batch-ask the user about what cannot. Transition status to `finalized`.

## Inputs

- Target artifact path (required first argument)

## Procedure

### Phase 1: Inventory unresolved items

Read the target artifact in full.

Build inventory:

- Open Questions table entries with status `OPEN` or `NEW`
- Inline markers in body: `[OPEN]`, `[TODO]`, `[TBD]`, `[ARCHITECTURE]`, `[DECISION NEEDED]`, `[?]`
- Orphan requirements (FR/NFR with no AC entries)
- Ambiguous language: requirements using "should", "may", "might", "could" where "shall" is expected (per `references/requirement-syntax.md §1.7`)
- Review findings from any sibling `<artifact-basename>-review-*.md` files (especially Critical and High-priority)

Print inventory summary (terse format):

```
[Refinery] Inventory:
[Refinery]   Open Questions: <N>
[Refinery]   Inline flags: <N>
[Refinery]   Orphan requirements: <N>
[Refinery]   Ambiguous language: <N>
[Refinery]   Review findings: <N> (Critical: <C>, High: <H>, Medium: <M>, Low: <L>)
[Refinery]   Total items: <N>
```

If there are zero items to resolve, jump to Phase 7 directly (status transition).

### Phase 2: Classify

For each item, classify:

- `RESEARCHABLE` — can be answered by reading the codebase
- `DECIDABLE` — requires user decision between concrete options
- `DERIVABLE` — can be inferred from other spec content or upstream artifacts
- `EDITORIAL` — language fix, formatting, or trivial typo

Use the `spec-critic` agent's classification logic if the items came from a prior iteration; otherwise classify directly using the heuristics in `${CLAUDE_SKILL_DIR}/references/state-detection.md` and the agent definitions.

### Phase 3: Resolve RESEARCHABLE via spawned code-archaeologist

If any RESEARCHABLE items:

- Spawn agent `refinery:code-archaeologist` with:
  - All RESEARCHABLE items + their suggested search strategies
  - Project root path
  - Instruction to research and report findings with explicit confidence levels

- Receive the findings report.

For each finding:

- If confidence is HIGH or MEDIUM → prepare a resolution edit:
  - Mark the OQ as `RESOLVED` in the Open Questions table (with research context appended)
  - Update the relevant requirement with new Confidence + Evidence
  - Flag for application in Phase 6
- If confidence is LOW → keep the OQ as `OPEN` with research context appended (the user may need to decide; reclassify to DECIDABLE)

Per FR-021, **never** ask the user a question that could be answered by reading the codebase. If research returns inconclusive, only then promote the question to DECIDABLE.

### Phase 4: Resolve DERIVABLE / EDITORIAL immediately

For each DERIVABLE item:

- Apply the inference (e.g., a default value derived from the upstream principles, a section's omitted constraint inferred from the parent design)
- Append a Changelog entry: "<date> | <section> | <change> | Derived from <source> | finalize"

For each EDITORIAL item:

- Apply the fix directly (typos, "should" → "shall" where appropriate, formatting cleanup)
- Append a Changelog entry: "<date> | <section> | <change> | Editorial fix | finalize"

These are applied without user prompt.

### Phase 5: Resolve DECIDABLE via batched AskUserQuestion

For each DECIDABLE item:

- Formulate **2-4 concrete options** with stated trade-offs (per FR-022, AC-FR-022-1)
- Include any research context that informs the options
- Never present open-ended questions; always concrete options

Batch related questions: **max 4 questions per AskUserQuestion call** (per NFR-U-003).

Sequential calls allowed when later decisions depend on earlier answers.

For each user answer:

- If answered → prepare a resolution edit (mark OQ as `RESOLVED`, apply changes)
- If deferred (user explicitly says "I need to think about this") → mark item as `[DEFERRED: <reason>]` per FR-023; do **not** leave as `[OPEN]`

### Phase 6: Apply all resolutions

Spawn agent `refinery:spec-scribe` with:

- Current target artifact content
- All accumulated edits (from Phases 3, 4, 5)
- Instruction to apply atomically, preserve structure, append Changelog entries (one per discrete change), recalculate convergence

Receive the updated artifact. Validate (per `references/document-format.md`).

Write the artifact (atomic).

### Phase 7: Verify finalization

Re-read the artifact. Verify:

- No `[OPEN]` markers remain in body (all promoted to OQ table, RESOLVED, or DEFERRED)
- No orphan requirements (every FR/NFR has at least one AC if applicable to artifact type)
- No ambiguous "should" where "shall" is expected
- Changelog complete with entry per change
- All cross-references resolve
- INV-002, INV-003 satisfied (convergence metrics match content)

If any check fails:

- For automatically-fixable issues: re-spawn spec-scribe with the specific fix request
- For human-judgment issues: surface back to the user via AskUserQuestion (treat as a new DECIDABLE) and re-loop through Phase 5-7
- Maximum 2 finalize loops; if still unresolved, refuse the finalize and report.

### Phase 8: Transition status

Transition status `<previous>` → `finalized` (per §10.2).

Update:

- `last_updated: <now>`
- `iteration: iteration` (do **not** increment for finalize)
- `convergence` recomputed
- Append a Changelog entry: "<date> | (status) | Status → finalized | <count> items resolved (<R> via research, <D> via decision, <E> editorial, <X> deferred) | finalize"

Atomic write.

### Phase 9: Report

```
[Refinery] finalize complete.
[Refinery] Items resolved via research: <R>
[Refinery] Items resolved via user decision: <D>
[Refinery] Items resolved via derivation: <V>
[Refinery] Editorial fixes applied: <E>
[Refinery] Items deferred: <X>
[Refinery] Final status: finalized

Suggested next:
  /refine --stage=<next>                  (advance pipeline)
  /refine tickets <path>                  (decompose into dispatch-compatible tickets, for plan/spec/feature-spec)
  (implementation begins)
```

Commit hint:

```
spec(<basename>): finalize
```

## Edge Cases

- **All items RESEARCHABLE; no codebase exists:** Reclassify all to DECIDABLE; surface to user via batched AskUserQuestion. Per FR-021's spirit — research is impossible, so user input becomes the only path.
- **User defers everything:** Status remains `reviewed`; no transition to `finalized`. Report the unresolved count and suggest re-running finalize after reflection time.
- **Artifact has Critical review findings still unaddressed:** Refuse the finalize. Report: "Cannot finalize: <N> Critical review finding(s) unaddressed. Run `/refine update <path>` to address, then re-finalize."
- **Already finalized:** Refuse. Suggest `/refine update <path>` for changes or `/refine iterate <path>` for additional research (which would transition status to `iterating`).

## Performance

Loads: orchestrator + this mode (~140) + code-archaeologist agent + spec-scribe agent + AskUserQuestion calls. Each agent forks; total context per finalize is moderate but spec-scribe receives the full artifact + all edits, which can be large.
