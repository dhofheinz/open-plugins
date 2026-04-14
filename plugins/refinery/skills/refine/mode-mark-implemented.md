# Mode: mark-implemented

**Purpose:** Transition a `finalized` artifact to `implemented` with provenance, without running a drift check.

This is the lightweight terminal step in the state machine: the author asserts the implementation matches the spec and records the shipping commit hash for audit. `mode-check` handles the verified path — it runs the archaeologist and transitions automatically on a clean drift report. This mode handles the trusted path: the author already knows implementation matches and just wants the bookkeeping closed.

Two consequences of that split:

- `mode-mark-implemented` does not load the code-archaeologist agent. It is fast and context-cheap.
- The commit hash in the Changelog is the only provenance link. Without it, future audits cannot trace the `finalized → implemented` transition to the shipping change.

## Inputs

- Target artifact path (required first argument)
- Optional `--commit=<hash>` — the shipping commit. **Strongly recommended** (it's the primary provenance signal); if omitted, the Changelog entry says `commit: unrecorded` and the mode warns.
- Optional `--tickets=<path>` — path to a tickets artifact whose per-ticket `status: pending` / `in_progress` fields should flip to `complete`. If omitted, tickets are left untouched.
- Optional `--dry-run` — print intended changes without writing.
- Optional `--force` — override validation refusals (e.g., transitioning from `drifted` or re-marking an already-`implemented` artifact).

## Procedure

### Phase 1: Validate target

Read target artifact's frontmatter. Validate:

- File exists and is a Refinery artifact (has `artifact:` field)
- Current status is `finalized` (the normal case). If `drifted`, refuse unless `--force` — drifted artifacts should be re-aligned via `/refine update` before being marked shipped. If `implemented`, refuse unless `--force` — re-marking is usually a mistake; with `--force` it updates the commit hash and appends a changelog row.
- Artifact type supports `implemented` per `references/document-format.md §7`: must be one of `stack`, `spec`, `feature-spec`, `plan`, `tickets`. Principles and design do not support `implemented` (they are not directly executable); refuse with an explanatory message directing the user to mark a downstream artifact instead.

### Phase 2: Validate commit hash (if provided)

If `--commit=<hash>` is passed:

- Sanity-check the shape: SHA-1 prefix (7+ hex chars) or full SHA-256. Accept short prefixes (≥7 chars), long hashes, and annotated tags (`v1.2.3`, `release-2026-04-13`). Reject anything with whitespace or shell metacharacters.
- Optionally verify the commit exists in `git` via `git cat-file -e <hash>`. If the shell invocation fails (not a git repo, detached state, permission denied), warn but do not refuse — the user may be marking implementation that happened in a different repo.
- Normalize: if the user passed a short prefix and `git rev-parse <hash>` succeeds, record the full hash in the Changelog for stable long-term reference. Keep the short form in the "Commit hint" report for readability.

If `--commit` is omitted, record `commit: unrecorded` in the Changelog and warn at Phase 6 that future `status` audits will have no provenance link.

### Phase 3: Apply target transition

Apply the status-transition procedure per `${CLAUDE_SKILL_DIR}/references/operation-bookkeeping.md §2`, with these parameters:

- **New status:** `implemented`
- **Additional frontmatter:** none (status + last_updated only)
- **Changelog change:** `Status: <prev> → implemented`
- **Changelog reason:** `Shipped in <commit-hash-or-"unrecorded">`
- **Operation name:** `mark-implemented`

If `--force` was used to re-mark an already-`implemented` artifact, the Changelog row reflects `implemented → implemented` (self-transition) and the reason column says `Re-recorded shipping commit: <new hash>`.

### Phase 4: Update tickets (if `--tickets=<path>` passed)

If `--tickets` is provided:

- Read the tickets artifact. Validate it is a Refinery `artifact: tickets` file.
- For each ticket body whose `status` is `pending` or `in_progress`, update it to `complete`.
- Tickets already `complete` or `blocked` are **left untouched** — `complete` is idempotent, and `blocked` signals a real problem the user should resolve before marking shipped.
- If any ticket was `blocked`, warn in the Phase 6 report and suggest the user resolve it before the artifact is truly "implemented."
- Append a tickets Changelog row per `${CLAUDE_SKILL_DIR}/references/document-format.md §2.3`, with section `(ticket-status)`, change `N tickets: pending/in_progress → complete`, reason `Shipped in <commit-hash>`, operation `mark-implemented`.
- Then apply `operation-bookkeeping.md §2` to transition the tickets artifact itself to `status: implemented` (same commit-hash reason).

If `--tickets` is omitted, skip this phase. The tickets artifact (if any) remains at its prior status; per-ticket bodies remain at their prior status. This is the right default when tickets aren't being tracked this tightly.

### Phase 5: Detect cross-artifact inconsistencies

Before declaring success, scan the working directory per `references/state-detection.md §2` and check:

- **Missing tickets update:** if the target has a `children: [<path-to-tickets>]` entry and `--tickets` was not passed, warn (but do not refuse): "Target references tickets at `<path>`; consider re-running with `--tickets=<path>` to flip ticket bodies to complete."
- **Unfinalized children:** if the target has `children:` entries other than tickets, and any child is not `implemented`, warn: "Target has child artifacts not yet implemented: <list>. Consider marking them first, or confirm this is the intended order."

Warnings are non-blocking; the mode still completes. They surface in the Phase 6 report.

### Phase 6: Report

```
[Refinery] mark-implemented complete.
[Refinery] Target: <path>
[Refinery] Status: <prev> → implemented
[Refinery] Commit: <hash or "unrecorded (warning)">
[Refinery] Tickets: <N> pending/in_progress → complete (or "not updated — --tickets not passed")
[Refinery] Warnings: <list of Phase 5 warnings, or "none">

Suggested next:
  /refine check <path>              (verify implementation matches the spec — optional but recommended)
  /refine status                    (confirm pipeline state)
```

Commit hint per `references/commit-protocol.md`:

```
spec(<basename>): mark implemented (<short-hash>)
```

### Phase 7: Dry-run exit

If `--dry-run` was passed, do **not** write any files. Print:

```
[Refinery] mark-implemented DRY RUN — no files written.
[Refinery] Would transition: <path> from <prev> → implemented
[Refinery] Would record commit: <hash or "unrecorded">
[Refinery] Would update tickets: <N> ticket bodies → complete (if --tickets passed)
[Refinery] Would append Changelog entries to: <list of paths>
[Refinery] Warnings (would surface): <list>
```

This lets users preview impact before committing. Especially useful when `--tickets` is passed against a large ticket chain.

## Edge Cases

- **Target already `implemented`:** Refuse unless `--force`. With `--force`, treat as a re-recording of provenance (update `last_updated`, new Changelog row citing the new commit).
- **Target is `drifted`:** Refuse unless `--force`. Drifted artifacts should be realigned via `/refine update` before being marked shipped; `--force` bypasses for special cases (e.g., the drift was documented elsewhere).
- **Target is `archived` or `superseded`:** Refuse without escape. An archived artifact can't be implemented; create a successor or re-open the target first.
- **Target is `principles` or `design`:** Refuse with explanatory message — those stages are not directly executable. Suggest marking a downstream `plan` or `spec` artifact instead.
- **Target has no `finalized` status (still `draft`/`iterating`/`reviewed`):** Refuse. The state machine requires `finalized` before `implemented`. Suggest `/refine finalize <path>` first.
- **`--commit` value doesn't exist in git:** Warn but do not refuse. The user may be in a worktree state that can't resolve the hash locally, or the commit lives in a fork. The bookkeeping still lands.
- **`--tickets` path is not a tickets artifact:** Refuse with a type-mismatch error. Do not silently update a non-tickets file.
- **`--tickets` has no `pending`/`in_progress` entries:** Proceed; report `0 tickets updated`. Appending a no-op Changelog row would be noise; suppress the tickets Changelog entry in this case.

## Interaction with `mode-check`

These two modes overlap slightly:

| Mode | When to use | What it does |
|------|-------------|--------------|
| `mark-implemented` | After shipping, when you know implementation matches the spec | Transitions `finalized → implemented`; records commit; fast |
| `check` (clean) | After shipping, when you want to verify before transitioning | Runs drift check; **may** offer `implemented` transition if check passes |

Use `mark-implemented` when you trust your own implementation and want the bookkeeping closed. Use `check` when you want a second opinion from the archaeologist agent. They are complementary, not competing.

`mode-check.md` Phase 6's optional `finalized → implemented` transition remains — it's the slower, drift-verified path. If you run `mark-implemented` first and then `check` later, `check` will see `status: implemented` and just append a "re-checked: still implemented" Changelog entry.

## Performance

Loads: orchestrator + this mode (~170 lines). No agent spawning; the mode operates directly on artifact files. Fast even when `--tickets` is passed against a chain of 30+ tickets — the work is just frontmatter edits and per-ticket status substitutions.
