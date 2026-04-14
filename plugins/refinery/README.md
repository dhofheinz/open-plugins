# Refinery — Unified Specification Refinement

Refinery is a Claude Code plugin that unifies architecture pipelines, feature spec creation, iterative convergence, drift detection, and dispatch-compatible ticket generation into a single, coherent system organized around one progressively-disclosed entry point: `/refine`.

> **Documentation map:** new users start with **[GETTING_STARTED.md](GETTING_STARTED.md)** (5-minute walkthrough). Print **[CHEATSHEET.md](CHEATSHEET.md)** for a single-page reference. Read **[USER_GUIDE.md](USER_GUIDE.md)** for deep dives on every mode, agent, format, and recovery procedure. The formal v1.0.0 spec this plugin implements lives at [docs/specs/refinery.md](../../docs/specs/refinery.md).

## What it does

Refinery treats specifications as **typed nodes in a graph**. Every artifact (principles, design, stack, spec, feature-spec, plan, tickets) shares a unified frontmatter and trailing sections, but retains stage-specific structure. A single user command (`/refine`) dispatches to the right operation based on context, intent, and existing artifacts — no menu of competing commands to choose between.

Key capabilities:

- **Greenfield architecture pipelines** (principles → design → stack → spec → plan → tickets)
- **Feature spec creation** with structured intake and codebase grounding (supports nested sub-features)
- **Iterative convergence loops** that research the codebase, integrate findings, and stop when diminishing returns hit
- **Quality reviews** scored across 5 dimensions
- **Drift detection** in both directions: spec drifted from code AND code drifted from spec (undocumented behavior)
- **Finalization** that resolves Open Questions via codebase research first, AskUserQuestion for what's left
- **Dispatch-compatible ticket decomposition** with dependency waves, size hints, authorized files
- **Traceable updates** with strict ID discipline (no reused deleted IDs; bidirectional cross-references)
- **Lifecycle archival** with bookkeeping discipline

## Installation

### Via OpenPlugins Marketplace

```bash
# Add the marketplace (one-time)
/plugin marketplace add https://github.com/dhofheinz/open-plugins

# Install the plugin
/plugin install refinery@open-plugins

# Restart Claude Code, then:
/refine status
```

## Quick Start

```bash
# Bootstrap a project
/refine init

# Greenfield: start a new system pipeline from an idea
/refine "an event-sourced billing system with idempotent webhook ingress"

# Brownfield: spec a feature in an existing system
/refine user-authentication

# Iterate on a draft
/refine iterate docs/refinery/billing-principles.md

# Finalize (closes Open Questions via research + AskUserQuestion)
/refine finalize docs/refinery/billing-spec.md

# Drift check against codebase
/refine check docs/refinery/billing-spec.md

# Decompose into dispatch-compatible tickets
/refine tickets docs/refinery/billing-plan.md

# What's the current state?
/refine status
```

## The One Command

`/refine` is the only user-invocable command in this plugin. It accepts:

- **Empty** — auto-detect intent; runs `status` if artifacts exist, prompts for input if not
- **Free-text idea** in quotes — seeds a new pipeline at the principles stage
- **A file path** — inspects the artifact and suggests the right operation
- **A feature name** (single word) — routes to the feature-spec workflow
- **A mode keyword** (`init`, `advance`, `iterate`, `review`, `finalize`, `check`, `tickets`, `update`, `status`, `archive`) — explicit mode

Flags include `--stage=<name>`, `--scope=<name>`, `--output-dir=<path>`, `--max-iterations=<n>`, `--converge-on=<criterion>`, `--verbose`, `--dry-run`.

## Architecture

```
refinery/
├── .claude-plugin/plugin.json     # Manifest with userConfig (working_directory, model preferences)
├── skills/
│   ├── refine/                     # The orchestrator (the only user-invocable skill)
│   │   ├── SKILL.md
│   │   ├── mode-*.md               # 11 mode files (init, advance, iterate, review,
│   │   │                           #   finalize, check, tickets, update, status, archive,
│   │   │                           #   mark-implemented)
│   │   ├── stage-*.md              # 6 stage files (principles, design, stack, spec,
│   │   │                           #   feature-spec, plan)
│   │   ├── templates/              # 9 templates (one per artifact type + _conventions, _glossary)
│   │   └── references/             # 8 references (document-format, convergence,
│   │                               #   requirement-syntax, state-detection,
│   │                               #   ticket-format, commit-protocol,
│   │                               #   agent-handoffs, operation-bookkeeping)
│   └── specification-writing/      # Reference skill (preloaded by spec-writer)
└── agents/                         # 6 specialist agents
    ├── spec-writer.md              # Authoring (sonnet default; principles/design → opus, memory: user, color: purple)
    ├── spec-critic.md              # Skeptical analysis (sonnet)
    ├── spec-scribe.md              # Tracked editing (sonnet)
    ├── code-archaeologist.md       # Codebase research (sonnet)
    ├── requirements-interviewer.md # Feature intake (sonnet)
    └── ticket-architect.md         # Dispatch-compatible decomposition (sonnet)
```

The orchestrator's always-loaded SKILL.md is small (~170 lines, well under the 400-line budget). All other behavior loads on demand: mode files when their mode runs, stage files when a stage runs, agents when spawned. This keeps context costs low for any single operation.

## User Configuration

You can persist common preferences via plugin user config:

```bash
/plugin config refinery
```

Three keys (all optional):

| Key | Default | Purpose |
|-----|---------|---------|
| `working_directory` | `docs/refinery/` | Default working directory for artifacts |
| `spec_writer_model` | `sonnet` | Model alias for the spec-writer agent (principles/design stages fall back to `opus` when unset) |
| `specialist_model` | `sonnet` | Model alias for the five specialist agents |

Per-invocation flags (`--output-dir`, etc.) override user config.

## Document Format

Every artifact uses a unified format:

- **Universal frontmatter** (artifact type, scope, status, parent/children graph, convergence metrics)
- **Per-artifact body** (varies by stage)
- **Universal trailing sections:** Open Questions, Iteration Log, Changelog (always present)

Confidence is **first-class metadata**. Every tracked claim (FR, NFR, INV, RD, etc.) has a Confidence tier (High / Medium / Low) and either Evidence (file:line citations or upstream artifact references) or appears in Open Questions.

See [`skills/refine/references/document-format.md`](skills/refine/references/document-format.md) for the full schema.

## Tickets Are Dispatch-Compatible

Refinery's tickets artifact is designed to be readable by both human teams (as a sprint backlog) and agent dispatchers (as a work queue). Each ticket includes:

- ID (`T-NN`), wave, size (S/M/L/XL), layer
- `depends_on` and `blocks` lists
- Authorized files with `[NEW]/[MODIFY]/[EXISTS]` markers
- Acceptance criteria in Given/When/Then
- Convention recipe references, technical notes, anti-patterns

The format aligns with Dispatch's classification cascade. See [`skills/refine/references/ticket-format.md`](skills/refine/references/ticket-format.md).

## Coexistence

Refinery does not interact with other plugins or with personal skills. The default working directory `docs/refinery/` is distinct from common alternatives (`docs/specs/`, `specs/`, `spec/`). When invoked alongside a personal `/refine` skill, this plugin is invokable as `/refinery:refine` (per plugin namespacing).

If you have artifacts in `docs/specs/`, `init` offers to coexist (default), merge, or use as primary working directory. Migration tooling for legacy artifacts (from `spec-refine` plugin or `spec-*` personal skills) is deferred to v1.1.

## Specification

The full v1.0.0 specification for this plugin lives at [`docs/specs/refinery.md`](../../docs/specs/refinery.md) in this repository. It was authored using a precursor of this same workflow (dog-fooded — see §3.7 of the spec) and resolved its 12 open questions during the implementation kickoff session that produced this plugin.

## What's Deferred to v1.1+

Per the v1.0.0 open-questions resolution:

- **`mode-migrate.md`** for translating legacy artifacts into Refinery's unified format (deferred — coexistence handles transition)
- **Hooks** (PostToolUse, SessionStart) for automation (deferred — explicit commands first)
- **Snapshots** (`.refinery/snapshots/` for iteration rollback) (deferred — use git)
- **Partial check scoping** (`--section` flag) (deferred — full check is canonical)

## License

MIT — see [LICENSE](LICENSE).

## Contributing

Issues and PRs welcome at https://github.com/dhofheinz/open-plugins. Plugin submissions to the OpenPlugins marketplace follow the [contribution guidelines](https://github.com/dhofheinz/open-plugins/blob/main/CONTRIBUTING.md).
