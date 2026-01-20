---
name: spec-refine
description: Iterative specification refinement for large features. Creates detailed What (requirements) and How (implementation) specs through automated codebase research loops followed by human-in-loop review. Use when planning significant features for brownfield projects.
argument-hint: <feature-name> [--human-only] [--verbose] [--include-docs]
disable-model-invocation: true
---

# Spec Refine - Iterative Specification Refinement

You are orchestrating an iterative specification refinement workflow for the feature: **$ARGUMENTS**

## Parse Arguments

Extract from `$ARGUMENTS`:
- `feature_name`: The feature being specified (required, first positional argument)
- `--human-only`: Skip automated phases, go directly to human review
- `--verbose`: Show detailed search and decision information
- `--include-docs`: Include docs/, README files in research scope

If no feature name provided, use AskUserQuestion to request it.

## Workflow Overview

```
PHASE 1: what-auto   → Automated requirements refinement (2-5 iterations)
PHASE 2: what-human  → Human review of requirements spec
PHASE 3: how-auto    → Automated implementation planning (2-5 iterations)
PHASE 4: how-human   → Human review of implementation spec
PHASE 5: tickets     → Generate implementation tickets
```

## Step 1: Check for Existing Spec

Look for existing spec at: `docs/specs/{feature_name}/spec.md`

**If exists**: Read the YAML frontmatter to determine current state:
- Extract `phase`, `iteration`, and `convergence` metrics
- Resume from current phase/iteration
- Report: "Resuming {feature_name} from {phase}, iteration {iteration}"

**If not exists**: Proceed to Step 2 (seeding)

## Step 2: Seed Initial Spec (New Features Only)

Invoke the seed-spec skill to gather requirements and generate initial spec:

```
Use skill: seed-spec
Arguments: {feature_name}
```

This will:
1. Ask clarifying questions about the feature via AskUserQuestion
2. Generate initial spec.md from template
3. Create docs/specs/{feature_name}/ directory

## Step 3: Execute Current Phase

### Phase: what-auto or how-auto (Automated Refinement)

For each iteration (min 2, max 5):

1. **Analyze**: Invoke analyze-ambiguities skill (context: fork)
   - Input: Current spec document
   - Output: List of ambiguities, gaps, unclear items

2. **Research**: Invoke research-codebase skill (context: fork)
   - Input: Ambiguity list from step 1
   - Output: Findings with confidence levels

3. **Integrate**: Invoke integrate-findings skill (context: fork)
   - Input: Current spec + research findings
   - Output: Updated spec with new items categorized by confidence

4. **Check Convergence** (after minimum 2 iterations):

   Stop early if ANY condition met:
   - Open Questions unchanged for 2 consecutive iterations
   - Open Questions count ≤ 3
   - High Confidence ratio > 80%

5. **Log Iteration**: Append summary to Iteration Log section

After automated phase completes (converged or max iterations):
- Use AskUserQuestion: "Automated {phase} complete after {n} iterations. {summary}. Ready to proceed to human review?"
- Options: "Yes, proceed to human review" / "Run more automated iterations" / "Show me the current spec"

### Phase: what-human or how-human (Human Review)

Invoke human-review skill:
- Reads Open Questions from spec
- Groups questions by topic/complexity
- Presents batched AskUserQuestion prompts
- Updates spec with human answers
- Moves answered items to appropriate confidence tier

After all questions addressed:
- Use AskUserQuestion: "{phase} spec complete. Proceed to next phase?"
- For what-human → Transition to how-auto
- For how-human → Transition to tickets

### Phase: tickets (Final)

Invoke generate-tickets skill:
- Reads finalized impl.md (How spec)
- Generates actionable implementation tickets
- Outputs to docs/specs/{feature_name}/tickets.md

## Step 4: Update Spec Frontmatter

After each phase transition or iteration, update YAML frontmatter:

```yaml
---
feature: {feature_name}
phase: {current_phase}
iteration: {current_iteration}
last_updated: {ISO timestamp}
convergence:
  questions_stable_count: {0-2}
  open_questions_count: {n}
  high_confidence_ratio: {0.0-1.0}
---
```

## Verbose Mode

If `--verbose` flag is set, output additional information:
- Which files/patterns being searched
- Confidence scoring rationale
- Convergence metric calculations
- Agent decision points

## File Locations

- What Spec: `docs/specs/{feature_name}/spec.md`
- How Spec: `docs/specs/{feature_name}/impl.md`
- Tickets: `docs/specs/{feature_name}/tickets.md`
- Templates: See [templates/](templates/) directory

## Child Skills Reference

All child skills run with `context: fork` for isolated execution:

| Skill | Purpose | Agent | Tools |
|-------|---------|-------|-------|
| [seed-spec](skills/seed-spec/SKILL.md) | Initial questionnaire and spec generation | requirements-interviewer | AskUserQuestion, Write |
| [analyze-ambiguities](skills/analyze-ambiguities/SKILL.md) | Identify gaps and unclear items | spec-critic | Read |
| [research-codebase](skills/research-codebase/SKILL.md) | Search codebase for answers | code-archaeologist | Glob, Grep, Read |
| [integrate-findings](skills/integrate-findings/SKILL.md) | Update spec with findings | spec-scribe | Read, Edit |
| [human-review](skills/human-review/SKILL.md) | Batch questions for human | — | AskUserQuestion, Edit |
| [generate-tickets](skills/generate-tickets/SKILL.md) | Create implementation tickets | ticket-architect | Read, Write |

## Agents

Specialized agents provide persona and behavioral guidelines for each skill:

| Agent | Role | Model |
|-------|------|-------|
| [requirements-interviewer](../../agents/requirements-interviewer.md) | Structured requirements gatherer | sonnet |
| [spec-critic](../../agents/spec-critic.md) | Skeptical specification analyzer | sonnet |
| [code-archaeologist](../../agents/code-archaeologist.md) | Deep codebase researcher | sonnet |
| [spec-scribe](../../agents/spec-scribe.md) | Meticulous document updater | sonnet |
| [ticket-architect](../../agents/ticket-architect.md) | Dependency-aware ticket creator | sonnet |

## Error Handling

- If spec file is malformed, offer to reset to template
- If child skill fails, log error and offer retry or skip
- Always preserve spec state - never lose work
