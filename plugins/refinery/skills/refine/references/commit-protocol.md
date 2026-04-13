# Reference: Commit Protocol

Recommended commit-message convention for spec changes. **Reference only — the plugin does not execute commits.** Mode files cite this reference in their "Suggested next" output, providing users a copy-pasteable commit message they can apply via their preferred commit workflow (`/commit`, the OpenPlugins `git-commit-assistant` plugin, or manual `git`).

Per OQ-012 resolution: spec changes should be versioned, but auto-execution belongs to dedicated commit tooling, not Refinery.

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
| `tickets` | `spec(<basename>): tickets (<N> across <M> waves)` | `spec(billing-plan): tickets (23 across 4 waves)` |
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

The `git-commit-assistant` plugin in this same marketplace can read the artifact's Changelog and Iteration Log to auto-generate a commit message in the format above. Mode files MAY suggest:

```
Suggested commit message (use /commit or git-commit-assistant):

  spec(<basename>): <subject>

  <body>

  Refinery-Op: <op>
```

But the plugin itself never runs `git commit`. The user invokes their commit workflow when ready.

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

## 9. What This Reference Is NOT

- Not an automation. The plugin does not execute `git commit`.
- Not a hook. There is no PostToolUse hook that auto-commits (per OQ-009 deferring hooks).
- Not enforced. Users may use any commit format they prefer; this is a recommendation that mode files cite for users who want consistency.
- Not a replacement for `git-commit-assistant`. That plugin handles the actual commit workflow; this reference defines the message format it can consume.
