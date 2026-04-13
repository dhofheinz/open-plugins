# Stage: principles

**Pipeline position:** Stage 1. The seed of a system pipeline. Establishes axiomatic constraints, invariants, and scope boundaries that all downstream artifacts derive from.

## Inputs

- Seed idea (free-text or file path) — required
- Output path (default: `<working-dir>/<project>-principles.md`)
- Optional `--scope=<system|subsystem>` (default `system`)

## Agent

`refinery:spec-writer` (with `specification-writing` skill preloaded; default model: `${user_config.spec_writer_model}` or `opus`)

## Template

`${CLAUDE_SKILL_DIR}/templates/principles.md`

## Procedure

### Phase 1: Project name resolution

If `--project <name>` was specified, use it.

Otherwise:

1. Detect from existing artifact prefixes if any exist in the working directory (e.g., `billing-design.md` implies project = `billing`)
2. Or from the working-dir basename (e.g., `docs/refinery/billing/` → `billing`)
3. Or extract the first significant noun from the idea text (kebab-case, e.g., "an event-sourced billing system" → `billing`)
4. Or AskUserQuestion: "Project name (kebab-case)?"

### Phase 2: Spawn spec-writer

Spawn agent `refinery:spec-writer` with prompt:

```
You are filling the principles template for a new system. Your output is the foundational artifact from which design, stack, spec, and plan will derive.

# Inputs
- Project name: <project>
- Seed idea: <idea text or content of seed file>
- Template path: ${CLAUDE_SKILL_DIR}/templates/principles.md
- Output path: <output-path>
- Reference: ${CLAUDE_SKILL_DIR}/references/document-format.md (universal frontmatter, sections, numbering)
- Reference: ${CLAUDE_SKILL_DIR}/references/requirement-syntax.md (EARS/RFC 2119 — though principles use axiomatic statements rather than EARS)

# Constraints

1. **Axiomatic statements only.** Principles are constraints on the design space, not solutions. "The system shall maintain a single source of truth for X" is good; "The system shall use PostgreSQL" is not (that's a stack decision).

2. **Constraining, not solving.** Each principle narrows what designs are valid. If a principle could be violated and the system still work the same way, it's not a principle.

3. **No technology names, library names, or implementation details.** Defer those to design and stack stages. "The system shall be deployable as a single binary" is OK; "The system shall use Go" is not.

4. **Favor tables, state machines, formal statements over prose.** Principles are reference material; readers scan rather than read linearly.

5. **Tracked items: Hard Invariants (INV-NNN), Core Principles (P-NNN).** Each carries Confidence (typically High when explicit user statement; Medium when extrapolation; Low when speculative — surface to Open Questions). Each has a Source field tracing to the seed idea or explicit user decision.

# Workflow

1. Read the template at ${CLAUDE_SKILL_DIR}/templates/principles.md.
2. Fill every section with substantive content derived from the seed idea. Do not leave any section as a placeholder.
3. For each tracked claim (P-NNN, INV-NNN), assign Confidence + Source. Low-confidence items go to Open Questions.
4. Use the universal frontmatter:
   - artifact: principles
   - scope: <scope from --scope>
   - feature: <project>
   - stage: principles
   - iteration: 0
   - last_updated: <now>
   - status: draft
   - parent: null
   - children: []
   - convergence: { questions_stable_count: 0, open_questions_count: <count>, high_confidence_ratio: <computed> }
   - plugin_version: <version>
5. Include Open Questions table (with iteration-0 entries for any items you couldn't confidently fill), Iteration Log (with the iteration 0 entry per format below), and Changelog (with the creation entry).
6. Run the Phase 3 quality checks (below) before writing.

# Iteration Log entry to include
### Iteration 0 — Initial draft (<date>)
- **Created via:** advance --stage=principles
- **Source:** <"seed idea text" or seed file path>
- **Initial state:** <N principles, N invariants, N open questions>

# Output

Write the artifact to: <output-path>

After writing, return a structured summary:
- Counts of principles, invariants, scope-boundary items
- Counts of High / Medium / Low confidence items
- Count of Open Questions added
- Quality-check results (which passed, which warned)
```

### Phase 3: Validate output

Read the produced artifact. Run principles-specific quality checks:

| Check | Description | Pass criteria |
|-------|-------------|---------------|
| Q1 | Prime postulate single, irreducible | Section 0 contains exactly one statement |
| Q2 | Core concepts have explicit relationships | Section 1 has both Concept table and Relationships description |
| Q3 | Lifecycle models complete | Each lifecycle has explicit States + Transitions + Authority |
| Q4 | Trust hierarchy strictly ordered | Section 3 lists trust levels in ranked order |
| Q5 | Hard invariants are unconditional | INV-NNN statements have no "if" clauses dependent on runtime state |
| Q6 | No technology references | Body contains no specific framework/language/library names |
| Q7 | All tracked items have Confidence + Source | Every P-NNN and INV-NNN has both fields |
| Q8 | Open Questions populated for unknowns | Items the agent couldn't fill confidently appear here, not as `[TBD]` in body |
| Q9 | Universal sections present | Open Questions, Iteration Log, Changelog all present |
| Q10 | Frontmatter valid | All required fields per `references/document-format.md §1` |

If 1-2 checks fail → request a revision (max 2 attempts).
If ≥3 fail → report and surface to user via AskUserQuestion: "<N> quality checks failed. Proceed anyway, revise, or abort?"

### Phase 4: Set graph and report

- Set frontmatter `parent: null` (or path to seed file if seed was a file)
- Set frontmatter `children: []`
- This is the root artifact — no parent updates needed

Return control to `mode-advance.md` for its Phase 7 universal report.
