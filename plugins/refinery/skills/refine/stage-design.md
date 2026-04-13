# Stage: design

**Pipeline position:** Stage 2. Translates principles into architecture: subsystems, decomposition, failure modes, and operational concerns.

## Inputs

- Parent artifact (a `finalized` or `reviewed` `principles` artifact) — required (resolved by `mode-advance.md`)
- Output path (default: `<working-dir>/<project>-design.md`)
- Optional `--scope=<system|subsystem>` (inherited from parent if not specified)

## Agent

`refinery:spec-writer` (model: `${user_config.spec_writer_model}` or `opus`)

## Template

`${CLAUDE_SKILL_DIR}/templates/design.md`

## Procedure

### Phase 1: Read parent

Read the principles artifact in full. Extract:

- Prime postulate (drives the thesis)
- Core concepts (drive subsystem boundaries)
- Hard invariants (constraints all design choices must satisfy)
- Trust hierarchy (drives security model)
- Scope boundaries (drives in/out-of-scope decisions)
- Error doctrine (drives failure-mode handling)

### Phase 2: Spawn spec-writer

Spawn agent `refinery:spec-writer` with prompt:

```
You are filling the design template for a system whose principles have been established. Your job is to translate axiomatic constraints into a concrete architecture that satisfies them.

# Inputs
- Parent (principles): <parent path>
- Project name: <project>
- Template path: ${CLAUDE_SKILL_DIR}/templates/design.md
- Output path: <output-path>
- Reference: ${CLAUDE_SKILL_DIR}/references/document-format.md
- Reference: ${CLAUDE_SKILL_DIR}/references/requirement-syntax.md

# Constraints

1. **Every design decision traces to a principle.** If you make a choice that's not derivable from a principle in the parent, either (a) cite a new constraint as Source, or (b) flag as Open Question.

2. **Thesis reframes the problem.** Section 0 should surprise someone who only knows the domain surface. What kind of engineering problem is this *actually*? (E.g., "a CRUD app" might actually be "a distributed consensus problem" if multiple devices write the same data.)

3. **Three or more second-order failure scenarios.** Section 9 must explore failures that emerge from interactions, not just direct failures. (E.g., "What happens when a retry storm coincides with a leader election?")

4. **Failure modes numbered FM-NNN.** Each has Detection + Recovery.

5. **Degradation policy explicit.** Section 6 names what gets cut first under load and what is never degraded.

6. **No technology names yet.** That's the stack stage. "Subsystem A communicates with Subsystem B via an event bus" is OK; "Subsystem A publishes to Kafka" is not.

7. **Confidence on every claim.** Subsystems, integration choices, security boundaries, etc.

# Workflow

1. Read parent principles in full.
2. Read the template at ${CLAUDE_SKILL_DIR}/templates/design.md.
3. For each section, derive content from the principles. When a design decision narrows the design space, name the principle it derives from in Source.
4. Identify second-order failure scenarios (≥3) — interactions between subsystems that produce emergent failure.
5. For each tracked claim, assign Confidence + Evidence (upstream principle reference) + Source.
6. Set frontmatter:
   - artifact: design, scope: <scope>, feature: <project>, stage: design, iteration: 0
   - parent: <parent path>, children: []
   - status: draft, last_updated: now, plugin_version: <v>
   - convergence with initial counts
7. Universal sections (Open Questions, Iteration Log w/ iteration 0, Changelog).

# Output

Write to <output-path>. Return structured summary (subsystems counted, failure modes, integrations, etc.).
```

### Phase 3: Quality checks

| Check | Description |
|-------|-------------|
| Q1 | Thesis reframes problem (≠ verbatim restatement of seed idea) |
| Q2 | ≥3 second-order failure scenarios in §9 |
| Q3 | Every subsystem has Responsibility + Characteristics + Key Constraint |
| Q4 | Every integration has Contract + Abstraction + Testing + Fallback |
| Q5 | Failure modes (FM-NNN) have Detection + Recovery |
| Q6 | Degradation policy names "first to cut" + "never degrade" |
| Q7 | No technology references |
| Q8 | Every design claim has Confidence + Source (tracing to upstream principle) |
| Q9 | Universal sections present, frontmatter valid |

### Phase 4: Set graph

Per `mode-advance.md` Phase 6 — already handled by mode-advance.

Return control to mode-advance.
