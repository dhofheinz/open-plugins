# Changelog

All notable changes to the Refinery plugin are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/). This project uses [Semantic Versioning](https://semver.org/).

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
