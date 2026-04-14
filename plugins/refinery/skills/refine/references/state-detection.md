# Reference: State Detection

Canonical algorithm for scanning a Refinery working directory and constructing the artifact graph. Used by `mode-status.md`, the orchestrator's auto-detection, and any operation that needs to validate state transitions.

## 1. Inputs

- Working directory path (resolved per orchestrator §"Working Directory")
- (Optional) project root for cross-artifact references

## 2. Algorithm

```
artifact_graph = {}

FOR each *.md file in working_dir (recursively):
  Read frontmatter (YAML block between leading `---` markers)
  IF frontmatter contains "artifact:" field:
    Validate "artifact:" value is one of: principles, design, stack, spec, feature-spec, plan, tickets
    Record:
      key = relative path (from working_dir)
      value = {
        path,
        artifact_type,
        scope,
        feature,
        stage,
        iteration,
        last_updated,
        status,
        parent,
        children,
        references,
        convergence: {questions_stable_count, open_questions_count, high_confidence_ratio},
        source_documents,
        superseded_by,
        plugin_version
      }
    Add to artifact_graph
  ELSE:
    Skip (not a Refinery artifact; could be _conventions.md, _glossary.md, a pointer file [frontmatter `pointer: true`], README.md, or unrelated)

FOR each artifact in artifact_graph:
  Validate frontmatter required fields per `references/document-format.md §1`
  Validate status is in the valid set for the artifact type per §1.7 status compatibility matrix
  Validate parent reference resolves to an artifact in the graph (or is null)
  Validate bidirectional graph integrity (INV-001):
    IF artifact.parent != null:
      assert artifact.parent in artifact_graph
      assert artifact.path in artifact_graph[artifact.parent].children
  Validate INV-002 (high_confidence_ratio matches body) — ONLY if a recompute is requested by the calling mode
  Validate INV-003 (open_questions_count matches body) — ONLY if a recompute is requested by the calling mode
  Validate INV-004 (no deleted IDs reused) — ONLY if a recompute is requested by the calling mode
  Validate INV-005 (source_documents resolve)
  Validate INV-006 (iteration log monotonic) — ONLY if a recompute is requested
  
  Compute "needs_attention" flags:
    - missing_children: artifact has type X but no expected child Y exists
    - drifted_status: status == "drifted"
    - high_open_questions: open_questions_count > 5
    - low_confidence: high_confidence_ratio < 0.6
    - stale_relative_to_parent: last_updated < parent.last_updated (potential drift indicator)
    - terminal_with_active_children: status in {archived, superseded} but children.status not in {archived, superseded, drifted}

Return {
  artifacts: artifact_graph,
  validation_errors: [list of any failures],
  pipeline_state: derived pipeline state (see §3),
  needs_attention: [list of flagged artifacts]
}
```

## 3. Pipeline State Derivation

After scanning, classify the pipeline state by detecting which stages exist and at what status:

```
expected_pipeline = []
IF any artifact has scope="system":
  expected_pipeline = [principles, design, stack, spec, plan, tickets]  # any may also have feature-specs as siblings
IF any artifact has scope="feature":
  per-feature expected_pipeline = [feature-spec, plan?, tickets?]
IF working_dir empty:
  expected_pipeline = []  # no pipeline yet

For each stage in expected_pipeline:
  IF stage not present:
    flag missing_stage(stage)
  ELSE IF stage present but status in {draft, iterating}:
    flag incomplete_stage(stage, status)
  ELSE IF stage present and status == drifted:
    flag drifted_stage(stage)
```

## 4. Suggested Next Action

Based on `needs_attention` flags, suggest the highest-priority next action. Priority order (top to bottom):

1. Any `validation_error` → fix the artifact first; suggest `/refine update <path>` or report to user.
2. Any artifact with `terminal_with_active_children` → `/refine archive <child>` for each child or `/refine update <child>` to retarget to replacement.
3. Any artifact with `drifted_status` → `/refine update <path> "address drift"` (or, if user wants to re-validate first, `/refine check <path>`).
4. Any artifact with `incomplete_stage` (status `draft` or `iterating`) → `/refine iterate <path>` (if convergence not yet reached) or `/refine review <path>` (if iterations exhausted) or `/refine finalize <path>` (if reviewed and questions remain).
5. Any `missing_stage` in the expected pipeline → `/refine --stage=<name>` to advance.
6. If everything finalized but no tickets exist for a finalized plan/spec → `/refine tickets <path>`.
7. If everything finalized, tickets are complete, but the artifact isn't yet `implemented` → `/refine mark-implemented <path> --commit=<hash>` (lightweight) or `/refine check <path>` (drift-verified).
8. If everything implemented and no recent check → `/refine check <path>` to verify implementation matches.
9. Otherwise → no action suggested; pipeline is healthy.

## 5. Validation Rules (formalized)

| Rule | Source | Failure handling |
|------|--------|------------------|
| Frontmatter parses as YAML | Standard | Report parse error; treat artifact as malformed |
| `artifact` field exists and is in the seven-value set | §9.1 (document-format §1) | Skip artifact (not Refinery-managed) |
| `status` field in valid set for artifact type | §9.7 status matrix | Report invalid status; suggest `/refine update` to correct |
| `parent` is null or resolves to existing artifact | §10.4 INV-001 | Report dangling parent reference |
| `parent.children` includes this artifact's path | §10.4 INV-001 | Report bidirectional graph violation; suggest `/refine update <parent>` |
| `iteration ≥ 0` | §9.1 | Report invalid iteration |
| `convergence.*` non-negative | §9.1 | Report invalid convergence values |
| `source_documents.*.path` resolves | §10.4 INV-005 | Report dangling source reference |

Recompute-only validation rules (only invoked when caller asks for full validation, e.g., before `finalize`):

| Rule | Source | Failure handling |
|------|--------|------------------|
| `high_confidence_ratio` matches actual body | INV-002 | Recompute and write back; log discrepancy |
| `open_questions_count` matches actual body | INV-003 | Recompute and write back; log discrepancy |
| No deleted IDs reused | INV-004 | Refuse the operation; report which ID was reused |
| Iteration log monotonically increases | INV-006 | Refuse the operation; report which entry is out of order |

## 6. Performance Notes

- **Frontmatter-only reads** are cheap. Use the YAML-block-only read pattern (read first 50-100 lines and stop at the second `---`) when scanning many artifacts.
- **Full body reads** are expensive for INV-002/003/004/006 recomputation. Only do these when the caller explicitly requests full validation.
- **Glob with frontmatter filter** is efficient for first-pass detection: `Glob: <working-dir>/**/*.md`, then frontmatter-read each match.

For NFR-P-002 budget compliance, `mode-status.md` reads frontmatter only (no body reads). Total context cost: orchestrator (~170 lines) + mode-status (~100 lines) + N × (frontmatter ~30 lines per artifact). Well under the 600-line budget for typical projects.
