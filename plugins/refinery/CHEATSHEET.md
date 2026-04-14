# Refinery Cheat Sheet

One command. Eleven modes. Six agents. Print and pin.

## Commands at a glance

| Mode | Invocation | What it does |
|------|------------|--------------|
| (auto) | `/refine` | `status` if artifacts exist; prompts otherwise |
| init | `/refine init` | Bootstrap working directory + templates + glossary |
| advance (idea) | `/refine "<your idea>"` | Seed pipeline at `principles` |
| advance (feature) | `/refine <feature-name>` | Feature spec from intake |
| advance (explicit) | `/refine --stage=<name>` | Force advancement to a specific stage |
| iterate | `/refine iterate <path>` | Convergence research loop (≤5 iterations) |
| review | `/refine review <path>` | Quality assessment (read-only, writes report) |
| finalize | `/refine finalize <path>` | Close open questions; status → finalized |
| check | `/refine check <path>` | Drift against codebase; status → drifted if found |
| tickets | `/refine tickets <path>` | Dispatchable decomposition with dependency waves |
| update | `/refine update <path> "<change>"` | Traceable modification with Changelog entry |
| status | `/refine status` | Pipeline state report (no file changes) |
| archive | `/refine archive <path> --reason "..."` | `archived` or `superseded` (with `--as superseded --replaced-by <path>`) |
| mark-implemented | `/refine mark-implemented <path> --commit=<hash>` | `finalized → implemented`; optionally `--tickets=<path>` to flip tickets to `complete` |

## Common flags

| Flag | Modes | Effect |
|------|-------|--------|
| `--output-dir=<path>` | all | Override default working directory (`docs/refinery/`) |
| `--stage=<name>` | advance | Force a specific stage: `principles`, `design`, `stack`, `spec`, `feature-spec`, `plan` |
| `--scope=<name>` | advance | `system`, `subsystem`, `feature`, `component` |
| `--max-iterations=<N>` | iterate | Override default 5 (must be ≥ 2) |
| `--converge-on=<criterion>` | iterate | `any` (default), `stable_count`, `low_count`, `high_confidence`, `no_new_findings` |
| `--as <archived\|superseded>` | archive | Default `archived` |
| `--replaced-by <path>` | archive | Required when `--as superseded` |
| `--reason "<text>"` | archive | Required for Changelog entry |
| `--commit=<hash>` | mark-implemented | Shipping commit for provenance (strongly recommended) |
| `--tickets=<path>` | mark-implemented | Also flip a tickets artifact's per-ticket bodies to `complete` |
| `--dry-run` | archive, mark-implemented | Preview changes without writing |
| `--force` | various | Override safety checks (use sparingly) |
| `--verbose` | all | Detailed routing decisions and agent diagnostics |

## Artifact types (7)

| Type | Scope | Position | Key sections |
|------|-------|----------|--------------|
| `principles` | system | Stage 1 | Prime postulate, Hard Invariants (INV-NNN), Core Principles (P-NNN) |
| `design` | system/subsystem | Stage 2 | Subsystems, Failure Modes (FM-NNN), Second-order failures |
| `stack` | system/subsystem | Stage 3 | Tech choices with Confidence + Justification + Gotchas |
| `spec` | system | Stage 4 | FR-NNN, NFR-<CAT>-NNN, INV-NNN, RD-NNN, R-NNN, Traceability Matrix |
| `feature-spec` | feature | Stage 4 | FR-NNN, NFR-NNN, AC-FR-NNN-N (supports nested via `--parent`) |
| `plan` | system/feature | Stage 5 | Phases with components, type contracts, anti-patterns |
| `tickets` | system/feature | Stage 5 (decomposed) | T-NN with dependency waves, sizes, authorized files |

## Lifecycle states (8)

```
seed → draft → iterating → reviewed → finalized → implemented → drifted
                  ↑__________|              ↓                       |
                                         archived | superseded ←____|
```

| State | Meaning | Reachable from |
|-------|---------|----------------|
| draft | Just created | (initial) |
| iterating | In active research loop | draft, reviewed |
| reviewed | Quality assessment complete | draft, iterating |
| finalized | Open questions closed | reviewed, iterating |
| implemented | Code exists | finalized (via `check` clean) |
| drifted | `check` found code↔spec divergence | finalized, implemented |
| superseded | Replaced by newer artifact (terminal) | any non-terminal |
| archived | Retained for reference (terminal) | any non-terminal |

## Universal frontmatter (every artifact)

```yaml
---
artifact: principles | design | stack | spec | feature-spec | plan | tickets
scope: system | subsystem | feature | component
feature: <project-or-feature-name>
stage: <stage-name>
iteration: <integer ≥ 0>
last_updated: <ISO date>
status: draft | iterating | reviewed | finalized | implemented | drifted | superseded | archived
parent: <relative path or null>
children: [<paths>]
references: [<paths>]
convergence:
  questions_stable_count: <int>
  open_questions_count: <int>
  high_confidence_ratio: <float 0.0-1.0>
plugin_version: <semver>
---
```

## Universal sections (every artifact)

1. Body (per artifact type)
2. `## Open Questions` (always present, may be empty)
3. `## Iteration Log` (append-only)
4. `## Changelog` (append-only)

## Tracked claim format

```markdown
#### FR-NNN: <Title>

<EARS or RFC 2119 statement>

**Priority:** Must | Should | Could | Won't
**Confidence:** High | Medium | Low
**Evidence:** <file:line OR upstream artifact reference>
**Source:** <provenance>
**Status:** Verified | Under Review | Inferred | Deferred
```

## EARS patterns (6)

| Pattern | Form |
|---------|------|
| Ubiquitous | The system shall <action> |
| Event-Driven | When <trigger>, the system shall <action> |
| State-Driven | While <state>, the system shall <action> |
| Unwanted | If <unwanted>, then the system shall <action> |
| Optional Feature | Where <feature included>, the system shall <action> |
| Complex | When <X> and while <Y> and if <Z>, the system shall <action> (use sparingly) |

## Given/When/Then (acceptance criteria)

```gherkin
Given <precondition>
  And <additional precondition>
When <action>
Then <observable outcome>
  And <additional outcome>
```

Rules: atomic, deterministic, observable, concrete, independent.

## RFC 2119 (system specs only)

| Keyword | Meaning |
|---------|---------|
| MUST / SHALL | Absolute requirement |
| MUST NOT | Absolute prohibition |
| SHOULD | Strong recommendation; deviation requires justification |
| MAY | Truly optional |

Use uppercase RFC 2119; lowercase `shall` inside EARS patterns.

## Confidence tiers

| Tier | Required evidence |
|------|-------------------|
| High | file:line citations OR upstream artifact reference OR user-decision Changelog entry |
| Medium | Single example with note OR inferred-from note |
| Low | Item must appear in Open Questions; no evidence required |

`high_confidence_ratio = high_count / (high_count + medium_count + open_questions_count)`

## Convergence stop conditions

After ≥2 iterations, stop if **any** of:

| Condition | Threshold | Meaning |
|-----------|-----------|---------|
| Stability | `questions_stable_count >= 2` | Question count unchanged for 2 iterations |
| Low count | `open_questions_count <= 3` | Few enough for direct human review |
| High confidence | `high_confidence_ratio > 0.80` | Most claims well-supported |
| No new findings | critic returns all four Mode A tables empty | Spec-critic itself signals convergence (independent of `open_questions_count`) |

Always stops at iteration 5 (default `--max-iterations`).

## Numbering conventions

| Type | Format |
|------|--------|
| Functional Requirement | `FR-NNN` |
| Non-Functional Requirement | `NFR-<P\|S\|SC\|R\|A\|U\|M\|C>-NNN` |
| Acceptance Criterion | `AC-<REQ-ID>-N` |
| Invariant | `INV-NNN` |
| Resolved Design Decision | `RD-NNN` |
| Risk | `R-NNN` |
| Failure Mode | `FM-NNN` (design only) |
| Principle | `P-NNN` (principles only) |
| Open Question | `OQ-NNN` |
| Source Document | `SD-NNN` |
| Ticket | `T-NN` |

**Never reuse a deleted ID.** Mark deletions as `[DELETED — <reason>]`.

## Open Questions classification

| Type | Resolved by |
|------|-------------|
| RESEARCHABLE | `code-archaeologist` agent (Glob/Grep/Read) |
| HUMAN_NEEDED | `AskUserQuestion` (batched, max 4 per call) |
| DERIVABLE | Inference from other spec content |
| OUT_OF_SCOPE | Marked in Scope Boundaries; closed |

## Ticket schema (per `T-NN`)

```yaml
id: T-NN
title: <Action verb> <thing>
wave: <integer ≥ 1>                 # always 1 in sequence format
size: S | M | L | XL                # XL emits decomposition warning
layer: frontend | backend | data | infra | docs | test
depends_on: [<ticket IDs>]
blocks: [<ticket IDs>]
spec_ref: [<FR-NNN, AC-..., plan §N>]
files:
  - {path: <path>, status: NEW | MODIFY | EXISTS}
acceptance: [<independently testable assertions>]
convention_recipe: <int or null>
technical_notes: <multi-line>
anti_patterns: [<forbidden approaches>]
status: pending | in_progress | complete | blocked
```

## Tickets artifact formats

| `format:` | When used | Body structure |
|-----------|-----------|----------------|
| `waves` | Graph has parallelism (fan-in, fan-out, or disconnected subgraphs) | Summary + Dependency Graph ASCII + per-wave sections |
| `sequence` | Linear chain (every non-blocked ticket has ≤1 predecessor and ≤1 successor, single connected path) | Summary (trimmed) + single `## Steps` section, no Dependency Graph |

`mode-tickets` auto-detects. Per-ticket schema is identical across formats. Full spec: `references/ticket-format.md §11`.

## Specialist agents (6)

| Agent | Role | Default model | Tools |
|-------|------|---------------|-------|
| `refinery:spec-writer` | Authoring (all stages) | sonnet (principles/design: opus) | Read, Write, Edit, Glob, Grep, AskUserQuestion, Bash (stack only) |
| `refinery:spec-critic` | Skeptical analysis | sonnet | Read |
| `refinery:spec-scribe` | Tracked editing | sonnet | Read, Edit, Write |
| `refinery:code-archaeologist` | Codebase research | sonnet | Glob, Grep, Read |
| `refinery:requirements-interviewer` | Feature intake | sonnet | Read, Glob, Grep, AskUserQuestion |
| `refinery:ticket-architect` | Decomposition | sonnet | Read, Write |

## Key file paths

| Concept | Path |
|---------|------|
| Working directory | `docs/refinery/` (default; override per `--output-dir` or userConfig) |
| Templates | `<plugin>/skills/refine/templates/` (copied to `docs/refinery/_templates/` by `init`) |
| Project conventions | `docs/refinery/_conventions.md` (generated by `init`, customizable) |
| Project glossary | `docs/refinery/_glossary.md` (generated by `init`, populated by agents) |
| Review reports | `<artifact-dir>/<basename>-review-<YYYY-MM-DD>.md` |
| Drift reports | `<artifact-dir>/<basename>-check-<YYYY-MM-DD>.md` |

## userConfig keys

| Key | Default | Purpose |
|-----|---------|---------|
| `working_directory` | `docs/refinery/` | Default output directory |
| `spec_writer_model` | `sonnet` | Model for spec-writer agent (principles/design fall back to `opus` when unset) |
| `specialist_model` | `sonnet` | Model for the 5 specialist agents |

Set via `/plugin config refinery`. Per-invocation flags override.

## Status detection algorithm (mode-status priority)

When `/refine status` reports a suggested next, priority order:

1. Validation errors → fix first
2. Terminal artifacts with active children → archive children or update them
3. Drifted artifacts → `update`
4. Incomplete stages (draft/iterating) → `iterate`/`review`/`finalize`
5. Missing pipeline stages → `--stage=<next>`
6. Finalized plan/spec without tickets → `tickets`
7. Implemented + no recent check → `check`
8. Otherwise → "pipeline healthy"

## Commit message format

Per `references/commit-protocol.md` (citation reference; plugin does NOT execute commits):

```
spec(<artifact-basename>): <imperative summary, ≤72 chars>

<rationale>

Changelog entries:
- <date> | <section> | <change> | <reason>

Refinery-Op: <op>
Refinery-Iteration: <N>
```

## Commit granularity

Per `references/commit-protocol.md §9`: a Refinery commit represents one **vertical slice** of change to the artifact graph, not one mode operation. Common slices:

| Slice | Operations bundled | Example subject |
|-------|--------------------|-----------------|
| Feature introduction | `advance(feature-spec)` + `iterate` + `finalize` | `feat(spec): introduce <feature>` |
| Pipeline advancement | `advance(<stage>)` + `iterate` + `finalize` | `feat(spec): finalize <stage>` |
| Feature decomposition | `plan` + `tickets` | `feat(plan): decompose <feature>` |
| Feature shipping | impl commits (external) + `mark-implemented` | `feat(<area>): ship <feature>` |
| Drift realignment | `check` + `update` | `fix(spec): address drift` |
| Archive | `archive` + child propagation | `chore(spec): archive <artifact>` |

Per-operation hints are **ingredients**, not commands. Bundle at the vertical-slice boundary. Litmus test: "Could this commit be cleanly reverted to undo one coherent change?" Branch-workflow users rely on squash-on-merge; main-workflow users bundle manually. See §9 for the full framing.

## Coexistence

- Plugin namespace: `/refinery:refine` (when invoked alongside a personal `/refine` skill)
- Working dir: `docs/refinery/` (distinct from `docs/specs/`)
- Legacy artifacts: untouched; `init` offers coexistence/merge/primary
- Glossary/conventions coexistence: when canonical `_glossary.md` or `_conventions.md` exists in a peer dir, `init` writes a **pointer file** (`pointer: true`, `canonical: <path>`) rather than duplicating; agents resolve the canonical automatically

## Performance budgets

| Budget | Limit | Source |
|--------|-------|--------|
| Always-loaded orchestrator | ≤ 400 lines | NFR-P-001 (actual: ~200 incl. status fast-path) |
| `/refine status` total context (terse, default) | orchestrator only + per-artifact frontmatter (~30 lines each); fast-path is inline in SKILL.md | NFR-P-002 |
| `/refine status` total context (`--verbose`) | ≤ 600 lines (loads `mode-status.md`) | NFR-P-002 |
| Max iterations per `iterate` | 5 (configurable) | FR-013 |
| AskUserQuestion batch max | 4 questions | NFR-U-003 |
| Ticket file count default | ≤ 3 per ticket | FR-034 (exceptions documented) |
