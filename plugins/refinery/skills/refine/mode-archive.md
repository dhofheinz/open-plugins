# Mode: archive

**Purpose:** Mark an artifact as `archived` or `superseded`, encapsulating the bookkeeping (status transition, Changelog entry, optional supersession reference, optional children flagging). Per OQ-005 — provides discoverable, consistent semantics for terminal-state transitions that would otherwise rely on error-prone manual frontmatter editing.

## Inputs

- Target artifact path (required first argument)
- `--reason "<text>"` (required) — one-line justification for the archive (e.g., "superseded by v2", "abandoned, no longer in scope", "replaced by external spec")
- Optional `--as <archived | superseded>` (default `archived`)
- Optional `--replaced-by <path>` (required when `--as superseded`; sets target's `superseded_by` frontmatter field)

## Procedure

### Phase 1: Validate

Read target's frontmatter. Validate:

- File exists and is a Refinery artifact
- Current status permits the requested transition (per `references/document-format.md §7` and §10.2): `archived` and `superseded` are reachable from any non-terminal state. From a terminal state (already `archived`/`superseded`), refuse unless `--force` is set (this would change the supersession chain).

If `--as superseded`:

- Validate `--replaced-by` is provided
- Validate `--replaced-by` points to an existing artifact in the same working directory
- Optionally validate the replacement's `artifact:` type matches (a `spec` should be superseded by another `spec`, not a `plan` — warn if mismatched)

### Phase 2: Confirm (for finalized/implemented targets)

If target's current status is `finalized` or `implemented`, prompt the user via AskUserQuestion (per FR-005):

```
AskUserQuestion: "Archive a <status> artifact?"
Question text: "<target-path> is currently <status>. Archive it as '<archived|superseded>' with reason: '<reason from --reason>'?"
Options:
  - "Yes, archive"
  - "No, cancel"
```

If user cancels, exit without changes.

### Phase 3: Apply transition

Update target's frontmatter:

- `status` → `archived` or `superseded`
- `last_updated` → now
- If `--as superseded`, set `superseded_by: <relative path>`

Append Changelog entry to target:

```
| <date> | (status) | Status → <archived|superseded>[; superseded by <path>] | <reason from --reason> | archive |
```

Atomic write of the target.

### Phase 4: Optionally flag children

Read target's frontmatter `children` list.

If non-empty, AskUserQuestion:

```
Question: "Target had <N> children deriving from it. Flag them as 'drifted' (they may need re-review against the replacement artifact, if any)?"
Options:
  - "Yes, flag all <N> children as drifted"
  - "No, leave children as-is"
  - "Per-file (let me choose)" → followed by individual yes/no per child
```

For each child the user opts to flag:

- Update child's `status` to `drifted`
- Append Changelog entry to child:

```
| <date> | (status) | Status → drifted | Parent <target> <archived|superseded> on <date>; review against <replacement or "no replacement"> | archive (parent propagation) |
```

- Atomic write of the child

### Phase 5: Update replacement (if --as superseded)

If `--as superseded` and `--replaced-by` is set:

- Read the replacement artifact's frontmatter
- Append to its `references` list (if not already present): the path to the now-superseded target
- This creates a discoverable backlink from the replacement to its predecessor

### Phase 6: Report

Report (terse):

```
[Refinery] archive complete.
[Refinery] Target: <path>
[Refinery] Status: <prev> → <archived|superseded>
[Refinery] Reason: <reason from --reason>
[Refinery] Replacement: <path or "none">
[Refinery] Children flagged drifted: <count> of <total>

Suggested next:
  /refine status                          (verify graph integrity)
  /refine update <child-path> "retarget to <replacement>"   (per flagged child)
```

Commit hint per `references/commit-protocol.md`:

```
spec(<basename>): archive (<reason short form>)
```

For supersession, include bidirectional reference per `references/commit-protocol.md §4`:

> "Supersedes <prev-path> (now archived; replaced by <replacement-path>)"

## Edge Cases

- **Target has no children:** Skip Phase 4 entirely.
- **Target is already terminal (`archived` or `superseded`):** Refuse unless `--force`. With `--force`, the operation can re-classify (e.g., from `archived` to `superseded` once a replacement emerges).
- **Replacement artifact doesn't exist yet:** User can either create the replacement first (`/refine --stage=<name>` etc.), or use `--as archived` (no replacement implied) for now and supersede later.
- **Replacement is itself archived/superseded:** Warn but allow (`--force` to confirm). User may be archiving an obsolete predecessor that pointed to an obsolete replacement.
- **Cyclic supersession** (A superseded by B; B superseded by A): Detect and refuse. This violates the artifact graph DAG property.
- **`--as superseded` without `--replaced-by`:** Refuse with explicit error: "Supersession requires --replaced-by <path>".
- **No `--reason` provided:** Refuse with: "Archive requires --reason '<text>' for the Changelog entry."

## Read-Only Variant (preview)

If invoked as `/refine archive <path> --reason "..." --dry-run`, do not write any files. Print the intended changes:

- Status transition that would happen
- Children that would be flagged (with their current status)
- Changelog entries that would be appended
- Suggested commit message

This lets users preview impact before committing.

## Performance

Loads: orchestrator + this mode (~110). No agent spawning; the mode operates directly on artifact files. Fast even for hundreds of artifacts (only target + children-list children are read).

## Why a Mode (Not Manual Editing)

Per OQ-005 resolution:

- **Discoverability:** Users browsing `/refine` modes see archive as a first-class operation
- **Consistency:** Bookkeeping (Changelog entry, last_updated, supersession backlink) is uniform
- **Bidirectional graph integrity:** Children-flagging is automated; manual editing risks forgetting
- **Audit trail:** Changelog records the archive intent + reason in a parseable format

Manual frontmatter editing remains possible but is no longer the recommended path.
