# Spec Refine Plugin

Iterative specification refinement for large features in brownfield projects. Creates detailed **What** (requirements) and **How** (implementation) specs through automated codebase research loops followed by human-in-loop review.

### Via OpenPlugins Marketplace

```bash
# Add the marketplace (one-time)
/plugin_marketplace_add https://github.com/dhofheinz/open-plugins

# Install the plugin
/plugin_install spec-refine@open-plugins
```

## Usage

```bash
/spec-refine <feature-name> [options]
```

### Options

| Option | Description |
|--------|-------------|
| `--human-only` | Skip automated phases, go directly to human review |
| `--verbose` | Show detailed search and decision information |
| `--include-docs` | Include docs/, README files in research scope |

### Examples

```bash
# Start refining a new feature
/spec-refine user-authentication

# Resume with verbose output
/spec-refine user-authentication --verbose

# Skip to human review
/spec-refine user-authentication --human-only
```

## Workflow

The plugin guides you through 5 phases:

```
PHASE 1: what-auto   → Automated requirements refinement (2-5 iterations)
PHASE 2: what-human  → Human review of requirements spec
PHASE 3: how-auto    → Automated implementation planning (2-5 iterations)
PHASE 4: how-human   → Human review of implementation spec
PHASE 5: tickets     → Generate implementation tickets
```

### Phase Details

1. **Seed**: Gather initial requirements through questionnaire
2. **Analyze**: Identify ambiguities, gaps, and unclear items
3. **Research**: Search codebase for answers with confidence levels
4. **Integrate**: Update spec with findings, track convergence
5. **Human Review**: Present open questions in batched prompts
6. **Tickets**: Generate actionable implementation tickets

## Output Files

All outputs are written to `docs/specs/{feature-name}/`:

| File | Description |
|------|-------------|
| `spec.md` | Requirements specification (What) |
| `impl.md` | Implementation specification (How) |
| `tickets.md` | Actionable implementation tickets |

## Convergence Criteria

Automated phases stop early when ANY condition is met:
- Open Questions unchanged for 2 consecutive iterations
- Open Questions count ≤ 3
- High Confidence ratio > 80%

## Child Skills

| Skill | Agent | Purpose |
|-------|-------|---------|
| `seed-spec` | `requirements-interviewer` | Initial questionnaire and spec generation |
| `analyze-ambiguities` | `spec-critic` | Identify gaps and unclear items |
| `research-codebase` | `code-archaeologist` | Search codebase for answers |
| `integrate-findings` | `spec-scribe` | Update spec with findings |
| `human-review` | — | Batch questions for human |
| `generate-tickets` | `ticket-architect` | Create implementation tickets |

## Agents

Specialized agents provide persona and behavioral guidelines for each skill:

| Agent | Role | Model |
|-------|------|-------|
| `requirements-interviewer` | Structured requirements gatherer - asks the right questions | sonnet |
| `spec-critic` | Skeptical analyzer - finds gaps and unstated assumptions | sonnet |
| `code-archaeologist` | Deep researcher - uncovers patterns and conventions | sonnet |
| `spec-scribe` | Meticulous editor - integrates findings preserving structure | sonnet |
| `ticket-architect` | Dependency-aware planner - breaks specs into actionable tickets | sonnet |

## License

MIT
