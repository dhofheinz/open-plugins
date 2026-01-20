---
name: seed-spec
description: Gather initial requirements through questionnaire and generate starting spec document. Used when creating a new feature specification.
context: fork
allowed-tools: Read, Write, Glob, AskUserQuestion
user-invocable: false
agent: requirements-interviewer
---

# Seed Spec - Initial Specification Generator

You are creating the initial specification for feature: **$ARGUMENTS**

## Step 1: Understand the Feature

Use AskUserQuestion to gather essential information. Ask up to 4 questions per batch, grouped by topic.

### Batch 1: Core Purpose
- What is the primary goal of this feature?
- Who are the target users?
- What problem does this solve?

### Batch 2: Scope & Boundaries
- What should this feature explicitly NOT do?
- Are there existing features this interacts with?
- What are the key success criteria?

### Batch 3: Technical Context (if applicable)
- Are there specific technologies or patterns to use?
- Are there performance or scale requirements?
- Are there security considerations?

Adapt questions based on initial answers - skip irrelevant follow-ups.

## Step 2: Quick Codebase Scan

Before generating the spec, do a brief exploration:

1. Check for similar features:
   ```
   Glob: **/*{feature_keyword}*
   Grep: related terms in likely directories
   ```

2. Identify relevant areas:
   - Entry points that might need modification
   - Data models that might be affected
   - Existing patterns to follow

3. Note findings for inclusion in spec

## Step 3: Create Directory Structure

```bash
mkdir -p docs/specs/{feature_name}
```

## Step 4: Generate Initial Spec

Read the template from: `templates/spec-template.md`

Generate `docs/specs/{feature_name}/spec.md` with:

### YAML Frontmatter
```yaml
---
feature: {feature_name}
phase: what-auto
iteration: 0
last_updated: {current ISO timestamp}
convergence:
  questions_stable_count: 0
  open_questions_count: {count from initial questions}
  high_confidence_ratio: 0.0
---
```

### Content Sections

1. **Overview**: Synthesize user's description into clear problem statement

2. **High Confidence**: Items directly stated by user or verified in code
   - User-stated requirements
   - Discovered existing patterns to follow

3. **Medium Confidence**: Inferred from user answers or codebase
   - Likely integrations based on codebase scan
   - Assumed patterns based on project conventions

4. **Open Questions**: Everything that needs research
   - Technical questions surfaced during questionnaire
   - Integration points that need verification
   - Edge cases mentioned but not detailed

5. **Iteration Log**: Empty, will be populated by refinement loops

## Step 5: Report Completion

Output summary:
- Feature name
- Number of high/medium confidence items
- Number of open questions
- File location

Do NOT proceed to refinement - return control to orchestrator.

## Output Format

Return a structured summary:

```
SEED COMPLETE
Feature: {feature_name}
Location: docs/specs/{feature_name}/spec.md
High Confidence Items: {n}
Medium Confidence Items: {n}
Open Questions: {n}
Ready for: what-auto phase
```
