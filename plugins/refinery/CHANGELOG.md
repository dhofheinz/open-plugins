# Changelog

All notable changes to the Refinery plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/). This project uses [Semantic Versioning](https://semver.org/).

## [1.2.0] — 2026-04-13

Additive release. No removals or breaking changes. Adds a terser tickets format for linear chains and reframes the commit protocol around vertical slicing.

### Added

- **Sequence-format ticket artifacts** — when the ticket dependency graph is a linear chain (every non-blocked ticket has ≤1 predecessor and ≤1 successor, single connected path), `mode-tickets` now emits a terser `format: sequence` artifact instead of the full wave machinery. No Dependency Graph ASCII, no per-wave section headers — a single `## 2. Steps` section with per-ticket bodies intact. Non-linear graphs continue to use the waves format unchanged. A new `format:` frontmatter field (`waves | sequence`) lets dispatchers read the variant without parsing the body. Specification: `references/ticket-format.md §11`.

- **Commit granularity as vertical slicing** — `references/commit-protocol.md §9` reframes commit cadence around coherent changes to the artifact graph, not per-operation bookkeeping. Defines common Refinery vertical slices (feature introduction, pipeline advancement, feature decomposition, feature shipping, drift realignment, archive), the litmus test ("could this commit be cleanly reverted to undo one coherent change?"), and names the horizontal-slicing anti-pattern that AI-assisted pipelines naturally produce. Branch vs main workflows become sub-cases of the same principle (§9.5 / §9.6).

### Changed

- **`mode-tickets` Phase 2** now instructs the ticket-architect to select format per `ticket-format.md §11`; **Phase 3** adds a format-consistency check (sequence-on-branched is invalid and triggers revision; waves-on-linear is permitted but flagged); **Phase 6** reports the format in the summary output.

- **`ticket-architect` agent** teaches both format variants with the detection rule; Quality Check list gains a format-matches-graph-shape item.

- **All 9 write-operation mode files** normalize their "Commit hint" section to reference `commit-protocol.md §9` for granularity guidance. Per-operation subject lines are retained as ingredients for a potential commit message.

- **`commit-protocol.md`** — dropped §9 "What This Reference Is NOT" (defensive meta-framing); useful bullets migrated into the file intro (no-hooks clarification, no-automation, recommendation-not-enforcement) and §7 (complementarity with external commit-execution tooling). §10 renumbered to §9.

- **`templates/tickets.md`** — adds `format: waves` default in the skeleton frontmatter plus a pointer comment to §11 for the sequence variant.

- **`references/commit-protocol.md` §1 subject-line table** — `tickets` row split into two rows for waves vs sequence formats.

### Documentation

- USER_GUIDE.md §8.2.1 (new): sequence-format explanation. §15 reference list extended.
- CHEATSHEET.md: ticket-schema note clarifies `wave: 1` for sequence; new "Tickets artifact formats" table; new "Commit granularity" section with the vertical-slice table.

## [1.1.0] — 2026-04-13

Batch of first-principles improvements informed by a full end-to-end workflow retrospective. All changes are additive — no removals or breaking changes to the document format, state machine, or user-invocable command surface.

### Added

- **`mode-mark-implemented`** — new lightweight mode (`/refine mark-implemented <path> --commit=<hash>`) that closes the implementation loop without running a drift check. Transitions `finalized → implemented`, records the shipping commit in the Changelog, and can optionally flip a tickets artifact's per-ticket bodies from `pending`/`in_progress` to `complete` via `--tickets=<path>`. Supports `--dry-run` and `--force`. Complements (rather than replaces) `mode-check`'s drift-verified transition path.

- **`references/agent-handoffs.md`** — canonical schema for the YAML handoff blocks that `spec-critic`, `code-archaeologist`, and `spec-scribe` exchange during `mode-iterate`. Defines item ID conventions (`Q-N` / `F-N` / `C-N`), coverage and consumption invariants, greenfield short-circuit, schema versioning, and backward-compat policy. Orchestrator now forwards these blocks verbatim between agents instead of paraphrasing prose.

- **`references/operation-bookkeeping.md`** — canonical procedures for the three invariants every write operation must preserve (file integrity, graph integrity, audit integrity). Covers atomic writes, status transitions, graph mutations on child creation, child-drift propagation, post-write validation, and confirmation gates. Eight mode files now cite sections here rather than inlining duplicated bookkeeping; when bookkeeping changes, one edit propagates.

- **`no_new_findings` stop condition** — fourth first-class convergence stop signal. Triggered when `spec-critic` returns all four Mode A tables empty (nothing new to flag beyond what's already tracked). Captures the case where persistent HUMAN_NEEDED items carried over from prior iterations keep the numeric stop conditions from ever firing. Selectable via `--converge-on=no_new_findings` or honored under the default `--converge-on=any`.

- **Glossary/conventions pointer-file coexistence** — when `/refine init` runs with coexist selected and detects an existing canonical `_glossary.md` or `_conventions.md` in a peer directory (typically `docs/specs/`), it writes a **pointer file** (`pointer: true`, `canonical: <path>`) in the new working directory instead of duplicating the template. Keeps a single source of truth and avoids glossary fragmentation across directories.

- **Inline `status` fast-path** — the `/refine status` default case now runs a compressed ~20-line sub-procedure directly in the orchestrator. `mode-status.md` is loaded only when `--verbose` is set (or when the fast-path encounters a validation error that needs detailed reporting). Reduces the terse status-mode context cost from ~280 lines to ~190 lines.

### Changed

- **`spec_writer_model` default** flipped from `opus` to `sonnet`. Template-filling stages (`stack`, `spec`, `feature-spec`, `plan`) now use `sonnet` by default; `principles` and `design` retain `opus` fallback because they synthesize structure from a seed idea. User config `${user_config.spec_writer_model}` still overrides both tiers.

- **`spec-critic` Mode A output** now requires a YAML handoff block after the four prose tables, keyed by `Q-N` IDs. Deduplication directive promoted from `mode-iterate`'s per-invocation prompt into the agent's own Mode A definition: don't re-list items already tracked as OPEN in the artifact's Open Questions table.

- **`code-archaeologist` Mode A output** now requires a findings + unresolved YAML block keyed by the critic's `Q-N` IDs. Coverage invariant: every researchable `Q-N` must appear exactly once across `findings[].answers` or `unresolved[].id`. No silent drops.

- **`spec-scribe` integrate output** now emits a receipt block (changes + refusals + `convergence_after`) keyed by `C-N` IDs that reference upstream `F-N` and `Q-N`. The orchestrator builds the Iteration Log entry directly from this block without re-reading the artifact.

- **`mode-iterate` Phase 2a/2b/2c/2d** rewritten to forward structured handoff blocks by ID rather than paraphrasing prose. The orchestrator validates coverage + consumption invariants and surfaces violations rather than patching silently.

- **`mode-check` Phase 6** now cross-references `mode-mark-implemented` as the alternative (faster, no drift check) path for `finalized → implemented`.

- **`references/state-detection.md §4`** priority list now recognizes the "finalized + tickets complete, not yet implemented" state and suggests `mark-implemented` or `check`.

- **`references/document-format.md §2.3`** expanded with Changelog row field conventions, bucket vocabulary (`(status)`, `(graph)`, `(propagation)`, `(ticket-status)`, `(verification)`, `(created)`), and the one-row-per-discrete-change atomicity rule.

- **All write-operation mode files** (`mode-advance`, `mode-archive`, `mode-check`, `mode-finalize`, `mode-iterate`, `mode-mark-implemented`, `mode-review`, `mode-tickets`, `mode-update`) now cite `references/operation-bookkeeping.md` for shared procedures instead of inlining status-transition, graph-mutation, child-drift, and post-write-validation boilerplate. Mode files retain their mode-specific phases (prerequisites, agent dispatch, stage execution); the bookkeeping is parameterized.

### Documentation

- USER_GUIDE.md: new §3.11 (`mark-implemented`), §11.5 (pointer files for glossary/conventions), §12.0 (structured handoffs + invariants); "ten modes" → "eleven modes" throughout.
- CHEATSHEET.md: new mode row, flag rows for `--commit`, `--tickets`, `--dry-run`; pointer-file coexistence note; stop-conditions table gains `no_new_findings` row.
- README.md: reference count updated (6 → 7); mode file count updated (10 → 11); spec-writer default model line updated.
- mode-iterate.md, convergence.md: per-stop-condition behavior documented; verbose diagnostic output extended.

### Behind-the-Scenes

- Orchestrator (`SKILL.md`) grew from ~170 to ~214 lines (still well under the 400-line NFR-P-001 budget). The bulk of the growth is the inline `status` fast-path and the structured-handoffs conventions note.
- No changes to: `references/document-format.md` state matrix, `references/ticket-format.md` schema, universal frontmatter fields, the status transition table, or any agent's intrinsic tools list.

## [1.0.0] — 2026-04-08

Initial release. See [`docs/specs/refinery.md`](../../docs/specs/refinery.md) for the formal v1.0.0 specification.

### Added

- Unified `/refine` orchestrator with 10 modes (`init`, `advance`, `iterate`, `review`, `finalize`, `check`, `tickets`, `update`, `status`, `archive`)
- Six specialist agents (`spec-writer`, `spec-critic`, `spec-scribe`, `code-archaeologist`, `requirements-interviewer`, `ticket-architect`)
- Six stage files (`principles`, `design`, `stack`, `spec`, `feature-spec`, `plan`)
- Six reference files (`document-format`, `convergence`, `requirement-syntax`, `state-detection`, `ticket-format`, `commit-protocol`)
- Nine templates (seven artifact types + `_conventions` + `_glossary`)
- Artifact graph with bidirectional parent/children references and strict ID discipline (INV-001 through INV-006)
- First-class confidence metadata + evidence citations for every tracked claim
- Iterative convergence loop with three stop conditions (`stable_count`, `low_count`, `high_confidence`)
- Drift detection in both directions (spec→code, code→spec for undocumented behavior)
- Dispatch-compatible ticket format with dependency waves, size hints, and authorized files
