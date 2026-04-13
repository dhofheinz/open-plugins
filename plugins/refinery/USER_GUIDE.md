# Refinery User Guide

The complete user-facing guide to Refinery. For first-run, see [GETTING_STARTED.md](GETTING_STARTED.md). For quick reference, see [CHEATSHEET.md](CHEATSHEET.md). For the formal specification this plugin implements, see [docs/specs/refinery.md](../../docs/specs/refinery.md).

## Table of contents

1. [Mental model](#1-mental-model)
2. [The pipeline](#2-the-pipeline)
3. [The ten modes](#3-the-ten-modes)
4. [The document format](#4-the-document-format)
5. [The artifact graph](#5-the-artifact-graph)
6. [Confidence + Evidence discipline](#6-confidence--evidence-discipline)
7. [The convergence model](#7-the-convergence-model)
8. [The ticket format](#8-the-ticket-format)
9. [Drift detection](#9-drift-detection)
10. [Configuration via userConfig](#10-configuration-via-userconfig)
11. [Coexistence with legacy specs](#11-coexistence-with-legacy-specs)
12. [The agent system](#12-the-agent-system)
13. [Recovery procedures](#13-recovery-procedures)
14. [Troubleshooting](#14-troubleshooting)

---

## 1. Mental model

Refinery has one organizing principle: **specifications are typed nodes in a graph, not linear documents.**

Every artifact (a single `.md` file) is a node. Edges are declared in frontmatter via `parent:` and `children:`. Operations traverse the graph: changing a principle flags its descendants for re-review; finalizing a spec checks parent constraints; drift detection asks "what artifacts no longer match their parents or the codebase?"

Three more axioms:

1. **Confidence is first-class metadata.** Every requirement, invariant, design decision has a Confidence tier (High / Medium / Low) and either Evidence (file:line citations or upstream artifact references) or appears in Open Questions.

2. **Operations are state transitions on a typed state machine.** Every artifact has an explicit `status` (`draft → iterating → reviewed → finalized → implemented → drifted | superseded | archived`). Operations respect transitions; the plugin refuses invalid ones.

3. **One entry point, many workflows.** `/refine` is the only user-invocable command. It dispatches to one of ten modes based on input shape. No menu of competing commands.

---

## 2. The pipeline

The system pipeline has 5 stages. Each produces one artifact. Each derives from the previous.

```
[seed idea]
    ↓
principles  ──── axioms, invariants, scope boundaries
    ↓
design     ──── architecture, subsystems, failure modes (no tech)
    ↓
stack      ──── concrete tech choices justified against design
    ↓
spec       ──── formal RFC 2119 system requirements with traceability
    ↓
plan       ──── phased implementation with type contracts
    ↓
tickets    ──── dispatch-compatible decomposition
```

Feature-spec is **parallel** to this pipeline. It works on a single feature in an existing system:

```
[feature name]
    ↓
feature-spec ──── EARS feature requirements with codebase grounding
    ↓
plan        ──── feature-scoped phased implementation
    ↓
tickets     ──── dispatch-compatible decomposition
```

Per OQ-010, a feature-spec MAY have child feature-specs (sub-features). Pass `--parent <feature-spec-path>` to nest.

### Stage prerequisites

| Stage | Required input |
|-------|----------------|
| principles | Seed idea (text or file). No artifact prerequisite. |
| design | A `finalized` or `reviewed` principles artifact |
| stack | A `finalized` or `reviewed` design artifact |
| spec | A `finalized` or `reviewed` design artifact (stack optional but recommended) |
| feature-spec | None required (standalone OK); optional system-spec parent or feature-spec parent |
| plan | A `finalized` or `reviewed` spec or feature-spec |

If a prerequisite is missing → refused; suggested prerequisite stage. If prerequisite exists but is `draft` or `iterating` → warned; AskUserQuestion to proceed/iterate-first/review-first.

### Skipping stages

You can skip stages, but the plugin warns. Common patterns:

- **Existing codebase, no architecture docs:** skip `principles` and `design`; start with `/refine <feature-name>` for feature-specs
- **Architecture-only project:** stop at `design` or `stack`; don't generate plan/tickets
- **Spec without principles:** technically possible (`/refine --stage=spec --force`), but loses the constraint-derivation chain

---

## 3. The ten modes

### 3.1 `init` — bootstrap project conventions

```bash
/refine init
```

What it does: discovers existing spec directories (`docs/specs/`, `specs/`, etc.), creates the working directory (default `docs/refinery/`), generates `_conventions.md` and `_glossary.md`, copies templates to `_templates/`.

If existing artifacts exist, prompts for coexist (default), merge, or use as primary.

Output: working directory + 9 templates + 2 convention files.

### 3.2 `advance` — progress the pipeline

```bash
# Explicit stage
/refine --stage=design

# Seed pipeline from idea
/refine "an event-sourced billing system"

# Feature spec from name
/refine user-authentication

# Nested feature-spec
/refine user-authentication-mfa --parent docs/refinery/features/user-authentication-spec.md
```

What it does: validates prerequisites, spawns the appropriate agent (typically `spec-writer`; for feature-spec, first `requirements-interviewer` then `spec-writer`), produces a draft artifact with universal frontmatter and graph relationships set.

### 3.3 `iterate` — convergence research loop

```bash
/refine iterate docs/refinery/billing-spec.md
/refine iterate docs/refinery/billing-spec.md --max-iterations=3
/refine iterate docs/refinery/billing-spec.md --converge-on=high_confidence
```

What it does: for each iteration (≤5):
1. `spec-critic` identifies ambiguities (RESEARCHABLE / HUMAN_NEEDED / DERIVABLE / OUT_OF_SCOPE)
2. `code-archaeologist` researches RESEARCHABLE items (skipped if greenfield)
3. `spec-scribe` integrates findings, updates Open Questions, recalculates convergence

Stops when convergence stop conditions met (per §7) or max iterations hit. Status transitions to `reviewed`.

**Implicit resume:** If the loop is interrupted, re-running `/refine iterate <path>` continues from `iteration: N + 1` (the artifact's frontmatter IS the resume point per OQ-006).

### 3.4 `review` — quality assessment (read-only)

```bash
/refine review docs/refinery/billing-spec.md
```

What it does: spawns `spec-critic` in Mode B (Review Report). Produces a sibling file `<basename>-review-<YYYY-MM-DD>.md` with:

- Overall assessment (5 dimensions scored)
- Critical / High / Medium / Low findings
- Per-requirement scoring (Atomicity, EARS, Specificity, Testability, Necessity)
- Per-AC scoring (Structure, Preconditions, Single Action, Determinism, Coverage)
- Prioritized recommendations

Does **not** modify the target artifact (per FR-017).

### 3.5 `finalize` — close open questions

```bash
/refine finalize docs/refinery/billing-spec.md
```

What it does (7 phases per §11.2.5):
1. **Inventory** unresolved items (Open Questions + inline `[OPEN]/[TODO]/[TBD]` + orphan FRs + ambiguous language + review findings)
2. **Classify** each as RESEARCHABLE / DECIDABLE / DERIVABLE / EDITORIAL
3. **Resolve RESEARCHABLE** via `code-archaeologist` (per FR-021 — never asks user what code can answer)
4. **Resolve DERIVABLE / EDITORIAL** immediately
5. **Resolve DECIDABLE** via batched AskUserQuestion (max 4 questions per call, with concrete options per FR-022)
6. **Apply all resolutions** via `spec-scribe`
7. **Verify** no `[OPEN]` markers remain; transition status to `finalized`

Deferred items get `[DEFERRED: <reason>]` markers (per FR-023), never silently left as `[OPEN]`.

### 3.6 `check` — drift against codebase

```bash
/refine check docs/refinery/billing-spec.md
```

What it does: for each FR/NFR/AC, classifies implementation status (IMPLEMENTED / PARTIAL / MISSING / DIVERGED / SUPERSEDED). For each AC, additionally classifies test coverage (TESTED / PARTIAL / UNTESTED). Identifies undocumented behavior (code present but absent from spec — reverse drift).

Produces sibling file `<basename>-check-<YYYY-MM-DD>.md`.

If any drift found → status transitions `finalized → drifted`. If clean → `finalized → implemented`.

Refused for `principles`, `design`, `stack` artifacts (not directly verifiable).

### 3.7 `tickets` — dispatch-compatible decomposition

```bash
/refine tickets docs/refinery/billing-plan.md
```

What it does: spawns `ticket-architect` to decompose the plan into individually-dispatchable tickets organized into dependency waves. Each ticket has size (S/M/L/XL), authorized files (NEW/MODIFY/EXISTS), acceptance criteria, technical notes, anti-patterns.

Validates ticket integrity (no dangling deps, no cycles, full spec coverage) before writing.

Output is dual-audience: human teams use as sprint backlog; agent dispatchers use as work queue.

### 3.8 `update` — traceable modification

```bash
/refine update docs/refinery/billing-spec.md "add rate limiting requirement"
/refine update docs/refinery/billing-spec.md "remove FR-007 (covered by FR-014 now)"
```

What it does: spawns `spec-scribe` to:
1. Categorize change (Additive / Modificative / Subtractive / Corrective)
2. Assess blast radius (which sections / cross-references affected)
3. Apply with strict ID discipline (never reuse deleted IDs; mark deletions as `[DELETED]`)
4. Append Changelog entries (one per discrete change)
5. Recompute convergence

Cross-artifact propagation: if the parent has `children`, prompts whether to flag them as `drifted`.

For `finalized`/`implemented`/`drifted` targets, prompts for confirmation (per FR-005).

### 3.9 `status` — pipeline state report

```bash
/refine status
```

Read-only report. Shows artifacts table, pipeline gaps, drift indicators, suggested next action. No file changes.

Suggested-next priority order (per `references/state-detection.md §4`):

1. Validation errors → fix
2. Terminal artifacts with active children → archive/update children
3. Drifted artifacts → `update`
4. Incomplete stages → `iterate`/`review`/`finalize`
5. Missing stages → `--stage=<next>`
6. Finalized plan/spec without tickets → `tickets`
7. Implemented + no recent check → `check`
8. Otherwise → "pipeline healthy"

### 3.10 `archive` — terminal-state transition

```bash
/refine archive docs/refinery/legacy-spec.md --reason "abandoned, no longer in scope"

/refine archive docs/refinery/legacy-spec.md --as superseded \
  --replaced-by docs/refinery/system-spec.md \
  --reason "v2 redesign"
```

What it does: validates current status permits transition, prompts for confirmation if `finalized`/`implemented`, updates frontmatter (`status`, `last_updated`, optional `superseded_by`), appends Changelog entry, optionally flags children as `drifted`.

For `--as superseded`, also adds a backlink in the replacement's `references` list.

`--dry-run` previews without writing.

---

## 4. The document format

Every artifact follows a unified format. The frontmatter and trailing sections are **invariant**; the body varies by artifact type.

### 4.1 Universal frontmatter

```yaml
---
artifact: <type>                          # principles | design | stack | spec | feature-spec | plan | tickets
scope: <scope>                            # system | subsystem | feature | component
feature: <name>                           # project name (system) or feature name (feature)
stage: <name>                             # current stage being executed
iteration: <int>                          # ≥ 0; starts at 0
last_updated: <ISO date>
status: <state>                           # see Lifecycle States
parent: <relative path or null>
children: [<paths>]
references: [<paths>]                     # cross-references but doesn't own
convergence:
  questions_stable_count: <int>
  open_questions_count: <int>
  high_confidence_ratio: <float>          # 0.0 to 1.0
plugin_version: <semver>
---
```

Validation rules per `references/document-format.md §1`. Bidirectional graph integrity (INV-001): every artifact A with `parent: B` must appear in B's `children` list.

### 4.2 Universal sections

Three sections at the end of every artifact, in this order:

```markdown
## Open Questions

| ID | Question | Type | Added | Status |
|----|----------|------|-------|--------|
| OQ-001 | <question> | RESEARCHABLE | 2026-04-13 | OPEN |

## Iteration Log

### Iteration 0 — Initial draft (2026-04-13)
- **Created via:** advance --stage=spec
- **Source:** docs/refinery/billing-design.md
- **Initial state:** 32 requirements, 11 open questions

### Iteration N (date)
- **Operation:** iterate | finalize | update
- **Researched:** ...
- **Resolved:** ...
- **Convergence:** stable_count=N, open=N, ratio=N.NN

## Changelog

| Date | Section | Change | Reason | Operation |
|------|---------|--------|--------|-----------|
| 2026-04-13 | (created) | Initial draft | derived from design | advance |
```

### 4.3 Tracked claim format

Every FR/NFR/INV/RD/R/FM/P/etc. follows:

```markdown
#### FR-NNN: <Title using verb-object>

<EARS or RFC 2119 statement>

**Priority:** Must | Should | Could | Won't
**Confidence:** High | Medium | Low
**Evidence:** <file:line citations or upstream artifact reference>
**Source:** <provenance>
**Status:** Verified | Under Review | Inferred | Deferred
**Last validated:** <ISO date>
**Notes:** <optional>
```

For acceptance criteria:

````markdown
##### AC-FR-NNN-M: <Brief scenario name>

```gherkin
Given <precondition>
When <action>
Then <observable outcome>
```
````

### 4.4 EARS patterns (functional requirements)

| Pattern | Form |
|---------|------|
| Ubiquitous | The system shall <action> |
| Event-Driven | When <trigger>, the system shall <action> |
| State-Driven | While <state>, the system shall <action> |
| Unwanted | If <unwanted condition>, then the system shall <action> |
| Optional Feature | Where <feature included>, the system shall <action> |
| Complex | When <X> and while <Y> and if <Z>, the system shall <action> |

Use sparingly for Complex; prefer decomposition.

### 4.5 RFC 2119 (system specs only)

| Keyword | Meaning |
|---------|---------|
| MUST / SHALL | Absolute requirement |
| MUST NOT | Absolute prohibition |
| SHOULD | Strong recommendation; deviation requires justification |
| MAY | Truly optional |

Uppercase RFC 2119; lowercase `shall` inside EARS patterns.

---

## 5. The artifact graph

```
docs/refinery/
├── system-principles.md          # parent: null
├── system-design.md              # parent: system-principles.md
├── system-stack.md               # parent: system-design.md
├── system-spec.md                # parent: system-design.md
│                                 # references: [system-stack.md]
├── system-plan.md                # parent: system-spec.md
├── system-tickets.md             # parent: system-plan.md
└── features/
    ├── user-auth-spec.md         # parent: ../system-spec.md (or null if standalone)
    ├── user-auth/                # nested feature-specs (per OQ-010)
    │   ├── mfa-spec.md           # parent: ../user-auth-spec.md
    │   └── sso-spec.md           # parent: ../user-auth-spec.md
    └── records-spec.md
```

### 5.1 Graph operations

- **Adding a child:** `mode-advance` automatically updates the parent's `children` list when writing a new artifact
- **Modifying a parent:** `mode-update` reports children that may need re-review and offers to flag them `drifted`
- **Archiving:** `mode-archive` optionally flags children as `drifted`; `mode-archive --as superseded` adds a backlink to the replacement's `references` list

### 5.2 Graph integrity invariants

Per `references/document-format.md §10.4`:

- INV-001: bidirectional graph integrity (parent ↔ children consistency)
- INV-002: `high_confidence_ratio` matches body content
- INV-003: `open_questions_count` matches OQ table
- INV-004: no deleted IDs reused
- INV-005: source documents resolve
- INV-006: iteration log monotonically increases
- INV-007: status-operation compatibility

`mode-status` validates these on every scan.

---

## 6. Confidence + Evidence discipline

The most distinctive aspect of Refinery vs. legacy spec workflows: **confidence is structurally required, not narrative.**

Every tracked claim (FR/NFR/INV/RD/R/FM/P/component/etc.) MUST carry:

- **Confidence:** High | Medium | Low
- One of:
  - **Evidence:** file:line citation OR upstream artifact reference (for High/Medium)
  - **Open Question entry:** required for Low

This makes operations precise:

- `iterate` upgrades Low → Medium → High by gathering evidence
- `check` validates that Evidence still resolves to actual code
- `finalize` requires Open Questions to be RESOLVED or DEFERRED (no `[OPEN]` may remain)
- `review` scores per requirement on Confidence consistency

### 6.1 Tier criteria

| Tier | Criteria | Required form |
|------|----------|---------------|
| **High** | Direct evidence with multiple consistent examples (≥3), OR explicit derivation from finalized upstream artifact, OR explicit user decision in Changelog | file:line citations OR upstream reference OR Changelog reference |
| **Medium** | Single example, OR inferred from related code, OR partially supported by upstream | file:line with "(single example)" note OR "(inferred from)" note |
| **Low** | No direct evidence, contradictory examples, speculative | None required; item must appear in Open Questions |

### 6.2 The convergence ratio

```
high_confidence_ratio = high_count / (high_count + medium_count + open_questions_count)
```

This is the **maturity signal**. A spec with ratio 0.45 is unrefined; a spec with ratio 0.85+ is finalize-ready. The convergence loop's primary stop condition is ratio > 0.80 (per `references/convergence.md §3`).

---

## 7. The convergence model

The iteration loop terminates at a point where additional automated research yields diminishing returns relative to human review. Three metrics drive the decision:

| Metric | Definition | Indicates |
|--------|------------|-----------|
| `questions_stable_count` | Consecutive iterations with unchanged open question count | Research has plateaued |
| `open_questions_count` | OPEN entries in Open Questions table | Residual uncertainty |
| `high_confidence_ratio` | High / (High + Medium + Open) | Spec maturity |

### 7.1 Stop conditions

After ≥2 iterations (minimum-iterations floor), stop if **any** of:

| Condition | Threshold |
|-----------|-----------|
| Stability | `questions_stable_count >= 2` |
| Low question count | `open_questions_count <= 3` |
| High confidence | `high_confidence_ratio > 0.80` |

Always stops at iteration 5 (max-iterations cap).

### 7.2 Configurable thresholds

```bash
/refine iterate <path> --max-iterations=10
/refine iterate <path> --converge-on=high_confidence
```

Override defaults per invocation.

### 7.3 Implicit resume

If the loop is interrupted, re-running picks up from `iteration: N + 1` (per OQ-006). No special "resume mode" — the artifact frontmatter IS the resume point.

### 7.4 Greenfield degradation

If no codebase exists, the research phase reports the absence and reclassifies all RESEARCHABLE items to HUMAN_NEEDED. Convergence still progresses (stable_count typically reaches 2 within 2-3 iterations as the same items persist).

---

## 8. The ticket format

Refinery's tickets artifact is **dispatch-compatible**: dual-audience for human teams (sprint backlog) and agent dispatchers (work queue).

### 8.1 Per-ticket schema

```yaml
id: T-NN
title: <Action verb> <thing>
wave: <integer ≥ 1>
size: S | M | L | XL
layer: frontend | backend | data | infra | docs | test
depends_on: [<ticket IDs in this artifact>]
blocks: [<ticket IDs blocked by this>]
spec_ref: [<FR-NNN, AC-..., plan §N>]
files:
  - {path: <workspace-relative>, status: NEW | MODIFY | EXISTS}
acceptance:
  - <independently testable assertion>
convention_recipe: <int or null>
technical_notes: |
  <multi-line guidance>
anti_patterns:
  - <forbidden approach>
status: pending | in_progress | complete | blocked
```

### 8.2 Wave organization

- **Wave 1**: no `depends_on`; can start immediately
- **Wave N (N>1)**: depends on tickets in Wave N-1 or earlier
- Within a wave, tickets can run in parallel

The tickets artifact includes a textual dependency graph in §2.

### 8.3 Size classification

| Size | Effort | Dispatcher hint |
|------|--------|------------------|
| S | Hours | FLASH-eligible (ephemeral subagent) |
| M | One day | FLASH if low-risk; CORE otherwise |
| L | Multi-day | CORE-required (persistent worker) |
| XL | Week+ | **Decompose further** (warning emitted to Open Questions) |

### 8.4 Authorized files

Each ticket lists exactly the files the implementer (human or agent) is authorized to touch:

```
[NEW]    src/auth/login.go
[MODIFY] src/router.go
[EXISTS] src/types.go (read-only context)
```

No "and any other necessary files" wildcards. By default, ≤ 3 files per ticket (FR-034); exceptions documented in technical_notes.

### 8.5 Blocked tickets

If an Open Question in the source artifact prevents full specification:

```markdown
## T-09: [BLOCKED] Implement payment reconciliation

**Blocked By:** OQ-005 (in source: billing-spec.md) — "Reconciliation: real-time vs daily batch?"
**Unblocks:** T-10, T-11

### To Proceed
1. Resolve OQ-005 via /refine finalize docs/refinery/billing-spec.md
2. Re-run /refine tickets to regenerate this ticket fully specified
```

Blocked tickets appear in Appendix B of the artifact and don't count toward FLASH/CORE counts.

### 8.6 Validation

Before writing, `mode-tickets` validates:

- All `depends_on` resolve (no dangling)
- No circular dependencies (DAG check)
- Every spec item maps to ≥1 ticket
- At least one Wave 1 root (empty `depends_on`)
- All sizes assigned; XLs warned
- All files lists non-empty; all ACs non-empty

### 8.7 Compatibility with Dispatch

Refinery's tickets format aligns with the Dispatch skill's classification cascade. A dispatcher can ingest the tickets artifact directly without translation. The source-of-truth for ticket state is the markdown file itself; if a dispatcher caches state separately, that's the dispatcher's responsibility.

---

## 9. Drift detection

After implementing code from a spec, drift accumulates in two directions:

1. **Spec drifted from code**: requirements without implementing code (DIVERGED, MISSING, PARTIAL)
2. **Code drifted from spec**: code present but absent from spec (undocumented behavior, configuration, error handling)

`mode-check` detects both.

### 9.1 Workflow

```bash
# Initial check after implementation
/refine check docs/refinery/billing-spec.md
# → produces drift report at billing-spec-check-2026-04-13.md
# → status transitions: finalized → implemented (clean) OR finalized → drifted (any drift)

# If drifted, address findings
/refine update docs/refinery/billing-spec.md "address drift findings"

# Re-check
/refine check docs/refinery/billing-spec.md
# → status: drifted → implemented (if clean now)
```

### 9.2 Drift classifications

For each FR/NFR/AC:

| Class | Meaning |
|-------|---------|
| IMPLEMENTED | Code matches |
| PARTIAL | Code exists but doesn't fully satisfy |
| MISSING | No implementing code found |
| DIVERGED | Code contradicts spec |
| SUPERSEDED | Code does different (potentially better) approach |

For acceptance criteria, additionally:

| Class | Meaning |
|-------|---------|
| TESTED | Test exists in `tests/` or equivalent |
| PARTIAL | Partial test coverage (e.g., happy path tested, error case not) |
| UNTESTED | No test found |

### 9.3 Reverse drift

`code-archaeologist` also identifies behavior present in code but absent from spec:

- Undocumented public API endpoints/exports
- Undocumented configuration options
- Undocumented error handling (exception types, error codes)
- Undocumented dependencies
- Undocumented side effects

Each surfaces in the drift report's "Spec Drift (Undocumented Behavior)" section with a recommendation: "add to spec / remove from code / explicit deferral".

### 9.4 Drift cadence

Suggested cadence: every release, every refactor, every quarter. Drift detection is the maintenance loop that keeps spec and code aligned over time.

---

## 10. Configuration via userConfig

```bash
/plugin config refinery
```

Three keys, all `sensitive: false`:

| Key | Default | Purpose |
|-----|---------|---------|
| `working_directory` | `docs/refinery/` | Default output directory |
| `spec_writer_model` | `opus` | Model for spec-writer agent |
| `specialist_model` | `sonnet` | Model for the 5 specialist agents |

### 10.1 Resolution precedence

Highest to lowest:

1. Per-invocation flags (`--output-dir`, `--model`, etc.)
2. `userConfig` values
3. Built-in defaults

### 10.2 When to set what

- **`working_directory`**: set once if your team uses a non-default location (e.g., `specs/refinery/` or `architecture/refinery/`)
- **`spec_writer_model`**: set to `sonnet` or `haiku` if you don't need opus-level reasoning and want faster/cheaper synthesis
- **`specialist_model`**: rarely changed; sonnet is the right balance for the specialist roles

---

## 11. Coexistence with legacy specs

Refinery installs alongside existing setups without modifying them.

### 11.1 What's untouched

| Existing component | After install |
|--------------------|---------------|
| Personal `refine`, `refine-*`, `spec-*` skills at `~/.claude/skills/` | Untouched |
| Personal `spec-writer` agent at `~/.claude/agents/` | Untouched |
| `spec-refine` plugin from the marketplace | Untouched (still enabled if previously enabled) |
| Existing `docs/specs/` artifacts | Untouched |

### 11.2 Namespace disambiguation

If you have a personal `/refine` skill, both will appear:

- `/refine` → personal skill (your existing)
- `/refinery:refine` → this plugin's orchestrator

Once you're satisfied with Refinery, you can delete the personal skill to free the unprefixed `/refine`.

### 11.3 Working directory distinct

Refinery's default is `docs/refinery/`; legacy spec workflows typically use `docs/specs/`. They don't collide.

If you want to use `docs/specs/` as Refinery's working directory:

```bash
# Per invocation
/refine --output-dir=docs/specs status

# Persistent (via userConfig)
/plugin config refinery
# → set working_directory: docs/specs
```

`/refine init` will detect existing artifacts and offer coexist (default), merge, or use as primary.

### 11.4 Migrating from legacy artifacts

v1.0.0 does **not** include `mode-migrate` (deferred to v1.1 per OQ-002). Coexistence handles the transition: keep old artifacts in `docs/specs/`, write new ones in `docs/refinery/`. Manual port the format (add universal frontmatter, rename sections to match the universal Open Questions / Iteration Log / Changelog) is the v1 path.

---

## 12. The agent system

Six specialist agents handle the heavy lifting. Each is namespaced as `refinery:<agent-name>`.

| Agent | Role | Default model | Tools |
|-------|------|---------------|-------|
| `spec-writer` | Authoring (all stages) | opus | Read, Write, Edit, Glob, Grep, AskUserQuestion, Bash |
| `spec-critic` | Skeptical analysis | sonnet | Read |
| `spec-scribe` | Tracked editing | sonnet | Read, Edit, Write |
| `code-archaeologist` | Codebase research | sonnet | Glob, Grep, Read |
| `requirements-interviewer` | Feature intake | sonnet | Read, Glob, Grep, AskUserQuestion |
| `ticket-architect` | Decomposition | sonnet | Read, Write |

### 12.1 Memory in spec-writer

`spec-writer` uses `memory: user` — accumulates project conventions, domain terminology, and your preferences across conversations. The agent automatically:

- Recalls relevant context at the start of each spec authoring session
- Updates memory with new domain terms discovered, patterns that worked well, feedback received

Memory is per-user, project-scoped (the agent keys memory by project root).

### 12.2 Skills preloaded by spec-writer

The `specification-writing` skill is preloaded into spec-writer's context via the `skills:` frontmatter field. This injects EARS patterns, GWT structure, RFC 2119 language, and quality checklists at agent startup — no separate invocation needed.

### 12.3 Specialist behavioral guidelines

Each agent has a focused persona (see `agents/<name>.md`):

- **spec-writer:** Codebase-grounded, EARS-disciplined, confidence-first
- **spec-critic:** Skeptical not cynical, specific not vague, practical not academic
- **spec-scribe:** Conservative, atomic edits, ID discipline, structure preservation
- **code-archaeologist:** Wide-net-then-focus, follow-the-trail, evidence-over-intuition
- **requirements-interviewer:** Why → what → how (lightly), batched questions, codebase verification before generating draft
- **ticket-architect:** Right-size tickets, respect dependencies, be practical (specific files + gotchas + testable AC)

---

## 13. Recovery procedures

### 13.1 Iteration loop crashed mid-run

The artifact's frontmatter `iteration: N` IS the resume point. Re-run:

```bash
/refine iterate <path>
```

The loop continues from `N + 1` automatically (per OQ-006).

### 13.2 Artifact frontmatter corrupted

Manually fix the YAML (or restore from git). The plugin will report parse errors but won't auto-fix to avoid further damage.

### 13.3 Validation errors after `/refine update`

`mode-update` validates before writing; if validation fails, the spec-scribe agent is asked to revise (up to 2 attempts). If still failing, the original artifact is preserved. Read the error message and either:

- Retry with a more specific change description: `/refine update <path> "<more specific>"`
- Manually edit the artifact (and re-run `/refine review` to verify)

### 13.4 Children flagged drifted unintentionally

The `update` and `archive` modes prompt before flagging children. If you accidentally flagged children:

- For each affected child: `/refine update <child> "revert drift flag (parent change reverted/incorrect)"`
- Or manually edit the child's frontmatter `status: drifted → reviewed/finalized` and append a Changelog entry explaining

### 13.5 Wrong artifact archived

`mode-archive` is reversible by manually editing frontmatter:

- `status: archived → reviewed` (or whatever the prior state was)
- Remove `superseded_by` if `--as superseded` was used
- Append a Changelog entry: "Reversed archive — was incorrect"

To preserve audit trail, prefer this approach over `--force` un-archiving.

### 13.6 Generated tickets don't match spec coverage

The `mode-tickets` validation catches this (per FR's-coverage check). If tickets are missing for some FRs:

```bash
/refine update docs/refinery/<plan>.md "elaborate phase covering FR-NNN, FR-MMM"
/refine tickets docs/refinery/<plan>.md
# → re-decomposes; new tickets cover the elaborated phase
```

---

## 14. Troubleshooting

### Plugin not found after install

Restart Claude Code. Plugin manifests are loaded at startup; new installs require restart.

### `/refine status` reports "no working directory"

Run `/refine init` first to bootstrap. Or specify an existing directory: `/refine status --output-dir=<path>`.

### "Cannot finalize a drifted artifact"

The state machine refuses this transition. Run `/refine update <path> "address drift"` first, then `/refine finalize <path>`.

### "Stage X requires Y artifact"

The pipeline enforces dependencies. Either:

- Run the prerequisite stage: `/refine --stage=Y`
- Use `--force` to skip (warns and confirms; not recommended)

### Iteration loop ran 5 times without converging

Check the artifact's Open Questions section. Likely most items are HUMAN_NEEDED (greenfield project, or genuinely needs human decisions). Run:

```bash
/refine finalize <path>
```

This batches the questions via AskUserQuestion (max 4 per call) and resolves them.

### `code-archaeologist` returns "no relevant files found"

Two cases:

1. **Greenfield**: project has no source code yet → archaeologist correctly reports nothing; iterate degrades gracefully (per `references/convergence.md §9`)
2. **Search strategy too narrow**: increase scope by running `/refine iterate <path> --verbose` to see what searches were attempted; manually broaden the spec's evidence hints if needed

### Tickets artifact has circular dependencies (validation failure)

`mode-tickets` should catch this. If it slipped through (rare), it's a `ticket-architect` agent failure. Re-run with `--verbose`:

```bash
/refine tickets <path> --verbose
```

If still circular, file an issue with the source plan and the failing tickets output.

### `userConfig` value not respected

Verify it's set: `/plugin config refinery`. Per-invocation flags override userConfig — check you're not passing `--output-dir` etc. that overrides.

### Spec itself drifts from the implementation

If you notice the plugin behaves differently from this guide or the spec at `docs/specs/refinery.md`:

```bash
/refine check docs/specs/refinery.md
```

The plugin can detect drift in its own spec (dog-fooding per spec §3.7). The drift report tells you which FRs/NFRs no longer match the implementation.

### Where do I report bugs?

https://github.com/dhofheinz/open-plugins/issues

---

## Reference

- **[CHEATSHEET.md](CHEATSHEET.md)** — single-page reference
- **[GETTING_STARTED.md](GETTING_STARTED.md)** — first-experience guide
- **[docs/specs/refinery.md](../../docs/specs/refinery.md)** — formal v1.0.0 specification
- **`skills/refine/references/`** — canonical reference files for document format, convergence, requirement syntax, state detection, ticket format, commit protocol
- **`skills/refine/templates/`** — artifact templates (also installed to `<working-dir>/_templates/` by `init`)
- **`agents/`** — six specialist agent definitions
