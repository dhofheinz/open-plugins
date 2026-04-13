# Reference: Convergence Model

Canonical definition of the convergence metrics, calculation formulas, stop conditions, and iteration log discipline used by `mode-iterate.md`. This is the **single source of truth** for convergence behavior.

## 1. Purpose

The convergence model governs the iterative refinement loop. Its purpose is to **terminate the loop** at the point where additional automated research yields diminishing returns relative to human review. Without convergence stop conditions, an iteration loop either burns context indefinitely or stops arbitrarily.

## 2. Tracked Metrics

Three metrics are tracked in every artifact's `convergence` frontmatter block. All three are recalculated on every write.

### 2.1 `questions_stable_count`

**Definition:** Count of consecutive iterations where `open_questions_count` did not change.

- Reset to `0` if `open_questions_count` changes between iterations
- Increment by `1` if `open_questions_count` is unchanged

**Indicates:** Research has plateaued; remaining questions likely require human input.

### 2.2 `open_questions_count`

**Definition:** Count of entries in the artifact's Open Questions table with status `OPEN`.

**Excluded from count:** Entries marked `RESOLVED`, `DEFERRED`. Entries marked `NEW` (newly identified in the current iteration but not yet researched) are treated as `OPEN` for the **next** iteration's count, but for the current iteration's metric they are counted in `open_questions_count` (they represent uncertainty surface).

**Indicates:** Residual uncertainty surface.

### 2.3 `high_confidence_ratio`

**Definition:** Computed as:

```
high_confidence_ratio = high_count / (high_count + medium_count + open_questions_count)
```

Where:

- `high_count` = number of tracked claims (FR, NFR, INV, RD, R, P, FM, technology entries, components, etc.) tagged `Confidence: High` in the artifact body
- `medium_count` = number tagged `Confidence: Medium`
- `open_questions_count` = OPEN questions (counted as potential claims that don't yet exist)

**Range:** 0.0 to 1.0.

**Indicates:** Spec maturity — what fraction of the artifact is well-supported.

**Edge case:** If `high_count + medium_count + open_questions_count == 0` (empty artifact), define `high_confidence_ratio = 0.0`.

## 3. Stop Conditions

The loop stops after **at least 2 iterations** (minimum-iterations floor) if any of these conditions hold:

| Condition | Threshold | Meaning |
|-----------|-----------|---------|
| Stability | `questions_stable_count >= 2` | Question count unchanged for 2 consecutive iterations; research exhausted |
| Low question count | `open_questions_count <= 3` | Few enough questions for direct human review |
| High confidence | `high_confidence_ratio > 0.80` | 80%+ of tracked claims well-supported; remaining likely needs human judgment |

The loop **always stops** at iteration `max_iterations` (default 5) regardless of whether any condition has been met (max-iterations cap).

## 4. Configurable Thresholds

Via flags on `/refine iterate <path>`:

| Flag | Default | Effect |
|------|---------|--------|
| `--max-iterations=N` | 5 | Override the iteration cap. Must be ≥ 2. |
| `--converge-on=any` (default) | n/a | Stop on any of the three conditions. |
| `--converge-on=stable_count` | n/a | Stop only on stability (`questions_stable_count >= 2`). |
| `--converge-on=low_count` | n/a | Stop only on low question count (`open_questions_count <= 3`). |
| `--converge-on=high_confidence` | n/a | Stop only on high confidence ratio (`high_confidence_ratio > 0.80`). |

## 5. Iteration Loop Procedure (recap)

`mode-iterate.md` runs:

```
WHILE iteration < max_iterations:
  iteration += 1
  
  # Phase 2a: spec-critic identifies ambiguities (RESEARCHABLE / HUMAN_NEEDED / DERIVABLE / OUT_OF_SCOPE)
  # Phase 2b: code-archaeologist researches RESEARCHABLE items (skip if no codebase)
  # Phase 2c: spec-scribe integrates findings, updates Open Questions, recalculates convergence
  
  Append iteration log entry.
  Recompute convergence metrics from artifact body.
  
  IF iteration < 2: continue  # Minimum-iterations floor
  IF stop conditions met (per --converge-on): stop
```

After the loop terminates, transition status `iterating` → `reviewed`.

## 6. Iteration Log Discipline

Every iteration appends one entry to the artifact's Iteration Log section. Format:

```markdown
### Iteration N (YYYY-MM-DD)
- **Operation:** iterate
- **Researched:** <topics investigated by code-archaeologist>
- **Resolved:** <N questions → High Confidence: FR-X, FR-Y, …>
- **Added:** <N High, N Medium confidence items>
- **New questions:** <N discovered (with brief description)>
- **Still open:** <N questions remain>
- **Convergence:** stable_count=N, open=N, ratio=N.NN
- **Stop reason** (last iteration only): max_iterations | stable_count | low_count | high_confidence
```

Iteration numbers are **monotonic**. Iteration 0 is reserved for "initial draft" (created by `mode-advance`). Iteration 1+ is for refinement operations. The artifact's `iteration` frontmatter field reflects the highest iteration number in the log.

## 7. Convergence in Non-Spec Artifacts

The same convergence model applies to all artifact types with the following adaptations:

- **principles:** "claims" are Hard Invariants (`INV-NNN`) and Core Principles (`P-NNN`). Confidence is High when derived from explicit user statement or evident from the seed idea; Medium when extrapolated; Low when speculative.
- **design:** "claims" are subsystems, decomposition decisions, failure modes (`FM-NNN`). Confidence grounded in upstream principles + explicit reasoning.
- **stack:** "claims" are technology choices. Confidence is High when justified by a specific design constraint with stated tradeoffs; Medium when a reasonable default; Low when speculative.
- **plan:** "claims" are phases, components with type signatures, acceptance criteria. Confidence is High when the spec's requirements clearly drive them; Medium when inferred; Low when missing detail.
- **tickets:** Convergence is **N/A**. Tickets are derived from a `finalized` plan and iterate at the plan level, not the ticket level. The tickets artifact transitions `draft → finalized` directly via the validation in `mode-tickets.md` Phase 3, with no `iterating`/`reviewed` intermediate states. The convergence frontmatter block may be omitted from tickets artifacts (or set to `null`).

## 8. Implicit Resume

If an `iterate` invocation is interrupted (e.g., agent crash, user cancel), the next `/refine iterate <path>` invocation resumes naturally:

- Read target's frontmatter `iteration: N`
- Start at `iteration = N + 1`
- Continue the loop from there

No special "resume mode" or recovery logic is needed. The artifact's frontmatter IS the resume point. Per OQ-006.

## 9. Greenfield Degradation

If the project has no source code (greenfield) or no relevant files for the artifact's domain, the convergence loop's research phase (Phase 2b) reports the absence and **reclassifies** all RESEARCHABLE ambiguities to HUMAN_NEEDED for the artifact's Open Questions section. Convergence still progresses (stable_count typically reaches 2 within 2-3 iterations once the same human-needed questions persist).

## 10. Diagnostic Output

In `--verbose` mode, after each iteration print:

```
[Refinery] Iteration N: stable_count=A, open=B (was C), high_ratio=D.DD (was E.EE)
[Refinery]   Critic flagged: X RESEARCHABLE, Y HUMAN_NEEDED, Z DERIVABLE
[Refinery]   Archaeologist resolved: P findings (Q High, R Medium, S Low)
[Refinery]   Scribe applied: T edits (U new High, V new Medium, W moved to Open Questions)
[Refinery]   Stop conditions: stability=<met|not>, low_count=<met|not>, high_ratio=<met|not>
```

In default (terse) mode, only print the per-iteration summary and the final stop reason.
