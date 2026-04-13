# Mode: advance

**Purpose:** Move the pipeline forward by one stage (or to a target stage). Creates a new artifact deriving from existing inputs.

## Inputs

- Current pipeline state (from orchestrator's state detection)
- Target stage (from `--stage=<name>` flag, OR inferred as the next missing stage)
- Optional input — idea text (for `principles` stage seed) or file path (when stage has an existing parent)
- Optional `--scope=<name>` flag (`system`, `subsystem`, `feature`, `component`)

## Procedure

### Phase 1: Resolve target stage

If `--stage=<name>` specified → use it.

Otherwise, walk the system pipeline `[principles, design, stack, spec, plan]` and pick the first stage for which no artifact exists in the working directory. If all system-level stages exist, ask the user to be explicit:

```
AskUserQuestion: "All system stages have artifacts. What would you like to advance?"
Options:
  - "Generate tickets from a finalized plan" (routes to /refine tickets)
  - "Document a new feature" (routes to feature-spec workflow)
  - "Iterate on an existing stage" (routes to /refine iterate)
  - "Cancel"
```

For `--stage=feature-spec`:

- The first positional argument is the feature name
- Optional `--parent <path>` to specify a system-spec parent
- Per OQ-010, optional `--parent <path-to-feature-spec>` to nest under another feature-spec (creates a sub-feature)

### Phase 2: Validate prerequisites

| Stage | Required input |
|-------|----------------|
| principles | Seed idea (text or file). No artifact prerequisite. |
| design | A `finalized` or `reviewed` principles artifact. |
| stack | A `finalized` or `reviewed` design artifact. |
| spec | A `finalized` or `reviewed` design artifact. (Stack is recommended but optional.) |
| feature-spec | None required (standalone OK). Optional system-spec parent or feature-spec parent (for nested sub-features per OQ-010). |
| plan | A `finalized` or `reviewed` spec or feature-spec artifact. |

If a prerequisite is missing → refuse the operation; report the missing prerequisite; suggest the prerequisite stage:

```
[Refinery] Cannot advance to '<target>': missing prerequisite '<prereq>'.
[Refinery] Suggested: /refine --stage=<prereq>
```

If a prerequisite exists but is `draft` or `iterating` → warn and confirm via AskUserQuestion (per FR-009):

```
AskUserQuestion: "Parent artifact is in <status> status. Recommended to iterate or review first."
Options:
  - "Iterate parent first (/refine iterate <parent>)"
  - "Review parent first (/refine review <parent>)"
  - "Proceed anyway (use parent as-is)"
  - "Cancel"
```

### Phase 3: Project name resolution

Determine the artifact's project/feature name (used in filenames):

- `--project <name>` flag if specified
- For `principles`: extract from existing artifact prefixes if any, else from `--output-dir` basename, else from the first significant noun in the idea text (kebab-case), else AskUserQuestion
- For all other stages: inherit from parent artifact's `feature:` frontmatter field
- For `feature-spec`: the first positional argument IS the feature name (single token, kebab-case)

### Phase 4: Load stage file

Load the procedure for the target stage:

| Target stage | File |
|--------------|------|
| principles | `${CLAUDE_SKILL_DIR}/stage-principles.md` |
| design | `${CLAUDE_SKILL_DIR}/stage-design.md` |
| stack | `${CLAUDE_SKILL_DIR}/stage-stack.md` |
| spec | `${CLAUDE_SKILL_DIR}/stage-spec.md` |
| feature-spec | `${CLAUDE_SKILL_DIR}/stage-feature-spec.md` |
| plan | `${CLAUDE_SKILL_DIR}/stage-plan.md` |

Load via `Read`. The stage file specifies which agent to spawn, which template to use, and stage-specific quality checks.

### Phase 5: Execute stage

Follow the loaded stage file's procedure. Generally:

1. Spawn the appropriate agent (typically `refinery:spec-writer`, but `feature-spec` uses `refinery:requirements-interviewer` for intake then `refinery:spec-writer` for synthesis)
2. The agent reads inputs, fills the template, performs codebase research where appropriate, runs stage-specific quality checks
3. The agent writes the artifact to the resolved output path

If the agent's output fails the stage-specific quality checks (per FR-011), request a revision (up to 2 attempts before reporting and asking the user how to proceed).

### Phase 6: Set graph relationships

After the agent completes:

- Set the new artifact's frontmatter:
  - `parent` = path to the input artifact (or `null` for the seed `principles` case)
  - `children: []`
  - `iteration: 0`
  - `status: draft`
  - `last_updated: <now>`
  - `convergence: { questions_stable_count: 0, open_questions_count: <count>, high_confidence_ratio: <computed> }`
  - `plugin_version: <current refinery version>`
- Update the parent artifact's `children` list to include the new artifact's path (per FR-010)
- Update the parent's `last_updated` to now
- Append a Changelog entry to the parent: "<date> | (graph) | Added child: <new-artifact-path> | New stage advanced | advance"

### Phase 7: Validate output

Run universal post-write validation:

- Frontmatter required fields per `references/document-format.md §1`
- Status compatibility per §1.7
- Bidirectional graph integrity (INV-001)
- All tracked claims have Confidence + Evidence (or appear in Open Questions)
- Universal sections present (Open Questions, Iteration Log with iteration 0 entry, Changelog with creation entry)

If any validation fails, refuse the write and report. (The agent should have caught these; if it didn't, ask for revision.)

### Phase 8: Report

Report (terse format):

```
[Refinery] advance complete.
[Refinery] Stage: <stage-name>
[Refinery] Wrote: <output-path> (status: draft, iteration: 0)
[Refinery]   <N> tracked items added (<H> High, <M> Medium confidence)
[Refinery]   <Q> open questions surfaced
[Refinery]   high_confidence_ratio: <R>
[Refinery] Quality checks: <P>/<T> pass<, <W> warning(s) if any>

Suggested next:
  /refine iterate <output-path>          (resolve open questions; minimum 2 iterations)
  /refine review <output-path>           (quality assessment without modification)
  /refine --stage=<next-stage>           (continue pipeline; warns about draft status)
```

Commit hint per `${CLAUDE_SKILL_DIR}/references/commit-protocol.md`:

```
spec(<basename>): seed from <source>
```

## Edge Cases

- **Greenfield project (no codebase):** `principles` stage works fine without code; `design` and beyond mostly work without code; `spec` can synthesize but flags many Open Questions for human review; `stack` may have limited evidence (no existing files to consult — agent uses package-manager queries via `Bash`).
- **Stage skip:** If user runs `/refine --stage=plan` with no spec, refuse and suggest spec stage. If `spec` exists but no design (unusual, possible if user seeded with an external spec), warn and confirm.
- **Stage re-run:** If the target artifact already exists, refuse unless `--force` is set. With `--force`, prompt confirmation per FR-005 if existing status is `finalized` or `implemented`. Treat re-run as a new advance: append `-v2`, `-v3` etc. to filename, mark old artifact `superseded` via mode-archive, link via `superseded_by`.
- **Nested feature-specs (per OQ-010):** When `--stage=feature-spec` with `--parent <feature-spec-path>`, write to `<working-dir>/features/<parent-feature>/<feature>-spec.md` (or similar nested structure). Update parent's `children` list.
- **Stack stage with `Bash` (per OQ-004):** The stage file may invoke `Bash(npm view:*)`, `Bash(cargo search:*)`, etc. for current version data. Per the stage file's `allowed-tools`. Do not exec arbitrary content from artifact bodies.

## Performance

This mode loads: orchestrator (~170 lines) + this mode file (~140 lines) + stage file (~100-200 lines per stage) + template (~150-300 lines) + spawned agent. Total well within typical context budgets.
