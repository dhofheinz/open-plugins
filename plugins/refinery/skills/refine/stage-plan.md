# Stage: plan

**Pipeline position:** Stage 5. Translates a `finalized` spec or feature-spec into a phased implementation plan with type contracts, anti-patterns, and acceptance criteria per phase.

## Inputs

- Parent artifact (a `finalized` or `reviewed` `spec` or `feature-spec`) — required
- Output path (default: `<working-dir>/<project>-plan.md` or `<working-dir>/features/<feature>-plan.md`)

## Agent

`refinery:spec-writer` (model: `${user_config.spec_writer_model}` or `opus`)

## Template

`${CLAUDE_SKILL_DIR}/templates/plan.md`

## Procedure

### Phase 1: Read parent + sibling context

Read the parent spec/feature-spec in full.

If a sibling stack artifact exists, read it too (informs implementation specifics: which language, framework, build system).

If a sibling design artifact exists (typical for system-scope), read its System Decomposition (informs phase boundaries).

### Phase 2: Spawn spec-writer

Spawn agent `refinery:spec-writer` with prompt:

```
You are filling the plan template. Your output is the implementation roadmap that ticket-architect will later decompose into individually-dispatchable tickets.

# Inputs
- Parent (spec or feature-spec): <parent path>
- Stack (if exists): <stack path or "none — infer from existing codebase or principles">
- Design (if exists): <design path or "n/a">
- Project name / feature: <name>
- Template path: ${CLAUDE_SKILL_DIR}/templates/plan.md
- Output path: <output-path>
- Reference: ${CLAUDE_SKILL_DIR}/references/document-format.md
- Reference: ${CLAUDE_SKILL_DIR}/references/requirement-syntax.md

# Constraints

1. **Every phase has Objective + Prerequisites + Module Scope + Components + Acceptance Criteria + Anti-Patterns.**
2. **Components have type signatures and [NEW]/[MODIFY]/[EXISTS] markers.** Type signatures are pseudocode (function signatures, struct layouts) — concrete enough to inform a reasonable implementation but not language-specific unless the stack mandates one.
3. **Phase dependency graph is acyclic.** Use the Phase Dependency Graph section to draw the DAG.
4. **Every spec FR maps to at least one phase.** Verify in the File Manifest appendix.
5. **Anti-patterns explicit.** What approach should NOT be used in this phase, and why?
6. **Cross-cutting appendices.** Error handling, observability, testing strategy, and decision index live in appendices (don't duplicate per phase; reference once).
7. **Confidence on every claim** (phase boundaries, component contracts, acceptance criteria).

# Workflow

1. Read parent + sibling context.
2. Read template.
3. Identify phase boundaries:
   - Foundation (data models, configuration, scaffolding)
   - Core (main functionality per FR)
   - Integration (connecting subsystems, external APIs)
   - Polish (error handling, observability, edge cases)
4. For each phase, fill: Objective, Prerequisites (which prior phases), Module Scope (which packages/dirs), Components (with type sigs + status markers), AC, Anti-Patterns, Confidence.
5. Build Phase Dependency Graph (textual or ASCII).
6. Map every FR to a phase in the File Manifest.
7. Cross-cutting appendices.
8. Set frontmatter (artifact: plan, parent: <spec/feature-spec path>, etc.).
9. Universal sections.

# Output

Write to <output-path>. Return summary: phase count, total components, FR coverage (% of source FRs mapped), anti-pattern count.
```

### Phase 3: Quality checks

| Check | Description |
|-------|-------------|
| Q1 | Every phase has Objective, Prerequisites, Module Scope, Components, AC, Anti-Patterns |
| Q2 | Components have type signatures and `[NEW]`/`[MODIFY]`/`[EXISTS]` markers |
| Q3 | Phase Dependency Graph acyclic |
| Q4 | Every FR in source spec maps to a phase (File Manifest cross-reference) |
| Q5 | Cross-cutting concerns covered in appendices (Error Handling, Observability, Testing Strategy) |
| Q6 | Decision Index appendix records resolved trade-offs during planning |
| Q7 | Universal sections present, frontmatter valid |

### Phase 4: Set graph

Per mode-advance Phase 6. Plan typically has children (the tickets artifact, generated later via `/refine tickets`).

## Edge Cases

- **Spec has Open Questions:** Plan must acknowledge them — phases that depend on unresolved questions are flagged with a Pre-Implementation Validation note.
- **No stack artifact yet:** Plan can still be written; its components use abstract type signatures that the stack stage's choices will later concretize. Flag this as Open Question: "Stack not yet specified; component contracts use abstract types."
- **Spec has many FRs (40+):** Plan likely has 6+ phases. Check that no phase is so large it can't be described concisely; if it grows beyond ~10 components, suggest splitting.
- **Multiple plans for the same spec:** Permitted (e.g., a "v1 plan" and "v2 plan" for different rollout strategies). Use distinct output paths and link via `references:` frontmatter.
