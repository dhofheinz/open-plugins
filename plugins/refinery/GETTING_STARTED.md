# Getting Started with Refinery

A 5-minute first-experience guide. For depth, see [USER_GUIDE.md](USER_GUIDE.md). For quick reference, see [CHEATSHEET.md](CHEATSHEET.md).

## What you need

- Claude Code with plugin support
- A project directory (greenfield empty repo, or an existing codebase)

## Install (1 minute)

```bash
/plugin marketplace add https://github.com/dhofheinz/open-plugins
/plugin install refinery@open-plugins
```

Restart Claude Code, then verify:

```bash
/refine status
```

If the plugin is installed and your project has no Refinery artifacts yet, you'll get a prompt to initialize.

## Your first 5 minutes

Pick the path that matches what you have.

### Path A — Brand-new system from an idea (greenfield)

You have an empty project and an idea. Run the full architecture pipeline.

```bash
# 1. Bootstrap the working directory
/refine init

# 2. Seed the pipeline with your idea
/refine "an event-sourced billing system with idempotent webhook ingress"

# 3. Iterate on the principles draft (resolves open questions)
/refine iterate docs/refinery/billing-principles.md

# 4. Finalize (closes remaining questions via batched user prompts)
/refine finalize docs/refinery/billing-principles.md

# 5. Advance to the next stage
/refine --stage=design

# (repeat iterate/finalize/advance through stack, spec, plan)
```

When the plan is finalized, generate dispatch-compatible tickets:

```bash
/refine tickets docs/refinery/billing-plan.md
```

### Path B — Document an existing feature (brownfield)

You have a codebase. You want to spec a feature for it.

```bash
# 1. Bootstrap (detects existing docs/specs/ and offers coexistence)
/refine init

# 2. Start a feature spec
/refine user-authentication
# → requirements-interviewer asks 3-4 batches of questions
# → spec-writer synthesizes from intake + codebase exploration
# → produces docs/refinery/features/user-authentication-spec.md

# 3. Iterate (research codebase for evidence)
/refine iterate docs/refinery/features/user-authentication-spec.md

# 4. Finalize
/refine finalize docs/refinery/features/user-authentication-spec.md

# 5. Optionally generate a plan + tickets
/refine --stage=plan      # creates a feature-scoped plan
/refine tickets docs/refinery/features/user-authentication-plan.md
```

### Path C — Just look around

You're not sure what to do. Let the plugin tell you.

```bash
/refine status
# → reports any existing artifacts, their status, and a suggested next action
```

If the directory is empty, `/refine` (with no args) will prompt you with options.

## What just happened

When you ran the commands above, Refinery created markdown files in `docs/refinery/`. Each file is an **artifact** — a typed node in a graph. Every artifact has:

- **Frontmatter** with type (`principles`, `design`, `stack`, `spec`, `feature-spec`, `plan`, `tickets`), status (`draft → iterating → reviewed → finalized → implemented → drifted`), parent/children edges, convergence metrics
- **Body sections** specific to its type (e.g., a spec has FRs/NFRs; a plan has phases)
- **Open Questions** table — anything unresolved
- **Iteration Log** — what was researched and resolved per iteration
- **Changelog** — every modification with date, reason, operation

The orchestrator (`/refine`) parses your input, picks the right operation, and dispatches. You never need to remember 10 different commands — one command, intelligent routing.

## Next steps

- **Adjust per-user defaults:** `/plugin config refinery` — set `working_directory`, `spec_writer_model`, `specialist_model`
- **Drift surveillance:** after implementing code from a spec, run `/refine check <spec-path>` to detect spec/code divergence
- **Update an existing artifact:** `/refine update <path> "<change description>"` — applies traceably with Changelog entry
- **Archive an obsolete artifact:** `/refine archive <path> --reason "..." [--as superseded --replaced-by <new-path>]`
- **Read the [USER_GUIDE.md](USER_GUIDE.md)** for deep dives on each mode, the document format, the ticket format, and the agent system

## Common questions

**Do I have to use all 5 stages (principles → design → stack → spec → plan)?**
No. The pipeline is for system-scope work. Feature-spec is standalone — start with `/refine <feature-name>` and skip principles/design entirely.

**What if I have legacy specs in `docs/specs/`?**
`/refine init` detects existing spec directories and offers three options: coexist (default — Refinery uses `docs/refinery/`, your existing files untouched), merge, or use as primary. No destructive operations without your explicit choice.

**Can I use it alongside a personal `/refine` skill?**
Yes. Plugin commands are namespaced: invoke as `/refinery:refine` to disambiguate.

**Does it call any external services or APIs?**
No. Refinery is local-filesystem-only by default. No WebFetch, no WebSearch. The only external invocation is scoped Bash for package-manager queries during the `stack` stage (e.g., `npm view`, `cargo search`).

**What if a research question can't be answered by the codebase?**
The convergence loop reclassifies it as `HUMAN_NEEDED` and surfaces it in Open Questions. `/refine finalize` then asks you via batched AskUserQuestion prompts (max 4 questions per batch, with concrete options).

**Where does my work get persisted?**
All state is in markdown files at `docs/refinery/`. No database, no `.refinery/` cache. Git-versionable, portable, inspectable.

## When something goes wrong

- **"Plugin not found":** Restart Claude Code after install
- **"Cannot finalize a drifted artifact":** Run `/refine update <path> "address drift"` first
- **Iteration loop ran 5 times without converging:** Check the artifact's Open Questions section for HUMAN_NEEDED items; run `/refine finalize <path>` to resolve them via user prompts
- **"Stage X requires Y artifact":** The pipeline enforces dependencies; run the prerequisite stage first or use `--force` (warns and confirms)

For more, see [USER_GUIDE.md](USER_GUIDE.md) §Troubleshooting.

## Where to learn more

- **[CHEATSHEET.md](CHEATSHEET.md)** — single-page reference of all modes, flags, formats
- **[USER_GUIDE.md](USER_GUIDE.md)** — comprehensive deep-dive
