# Reference: Commit Protocol

Recommended commit-message convention for spec changes. **Reference only — the plugin does not execute commits and installs no hooks that would** (per OQ-009 deferring hooks to a later version; per OQ-012 reserving commit-execution for dedicated commit tooling). Users apply messages via their preferred commit workflow (slash-command helpers, external commit tooling, or manual `git`).

Mode files cite this reference in their "Suggested next" output to provide copy-pasteable subject lines. The message shape defined here is a recommendation, not an enforcement — any commit format that communicates the change is acceptable.

## 1. Subject Line

Format:

```
spec(<artifact-basename>): <imperative summary>
```

- **Prefix:** `spec(<basename>):` where `<basename>` is the artifact's filename without `.md` (e.g., `system-spec`, `billing-plan`, `user-auth-spec`).
- **Imperative mood:** "add", "remove", "update", "finalize" (not "added", "adding").
- **Length:** ≤ 72 characters total (including prefix).
- **No trailing period.**

### Special-case prefixes

| Operation | Subject prefix | Example |
|-----------|---------------|---------|
| `advance` (new artifact) | `spec(<basename>): seed from <source>` | `spec(billing-design): seed from billing-principles` |
| `iterate` (one or more iterations) | `spec(<basename>): iterate (i<N>)` | `spec(system-spec): iterate (i3)` |
| `review` (report written) | `spec(<basename>): review report <YYYY-MM-DD>` | `spec(user-auth-spec): review report 2026-04-13` |
| `finalize` | `spec(<basename>): finalize` | `spec(system-spec): finalize` |
| `update` | `spec(<basename>): <change description>` | `spec(system-spec): add rate limiting requirement` |
| `check` (no drift) | `spec(<basename>): check (clean)` | `spec(system-spec): check (clean)` |
| `check` (drift detected) | `spec(<basename>): drift (<N> findings)` | `spec(system-spec): drift (4 findings)` |
| `tickets` (waves) | `spec(<basename>): tickets (<N> across <M> waves)` | `spec(billing-plan): tickets (23 across 4 waves)` |
| `tickets` (sequence) | `spec(<basename>): tickets (<N> steps, linear)` | `spec(auth-plan): tickets (5 steps, linear)` |
| `archive` | `spec(<basename>): archive (<reason>)` | `spec(legacy-spec): archive (superseded by system-spec v2)` |
| `init` | `spec: init refinery working directory` | `spec: init refinery working directory` |

## 2. Body

The commit body is **derived from the artifact's most recent Changelog entries**. Format:

```
<short rationale paragraph (1-3 sentences)>

Changelog entries:
- <date> | <section> | <change> | <reason>
- <date> | <section> | <change> | <reason>
- …

Affected artifacts:
- <path> (modified)
- <path> (drifted) [if applicable]
- <path> (children flagged for re-review) [if applicable]
```

Keep body lines ≤ 100 characters.

## 3. Trailers

Optional machine-readable trailers (for downstream tooling that parses commit messages):

```
Refinery-Op: <operation name>
Refinery-Iteration: <N>
Refinery-Status-Transition: <from> -> <to>
Refinery-Convergence: stable=<N>, open=<N>, ratio=<N.NN>
```

Trailers go after the body, separated by a blank line. Use `:` (not `=`) per the conventional-commits trailer format.

## 4. Bidirectional References

When a commit removes or supersedes a tracked claim, reference the replacement explicitly:

- "Removes FR-007 (superseded by FR-014)"
- "Marks INV-003 as [DELETED — moved to feature-spec]"
- "Supersedes legacy spec docs/specs/billing-old.md (now archived)"

This makes git log searches (`git log --all --grep=FR-007`) find both the removal and the replacement.

## 5. Multi-Artifact Commits

If an operation modifies multiple artifacts (e.g., `update` on a parent flags children as drifted), the commit subject names the **primary** artifact; the body lists all affected artifacts:

```
spec(system-design): refactor subsystem decomposition

Subsystem boundaries adjusted to separate observability from
infrastructure concerns. Children flagged for re-review.

Affected artifacts:
- docs/refinery/system-design.md (modified)
- docs/refinery/system-spec.md (children flagged drifted)
- docs/refinery/system-stack.md (children flagged drifted)

Refinery-Op: update
Refinery-Status-Transition: finalized -> finalized (children: drifted)
```

## 6. Squash and Merge Convention

For multi-iteration sessions on a single artifact, prefer **one commit per logical unit** rather than one per iteration:

- **Atomic commit:** `spec(X): iterate (i3)` after the loop completes
- **Avoid:** `spec(X): iterate (i1)`, `spec(X): iterate (i2)`, `spec(X): iterate (i3)` as three separate commits

The Iteration Log preserves the per-iteration history within the artifact; git history doesn't need to duplicate it.

## 7. Integration with Other Workflows

This reference defines the message format; other tools consume it. Any commit-authoring workflow — a dedicated commit-assistant plugin, an editor helper, or plain `git commit` — can read the artifact's Changelog and Iteration Log to generate a commit message in the format above. Mode files MAY suggest:

```
Suggested commit message:

  spec(<basename>): <subject>

  <body>

  Refinery-Op: <op>
```

Refinery does not execute commits itself. This file says how messages should look; the user's chosen commit workflow handles the `git commit` execution.

## 8. Examples

### Example 1: Iteration loop completes with convergence

```
spec(system-spec): iterate (i3)

Stopped at iteration 3: high_confidence_ratio (0.84) exceeds
threshold (0.80). 2 questions resolved via codebase research, 1
new question discovered (CSRF token rotation policy).

Changelog entries:
- 2026-04-13 | Requirements | Added FR-031: Rate limiting on /api/* | iterate (i3)
- 2026-04-13 | Requirements | Modified FR-008: clarified session lifetime to 4h | iterate (i3)

Refinery-Op: iterate
Refinery-Iteration: 3
Refinery-Status-Transition: iterating -> reviewed
Refinery-Convergence: stable=1, open=4, ratio=0.84
```

### Example 2: Drift check with findings

```
spec(billing-spec): drift (4 findings)

Drift check found 1 MISSING (FR-035), 1 DIVERGED (FR-022),
2 PARTIAL (FR-018, FR-029). Status transitioned finalized -> drifted.

Affected artifacts:
- docs/refinery/billing-spec.md (status: drifted)
- docs/refinery/billing-spec-check-2026-04-13.md (new check report)

Refinery-Op: check
Refinery-Status-Transition: finalized -> drifted
```

### Example 3: Archive with supersession

```
spec(legacy-billing): archive (superseded by billing v2)

Original billing spec archived; replaced by docs/refinery/billing-spec.md
following the v2 redesign. Children flagged for retargeting.

Affected artifacts:
- docs/refinery/legacy-billing.md (status: superseded)
- docs/refinery/legacy-billing-plan.md (children flagged drifted)

Refinery-Op: archive
Refinery-Status-Transition: finalized -> superseded
```

## 9. Commit Granularity: Vertical Slicing

A Refinery commit represents one coherent change to the artifact graph, not one mode's bookkeeping. Each mode emits a per-operation **subject-line hint** (per §1's special-case table) that is useful as an *ingredient* for a commit message — but a commit typically bundles several operations that together complete a logical unit.

### 9.1 Why not commit per operation

Two parallel histories already exist:

- The artifact's **Changelog** records every modification — one row per discrete edit, per `document-format.md §2.3`.
- The artifact's **Iteration Log** records each iterate-loop invocation with its convergence delta, per `convergence.md §6`.

Git history does not need to duplicate either. Its role is different: it records when *features*, *fixes*, and *decisions* landed in the repository, not when the bookkeeping happened. A commit message that says `spec(X): iterate (i3)` tells the reader nothing the Iteration Log didn't already; a commit that says `feat(X): introduce rate-limited auth flow` tells the reader what the repository gained.

### 9.2 Common Refinery vertical slices

| Vertical slice | Operations bundled | Example subject |
|----------------|--------------------|-----------------|
| **Feature introduction** | `advance(feature-spec)` + `iterate` + `finalize` (maybe `review`) | `feat(spec): introduce rate-limited auth flow` |
| **Pipeline advancement** | `advance(<stage>)` + `iterate` + `finalize` at one stage | `feat(spec): finalize system design` |
| **Feature decomposition** | `plan` + `tickets` from a finalized spec | `feat(plan): decompose rate-limited auth into 7 tickets` |
| **Feature shipping** | Implementation commits (outside Refinery) + `mark-implemented` | `feat(auth): ship rate-limited auth flow` (mark-implemented records this commit's hash) |
| **Drift realignment** | `check` + `update` | `fix(spec): address drift in rate-limit middleware` |
| **Traceable refinement** | `update` (with any child-drift propagation) | `refactor(spec): replace Redis with in-memory token bucket` |
| **Archive / supersession** | `archive` + any child-drift propagation | `chore(spec): archive v1 auth spec (superseded by v2)` |

These are patterns, not rules. The right slice is whatever "change of state to the repository" the commit represents.

### 9.3 Litmus test

Before committing, ask: **"Could this commit be cleanly reverted to undo one coherent change?"**

- If reverting would remove **half a feature**, the commit is too granular — combine it with the adjacent operation.
- If reverting would remove **two unrelated features**, the commit is too broad — split it.
- If reverting would remove **exactly one coherent thing** (one feature introduced, one drift fixed, one artifact archived), the granularity is right.

### 9.4 Anti-pattern: horizontal slicing

A Refinery pipeline (`advance → iterate → finalize → tickets → mark-implemented`) naturally produces per-operation commit hints. Following them literally yields **horizontal slicing**: one commit per layer of the pipeline, none of which corresponds to a coherent feature in the repository.

```
# Horizontal (anti-pattern)
spec(auth-spec): seed from design
spec(auth-spec): iterate (i2)
spec(auth-spec): finalize
spec(auth-plan): seed from auth-spec
spec(auth-plan): finalize
spec(auth-tickets): tickets (7 across 3 waves)

# Vertical (preferred)
feat(spec): introduce rate-limited auth flow
feat(plan): decompose rate-limited auth into 7 tickets
```

The pipeline's per-operation history lives in the artifacts themselves (Changelog + Iteration Log). The repository's history is about features, fixes, and decisions — not how the AI organized its writing.

### 9.5 Branch-workflow users: squash does the bundling

In a feature-branch workflow with squash-on-merge, per-operation commits are fine *inside the feature branch* — the squash step at merge produces the vertical slice automatically. In that case, follow the per-operation hints as you go; the final merge commit is where vertical slicing matters.

§6 covers the squash-merge convention; think of this section (§9) as the principle, and §6 as its instantiation for branch workflows.

### 9.6 Main-workflow users: bundle manually

Committing directly to `main`/`master`/`trunk`, or on a feature branch that will merge via rebase (preserving commits), means there is no squash step to consolidate. The vertical-slicing bundling has to happen before `git commit`:

- Run multiple Refinery operations without committing between them.
- At the logical boundary, review the accumulated `git status` / `git diff` and commit once.
- Derive the commit message from the operations' per-operation hints (pick the dominant one, or compose a new subject that captures the bundle).

The Refinery Changelog still records each operation individually; the commit captures the external consequence.

### 9.7 Manual workflow detection (optional)

Users who want to self-check their current workflow can run:

```bash
git symbolic-ref --short HEAD
```

If the output matches `main`, `master`, `trunk` (or the team's integration branch), apply §9.6. Otherwise apply §9.5. This plugin does not run the check automatically — the recommendation is advisory.
