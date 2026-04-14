# Stage: stack

**Pipeline position:** Stage 3. Selects concrete technology choices that satisfy design constraints.

## Inputs

- Parent artifact (a `finalized` or `reviewed` `design` artifact) — required
- Output path (default: `<working-dir>/<project>-stack.md`)
- Optional `--scope=<system|subsystem>`

## Agent

`refinery:spec-writer` (model: `${user_config.spec_writer_model}` or `sonnet`)

## Template

`${CLAUDE_SKILL_DIR}/templates/stack.md`

## Tools (per OQ-004 resolution)

This stage uniquely uses **scoped Bash** for read-only package-manager queries. The agent's invocation includes `Bash(npm view:*), Bash(cargo search:*), Bash(pip index:*), Bash(go list -m:*), Bash(uv pip:*), Bash(pip-audit:*), Bash(npm audit:*)` and similar read-only ecosystem-query commands.

**Bash is NOT used for:**

- Executing artifact content
- Running tests
- Modifying files
- Network operations beyond the package-manager query

This scoping aligns with NFR-S-001's intent (no execution of untrusted content) while enabling accurate version data for stack decisions.

## Procedure

### Phase 1: Read parent + detect existing stack

Read the design artifact. Extract:

- Subsystem decomposition (drives per-subsystem stack choices where appropriate)
- External integrations (drives library/SDK selection)
- Performance requirements (drives runtime choices)
- Security model (drives crypto/auth library choices)
- Operational concerns (drives deployment/config choices)

If the project has an existing codebase, also detect the current stack:

- Glob for `package.json`, `Cargo.toml`, `go.mod`, `requirements.txt`, `pyproject.toml`, `Gemfile`, `pom.xml`, `build.gradle`, `composer.json`
- Read and parse to extract current language, runtime, framework, key dependencies
- Use `Bash` for version queries on the existing dependencies (e.g., `npm view <pkg> version`)

For greenfield projects, the agent proposes a stack from scratch grounded in the design constraints.

### Phase 2: Spawn spec-writer

Spawn agent `refinery:spec-writer` with prompt:

```
You are filling the stack template. Your job is to make concrete technology choices that satisfy the design constraints.

# Inputs
- Parent (design): <parent path>
- Project name: <project>
- Existing stack (if detected): <summary from Phase 1, or "none — greenfield">
- Template path: ${CLAUDE_SKILL_DIR}/templates/stack.md
- Output path: <output-path>
- Reference: ${CLAUDE_SKILL_DIR}/references/document-format.md
- You have scoped Bash for read-only package-manager queries (see allowed-tools)

# Constraints

1. **Every choice has "why this" against a design constraint.** "We chose Postgres because the design requires ACID transactions across multiple subsystems" is good. "We chose Postgres because it's popular" is not.

2. **Every choice has "gotchas explicit."** Known issues, limitations, version pitfalls. The stack stage's value is preventing surprises in implementation.

3. **Deployment topology runnable.** Section 9 must specify HOW it deploys, not just WHAT runs (single-binary? container? serverless? what's the orchestration?).

4. **Use Bash to verify versions.** For each major dependency, run `npm view <pkg> version` (or equivalent) to record the current stable version. Note any compatibility constraints between dependencies.

5. **What we build vs what we buy.** Section 11 must explicitly justify any "build" decisions against existing libraries.

6. **Confidence on every choice.** High when justified by a specific design constraint with stated tradeoffs; Medium when a reasonable default; Low when speculative — surface to Open Questions.

# Workflow

1. Read parent design in full.
2. Read template.
3. For each section, propose concrete choices. For each choice:
   - State the design constraint it satisfies (Source field cites the design's section)
   - Use Bash to fetch current version where appropriate
   - List 2+ gotchas/known issues (consult package docs, GitHub issues — but DO NOT use WebFetch in v1)
   - Compare against alternatives if non-obvious (e.g., "Postgres vs MySQL — chose Postgres for JSON-B native indexing per design §3.2")
4. For greenfield: propose a coherent stack. For brownfield: respect existing choices unless the design explicitly requires migration.
5. Set frontmatter (artifact: stack, parent: <design path>, etc.).
6. Universal sections.

# Output

Write to <output-path>. Return summary (technology choices counted, gotchas surfaced, version data collected).
```

### Phase 3: Quality checks

| Check | Description |
|-------|-------------|
| Q1 | Every technology choice has Confidence + Justification (citing design constraint) + Gotchas |
| Q2 | Deployment topology is concrete (could a developer follow it to deploy?) |
| Q3 | Version numbers present and reasonably current (Bash queries succeeded for most) |
| Q4 | Build-vs-buy section explicitly justifies "build" decisions |
| Q5 | No design-stage decisions slipped in (this is HOW, not WHAT) |
| Q6 | Universal sections present, frontmatter valid |

### Phase 4: Set graph

Per mode-advance Phase 6.

## Edge Cases

- **Bash query fails** (no network, package not found, etc.): Note "version: unknown — Bash query failed" in the artifact; mark the affected choice's Confidence as Medium.
- **Existing stack contradicts a design constraint**: Surface as Open Question or Risk; do not silently override the design. (E.g., design says "must support PG-style transactions" but existing stack uses DynamoDB.)
- **Multi-language project**: Stack artifact may have per-subsystem subsections (e.g., "Frontend stack" and "Backend stack"). Use the template's structure but extend with subsystem dividers.
