# Reference: Agent Handoff Schemas

Canonical definition of the structured handoff blocks that specialist agents emit and that `mode-iterate.md` (and, where applicable, `mode-finalize.md` and `mode-review.md`) forward between agents. This file is the **single source of truth** for handoff structure.

## 1. Purpose

Specialist agents in the iterate loop exchange structured YAML blocks — not prose — when passing information downstream. A handoff block carries stable item IDs (`Q-N`, `F-N`, `C-N`) that thread across the three-agent pipeline (critic → archaeologist → scribe), enforcing two invariants:

- **Coverage.** Every item the upstream agent raised is addressed by the downstream agent — either acted on or explicitly marked unresolved. Items cannot be dropped in transit.
- **Consumption.** Every item that reached the scribe is either applied as a change or surfaced as an Open Question. Nothing is silently discarded.

The orchestrator forwards blocks **verbatim** between agents. It does not paraphrase, reorder, or editorialize. Downstream agents parse the YAML directly; they do not rely on the orchestrator's interpretation.

Agents still produce human-readable prose output — the YAML block is **appended**, not a replacement. Prose serves human review (`--verbose`) and intra-agent reasoning; YAML serves mechanical consumption and invariant-checking by the orchestrator.

## 2. Universal conventions

Every handoff block uses this wrapper:

````markdown
```yaml
handoff:
  schema_version: 1
  agent: <spec-critic | code-archaeologist | spec-scribe>
  mode: <A | B | integrate | review>
  ...agent-specific fields...
```
````

**ID conventions:**

| Prefix | Emitter | Meaning |
|--------|---------|---------|
| `Q-N` | spec-critic (Mode A) | Ambiguity item (one per row of the four Mode A tables) |
| `F-N` | code-archaeologist (Mode A) | Finding (one per answered question) |
| `C-N` | spec-scribe (integrate) | Change applied (or refused) by the scribe |
| `D-N` | spec-critic (Mode B) | Review-report finding, keyed by criticality (C-/H-/M-/L- in prose) |

IDs are **per-handoff-block**, not global. `Q-1` in iteration 2 is unrelated to `Q-1` in iteration 3 — the orchestrator discards the block after the iteration completes. Cross-block references (like "this `C-5` consumed `F-2` and `Q-3`") are valid only within a single iteration.

**Schema versioning:** bump `schema_version` on breaking changes. Agents must emit the version they support; the orchestrator refuses to forward blocks whose version it doesn't recognize.

**Verbatim forwarding:** when the orchestrator passes a block to a downstream agent, it passes the block **exactly** — no reformatting, no prose summary, no reordering. This is the whole point. Downstream agents parse the YAML directly; they do not rely on the orchestrator's interpretation.

## 3. Critic Mode A handoff (spec-critic → orchestrator → archaeologist + scribe)

Emitted by `refinery:spec-critic` when invoked in **Mode A** (ambiguity report, used by `mode-iterate` Phase 2a). Appended after the four markdown tables.

```yaml
handoff:
  schema_version: 1
  agent: spec-critic
  mode: A
  no_new_findings: <true|false>   # true iff the four item-arrays below are ALL empty
  items:
    - id: Q-1
      category: RESEARCHABLE       # one of: RESEARCHABLE | HUMAN_NEEDED | DERIVABLE | OUT_OF_SCOPE
      question: "<the question, verbatim>"
      target_section: "<where in the spec; e.g. 'FR-005', '§3.2', 'Open Questions'>"
      search_strategy: "Glob: src/**/*.ts ; Grep: 'AuthProvider'"   # RESEARCHABLE only; null otherwise
      already_tracked_as: "OQ-007"  # if this mirrors an existing OPEN question; null if new
      reasoning: "<short why-this-category; optional>"
    - id: Q-2
      category: HUMAN_NEEDED
      question: "<...>"
      target_section: "<...>"
      search_strategy: null
      already_tracked_as: null
      why_human: "<short; e.g. 'business policy decision'>"
    # ... up to ~20 items typical
```

**Invariants:**

- `no_new_findings == (items is empty)` — the boolean is computable from `items`, but emitted explicitly so the orchestrator can check without parsing the whole array.
- Every `RESEARCHABLE` item MUST have a non-null `search_strategy`.
- Every `HUMAN_NEEDED` item MUST have a non-null `why_human`.
- `target_section` is never null (use `"unclassified"` if genuinely unplaceable).

**How the orchestrator uses it:**

- `mode-iterate` Phase 2a: read `no_new_findings` directly for the stop-condition check; extract all `category: RESEARCHABLE` items as input to the archaeologist.
- Phase 2c: forward the entire block to the scribe as one of its two structured inputs.

## 4. Archaeologist Mode A handoff (archaeologist → orchestrator → scribe)

Emitted by `refinery:code-archaeologist` when invoked in **Mode A** (research output for `mode-iterate` / `mode-finalize`). Appended after the per-question prose.

```yaml
handoff:
  schema_version: 1
  agent: code-archaeologist
  mode: A
  findings:
    - id: F-1
      answers: [Q-1, Q-3]         # critic question IDs this finding resolves (zero or more)
      confidence: HIGH             # HIGH | MEDIUM | LOW
      evidence:
        - {path: "src/auth/session.ts", line: 42, quote: "<optional short quote>"}
        - {path: "src/auth/session.ts", line: 118}
      statement: "<one-sentence summary of what the code shows>"
      suggested_spec_text: |
        <draft sentence or paragraph suitable for direct insertion into the spec>
      implication: "<what this means: new FR, constraint, OQ resolution, etc.>"
      new_questions:               # follow-ups surfaced during research; feed into next iteration's critic pass
        - "<short question, no ID — critic will ID them on next pass>"
    - id: F-2
      ...
  unresolved:                      # critic Q-N items that research could NOT resolve
    - id: Q-5
      reason: no_evidence_found     # no_evidence_found | research_inconclusive | out_of_scope
      notes: "<one-line; e.g. 'Grep for RateLimiter returns zero hits across src/**'>"
    - id: Q-7
      reason: research_inconclusive
      notes: "<...>"
```

**Invariants:**

- Every `Q-N` from the critic's RESEARCHABLE items must appear **exactly once**: either within some finding's `answers` array, or in `unresolved`. No silent drops.
- Every HIGH-confidence finding MUST have ≥3 items in `evidence`. MEDIUM may have 1-2. LOW may have 0 (speculative / contradictory).
- `suggested_spec_text` is optional but recommended for HIGH and MEDIUM findings; the scribe uses it verbatim when assigning a new `FR-`/`NFR-`/etc. ID.

**How the orchestrator uses it:**

- Phase 2b: receive the block, validate the "every Q-N appears exactly once" invariant. If violated, refuse and surface to user (this is a research-completeness failure, not a coverage decision).
- Phase 2c: forward verbatim to the scribe alongside the critic's block.

**Greenfield short-circuit:** if the project has no relevant source code, the archaeologist emits a block with `findings: []` and an `unresolved` entry for every critic `Q-N` where `reason: no_evidence_found` and `notes: "greenfield or no relevant files"`. The scribe then moves them all to HUMAN_NEEDED in Open Questions.

## 5. Scribe integrate handoff (scribe → orchestrator)

Emitted by `refinery:spec-scribe` when invoked in **integrate mode** (`mode-iterate` Phase 2c). Appended after the artifact Edit/Write operations. This block is a **receipt**: it tells the orchestrator what changed so the orchestrator can update the iteration log and verify coverage without re-reading the whole artifact.

```yaml
handoff:
  schema_version: 1
  agent: spec-scribe
  mode: integrate
  iteration: <N>
  changes:
    - id: C-1
      kind: add_requirement        # add_requirement | add_open_question | resolve_open_question | move_to_oq | modify | mark_deleted
      consumed_from: [F-1, Q-3]    # upstream handoff IDs this change acted on
      target_section: "FR-008"
      new_id: FR-008                # null when kind is modify/mark_deleted (no new ID)
      confidence: High              # High | Medium | Low
      summary: "Add FR-008: session token refresh at 80% TTL"
      evidence: [{path: "src/auth/session.ts", line: 118}]
    - id: C-2
      kind: resolve_open_question
      consumed_from: [F-2]
      target_section: "Open Questions"
      new_id: null
      resolved_oq_id: OQ-004        # the OQ transitioned OPEN → RESOLVED
      confidence: High
      summary: "OQ-004 resolved: rate-limit lives in middleware layer"
      evidence: [{path: "src/middleware/rate-limit.ts", line: 12}]
    - id: C-3
      kind: move_to_oq
      consumed_from: [Q-5]          # critic HUMAN_NEEDED item
      target_section: "Open Questions"
      new_id: OQ-012                # newly assigned OQ ID
      confidence: null              # OQs have no confidence
      summary: "Q-5 added as HUMAN_NEEDED OQ-012 (policy decision required)"
      evidence: []
  refusals:
    - id: C-4
      kind: refuse
      consumed_from: [Q-8]
      reason: would_violate_INV-004 # would_violate_INV-NNN | ambiguous_resolution | conflicting_evidence
      surfaced_as: OQ-013           # refusal is always surfaced as a new OQ, never silently dropped
      notes: "Suggested spec text reused deleted ID FR-003; reraised as OQ-013"
  convergence_after:
    open_questions_count: <N>
    high_confidence_ratio: <R>
    questions_stable_count: <N>
    high_count: <N>
    medium_count: <N>
```

**Invariants:**

- Every upstream handoff ID (`F-N` from the archaeologist, `Q-N` from the critic) MUST appear in exactly one of: `changes[].consumed_from`, `refusals[].consumed_from`. No silent drops, no double-consumption.
- Every refusal MUST have `surfaced_as: OQ-NNN` — refusals never disappear; they become Open Questions for the human.
- `convergence_after` values match the frontmatter the scribe wrote. The orchestrator uses these directly (no recount needed).

**How the orchestrator uses it:**

- Phase 2c: consume `convergence_after` for the stop-condition check (avoids a re-read of the artifact).
- Phase 2c: build the iteration-log entry from `changes` (group by kind for the "Resolved / Added / New questions" lines).
- Phase 2c: verify the no-silent-drops invariant; if violated, log the discrepancy and surface to the user.

## 6. Mode B handoffs (review / drift)

The review (`mode-review.md`) and drift-check (`mode-check.md`) flows use Mode B variants of the critic and archaeologist. Their handoff schemas are documented alongside those modes, not here. This file covers the iterate-loop handoffs only (the high-churn path).

Future mode-review / mode-check structured handoffs will bump `schema_version` if they require a breaking change to shared fields.

## 7. Backward compatibility during schema evolution

When `schema_version` changes:

- The orchestrator keeps the old version's parser for one release.
- Agents emit the new version immediately.
- Mode files MUST declare which versions they accept.
- On version mismatch, the orchestrator refuses the handoff and reports to the user (rather than guessing). This matches Refinery's general "never silently drop" discipline.

## 8. Performance note

The YAML block adds ~5–15 lines per handoff (assuming 10–20 items). In a typical iterate run (critic + archaeologist + scribe), that's ~30–45 extra lines of structured output — trivial next to the per-agent prose, and more than offset by letting the orchestrator stop paraphrasing. Net effect on orchestrator context is lower, not higher.

The structured blocks also make it feasible to run the entire iterate loop with the orchestrator's main context carrying only the YAML (not the prose), if the user passes a future `--terse-handoffs` flag — deferred for now, but the schema supports it.
