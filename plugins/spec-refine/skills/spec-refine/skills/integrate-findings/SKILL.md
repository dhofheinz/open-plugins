---
name: integrate-findings
description: Update the specification document with research findings, categorizing by confidence level and managing the Open Questions section.
context: fork
allowed-tools: Read, Edit
user-invocable: false
agent: spec-scribe
---

# Integrate Findings - Specification Updater

You are updating the specification document with research findings from the codebase investigation.

**Input**: $ARGUMENTS contains:
- Path to spec document
- Research findings report with confidence-rated answers

## Step 1: Read Current State

Read the specification document and parse:
- Current YAML frontmatter (phase, iteration, convergence metrics)
- Existing High Confidence items
- Existing Medium Confidence items
- Current Open Questions
- Iteration Log

## Step 2: Process Research Findings

For each finding in the research report:

### HIGH Confidence Findings
- Add to "High Confidence" section
- Include evidence reference (file:line)
- Remove corresponding item from Open Questions
- Format: `- {statement} (verified: {file}:{line})`

### MEDIUM Confidence Findings
- Add to "Medium Confidence" section
- Note the uncertainty
- Keep related question in Open Questions with added context
- Format: `- {statement} (likely, based on {evidence})`

### LOW Confidence / No Answer
- Keep in Open Questions
- Add context from research: what was searched, why inconclusive
- Format: `- [ ] {question} — Searched: {what}, Result: {why inconclusive}`

### New Questions Discovered
- Add to Open Questions section
- Tag as newly discovered: `[NEW]`
- Format: `- [ ] [NEW] {question}`

## Step 3: Update Convergence Metrics

Calculate new metrics:

```yaml
convergence:
  questions_stable_count: {increment if same count as last iteration, else 0}
  open_questions_count: {current count of open questions}
  high_confidence_ratio: {high_items / (high_items + medium_items + open_questions)}
```

## Step 4: Update Frontmatter

```yaml
---
feature: {unchanged}
phase: {unchanged}
iteration: {increment by 1}
last_updated: {current ISO timestamp}
convergence:
  questions_stable_count: {calculated}
  open_questions_count: {calculated}
  high_confidence_ratio: {calculated}
---
```

## Step 5: Append to Iteration Log

Add entry to Iteration Log section:

```markdown
### Iteration {n} ({date})
- **Researched**: {list of questions investigated}
- **Resolved**: {count} questions answered
  - {brief list of what was resolved}
- **Added**: {count} new items
  - High Confidence: {count}
  - Medium Confidence: {count}
- **New Questions**: {count} discovered during research
  - {brief list}
- **Still Open**: {count} questions remain
- **Convergence**: {ratio}% high confidence, {stable_count} iterations stable
```

## Step 6: Detect Convergence

Check if ANY convergence criteria met:

1. **Stability**: `questions_stable_count >= 2`
   - Same number of open questions for 2 iterations
   - Indicates automated research has exhausted its ability

2. **Low Questions**: `open_questions_count <= 3`
   - Few enough questions that human review is efficient

3. **High Confidence**: `high_confidence_ratio > 0.80`
   - Spec is 80%+ verified against codebase

## Step 7: Output Summary

```
INTEGRATION COMPLETE
Spec: {path}
Iteration: {n} → {n+1}

## Changes Made
- Added to High Confidence: {n} items
- Added to Medium Confidence: {n} items
- Resolved from Open Questions: {n} items
- New questions added: {n} items

## Convergence Status
- Open Questions: {previous} → {current}
- Stability Count: {n} iterations
- High Confidence Ratio: {ratio}%
- Criteria Met: {YES: criteria | NO}

## Recommendation
{CONTINUE: more iterations needed | CONVERGED: ready for human review}
```

## Edit Guidelines

When editing the spec document:
- Preserve existing formatting
- Don't reorder items unnecessarily
- Add new items at the end of each section
- Use consistent bullet/checkbox formatting
- Keep evidence references inline and concise

## Error Handling

- If spec format is unexpected, report and don't modify
- If findings reference questions not in spec, add them
- If metrics can't be calculated, use conservative estimates
