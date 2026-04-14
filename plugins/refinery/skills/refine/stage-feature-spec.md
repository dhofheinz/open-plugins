# Stage: feature-spec

**Pipeline position:** Stage 4 (feature-level). Creates a feature-scoped specification, optionally as a child of a system spec or a parent feature-spec (per OQ-010, nested feature-specs are supported).

## Inputs

- Feature name (single token, kebab-case) — required (passed as the first argument to `mode-advance`)
- Optional `--parent <path>` — system spec OR another feature-spec (for nested sub-features per OQ-010); if omitted, the spec is standalone
- Output path (default: `<working-dir>/features/<feature>-spec.md`, or `<working-dir>/features/<parent-feature>/<feature>-spec.md` for nested)

## Agents

Two-phase agent flow:

1. **Intake:** `refinery:requirements-interviewer` (model: `${user_config.specialist_model}` or `sonnet`)
2. **Synthesis:** `refinery:spec-writer` (model: `${user_config.spec_writer_model}` or `sonnet`)

## Template

`${CLAUDE_SKILL_DIR}/templates/feature-spec.md`

## Procedure

### Phase 1: Resolve parent + output path

If `--parent <path>` was specified:

- Validate the parent exists and its `artifact:` is `spec` or `feature-spec`
- For nested feature-specs (`--parent <feature-spec-path>`): validate that nesting is permitted (per OQ-010, any feature-spec may have child feature-specs); set output path to `<parent-dir>/<parent-feature>/<feature>-spec.md` (e.g., `docs/refinery/features/billing/invoicing-spec.md`)

If no `--parent` specified:

- Auto-detect: if the working directory contains a system-spec, AskUserQuestion: "Should this feature be a child of <system-spec-path>?" (Default yes; if no, the feature-spec is standalone.)
- If no system-spec exists, create as standalone

### Phase 2: Intake (requirements-interviewer)

Spawn agent `refinery:requirements-interviewer` with prompt:

```
You are conducting structured intake for a new feature spec.

# Inputs
- Feature name: <feature>
- Parent (if any): <parent path or "standalone">
- Project root: <root>
- Reference: ${CLAUDE_SKILL_DIR}/references/requirement-syntax.md
- AskUserQuestion is your primary tool — batch related questions (max 4 per call)

# Workflow

Conduct your standard interview flow per your system prompt:

1. Batch 1 — Core Purpose: problem, who has it, success criteria
2. Batch 2 — Scope: explicit non-goals, interactions with existing features, hard constraints
3. Batch 3 — Context: adapt based on whether feature is user-facing, technical, or integration-focused
4. Batch 4 — Codebase Verification: scan for similar features, surface findings as confirmation questions

# Constraints

- Max 4 questions per AskUserQuestion call
- Don't ask questions answerable by reading the codebase — research them yourself with Glob/Grep
- Don't ask premature implementation details
- Track answers; surface unknowns as Open Questions for the synthesis phase

# Output

Return a structured intake summary:
- Feature purpose (in user's words)
- Goals + non-goals
- Key user journeys (or technical flows)
- Hard constraints
- Codebase findings (similar features, patterns to follow, with file:line evidence)
- Open Questions surfaced (HUMAN_NEEDED or RESEARCHABLE not-yet-resolved)
```

Receive the intake summary.

### Phase 3: Synthesis (spec-writer)

Spawn agent `refinery:spec-writer` with prompt:

```
You are filling the feature-spec template using the intake summary as the source of truth.

# Inputs
- Feature name: <feature>
- Parent: <parent path or "standalone">
- Intake summary: <full content from requirements-interviewer>
- Template path: ${CLAUDE_SKILL_DIR}/templates/feature-spec.md
- Output path: <output-path>
- Reference: ${CLAUDE_SKILL_DIR}/references/document-format.md
- Reference: ${CLAUDE_SKILL_DIR}/references/requirement-syntax.md (EARS for FRs, GWT for ACs)

# Constraints

1. **EARS for all FRs.** No "should" without strong reason. Use the six EARS patterns; flag any that don't fit.

2. **GWT for all ACs.** Every FR has ≥1 AC. Each AC has Given / When / Then. Atomic, deterministic, observable.

3. **Codebase-grounded.** Cite file:line in Evidence wherever the intake produced findings. Mark items without evidence as Low confidence + Open Question.

4. **Inherits from parent.** If parent is a system-spec or another feature-spec, its constraints flow down. Don't restate them; reference them.

5. **Confidence on every claim.**

# Workflow

1. Read template at ${CLAUDE_SKILL_DIR}/templates/feature-spec.md.
2. Map intake content to template sections:
   - Overview ← intake purpose
   - Context ← intake current state + problem statement
   - Scope ← intake goals/non-goals
   - Functional Requirements ← intake user journeys/technical flows, rendered as FRs
   - Non-Functional Requirements ← intake hard constraints
   - Acceptance Criteria ← derive per FR
   - Data Model ← if intake covered it (else flag Open Question)
   - API/Interface Contracts ← if technical feature
   - Error Handling ← derive from FR error cases
   - Dependencies ← intake interactions + codebase findings
   - Migration/Rollout ← if applicable
3. Set frontmatter:
   - artifact: feature-spec, scope: feature, feature: <feature>
   - parent: <parent-path or null>, children: []
   - status: draft, iteration: 0
   - convergence with initial counts
4. Universal sections.

# Output

Write to <output-path>. Return summary: FRs, NFRs, ACs, Open Questions surfaced, codebase evidence cited.
```

### Phase 4: Quality checks

| Check | Description |
|-------|-------------|
| Q1 | EARS for all FRs (one of six patterns; lowercase "shall") |
| Q2 | GWT for all ACs (Given/When/Then; atomic; deterministic) |
| Q3 | Every requirement has ≥1 AC |
| Q4 | Codebase-grounded: every High Confidence item has file:line evidence |
| Q5 | Parent reference set correctly (null if standalone) |
| Q6 | Universal sections present, frontmatter valid |

### Phase 5: Set graph

Per mode-advance Phase 6. Additionally, for nested feature-specs (per OQ-010): the parent feature-spec's `children` list is updated to include this artifact.

## Edge Cases

- **Greenfield (no codebase to cite):** All Confidence is Medium at best (derived from intake user statements); many Open Questions surface for research-after-implementation.
- **Sub-feature deeper than 2 levels:** Permitted but warn — deeply nested specs become hard to navigate. AskUserQuestion: "This would create a feature-spec at depth N. Continue?"
- **Same feature name as existing artifact:** Refuse with collision warning; suggest a more specific name or update the existing one via `/refine update`.
- **Intake reveals the feature is actually multiple features:** The interviewer should detect this and ask: "This sounds like multiple features (X, Y, Z). Would you like to spec them separately?" If user says yes, abort this feature-spec; suggest separate `/refine <feature-name>` invocations.
