# Mode: update

**Purpose:** Apply traceable modifications to an existing artifact. Categorizes the change, assesses blast radius, applies edits with strict ID preservation discipline, and propagates impact to children.

## Inputs

- Target artifact path (required first argument)
- Change description (required, second argument as a quoted string, e.g., `"add rate limiting requirement"`)

## Procedure

### Phase 1: Validate

Read target. Determine current `status`. Validate the change description is non-empty.

If `status` is `finalized`, `implemented`, or `drifted`, request user confirmation per FR-005 / NFR-R-003:

```
AskUserQuestion: "Target is in <status> status. Update may invalidate downstream artifacts. Proceed?"
Options:
  - "Yes, proceed (I will handle downstream propagation)"
  - "Yes, and auto-flag children as drifted"
  - "No, cancel"
```

The user's choice affects Phase 4 (propagation).

### Phase 2: Spawn spec-scribe for analysis + application

Spawn agent `refinery:spec-scribe` via the `Agent` tool with:

- Full target artifact content
- The change description
- Reference: `${CLAUDE_SKILL_DIR}/references/document-format.md` (for ID conventions, INV discipline)
- Instruction to:
  1. **Categorize** the change (Additive / Modificative / Subtractive / Corrective)
  2. **Assess blast radius**: which requirements / ACs / data models / sections / cross-references are affected
  3. **Apply changes** following discipline:
     - Never reuse deleted IDs (INV-004)
     - Mark deletions as `[DELETED — <reason>]` rather than removing (FR-036, AC-FR-036-1)
     - Update all cross-references when a target's ID/title changes
     - Append Changelog entries (one per discrete change; FR-035, AC-FR-035-1)
     - Update `last_updated`
  4. **Recompute convergence metrics** (open_questions_count, high_confidence_ratio, INV-002 + INV-003)
  5. **Return** updated artifact + structured change summary

Receive the updated artifact and the change summary.

### Phase 3: Apply changes

Validate the spec-scribe's output:

- Frontmatter integrity preserved
- All edits respect ID discipline (no INV-004 violation)
- Universal sections still present
- Convergence metrics match recomputation

Atomic write of the updated artifact per `${CLAUDE_SKILL_DIR}/references/operation-bookkeeping.md §1`.

### Phase 4: Cross-artifact propagation

Apply the child-drift-propagation procedure per `${CLAUDE_SKILL_DIR}/references/operation-bookkeeping.md §4`, with these parameters:

- **Parent change type:** whichever artifact type the target is (use §4.1's parent-type matrix).
- **Change category:** the Additive / Modificative / Subtractive / Corrective classification spec-scribe produced in Phase 2 (use §4.1's category matrix — skip children when the change is Additive or Corrective).
- **Change summary (for child Changelog rows):** the user-supplied change description from the invocation's second argument.
- **Operation name:** `update`
- **Prompt variant:** Phase 1's AskUserQuestion already captured the user's choice between auto-flag, per-file confirm, and cancel. §4.2's prompt is suppressed when Phase 1 said "Yes, and auto-flag" (user already consented); it's invoked when Phase 1 said "Yes, proceed (I will handle downstream propagation)" to let the user choose per-file; and Phase 4 is skipped entirely if Phase 1 said "No, cancel" (the mode won't reach this phase).

Print after propagation: `"Children that may need re-review: <list of paths and reason per child>"`.

### Phase 5: Report

Report (terse):

```
[Refinery] update complete.
[Refinery] Change category: <Additive | Modificative | Subtractive | Corrective>
[Refinery] Affected sections: <list>
[Refinery] Changelog entries added: <N>
[Refinery] Convergence: <delta from prior>
[Refinery] Children flagged: <count> of <total>

Suggested next:
  /refine review <target-path>           (assess updated artifact's quality)
  /refine iterate <target-path>          (if open questions resulted from change)
  /refine update <child-path> "..."      (per flagged child)
  /refine check <target-path>            (re-validate against codebase)
```

Commit hint per `${CLAUDE_SKILL_DIR}/references/commit-protocol.md` (see §9 on commit granularity for when to bundle):

```
spec(<basename>): <change description short form>
```

(For Modificative and Subtractive changes, include bidirectional references in body per `references/commit-protocol.md §4`.)

## Edge Cases

- **Change is too vague for spec-scribe to apply:** spec-scribe should refuse and request a more specific description. Mode then surfaces this to user via AskUserQuestion: "Spec-scribe couldn't apply '<vague desc>'. Please refine: …"
- **Change introduces a new Open Question:** spec-scribe adds it to the OQ table with status NEW. The convergence metrics adjust accordingly.
- **Change deletes a requirement that has children referencing it:** spec-scribe applies the [DELETED] marker, preserves the ID; cross-artifact propagation in Phase 4 surfaces the references for child updates.
- **Multi-part change in one update call** (e.g., "add rate limiting AND remove FR-007"): spec-scribe handles both atomically (multiple Changelog entries) but consider asking the user to split into two updates for clearer history.
- **Update on `tickets` artifact:** Tickets are derived; manual edits should be rare. If user wants to refine a ticket, they typically re-run `/refine tickets <plan-path>` to regenerate. Update is supported but warns: "Tickets are derived; consider regenerating from plan instead."
- **Update on `archived` or `superseded` artifact:** Refuse with "Cannot update an archived/superseded artifact. Update its replacement instead, or unarchive first via manual frontmatter edit (with caution)."

## Idempotency

If the user runs `/refine update <path> "<exact same change>"` twice, the second invocation should detect that the change has already been applied (e.g., the requested addition exists). Two acceptable behaviors:

1. **No-op:** Report "Change already applied; no modification" and exit
2. **Re-validate:** Re-spawn spec-scribe to verify and emit a no-op Changelog entry

The mode chooses **no-op detection** by default (cheaper). User can `--force` to re-apply.

## Performance

Loads: orchestrator + this mode (~140) + spec-scribe agent. Spec-scribe receives full artifact + change description; output is the updated artifact. Cross-artifact propagation in Phase 4 reads only frontmatter of children (cheap).
